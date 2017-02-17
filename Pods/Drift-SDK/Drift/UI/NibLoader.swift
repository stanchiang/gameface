//
//  NibLoader.swift
//  Drift
//
//  Created by Eoin O'Connell on 26/01/2016.
//  Copyright © 2016 Drift. All rights reserved.
//

import UIKit

extension UIView {
    /**
     Helper Method to load a UIView from a Nib
     
     - parameter nibNameOrNil: - NibName or nil - If nil the Class name of self is used instead
     - returns: Instance of the class or nil
     */
    class func fromNib<T : UIView>(_ nibNameOrNil: String? = nil) -> T? {
        var view: T?
        let name: String
        if let nibName = nibNameOrNil {
            name = nibName
        } else {
            // Most nibs are demangled by practice, if not, just declare string explicitly
            name = "\(self)".components(separatedBy: ".").last!
        }
        
        let bundle = Bundle(for: self)

        let nib = UINib(nibName: name, bundle: bundle)
        view = nib.instantiate(withOwner: self, options: nil)[0] as? T
        
        return view
    }
}
