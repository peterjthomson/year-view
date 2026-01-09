import Foundation
import AuthenticationServices
import Security

final class GoogleCalendarService: NSObject {
    private let clientID: String
    private let redirectURI: String
    private var accessToken: String?
    private var refreshToken: String?
    private var tokenExpirationDate: Date?

    private let keychainAccessTokenKey = "com.yearview.google.accessToken"
    private let keychainRefreshTokenKey = "com.yearview.google.refreshToken"
    private let keychainExpirationKey = "com.yearview.google.expiration"

    private var authSession: ASWebAuthenticationSession?

    var isAuthenticated: Bool {
        accessToken != nil && (tokenExpirationDate ?? Date.distantPast) > Date()
    }

    override init() {
        // These should be configured with your actual Google OAuth credentials
        self.clientID = Bundle.main.object(forInfoDictionaryKey: "GOOGLE_CLIENT_ID") as? String ?? ""
        self.redirectURI = Bundle.main.object(forInfoDictionaryKey: "GOOGLE_REDIRECT_URI") as? String ?? ""
        super.init()
        loadStoredTokens()
    }

    // MARK: - Authentication

    func signIn() async throws {
        let authorizationEndpoint = "https://accounts.google.com/o/oauth2/v2/auth"
        let scope = "https://www.googleapis.com/auth/calendar.readonly https://www.googleapis.com/auth/calendar.events.readonly"

        var components = URLComponents(string: authorizationEndpoint)!
        components.queryItems = [
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: scope),
            URLQueryItem(name: "access_type", value: "offline"),
            URLQueryItem(name: "prompt", value: "consent")
        ]

        guard let authURL = components.url else {
            throw GoogleCalendarError.invalidURL
        }

        let callbackURLScheme = URL(string: redirectURI)?.scheme ?? ""

        let code = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<String, Error>) in
            authSession = ASWebAuthenticationSession(
                url: authURL,
                callbackURLScheme: callbackURLScheme
            ) { callbackURL, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let callbackURL = callbackURL,
                      let components = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false),
                      let code = components.queryItems?.first(where: { $0.name == "code" })?.value else {
                    continuation.resume(throwing: GoogleCalendarError.noAuthorizationCode)
                    return
                }

                continuation.resume(returning: code)
            }

            authSession?.presentationContextProvider = self
            authSession?.prefersEphemeralWebBrowserSession = false
            authSession?.start()
        }

        try await exchangeCodeForTokens(code)
    }

    func signOut() {
        accessToken = nil
        refreshToken = nil
        tokenExpirationDate = nil
        deleteStoredTokens()
    }

    private func exchangeCodeForTokens(_ code: String) async throws {
        let tokenEndpoint = URL(string: "https://oauth2.googleapis.com/token")!

        var request = URLRequest(url: tokenEndpoint)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let body = [
            "client_id": clientID,
            "code": code,
            "grant_type": "authorization_code",
            "redirect_uri": redirectURI
        ].map { "\($0.key)=\($0.value)" }.joined(separator: "&")

        request.httpBody = body.data(using: .utf8)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw GoogleCalendarError.tokenExchangeFailed
        }

        let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
        accessToken = tokenResponse.accessToken
        refreshToken = tokenResponse.refreshToken
        tokenExpirationDate = Date().addingTimeInterval(TimeInterval(tokenResponse.expiresIn))

        saveTokens()
    }

    private func refreshAccessToken() async throws {
        guard let refreshToken = refreshToken else {
            throw GoogleCalendarError.noRefreshToken
        }

        let tokenEndpoint = URL(string: "https://oauth2.googleapis.com/token")!

        var request = URLRequest(url: tokenEndpoint)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let body = [
            "client_id": clientID,
            "refresh_token": refreshToken,
            "grant_type": "refresh_token"
        ].map { "\($0.key)=\($0.value)" }.joined(separator: "&")

        request.httpBody = body.data(using: .utf8)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw GoogleCalendarError.tokenRefreshFailed
        }

        let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
        accessToken = tokenResponse.accessToken
        tokenExpirationDate = Date().addingTimeInterval(TimeInterval(tokenResponse.expiresIn))

        saveTokens()
    }

    // MARK: - API Requests

    func fetchCalendars() async throws -> [GoogleCalendar] {
        try await ensureValidToken()

        let url = URL(string: "https://www.googleapis.com/calendar/v3/users/me/calendarList")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken ?? "")", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw GoogleCalendarError.apiFailed
        }

        let calendarList = try JSONDecoder().decode(CalendarListResponse.self, from: data)
        return calendarList.items
    }

    func fetchEvents(calendarID: String, from startDate: Date, to endDate: Date) async throws -> [GoogleEvent] {
        try await ensureValidToken()

        let formatter = ISO8601DateFormatter()
        let encodedCalendarID = calendarID.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? calendarID

        var components = URLComponents(string: "https://www.googleapis.com/calendar/v3/calendars/\(encodedCalendarID)/events")!
        components.queryItems = [
            URLQueryItem(name: "timeMin", value: formatter.string(from: startDate)),
            URLQueryItem(name: "timeMax", value: formatter.string(from: endDate)),
            URLQueryItem(name: "singleEvents", value: "true"),
            URLQueryItem(name: "orderBy", value: "startTime"),
            URLQueryItem(name: "maxResults", value: "2500")
        ]

        var request = URLRequest(url: components.url!)
        request.setValue("Bearer \(accessToken ?? "")", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw GoogleCalendarError.apiFailed
        }

        let eventList = try JSONDecoder().decode(EventListResponse.self, from: data)
        return eventList.items ?? []
    }

    private func ensureValidToken() async throws {
        if let expirationDate = tokenExpirationDate, expirationDate <= Date() {
            try await refreshAccessToken()
        }

        guard accessToken != nil else {
            throw GoogleCalendarError.notAuthenticated
        }
    }

    // MARK: - Keychain Storage

    private func saveTokens() {
        if let accessToken = accessToken {
            saveToKeychain(key: keychainAccessTokenKey, value: accessToken)
        }
        if let refreshToken = refreshToken {
            saveToKeychain(key: keychainRefreshTokenKey, value: refreshToken)
        }
        if let expirationDate = tokenExpirationDate {
            saveToKeychain(key: keychainExpirationKey, value: String(expirationDate.timeIntervalSince1970))
        }
    }

    private func loadStoredTokens() {
        accessToken = loadFromKeychain(key: keychainAccessTokenKey)
        refreshToken = loadFromKeychain(key: keychainRefreshTokenKey)
        if let expirationString = loadFromKeychain(key: keychainExpirationKey),
           let timestamp = TimeInterval(expirationString) {
            tokenExpirationDate = Date(timeIntervalSince1970: timestamp)
        }
    }

    private func deleteStoredTokens() {
        deleteFromKeychain(key: keychainAccessTokenKey)
        deleteFromKeychain(key: keychainRefreshTokenKey)
        deleteFromKeychain(key: keychainExpirationKey)
    }

    private func saveToKeychain(key: String, value: String) {
        let data = value.data(using: .utf8)!
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]

        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    private func loadFromKeychain(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }

        return value
    }

    private func deleteFromKeychain(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }
}

