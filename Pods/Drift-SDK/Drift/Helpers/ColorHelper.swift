//
//  ColorHelper.swift
//  Drift
//
//  Created by Eoin O'Connell on 23/02/2016.
//  Copyright © 2016 Drift. All rights reserved.
//

import UIKit

extension UIColor {
    /**
        Gived a Hex string will generate teh UIColor value
     
        - Parameter hexString: Hex Value in string formatat with # removed
     */
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.characters.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
    /**
     - parameter alpha: The Alpha value to be applied to self
     - returns: self with a different alpha
     */
    func alpha(_ alpha: CGFloat) -> UIColor{
        return self.withAlphaComponent(alpha)
    }
    
    /**
     Calculates the color of text based on selfs brightness
     
     - returns: UIColor for text when placed ontop of self
     */
    func brightnessColor() -> UIColor{
        if brightness() < 0.7
        {
            return UIColor.white
        }
        else
        {
            return UIColor.black
        }
    }
    /**
     Calculates the brightnes of self based on RGB
     
     - returns: value between 0 and 1 indicating brightness
     */
    func brightness() -> CGFloat{
        let components = self.cgColor.components
        let red = components?[0]
        let green = components?[1]
        let blue = components?[2]
        return ((red! * 299) + (green! * 587) + (blue! * 114)) / 1000
    }
    
}
