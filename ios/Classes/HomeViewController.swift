import WeScan
import Flutter
import Foundation

class HomeViewController: UIViewController, ImageScannerControllerDelegate {

    var cameraController: ImageScannerController!
    var _result:FlutterResult?
    
    var saveTo: String = ""
    var canUseGallery: Bool = true
    
    override func viewDidAppear(_ animated: Bool) {
        if self.isBeingPresented {
            cameraController = ImageScannerController()
            cameraController.imageScannerDelegate = self

            if #available(iOS 13.0, *) {
                cameraController.isModalInPresentation = true
                cameraController.overrideUserInterfaceStyle = .dark
                cameraController.view.backgroundColor = .black
            }
            
            // Temp fix for https://github.com/WeTransfer/WeScan/issues/320
            if #available(iOS 15, *) {
                let appearance = UINavigationBarAppearance()
                let navigationBar = UINavigationBar()
                appearance.configureWithOpaqueBackground()
                appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.label]
                appearance.backgroundColor = .systemBackground
                navigationBar.standardAppearance = appearance;
                UINavigationBar.appearance().scrollEdgeAppearance = appearance
                
                let appearanceTB = UITabBarAppearance()
                appearanceTB.configureWithOpaqueBackground()
                appearanceTB.backgroundColor = .systemBackground
                UITabBar.appearance().standardAppearance = appearanceTB
                UITabBar.appearance().scrollEdgeAppearance = appearanceTB
            }
            
            present(cameraController, animated: true) {
                if let window = UIApplication.shared.keyWindow {
                    window.addSubview(self.selectPhotoButton)
                    self.setupConstraints()
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (canUseGallery == true) {
            selectPhotoButton.isHidden = false
        }
    }
    
    lazy var selectPhotoButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "gallery", in: Bundle(for: SwiftEdgeDetectionPlugin.self), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = UIColor.white
        button.addTarget(self, action: #selector(selectPhoto), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
    }()
        
    @objc private func cancelImageScannerController() {
        hideButtons()
        
        _result!(false)
        cameraController?.dismiss(animated: true)
        dismiss(animated: true)
    }
    
    @objc func selectPhoto() {
        if let window = UIApplication.shared.keyWindow {
            window.rootViewController?.dismiss(animated: true, completion: nil)
            self.hideButtons()
            
            let scanPhotoVC = ScanPhotoViewController()
            scanPhotoVC._result = _result
            scanPhotoVC.saveTo = self.saveTo
            if #available(iOS 13.0, *) {
                scanPhotoVC.isModalInPresentation = true
                scanPhotoVC.overrideUserInterfaceStyle = .dark
            }
            window.rootViewController?.present(scanPhotoVC, animated: true)
        }
    }
    
    func hideButtons() {
        selectPhotoButton.isHidden = true
    }
    
    private func setupConstraints() {
        var selectPhotoButtonConstraints = [NSLayoutConstraint]()
        
        if #available(iOS 11.0, *) {
            selectPhotoButtonConstraints = [
                selectPhotoButton.widthAnchor.constraint(equalToConstant: 44.0),
                selectPhotoButton.heightAnchor.constraint(equalToConstant: 44.0),
                selectPhotoButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -24.0),
                view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: selectPhotoButton.bottomAnchor, constant: (65.0 / 2) - 10.0)
            ]
        } else {
            selectPhotoButtonConstraints = [
                selectPhotoButton.widthAnchor.constraint(equalToConstant: 44.0),
                selectPhotoButton.heightAnchor.constraint(equalToConstant: 44.0),
                selectPhotoButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -24.0),
                view.bottomAnchor.constraint(equalTo: selectPhotoButton.bottomAnchor, constant: (65.0 / 2) - 10.0)
            ]
        }
        NSLayoutConstraint.activate(selectPhotoButtonConstraints)
    }
    
    func setParams(saveTo: String, canUseGallery: Bool) {
        self.saveTo = saveTo
        self.canUseGallery = canUseGallery
    }
    
    func imageScannerController(_ scanner: ImageScannerController, didFailWithError error: Error) {
        print(error)
        _result!(false)
        self.hideButtons()
        self.dismiss(animated: true)
    }
    
    func imageScannerController(_ scanner: ImageScannerController, didFinishScanningWithResults results: ImageScannerResults) {
        // Your ViewController is responsible for dismissing the ImageScannerController
        scanner.dismiss(animated: true)
        self.hideButtons()
        
        saveImage(image:results.doesUserPreferEnhancedScan ? results.enhancedScan!.image : results.croppedScan.image)
        _result!(true)
        self.dismiss(animated: true)
    }
    
    func imageScannerControllerDidCancel(_ scanner: ImageScannerController) {
        // Your ViewController is responsible for dismissing the ImageScannerController
        scanner.dismiss(animated: true)
        self.hideButtons()
        
        _result!(false)
        self.dismiss(animated: true)
    }
    
    func saveImage(image: UIImage) -> Bool? {
        
        guard let data = image.jpegData(compressionQuality: 1) ?? image.pngData() else {
            return false
        }
        
        let path : String = "file://" + self.saveTo.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)!
        let filePath: URL = URL.init(string: path)!
        
        do {
            let fileManager = FileManager.default
            // Check if file exists
            if fileManager.fileExists(atPath: filePath.path) {
                // Delete file
                try fileManager.removeItem(atPath: filePath.path)
            }
            else {
                print("File does not exist")
            }
        }
        catch let error as NSError {
            print("An error took place: \(error)")
        }
        
        do {
            try data.write(to: filePath)
            return true
        }
        
        catch {
            print(error.localizedDescription)
            return false
        }
    }
}

