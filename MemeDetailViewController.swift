//
//  DetailViewController.swift
//  Pick Image
//
//  Created by Natasha Stopa on 4/14/20.
//  Copyright © 2020 Stopa Inc. All rights reserved.
//

import UIKit

class MemeDetailViewController: UIViewController {
    
    var meme : Meme!
    @IBOutlet weak var memeImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        self.memeImageView!.image = meme.memedImage
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
}
