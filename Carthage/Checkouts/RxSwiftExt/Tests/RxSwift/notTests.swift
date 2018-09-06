//
//  NotTests.swift
//  RxSwiftExt
//
//  Created by Thane Gill on 10/18/16.
//  Copyright © 2016 RxSwift Community. All rights reserved.
//

import XCTest

import RxSwift
import RxSwiftExt
import RxTest

class NotTests: XCTestCase {

    func testNot() {
        let values = [true, false, true]

        let scheduler = TestScheduler(initialClock: 0)
        let observer = scheduler.createObserver(Bool.self)

        _ = Observable.from(values)
            .not()
            .subscribe(observer)

        scheduler.start()

        let correct = [
            next(0, false),
            next(0, true),
            next(0, false),
            completed(0)
        ]

        XCTAssertEqual(observer.events, correct)
    }
}
