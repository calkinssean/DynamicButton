//
//  DynamicButtonDelegate.swift
//  DynamicButton
//
//  Created by Sean Calkins on 12/14/16.
//  Copyright © 2016 Sean Calkins. All rights reserved.
//

import Foundation

@objc protocol DynamicButtonDelegate {
    
    @objc optional func openDynamicButton(_ button: DynamicButton)
    @objc optional func closeDynamicButton(_ button: DynamicButton)
    
}
