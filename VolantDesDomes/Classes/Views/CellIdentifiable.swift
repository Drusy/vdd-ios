//
//  CellIdentifiable.swift
//  VolantDesDomes
//
//  Created by Drusy on 03/04/2018.
//  Copyright © 2018 Openium. All rights reserved.
//

import UIKit

protocol CellIdentifiable {
    static var identifier: String { get }
    static var nib: UINib { get }
}

extension CellIdentifiable {
    
    static var identifier: String {
        return String(describing: Self.self)
    }
    
    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
}
