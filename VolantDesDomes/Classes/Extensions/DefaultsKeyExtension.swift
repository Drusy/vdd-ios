//
//  DefaultsKeyExtension.swift
//  VolantDesDomes
//
//  Created by Drusy on 05/09/2018.
//  Copyright © 2016 Openium. All rights reserved.
//

import SwiftyUserDefaults

extension DefaultsKeys {
    var userFFBadLicence: DefaultsKey<String?> { .init("userFFBadLicence") }
    var categoryParallax: DefaultsKey<Bool> { .init("categoryParallax", defaultValue: true) }
    var newPostsNotification: DefaultsKey<Bool> { .init("newPostsNotification", defaultValue: true) }
    var appOpenCount: DefaultsKey<Int> { .init("appOpenCount", defaultValue: 0) }
        var forceCategoryLoading: DefaultsKey<Bool> { .init("forceCategoryLoading", defaultValue: false) }
}
