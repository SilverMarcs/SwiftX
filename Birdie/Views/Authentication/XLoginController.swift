import Foundation
import Observation
import WebKit

@MainActor
@Observable
final class XLoginController: NSObject, WKScriptMessageHandler, WKHTTPCookieStoreObserver {
    let page: WebPage
    private(set) var isValidating = false
    private(set) var errorMessage: String?
    private(set) var errorTitle = "Couldn't Finish Sign-In"
    private(set) var didSignIn = false

    @ObservationIgnored private let contentController: WKUserContentController
    @ObservationIgnored private let cookieStore = XSessionStore.websiteDataStore.httpCookieStore
    @ObservationIgnored private var isActive = false
    @ObservationIgnored private var generation = UUID()
    @ObservationIgnored private var bearer: String?
    @ObservationIgnored private var userAgent: String?
    @ObservationIgnored private var attemptedCredentials: XCredentials?
    @ObservationIgnored private var pendingSessionCheck = false
    @ObservationIgnored private var validationTask: Task<Void, Never>?
    @ObservationIgnored private var validationTimeout: Task<Void, Never>?
    @ObservationIgnored private var navigationTask: Task<Void, Never>?
    @ObservationIgnored private var navigationTimeout: Task<Void, Never>?
    @ObservationIgnored private var startupTask: Task<Void, Never>?
    @ObservationIgnored private var hasNavigationFailure = false
    // Return to the feed after sign-in.
    private static let signInURL = URL(string: "https://x.com/i/jf/onboarding/web?mode=login&redirect_after_login=%2Fhome")

    override init() {
        let contentController = WKUserContentController()
        var configuration = WebPage.Configuration()
        configuration.websiteDataStore = XSessionStore.websiteDataStore
        configuration.userContentController = contentController
        #if os(iOS)
        // Use a Safari-compatible identity for X's iOS web client.
        configuration.applicationNameForUserAgent = "Version/26.0 Mobile/15E148 Safari/604.1"
        #endif
        self.contentController = contentController
        page = WebPage(configuration: configuration, navigationDecider: XLoginNavigationPolicy())
        super.init()
    }

    func start() {
        guard !isActive else { return }
        isActive = true
        generation = UUID()
        contentController.add(self, contentWorld: .page, name: XLoginCaptureScript.handlerName)
        contentController.addUserScript(WKUserScript(source: XLoginCaptureScript.source, injectionTime: .atDocumentStart, forMainFrameOnly: true, in: .page))
        cookieStore.add(self)
        startupTask = Task { [weak self] in
            guard let self else { return }
            let cookies = await cookieStore.allCookies()
            guard isActive, !Task.isCancelled else { return }
            let hasExistingSession = sessionCookies(cookies) != nil
            load(hasExistingSession ? URL(string: "https://x.com/home") : Self.signInURL)
        }
    }

    func stop() {
        isActive = false
        generation = UUID()
        page.stopLoading()
        startupTask?.cancel()
        navigationTask?.cancel()
        navigationTimeout?.cancel()
        validationTask?.cancel()
        validationTimeout?.cancel()
        contentController.removeScriptMessageHandler(forName: XLoginCaptureScript.handlerName, contentWorld: .page)
        contentController.removeAllUserScripts()
        cookieStore.remove(self)
        isValidating = false
        bearer = nil
        userAgent = nil
        attemptedCredentials = nil
        pendingSessionCheck = false
    }

    func reload() {
        guard isActive else { return }
        errorMessage = nil
        attemptedCredentials = nil
        load(page.url ?? Self.signInURL)
        checkSession()
    }

    func retry() {
        errorMessage = nil
        attemptedCredentials = nil
        if hasNavigationFailure || bearer == nil { reload() } else { checkSession() }
    }

