//
//  DefaultsKeyExtension.swift
//  VolantDesDomes
//
//  Created by Drusy on 05/09/2018.
//  Copyright © 2016 Openium. All rights reserved.
//

import SwiftyUserDefaults

extension DefaultsKeys {
    static let userFFBadLicence = DefaultsKey<String?>("userFFBadLicence")
    static let categoryParallax = DefaultsKey<Bool>("categoryParallax", defaultValue: true)
    static let newPostsNotification = DefaultsKey<Bool>("newPostsNotification", defaultValue: true)
    static let appOpenCount = DefaultsKey<Int>("appOpenCount")
    static let forceCategoryLoading = DefaultsKey<Bool>("forceCategoryLoading", defaultValue: true)
}
