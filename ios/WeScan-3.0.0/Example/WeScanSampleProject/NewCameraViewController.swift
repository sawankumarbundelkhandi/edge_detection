//
//  NewCameraViewController.swift
//  WeScanSampleProject
//
//  Created by Chawatvish Worrapoj on 7/1/2020
//  Copyright © 2020 WeTransfer. All rights reserved.
//

import UIKit
import WeScan

final class NewCameraViewController: UIViewController {

    @IBOutlet private weak var cameraView: UIView!
    var controller: CameraScannerViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    private func setupView() {
        controller = CameraScannerViewController()
        controller.view.frame = cameraView.bounds
        controller.willMove(toParent: self)
        cameraView.addSubview(controller.view)
        self.addChild(controller)
        controller.didMove(toParent: self)
        controller.delegate = self
    }

    @IBAction func flashTapped(_ sender: UIButton) {
        controller.toggleFlash()
    }

    @IBAction func captureTapped(_ sender: UIButton) {
        controller.capture()
    }

}

extension NewCameraViewController: CameraScannerViewOutputDelegate {
    func captureImageFailWithError(error: Error) {
        print(error)
    }

    func captureImageSuccess(image: UIImage, withQuad quad: Quadrilateral?) {
        guard let controller = self.storyboard?.instantiateViewController(withIdentifier: "NewEditImageView") as? EditImageViewController
            else { return }
        controller.modalPresentationStyle = .fullScreen
        controller.captureImage = image
        controller.quad = quad
        navigationController?.pushViewController(controller, animated: false)
    }
}
