import UIKit
import SafariServices
import PassKit
import AVFoundation
import Flutter

@available(iOS 9.0, *)
@main
@objc class AppDelegate: FlutterAppDelegate, OPPCheckoutProviderDelegate, SFSafariViewControllerDelegate, PKPaymentAuthorizationViewControllerDelegate, OPPThreeDSEventListener {

    var navController: UINavigationController?
    var safariVC: SFSafariViewController?
    var checkoutProvider: OPPCheckoutProvider?
    var provider = OPPPaymentProvider(mode: .test)
    var transaction: OPPTransaction?
    var flutterResult: FlutterResult?
    var appConfig: [String: Any] = [:]

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)

        if let info = Bundle.main.infoDictionary {
            self.appConfig = info
        }

        configureAudioSession()
        setupNavigationController()
        setupFlutterChannel()

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    private func configureAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord,
                                       mode: .voiceChat,
                                       options: [.allowBluetooth, .defaultToSpeaker, .allowAirPlay])
            try audioSession.setActive(true, options: [.notifyOthersOnDeactivation])
            print("✅ Audio session configured successfully")
        } catch {
            print("❌ Failed to configure audio session: \(error.localizedDescription)")
        }
    }

    func setupNavigationController() {
        if let controller = window?.rootViewController as? FlutterViewController {
            navController = UINavigationController(rootViewController: controller)
            navController?.setNavigationBarHidden(true, animated: false)
            navController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            navController?.navigationBar.shadowImage = UIImage()
            navController?.navigationBar.isTranslucent = true
            window?.rootViewController = navController
        }
    }

    func setupFlutterChannel() {
        guard let controller = window?.rootViewController as? FlutterViewController else { return }

        let channel = FlutterMethodChannel(name: "Hyperpay.demo.fultter/channel", binaryMessenger: controller.binaryMessenger)
        channel.setMethodCallHandler { [weak self] call, result in
            guard let self = self else { return }
            self.flutterResult = result

            if call.method == "gethyperpayresponse",
               let args = call.arguments as? [String: Any],
               let type = args["type"] as? String,
               let brand = args["brand"] as? String,
               let mode = args["mode"] as? String,
               let local = args["local"] as? String,
               let merchantId = args["merchant_id"] as? String,
               let forName = args["app_name"] as? String,
               let checkoutId = args["checkoutid"] as? String {

                if type == "ReadyUI" {
                    DispatchQueue.main.async {
                        self.openCheckoutUI(checkoutId: checkoutId, forName: forName, brand: brand, local: local, mode: mode, merchantId: merchantId, result: result)
                    }
                }
            } else {
                result(FlutterError(code: "1", message: "Method name not found", details: nil))
            }
        }
    }

    private func openCheckoutUI(checkoutId: String, forName: String, brand: String, local: String, mode: String, merchantId: String, result: @escaping FlutterResult) {
        let checkoutSettings = OPPCheckoutSettings()
        checkoutSettings.language = local
        checkoutSettings.theme.style = .light
        checkoutSettings.theme.confirmationButtonColor = UIColor(hex: 0x34D49E)
        checkoutSettings.theme.navigationBarBackgroundColor = UIColor(hex: 0x34D49E)
        checkoutSettings.theme.cellHighlightedBackgroundColor = UIColor(hex: 0x34D49E)

        switch brand {
        case "mada": checkoutSettings.paymentBrands = ["MADA"]
        case "visa": checkoutSettings.paymentBrands = ["VISA", "MASTER"]
        case "applePay":
            let paymentRequest = OPPPaymentProvider.paymentRequest(withMerchantIdentifier: merchantId, countryCode: "SA")
            paymentRequest.supportedNetworks = [.visa, .masterCard, .mada]
            paymentRequest.currencyCode = "SAR"
            paymentRequest.paymentSummaryItems = [PKPaymentSummaryItem(label: forName, amount: NSDecimalNumber(value: 100.00))]
            checkoutSettings.applePayPaymentRequest = paymentRequest
            checkoutSettings.paymentBrands = ["APPLEPAY"]
        default: break
        }

        checkoutSettings.shopperResultURL = "com.bannerx.app.async://payments"
        provider = OPPPaymentProvider(mode: mode == "LIVE" ? .live : .test)
        checkoutProvider = OPPCheckoutProvider(paymentProvider: provider, checkoutID: checkoutId, settings: checkoutSettings)
        checkoutProvider?.delegate = self

        checkoutProvider?.presentCheckout(
            forSubmittingTransactionCompletionHandler: { transaction, error in
                self.transaction = transaction
                if let transaction = transaction {
                    switch transaction.type {
                    case .synchronous:
                        result("SYNC")
                    case .asynchronous:
                        NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveAsynchronousPaymentCallback), name: Notification.Name("AsyncPaymentCompletedNotificationKey"), object: nil)
                    default:
                        result("Failure")
                    }
                } else {
                    result("Failure")
                }
            },
            cancelHandler: {
                result("Failure")
            }
        )
    }

    @objc func didReceiveAsynchronousPaymentCallback() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("AsyncPaymentCompletedNotificationKey"), object: nil)
        checkoutProvider?.dismissCheckout(animated: true) {
            self.flutterResult?("success")
        }
    }

    override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if url.scheme?.caseInsensitiveCompare("com.bannerx.app.async") == .orderedSame {
            didReceiveAsynchronousPaymentCallback()
            return true
        }
        return false
    }

    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true, completion: nil)
    }

    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: @escaping (PKPaymentAuthorizationStatus) -> Void) {
        guard let checkoutId = transaction?.paymentParams.checkoutID,
              let params = try? OPPApplePayPaymentParams(checkoutID: checkoutId, tokenData: payment.token.paymentData) else {
            completion(.failure)
            return
        }

        let transaction = OPPTransaction(paymentParams: params)
        provider.submitTransaction(transaction) { submittedTransaction, error in
            if error == nil {
                completion(.success)
                self.flutterResult?("success")
            } else {
                completion(.failure)
            }
        }
    }

    func onThreeDSChallengeRequired(completion: @escaping (UINavigationController) -> Void) {
        if let nav = navController {
            completion(nav)
        }
    }

    func onThreeDSConfigRequired(completion: @escaping (OPPThreeDSConfig) -> Void) {
        let config = OPPThreeDSConfig()
        config.appBundleID = appConfig["VOIP_BUNDLE_ID"] as? String ?? "com.bannerx.app"
        completion(config)
    }
}

extension UIColor {
    convenience init(hex: UInt32, alpha: CGFloat = 1.0) {
        let red = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((hex & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(hex & 0x0000FF) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
