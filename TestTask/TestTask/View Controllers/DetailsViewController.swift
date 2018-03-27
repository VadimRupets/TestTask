//
//  DetailsViewController.swift
//  TestTask
//
//  Created by Vadim Rupets on 3/27/18.
//  Copyright © 2018 Vadim Rupets. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!

    var image: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.image = image
    }

}
