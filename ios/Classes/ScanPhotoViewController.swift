//
//  ScanPhotoViewController.swift
//  edge_detection
//
//  Created by Henry Leung on 3/9/2021.
//

import WeScan
import Flutter
import Foundation

class ScanPhotoViewController: UIViewController, ImageScannerControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var _result:FlutterResult?
    var saveTo: String = ""
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
        
        _result!(false)
        dismiss(animated: true)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        
        guard let image = info[.originalImage] as? UIImage else { return }
        let scannerVC = ImageScannerController(image: image)
        scannerVC.imageScannerDelegate = self
        
        if #available(iOS 13.0, *) {
            scannerVC.isModalInPresentation = true
            scannerVC.overrideUserInterfaceStyle = .dark
            scannerVC.view.backgroundColor = .black
        }
        present(scannerVC, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
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
        
        if self.isBeingPresented {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            
            present(imagePicker, animated: true)
        }
    }
    
    func imageScannerController(_ scanner: ImageScannerController, didFailWithError error: Error) {
        print(error)
        _result!(false)
        self.dismiss(animated: true)
    }
    
    func imageScannerController(_ scanner: ImageScannerController, didFinishScanningWithResults results: ImageScannerResults) {
        // Your ViewController is responsible for dismissing the ImageScannerController
        scanner.dismiss(animated: true)
        
        
        saveImage(image:results.doesUserPreferEnhancedScan ? results.enhancedScan!.image : results.croppedScan.image)
        _result!(true)
        self.dismiss(animated: true)
    }
    
    
    func imageScannerControllerDidCancel(_ scanner: ImageScannerController) {
        // Your ViewController is responsible for dismissing the ImageScannerController
        scanner.dismiss(animated: true)
        _result!(false)
        self.dismiss(animated: true)
    }
    
    
    func saveImage(image: UIImage) -> String? {
        guard let data = image.jpegData(compressionQuality: 1) ?? image.pngData() else {
            return nil
        }
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
            return nil
        }
        var fileName = randomString(length:10);
        let filePath: URL = directory.appendingPathComponent(fileName + ".png")!
        
        do {
            let fileManager = FileManager.default
            
            // Check if file exists
            if fileManager.fileExists(atPath: filePath.path) {
                // Delete file
                try fileManager.removeItem(atPath: filePath.path)
            } else {
                print("File does not exist")
            }
            
        }
        catch let error as NSError {
            print("An error took place: \(error)")
        }
        
        do {
            try data.write(to: filePath)
            try FileManager.default.moveItem(atPath: filePath.path, toPath: self.saveTo)
            return self.saveTo
        } catch {
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

