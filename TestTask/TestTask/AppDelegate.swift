//
//  AppDelegate.swift
//  TestTask
//
//  Created by Vadim Rupets on 3/26/18.
//  Copyright © 2018 Vadim Rupets. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    private var permissionsGranted: Bool {
        return PermissionChecker.cameraAuthorizationStatus == .authorized && PermissionChecker.locationAuthorizationStatus == .authorizedWhenInUse
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        configureNavigationController()

        return true
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        configureNavigationController()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        configureNavigationController()
    }

    private func configureNavigationController() {
        guard let navigationController = window?.rootViewController as? UINavigationController else { return }

        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        if permissionsGranted {
            guard !navigationController.viewControllers.contains(where: { $0 is PhotosViewController }) else { return }

            let photosViewController = storyboard.instantiateViewController(withIdentifier: PhotosViewController.StoryboardIdentifier)
            navigationController.setViewControllers([photosViewController], animated: true)
        } else {
            guard !navigationController.viewControllers.contains(where: { $0 is PermissionsViewController }) else { return }

            let permissionsViewController = storyboard.instantiateViewController(withIdentifier: PermissionsViewController.StoryboardIdentifier)
            navigationController.setViewControllers([permissionsViewController], animated: true)
        }
    }

}

