//
//  PermissionsViewController.swift
//  TestTask
//
//  Created by Vadim Rupets on 3/26/18.
//  Copyright © 2018 Vadim Rupets. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation

private enum Permission: String {
    case
    camera = "Camera",
    location = "Location"
}

class PermissionsViewController: UIViewController {

    let locationManager = CLLocationManager()

    var permissionsGranted = (camera: false, location: false) {
        didSet {
            if permissionsGranted.camera && permissionsGranted.location {
                showPhotosViewController()
            }
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self

        NotificationCenter.default.addObserver(self, selector: #selector(checkPermissions), name: .UIApplicationWillEnterForeground, object: nil)
        checkPermissions()
    }

    // MARK: - Permissions access

    @objc private func checkPermissions() {
        permissionsGranted.camera = AVCaptureDevice.authorizationStatus(for: .video) == .authorized
        permissionsGranted.location = CLLocationManager.authorizationStatus() == .authorizedWhenInUse

        if !permissionsGranted.camera {
            askForCameraPermission()
        }

        if !permissionsGranted.location {
            askForLocationPermission()
        }
    }

    private func askForPermissionViaSettings(_ permission: Permission) {
        let alertController = UIAlertController(title: "\(permission.rawValue) Error", message: "Application requires access to your \(permission.rawValue)", preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { _ in
            guard let settingsURL = URL(string: UIApplicationOpenSettingsURLString) else {
                return
            }

            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
        }

        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)

        present(alertController, animated: true, completion: nil)
    }

    private func doesDeviceHaveCamera() -> Bool {
        return UIImagePickerController.isCameraDeviceAvailable(.rear) || UIImagePickerController.isCameraDeviceAvailable(.front)
    }

    // MARK: - IBActions

    @IBAction func askForCameraPermission() {
        guard doesDeviceHaveCamera() else {
            let noCameraAlertController = UIAlertController(title: "Error", message: "There is no camera on your device", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            noCameraAlertController.addAction(okAction)

            present(noCameraAlertController, animated: true, completion: nil)
            return
        }

        let cameraAuthStatus = AVCaptureDevice.authorizationStatus(for: .video)
        switch cameraAuthStatus {
        case .authorized:
            break
        case .denied:
            askForPermissionViaSettings(.camera)
        default:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                self?.permissionsGranted.camera = granted
            }
        }
    }

    @IBAction func askForLocationPermission() {
        let locationAuthStatus = CLLocationManager.authorizationStatus()

        switch locationAuthStatus {
        case .denied:
            askForPermissionViaSettings(.location)
        case .authorizedWhenInUse:
            break
        default:
            locationManager.requestWhenInUseAuthorization()
        }
    }

    // MARK: - Navigation

    func showPhotosViewController() {
        DispatchQueue.main.async { [weak self] in
            guard
                let strongSelf = self,
                let photosViewController = strongSelf.storyboard?.instantiateViewController(withIdentifier: PhotosViewController.StoryboardIdentifier) else { return }

            strongSelf.navigationController?.setViewControllers([photosViewController], animated: true)
        }
    }

}

// MARK: - CLLocationManagerDelegate

extension PermissionsViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        let granted = status == .authorizedWhenInUse

        if permissionsGranted.location != granted {
            permissionsGranted.location = granted
        }
    }

}
