//
//  PageItem.swift
//  VolantDesDomes
//
//  Created by Drusy on 31/08/2018.
//  Copyright © 2018 Openium. All rights reserved.
//

import UIKit
import EventKitUI

class PageItem {
    enum ItemType {
        case home
        case calendar
        case tournaments
        case contact
        case club
        case price
        case shop
        case stats
        case interclubs
    }
    
    static let cellHeight: CGFloat = 150
    static let fullWidthCellHeight: CGFloat = 200
    
    var type: ItemType
    var title: String?
    var url: String?
    var image: UIImage?
    var customHeight: CGFloat?
    var isFullWidth: Bool = false

    init(type: ItemType) {
        self.type = type
    }
    
    // MARK: -
    
    static func items() -> [PageItem] {
        return [
            PageItem.homeItem(),
            PageItem.calendarItem(),
            PageItem.tournamentsItem(),
            PageItem.clubItem(),
            PageItem.interclubsItem(),
            PageItem.statsItem(),
            PageItem.shopItem(),
            PageItem.priceItem(),
            PageItem.contactsItem()
        ]
    }
    
    static func indexForType(_ type: ItemType) -> Int {
        let items = PageItem.items()
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
    
    fileprivate static func homeItem() -> PageItem {
        let item = PageItem(type: .home)
        
        item.title = "Accueil"
        item.url = AlamofireService.hostURL
        item.isFullWidth = true
        item.image = #imageLiteral(resourceName: "page-tournaments")

        return item
    }
    
    fileprivate static func clubItem() -> PageItem {
        let item = PageItem(type: .club)
        
        item.title = "Le Club"
        item.url = "\(AlamofireService.hostURL)/index.php/le-club"
        item.image = #imageLiteral(resourceName: "page-club")
        
        return item
    }
    
    fileprivate static func calendarItem() -> PageItem {
        let item = PageItem(type: .calendar)
        
        item.title = "Calendriers"
        item.url = "\(AlamofireService.hostURL)/index.php/creneaux"
        item.image = #imageLiteral(resourceName: "page-calendar")
        
        return item
    }
    
    fileprivate static func tournamentsItem() -> PageItem {
        let item = PageItem(type: .tournaments)
        
        item.title = "Tournois"
        item.url = "\(AlamofireService.hostURL)/index.php/inscriptions-tournois"
        item.image = #imageLiteral(resourceName: "page-smash")
        
        return item
    }
    
    fileprivate static func contactsItem() -> PageItem {
        let item = PageItem(type: .contact)
        
        item.title = "Contact"
        item.url = "\(AlamofireService.hostURL)/index.php/contact"
        item.image = #imageLiteral(resourceName: "page-contact")
        
        return item
    }
    
    fileprivate static func priceItem() -> PageItem {
        let item = PageItem(type: .contact)
        
        item.title = "Inscription & Tarifs"
        item.url = "\(AlamofireService.hostURL)/index.php/le-club/inscription-et-tarifs"
        item.image = #imageLiteral(resourceName: "page-price")
        
        return item
    }
    
    fileprivate static func shopItem() -> PageItem {
        let item = PageItem(type: .shop)
        
        item.title = "Textile & Volants"
        item.url = "\(AlamofireService.hostURL)/index.php/textile-et-volants"
        item.image = #imageLiteral(resourceName: "page-shop")
        
        return item
    }
    
    fileprivate static func statsItem() -> PageItem {
        let item = PageItem(type: .stats)
        
        item.title = "Statistiques"
        item.url = "http://badiste.fr/joueurs-club/vdd-535.html?nomenu=1"
//        item.url = "\(AlamofireService.hostURL)/index.php/le-club/nos-joueurs"
        item.image = #imageLiteral(resourceName: "page-stats")
        
        return item
    }
    
    fileprivate static func interclubsItem() -> PageItem {
        let item = PageItem(type: .interclubs)
        
        item.title = "Interclubs"
        item.image = #imageLiteral(resourceName: "page-versus")
        
        return item
    }
}
