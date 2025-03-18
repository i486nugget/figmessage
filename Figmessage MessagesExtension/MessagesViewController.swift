import UIKit
import Messages
import WebKit

class MessagesViewController: MSMessagesAppViewController {
    var webView: WKWebView!
    var cookieStore: WKHTTPCookieStore?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Create the WebView and set constraints
        webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)

        // Constraints to make sure the webView fills the screen
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        // Set the desktop macOS user agent
        let userAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
        webView.customUserAgent = userAgent
        
        // Save cookies
        cookieStore = webView.configuration.websiteDataStore.httpCookieStore
        
        // Load Figma link
        if let url = URL(string: "https://www.figma.com") {
            let request = URLRequest(url: url)
            webView.load(request)
        }
        
        // Load saved cookies (if any)
        loadCookies()
    }

    // This function will zoom out the page to 50%
    func zoomOut() {
        let zoomScript = "document.body.style.zoom = '50%';"
        webView.evaluateJavaScript(zoomScript, completionHandler: nil)
    }

    func loadCookies() {
        if let cookies = UserDefaults.standard.array(forKey: "savedCookies") as? [HTTPCookie] {
            for cookie in cookies {
                cookieStore?.setCookie(cookie)
            }
        }
    }

    func saveCookies() {
        cookieStore?.getAllCookies { cookies in
            let cookieArray = cookies as [HTTPCookie]
            UserDefaults.standard.set(cookieArray, forKey: "savedCookies")
        }
    }

    // Save cookies before leaving the view
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveCookies()
    }

    // Zoom out after page has finished loading
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Zoom out to 50% after the page is loaded
        zoomOut()
    }
}
