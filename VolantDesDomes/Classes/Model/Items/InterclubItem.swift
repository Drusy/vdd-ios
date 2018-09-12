//
//  InterclubItem.swift
//  VolantDesDomes
//
//  Created by Drusy on 31/08/2018.
//  Copyright © 2018 Openium. All rights reserved.
//

import UIKit

class InterclubItem {
    enum ItemType {
        case vdd1
        case vdd2
        case vdd3
        case vdd4
        case vdd5
        case vdd6
        case vdd7
        case vdd8
        case vdd9
    }
    
    static let cellHeight: CGFloat = 150
    static let fullWidthCellHeight: CGFloat = 200
    
    var type: ItemType
    var title: String?
    var url: String?
    var subtitle: String?

    init(type: ItemType) {
        self.type = type
    }
    
    // MARK: -
    
    static func items() -> [InterclubItem] {
        return [
            InterclubItem.vdd1Item(),
            InterclubItem.vdd2Item(),
            InterclubItem.vdd3Item(),
            InterclubItem.vdd4Item(),
            InterclubItem.vdd5Item(),
            InterclubItem.vdd6Item(),
            InterclubItem.vdd7Item(),
            InterclubItem.vdd8Item(),
            InterclubItem.vdd9Item()
        ]
    }
    
    static func indexForType(_ type: ItemType) -> Int {
        let items = InterclubItem.items()
        var index = 0
        
        for i in 0..<items.count {
            let item = items[i]
            
            if item.type == type {
                index = i
                break
            }
        }
        
        return index
    }
    
    // MARK: -
    
    fileprivate static func vdd1Item() -> InterclubItem {
        let item = InterclubItem(type: .vdd1)
        
        item.title = "Nationale 2"
        item.subtitle = "VDD 1"
        item.url = "\(ApiRequest.hostURL)/index.php/interclubs/nationale-2-vdd-1"

        return item
    }
    
    fileprivate static func vdd2Item() -> InterclubItem {
        let item = InterclubItem(type: .vdd2)
        
        item.title = "Nationale 3"
        item.subtitle = "VDD 2"
        item.url = "\(ApiRequest.hostURL)/index.php/interclubs/nationale-3-vdd-2"
        
        return item
    }
    
    fileprivate static func vdd3Item() -> InterclubItem {
        let item = InterclubItem(type: .vdd3)
        
        item.title = "Régionale 1"
        item.subtitle = "VDD 3"
        item.url = "\(ApiRequest.hostURL)/index.php/interclubs/regionale-1-vdd-3"

        return item
    }
    
    fileprivate static func vdd4Item() -> InterclubItem {
        let item = InterclubItem(type: .vdd4)
        
        item.title = "Régionale 3"
        item.subtitle = "VDD 4"
        item.url = "\(ApiRequest.hostURL)/index.php/interclubs/regionale-3-vdd-4"

        return item
    }
    
    fileprivate static func vdd5Item() -> InterclubItem {
        let item = InterclubItem(type: .vdd5)
        
        item.title = "Départementale 1"
        item.subtitle = "VDD 5"
        item.url = "\(ApiRequest.hostURL)/index.php/interclubs/departementale-1-vdd5"

        return item
    }
    
    fileprivate static func vdd6Item() -> InterclubItem {
        let item = InterclubItem(type: .vdd6)
        
        item.title = "Départementale 1"
        item.subtitle = "VDD 6"
        item.url = "\(ApiRequest.hostURL)/index.php/interclubs/departementale-1-vdd6"
        
        return item
    }
    
    fileprivate static func vdd7Item() -> InterclubItem {
        let item = InterclubItem(type: .vdd7)
        
        item.title = "Départementale 2"
        item.subtitle = "VDD 7"
        item.url = "\(ApiRequest.hostURL)/index.php/interclubs/departementale-2-vdd7"
        
        return item
    }
    
    fileprivate static func vdd8Item() -> InterclubItem {
        let item = InterclubItem(type: .vdd8)
        
        item.title = "Départementale 3"
        item.subtitle = "VDD 8"
        item.url = "\(ApiRequest.hostURL)/index.php/interclubs/departementale-3-vdd8"
        
        return item
    }
    
    fileprivate static func vdd9Item() -> InterclubItem {
        let item = InterclubItem(type: .vdd9)
        
        item.title = "Départementale 4"
        item.subtitle = "VDD 9"
        item.url = "\(ApiRequest.hostURL)/index.php/interclubs/departementale-4-vdd9"
        
        return item
    }
}