// MARK: - ASWebAuthenticationPresentationContextProviding

extension GoogleCalendarService: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        #if os(macOS)
        return NSApplication.shared.keyWindow ?? ASPresentationAnchor()
        #else
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow } ?? ASPresentationAnchor()
        #endif
    }
}

// MARK: - Data Models

struct TokenResponse: Codable {
    let accessToken: String
    let refreshToken: String?
    let expiresIn: Int
    let tokenType: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
        case tokenType = "token_type"
    }
}

struct CalendarListResponse: Codable {
    let items: [GoogleCalendar]
}

struct GoogleCalendar: Codable, Identifiable {
    let id: String
    let summary: String
    let backgroundColor: String?
    let foregroundColor: String?
    let primary: Bool?
    let accessRole: String
}

struct EventListResponse: Codable {
    let items: [GoogleEvent]?
}

struct GoogleEvent: Codable, Identifiable {
    let id: String
    let summary: String?
    let description: String?
    let location: String?
    let start: EventDateTime
    let end: EventDateTime
    let htmlLink: String?
    let hangoutLink: String?
    let status: String?
}

struct EventDateTime: Codable {
    let date: String?
    let dateTime: String?
    let timeZone: String?
}

// MARK: - Errors

enum GoogleCalendarError: Error, LocalizedError {
    case invalidURL
    case noAuthorizationCode
    case tokenExchangeFailed
    case tokenRefreshFailed
    case noRefreshToken
    case notAuthenticated
    case apiFailed

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid authorization URL"
        case .noAuthorizationCode:
            return "No authorization code received"
        case .tokenExchangeFailed:
            return "Failed to exchange authorization code for tokens"
        case .tokenRefreshFailed:
            return "Failed to refresh access token"
        case .noRefreshToken:
            return "No refresh token available"
        case .notAuthenticated:
            return "Not authenticated with Google"
        case .apiFailed:
            return "Google Calendar API request failed"
        }
    }
}
