//
//  DefaultsKeyExtension.swift
//  VolantDesDomes
//
//  Created by Drusy on 05/09/2018.
//  Copyright © 2016 Openium. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

extension DefaultsKeys {
    static let userFFBadLicence = DefaultsKey<String?>("userFFBadLicence")
    static let categoryParallax = DefaultsKey<Bool>("categoryParallax", defaultValue: true)
    static let newPostsNotification = DefaultsKey<Bool>("newPostsNotification", defaultValue: true)
    static let appOpenCount = DefaultsKey<Int>("appOpenCount")
    static let forceCategoryLoading = DefaultsKey<Bool>("forceCategoryLoading", defaultValue: false)
    static let darkTheme = DefaultsKey<Bool>("darkTheme", defaultValue: false)
    static let tintColor = DefaultsKey<String>("tintColor", defaultValue: "1e77b2")
    static let tintColorDarkTheme = DefaultsKey<String>("tintColorDarkTheme", defaultValue: "f4df42")
}
