//
//  UIColor + Extension.swift
//  Todoey
//
//  Created by Андрей Фроленков on 24.03.23.
//

import Foundation
import UIKit

extension UIColor {
    
    static var hue: CGFloat = 0
    static var saturation: CGFloat = 0
    static var brightness: CGFloat = 0
    
    static func generateRandomColor() {
        hue = CGFloat(arc4random() % 256) / 256 // use 256 to get full range from 0.0 to 1.0
        saturation = CGFloat(arc4random() % 128) / 256 + 0.5 // from 0.5 to 1.0 to stay away from white
        brightness = CGFloat(arc4random() % 128) / 256 + 0.5 // from 0.5 to 1.0 to stay away from black
    
    }
}
