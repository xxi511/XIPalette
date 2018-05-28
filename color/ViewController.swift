//
//  ViewController.swift
//  color
//
//  Created by Codegreen on 02/04/2018.
//  Copyright © 2018 Codegreen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func clickBtn(_ sender: Any) {
        let vc = XIPalettePopVC.instance()
        vc.delegate = self
        vc.present(at: self)
    }
}

extension ViewController: XIPaletteDelegate {
    func select(color: UIColor) {
        self.view.backgroundColor = color
    }
}
