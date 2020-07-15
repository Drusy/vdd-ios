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
            InterclubItem.veteranItem(),
            InterclubItem.loisirItem()
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
        item.url = "\(ApiRequest.hostURL)/interclubs/vdd1"

        return item
    }
    
    fileprivate static func vdd2Item() -> InterclubItem {
        let item = InterclubItem(type: .vdd2)
        
        item.title = "Pré-Nationale"
        item.subtitle = "VDD 2"
        item.url = "\(ApiRequest.hostURL)/interclubs/vdd2"
        
        return item
    }
    
    fileprivate static func vdd3Item() -> InterclubItem {
        let item = InterclubItem(type: .vdd3)
        
        item.title = "Régionale 1"
        item.subtitle = "VDD 3"
        item.url = "\(ApiRequest.hostURL)/index.php/interclubs/vdd3"

        return item
    }
    
    fileprivate static func vdd4Item() -> InterclubItem {
        let item = InterclubItem(type: .vdd4)
        
        item.title = "Départementale élite"
        item.subtitle = "VDD 4"
        item.url = "\(ApiRequest.hostURL)/index.php/interclubs/vdd4"

        return item
    }
    
    fileprivate static func vdd5Item() -> InterclubItem {
        let item = InterclubItem(type: .vdd5)
        
        item.title = "Départementale 1"
        item.subtitle = "VDD 5"
        item.url = "\(ApiRequest.hostURL)/index.php/interclubs/vdd5"

        return item
    }
    
    fileprivate static func vdd6Item() -> InterclubItem {
        let item = InterclubItem(type: .vdd6)
        
        item.title = "Départementale 3"
        item.subtitle = "VDD 6"
        item.url = "\(ApiRequest.hostURL)/index.php/interclubs/vdd6"
        
        return item
    }
    
    fileprivate static func vdd7Item() -> InterclubItem {
        let item = InterclubItem(type: .vdd7)
        
        item.title = "Départementale 4"
        item.subtitle = "VDD 7"
        item.url = "\(ApiRequest.hostURL)/index.php/interclubs/vdd7"
        
        return item
    }
    
    fileprivate static func vdd8Item() -> InterclubItem {
        let item = InterclubItem(type: .vdd8)
        
        item.title = "Départementale 4"
        item.subtitle = "VDD 8"
        item.url = "\(ApiRequest.hostURL)/interclubs/vdd8"
        
        return item
    }
    
    fileprivate static func veteranItem() -> InterclubItem {
        let item = InterclubItem(type: .vdd8)
        
        item.title = "Vétéran"
        item.subtitle = nil
        item.url = "\(ApiRequest.hostURL)/interclubs/interclubs-veteran/"
        
        return item
    }
    
    fileprivate static func loisirItem() -> InterclubItem {
        let item = InterclubItem(type: .vdd8)
        
        item.title = "Loisir"
        item.subtitle = nil
        item.url = "\(ApiRequest.hostURL)/interclubs/interclub-loisir/"
        
        return item
    }
}
