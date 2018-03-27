//
//  PermissionChecker.swift
//  TestTask
//
//  Created by Vadim Rupets on 3/27/18.
//  Copyright © 2018 Vadim Rupets. All rights reserved.
//

import Foundation
import AVFoundation
import CoreLocation

class PermissionChecker {

    static var cameraAuthorizationStatus: AVAuthorizationStatus {
        return AVCaptureDevice.authorizationStatus(for: .video)
    }

    static var locationAuthorizationStatus: CLAuthorizationStatus {
        return CLLocationManager.authorizationStatus()
    }

}
