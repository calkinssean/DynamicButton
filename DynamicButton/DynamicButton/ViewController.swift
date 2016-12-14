//
//  ViewController.swift
//  DynamicButton
//
//  Created by Sean Calkins on 12/14/16.
//  Copyright © 2016 Sean Calkins. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var dynamicButton: DynamicButton!
    
    @IBAction func openTapped(_ sender: UIBarButtonItem) {
        
        if dynamicButton.currentlyHidden {
            
            dynamicButton.openButton()
            
        } else {
            
            dynamicButton.closeButton()
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dynamicButton.openType = .slideDown
        dynamicButton.plusColor = .black
        
        self.dynamicButton.add(color: .blue, title: "Sup", image: nil, handler: {
            action in
            print("hi")
        })
        
        self.dynamicButton.add(color: .purple, title: nil, image: UIImage(named: "sean"), handler: {
            action in
            print("super balls")
        })
        
        self.dynamicButton.add(color: .cyan, title: "Beef Tits", image: nil, handler: {
            action in
            
            
        })
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

