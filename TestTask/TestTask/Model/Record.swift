//
//  Record.swift
//  TestTask
//
//  Created by Vadim Rupets on 3/26/18.
//  Copyright © 2018 Vadim Rupets. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class Record: NSCoding {
    let image: UIImage
    let location: CLLocation

    init(image: UIImage, location: CLLocation) {
        self.image = image
        self.location = location
    }

    required init?(coder aDecoder: NSCoder) {
        guard
            let location = aDecoder.decodeObject(forKey: "location") as? CLLocation,
            let image = aDecoder.decodeObject(forKey: "image") as? UIImage else { return nil }

        self.location = location
        self.image = image
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.location, forKey: "location")
        aCoder.encode(self.image, forKey: "image")
    }
}