    func cookiesDidChange(in cookieStore: WKHTTPCookieStore) {
        checkSession()
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard isActive, message.name == XLoginCaptureScript.handlerName,
              message.frameInfo.isMainFrame,
              message.frameInfo.securityOrigin.protocol == "https",
              message.frameInfo.securityOrigin.host == "x.com",
              [0, 443].contains(message.frameInfo.securityOrigin.port),
              let payload = message.body as? [String: Any],
              let urlString = payload["url"] as? String,
              let url = URL(string: urlString), url.scheme == "https", url.port == nil || url.port == 443,
              ["x.com", "api.x.com"].contains(url.host ?? ""),
              url.path.contains("/graphql/"),
              XLoginCaptureScript.allowedOperations.contains(url.lastPathComponent),
              let capturedBearer = payload["bearer"] as? String,
              capturedBearer.range(of: #"^Bearer\s+\S+$"#, options: .regularExpression) != nil,
              capturedBearer.count <= 2048,
              let capturedUserAgent = payload["userAgent"] as? String,
              !capturedUserAgent.isEmpty, capturedUserAgent.count <= 2048,
              !capturedUserAgent.contains("\r"), !capturedUserAgent.contains("\n") else { return }
        let rawBody = payload["body"] as? [String: Any] ?? [:]
        let method = (payload["method"] as? String ?? "GET").uppercased()
        guard ["GET", "POST"].contains(method) else { return }
        let body = rawBody.filter { ["variables", "features", "fieldToggles"].contains($0.key) }
        XOperationRegistry.shared.observe(url: urlString, body: body, method: method)
        bearer = capturedBearer
        userAgent = capturedUserAgent
        checkSession()
    }

    private func checkSession() {
        // Validate captured cookies independently of document loading.
        guard isActive, !didSignIn, bearer != nil, userAgent != nil else { return }
        guard validationTask == nil else {
            pendingSessionCheck = true
            return
        }
        pendingSessionCheck = false
        let expectedGeneration = generation
        validationTask = Task { [weak self] in
            guard let self else { return }
            defer {
                if generation == expectedGeneration {
                    validationTask = nil
                    validationTimeout?.cancel()
                    isValidating = false
                    if pendingSessionCheck { checkSession() }
                }
            }
            let cookies = await cookieStore.allCookies()
            guard isActive, generation == expectedGeneration, !Task.isCancelled,
                  let tokens = sessionCookies(cookies), let bearer, let userAgent,
                  page.url?.scheme == "https", page.url?.host == "x.com" else { return }
            guard attemptedCredentials?.authToken != tokens.auth || attemptedCredentials?.csrfToken != tokens.csrf || attemptedCredentials?.bearer != bearer else { return }
            isValidating = true
            errorMessage = nil
            beginValidationTimeout(generation: expectedGeneration)
            var failureTitle = "Couldn't Verify X Account"
            do {
                let credentials = XCredentials(authToken: tokens.auth, csrfToken: tokens.csrf, bearer: bearer, userAgent: userAgent)
                guard credentials.isValid, attemptedCredentials != credentials else { return }
                attemptedCredentials = credentials
                let account = try await XClient.shared.verify(credentials: credentials)
                let currentCookies = await cookieStore.allCookies()
                try Task.checkCancellation()
                guard isActive, generation == expectedGeneration else { return }
                guard let currentTokens = sessionCookies(currentCookies),
                      currentTokens.auth == credentials.authToken, currentTokens.csrf == credentials.csrfToken else {
                    attemptedCredentials = nil
                    pendingSessionCheck = true
                    return
                }
                failureTitle = "Couldn't Save X Session"
                try XSessionStore.shared.signIn(account: account, credentials: credentials)
                didSignIn = true
            } catch {
                guard isActive, generation == expectedGeneration, !Task.isCancelled,
                      !(error is CancellationError) else { return }
                errorTitle = failureTitle
                errorMessage = error.localizedDescription
            }
        }
    }

    private func sessionCookies(_ cookies: [HTTPCookie]) -> (auth: String, csrf: String)? {
        let matching = cookies.filter {
            ($0.domain == "x.com" || $0.domain == ".x.com") && ($0.expiresDate.map { $0 > .now } ?? true)
        }
        guard let auth = matching.first(where: { $0.name == "auth_token" })?.value, !auth.isEmpty,
              let csrf = matching.first(where: { $0.name == "ct0" })?.value, !csrf.isEmpty else { return nil }
        return (auth, csrf)
    }

    private func load(_ url: URL?) {
        hasNavigationFailure = false
        observeNavigation()
        page.load(url)
        beginNavigationTimeout()
    }

    private func observeNavigation() {
        navigationTask?.cancel()
        let navigations = page.navigations
        navigationTask = Task { [weak self] in
            guard let self else { return }
            do {
                for try await event in navigations {
                    guard isActive, !Task.isCancelled else { return }
                    switch event {
                    case .startedProvisionalNavigation:
                        if hasNavigationFailure {
                            hasNavigationFailure = false
                            errorMessage = nil
                        }
                        beginNavigationTimeout()
                    case .finished:
                        navigationTimeout?.cancel()
                        if hasNavigationFailure {
                            hasNavigationFailure = false
                            errorMessage = nil
                        }
                        checkSession()
                    default: break
                    }
                }
            } catch {
                guard isActive, !Task.isCancelled else { return }
                navigationTimeout?.cancel()
                checkSession()
                if !Self.isCancelledNavigation(error) {
                    hasNavigationFailure = true
                    errorTitle = "Couldn't Load Sign-In Page"
                    errorMessage = "The X sign-in page couldn't load. Try refreshing it."
                }
                // Each sequence ends after an error. Observe future user navigation as well.
                observeNavigation()
            }
        }
    }

    private static func isCancelledNavigation(_ error: any Error) -> Bool {
        if case WebPage.NavigationError.failedProvisionalNavigation(let underlying) = error {
            return isCancelledNavigation(underlying)
        }
        return error is CancellationError || (error as? URLError)?.code == .cancelled
    }

    private func beginNavigationTimeout() {
        navigationTimeout?.cancel()
        navigationTimeout = Task { [weak self] in
            do { try await Task.sleep(for: .seconds(30)) } catch { return }
            guard let self, isActive, page.isLoading else { return }
            hasNavigationFailure = true
            errorTitle = "Sign-In Page Is Taking Longer"
            errorMessage = "The X sign-in page is taking too long to load. Try refreshing it."
        }
    }

    private func beginValidationTimeout(generation expected: UUID) {
        validationTimeout?.cancel()
        validationTimeout = Task { [weak self] in
            do { try await Task.sleep(for: .seconds(30)) } catch { return }
            guard let self, isActive, generation == expected, isValidating else { return }
            generation = UUID()
            validationTask?.cancel()
            validationTask = nil
            isValidating = false
            errorTitle = "Couldn't Verify X Account"
            errorMessage = "Birdie couldn't verify your X session in time. Try again."
        }
    }
}
