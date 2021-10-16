import WeScan
import Flutter
import Foundation

class HomeViewController: UIViewController, CameraScannerViewOutputDelegate, ImageScannerControllerDelegate {
    func captureImageFailWithError(error: Error) {
        print(error)
    }
    
    func captureImageSuccess(image: UIImage, withQuad quad: Quadrilateral?) {
        cameraController?.dismiss(animated: true)
        
        hideButtons()
        let scannerVC = ImageScannerController(image: image, delegate: self)
        if #available(iOS 13.0, *) {
            scannerVC.isModalInPresentation = true
        }
        present(scannerVC, animated: true)
    }
    

    var cameraController: CameraScannerViewController!
    var _result:FlutterResult?

    override func viewDidAppear(_ animated: Bool) {       

        
        if self.isBeingPresented {
            cameraController = CameraScannerViewController()
            cameraController.delegate = self
            if #available(iOS 13.0, *) {
                cameraController.isModalInPresentation = true
            }
            present(cameraController, animated: true) {
                if let window = UIApplication.shared.keyWindow {
                    window.addSubview(self.selectPhotoButton)
                    window.addSubview(self.shutterButton)
                    window.addSubview(self.cancelButton)
                    self.setupConstraints()
                }
            }
        }  
    }
    
    private lazy var shutterButton: ShutterButton = {
        let button = ShutterButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(captureImage(_:)), for: .touchUpInside)
        return button
    }()

    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("wescan.scanning.cancel", tableName: nil, bundle: Bundle(for: ScannerViewController.self), value: "Cancel", comment: "The cancel button"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(cancelImageScannerController), for: .touchUpInside)
        return button
    }()
    
    lazy var selectPhotoButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "gallery", in: Bundle(for: SwiftEdgeDetectionPlugin.self), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = UIColor.white
        button.addTarget(self, action: #selector(selectPhoto), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Actions
    
    @objc private func cancelImageScannerController() {
        hideButtons()
        _result!(nil)
        
        cameraController?.dismiss(animated: true)
        dismiss(animated: true)
    }
    
    @objc private func captureImage(_ sender: UIButton) {
        shutterButton.isUserInteractionEnabled = false
        cameraController?.capture()
    }
    
    @objc func selectPhoto() {
        if let window = UIApplication.shared.keyWindow {
            window.rootViewController?.dismiss(animated: true, completion: nil)
            self.hideButtons()
            
            let scanPhotoVC = ScanPhotoViewController()
            scanPhotoVC._result = _result
            if #available(iOS 13.0, *) {
                scanPhotoVC.isModalInPresentation = true
            }
            window.rootViewController?.present(scanPhotoVC, animated: true)
        }
    }
    
    func hideButtons() {
        cancelButton.isHidden = true
        selectPhotoButton.isHidden = true
        shutterButton.isHidden = true
    }
    
    private func setupConstraints() {
        var cancelButtonConstraints = [NSLayoutConstraint]()
        var selectPhotoButtonConstraints = [NSLayoutConstraint]()
        var shutterButtonConstraints = [
            shutterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            shutterButton.widthAnchor.constraint(equalToConstant: 65.0),
            shutterButton.heightAnchor.constraint(equalToConstant: 65.0)
        ]
        
        if #available(iOS 11.0, *) {
            selectPhotoButtonConstraints = [
                selectPhotoButton.widthAnchor.constraint(equalToConstant: 44.0),
                selectPhotoButton.heightAnchor.constraint(equalToConstant: 44.0),
                selectPhotoButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -24.0),
                view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: selectPhotoButton.bottomAnchor, constant: (65.0 / 2) - 10.0)
            ]
            cancelButtonConstraints = [
                cancelButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 24.0),
                view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: cancelButton.bottomAnchor, constant: (65.0 / 2) - 10.0)
            ]
            
            let shutterButtonBottomConstraint = view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: shutterButton.bottomAnchor, constant: 8.0)
            shutterButtonConstraints.append(shutterButtonBottomConstraint)
        } else {
            selectPhotoButtonConstraints = [
                selectPhotoButton.widthAnchor.constraint(equalToConstant: 44.0),
                selectPhotoButton.heightAnchor.constraint(equalToConstant: 44.0),
                selectPhotoButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -24.0),
                view.bottomAnchor.constraint(equalTo: selectPhotoButton.bottomAnchor, constant: (65.0 / 2) - 10.0)
            ]
            cancelButtonConstraints = [
                cancelButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 24.0),
                view.bottomAnchor.constraint(equalTo: cancelButton.bottomAnchor, constant: (65.0 / 2) - 10.0)
            ]
            
            let shutterButtonBottomConstraint = view.bottomAnchor.constraint(equalTo: shutterButton.bottomAnchor, constant: 8.0)
            shutterButtonConstraints.append(shutterButtonBottomConstraint)
        }
        NSLayoutConstraint.activate(selectPhotoButtonConstraints + cancelButtonConstraints + shutterButtonConstraints)
    }

    func imageScannerController(_ scanner: ImageScannerController, didFailWithError error: Error) {
        print(error)
        _result!(nil)
        self.hideButtons()
        self.dismiss(animated: true)
    }

    func imageScannerController(_ scanner: ImageScannerController, didFinishScanningWithResults results: ImageScannerResults) {
        // Your ViewController is responsible for dismissing the ImageScannerController
        scanner.dismiss(animated: true)
        self.hideButtons()
        
        let imagePath = saveImage(image:results.croppedScan.image)
        _result!(imagePath)
        self.dismiss(animated: true)
    }

    func imageScannerControllerDidCancel(_ scanner: ImageScannerController) {
        // Your ViewController is responsible for dismissing the ImageScannerController
        scanner.dismiss(animated: true)
        self.hideButtons()

        _result!(nil)
        self.dismiss(animated: true)
    }

    func saveImage(image: UIImage) -> String? {

        guard let data = image.jpegData(compressionQuality: 1) ?? image.pngData() else {
            return nil
        }

        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
            return nil
        }

        let fileName = randomString(length:10);
        let filePath: URL = directory.appendingPathComponent(fileName + ".png")!
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
            return filePath.path
        }
        catch {
            print(error.localizedDescription)
            return nil
        }
    }

    func randomString(length: Int) -> String {
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        var randomString = ""
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        return randomString
    }
}
