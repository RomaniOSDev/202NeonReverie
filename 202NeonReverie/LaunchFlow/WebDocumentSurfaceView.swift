//
//  WebDocumentSurfaceView.swift
//  157Countdown
//

import SwiftUI
import WebKit

struct WebDocumentSurfaceView: View {
    let url: URL
    var requiresValidatedContent: Bool
    var onFailure: () -> Void

    @State private var webView: WKWebView?
    @State private var canGoBack = false
    @State private var isLoading = true

    init(url: URL, requiresValidatedContent: Bool = true, onFailure: @escaping () -> Void) {
        self.url = url
        self.requiresValidatedContent = requiresValidatedContent
        self.onFailure = onFailure
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button {
                        webView?.goBack()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(canGoBack ? .white : .gray)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 8)
                    }
                    .disabled(!canGoBack)

                    Spacer()

                    Button {
                        webView?.reload()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 8)
                    }
                }
                .frame(minHeight: 52)
                .background(Color.black)

                WebDocumentHostRepresentable(
                    url: url,
                    requiresValidatedContent: requiresValidatedContent,
                    webView: $webView,
                    canGoBack: $canGoBack,
                    isLoading: $isLoading,
                    onFailure: onFailure
                )
            }

            if isLoading {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(2.0)
                }
            }
        }
        .persistentSystemOverlays(.hidden)
    }
}

// MARK: - Content validation

private enum WebDocumentContentValidator {

    static let loadTimeout: TimeInterval = 12

    private static let probeScript = """
    (function() {
        try {
            var body = document.body;
            if (!body) return false;
            var text = (body.innerText || '').replace(/\\s+/g, ' ').trim();
            if (text.length < 20) return false;
            var html = (body.innerHTML || '').replace(/\\s+/g, '').trim();
            if (!html || html.length < 30) return false;
            if (body.children.length === 0 && text.length < 40) return false;
            return true;
        } catch (e) {
            return false;
        }
    })();
    """

    static func hasMeaningfulContent(in webView: WKWebView, completion: @escaping (Bool) -> Void) {
        webView.evaluateJavaScript(probeScript) { result, error in
            if error != nil {
                completion(false)
                return
            }
            if let ok = result as? Bool {
                completion(ok)
                return
            }
            if let text = result as? String {
                completion(text == "true" || text == "1")
                return
            }
            if let number = result as? NSNumber {
                completion(number.boolValue)
                return
            }
            completion(false)
        }
    }
}

// MARK: - UIViewRepresentable

struct WebDocumentHostRepresentable: UIViewRepresentable {
    let url: URL
    let requiresValidatedContent: Bool
    @Binding var webView: WKWebView?
    @Binding var canGoBack: Bool
    @Binding var isLoading: Bool
    var onFailure: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        let view = WKWebView(frame: .zero, configuration: configuration)
        view.navigationDelegate = context.coordinator
        view.uiDelegate = context.coordinator
        view.scrollView.contentInsetAdjustmentBehavior = .never
        view.backgroundColor = .black
        view.isOpaque = false
        view.allowsBackForwardNavigationGestures = true
        context.coordinator.attach(webView: view)
        view.load(URLRequest(url: url))
        DispatchQueue.main.async {
            webView = view
        }
        return view
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        context.coordinator.parent = self
        canGoBack = uiView.canGoBack
    }

    final class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        var parent: WebDocumentHostRepresentable
        private weak var attachedWebView: WKWebView?
        private var failureCalled = false
        private var loadTimeoutWorkItem: DispatchWorkItem?
        private var isValidatingContent = false

        init(parent: WebDocumentHostRepresentable) {
            self.parent = parent
        }

        func attach(webView: WKWebView) {
            attachedWebView = webView
        }

        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            if navigationAction.targetFrame == nil {
                webView.load(navigationAction.request)
            }
            return nil
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
            if let httpResponse = navigationResponse.response as? HTTPURLResponse {
                if shouldFailLaunchLoad(), !failureCalled {
                    if (400...599).contains(httpResponse.statusCode) {
                        triggerFailure(reason: "HTTP \(httpResponse.statusCode)")
                        decisionHandler(.cancel)
                        return
                    }
                }
            }
            decisionHandler(.allow)
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let url = navigationAction.request.url,
               ["mailto", "tel", "sms"].contains(url.scheme) {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
                decisionHandler(.cancel)
                return
            }
            decisionHandler(.allow)
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.isLoading = true
            isValidatingContent = false
            scheduleLoadTimeout(for: webView)
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.canGoBack = webView.canGoBack

            guard !failureCalled else { return }

            if parent.requiresValidatedContent && shouldFailLaunchLoad() {
                validateAndFinalize(webView: webView)
                return
            }

            cancelLoadTimeout()
            parent.isLoading = false
            if parent.requiresValidatedContent, let current = webView.url {
                LaunchSessionStore.shared.markWebEntryValidated(url: current)
            }
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            guard !isBenignNavigationError(error) else { return }
            parent.isLoading = false
            triggerFailure(reason: error.localizedDescription)
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            guard !isBenignNavigationError(error) else { return }
            parent.isLoading = false
            if shouldFailLaunchLoad() {
                triggerFailure(reason: error.localizedDescription)
            }
        }

        // MARK: - Validation & timeout

        private func validateAndFinalize(webView: WKWebView) {
            guard !failureCalled, !isValidatingContent else { return }
            isValidatingContent = true

            WebDocumentContentValidator.hasMeaningfulContent(in: webView) { [weak self] isValid in
                DispatchQueue.main.async {
                    guard let self, !self.failureCalled else { return }
                    self.isValidatingContent = false
                    self.cancelLoadTimeout()
                    self.parent.isLoading = false

                    if isValid, let current = webView.url {
                        LaunchFlowLogger.notice("Web content validated — persisting entry URL")
                        LaunchSessionStore.shared.markWebEntryValidated(url: current)
                    } else {
                        self.triggerFailure(reason: isValid ? "missing URL" : "empty or invalid page content")
                    }
                }
            }
        }

        private func scheduleLoadTimeout(for webView: WKWebView) {
            cancelLoadTimeout()
            let work = DispatchWorkItem { [weak self] in
                guard let self, !self.failureCalled else { return }
                if self.parent.requiresValidatedContent && self.shouldFailLaunchLoad() {
                    self.triggerFailure(reason: "load timeout")
                } else {
                    self.parent.isLoading = false
                }
            }
            loadTimeoutWorkItem = work
            DispatchQueue.main.asyncAfter(
                deadline: .now() + WebDocumentContentValidator.loadTimeout,
                execute: work
            )
        }

        private func cancelLoadTimeout() {
            loadTimeoutWorkItem?.cancel()
            loadTimeoutWorkItem = nil
        }

        private func shouldFailLaunchLoad() -> Bool {
            parent.requiresValidatedContent && !LaunchSessionStore.shared.hasValidatedWebEntry
        }

        private func triggerFailure(reason: String) {
            guard !failureCalled else { return }
            failureCalled = true
            cancelLoadTimeout()
            parent.isLoading = false

            if parent.requiresValidatedContent {
                LaunchSessionStore.shared.clearWebEntryState()
                LaunchSessionStore.shared.hasShownNativeShell = true
            }

            LaunchFlowLogger.debug("Web surface failure: \(reason)")
            DispatchQueue.main.async { self.parent.onFailure() }
        }

        private func isBenignNavigationError(_ error: Error) -> Bool {
            let nsError = error as NSError
            return nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorCancelled
        }
    }
}
