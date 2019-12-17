//
//  RetryWithBehaviorTests.swift
//  RxSwiftExt
//
//  Created by Anton Efimenko on 17/07/16.
//  Copyright © 2016 RxSwift Community. All rights reserved.
//

import XCTest
import RxSwift
import RxSwiftExt
import RxTest

class RetryWithBehaviorTests: XCTestCase {
	var sampleValues: TestableObservable<Int>!
    var sampleValuesImmediateError: TestableObservable<Int>!
    var sampleValuesNeverError: TestableObservable<Int>!
	let scheduler = TestScheduler(initialClock: 0)

	override func setUp() {
		super.setUp()

		sampleValues = scheduler.createColdObservable([
			.next(210, 1),
			.next(220, 2),
			.error(230, testError),
			.next(240, 3),
			.next(250, 4),
			.next(260, 5),
			.next(270, 6),
			.completed(300)
			])

        sampleValuesImmediateError = scheduler.createColdObservable([
            .error(230, testError)
            ])

        sampleValuesNeverError = scheduler.createColdObservable([
            .next(210, 1),
            .next(220, 2),
            .next(240, 3),
            .next(250, 4),
            .next(260, 5),
            .next(270, 6),
            .completed(300)
            ])
	}

	func testImmediateRetryWithoutPredicate() {
		let correctValues = Recorded.events([
			.next(210, 1),
			.next(220, 2),
			.next(440, 1),
			.next(450, 2),
			.next(670, 1),
			.next(680, 2),
			.error(690, testError)])

        let res = scheduler.start(created: 0, subscribed: 0, disposed: 1000) {
			self.sampleValues.asObservable().retry(.immediate(maxCount: 3), scheduler: self.scheduler)
		}

		XCTAssertEqual(res.events, correctValues)
	}

    func testImmediateRetryWithoutPredicate_ImmediateError() {
        let correctValues: [Recorded<Event<Int>>] = [
            .error(690, testError)
        ]

        let res = scheduler.start(created: 0, subscribed: 0, disposed: 1000) {
            self.sampleValuesImmediateError.asObservable().retry(.immediate(maxCount: 3), scheduler: self.scheduler)
        }

        XCTAssertEqual(res.events, correctValues)
    }

    func testImmediateRetryWithoutPredicate_NoError() {
        let correctValues = Recorded.events([
            .next(210, 1),
            .next(220, 2),
            .next(240, 3),
            .next(250, 4),
            .next(260, 5),
            .next(270, 6),
            .completed(300)
        ])

        let res = scheduler.start(created: 0, subscribed: 0, disposed: 1000) {
            self.sampleValuesNeverError.asObservable().retry(.immediate(maxCount: 3), scheduler: self.scheduler)
        }

        XCTAssertEqual(res.events, correctValues)
    }

	func testImmediateRetryWithPredicate() {
		let correctValues = Recorded.events([
			.next(210, 1),
			.next(220, 2),
			.next(440, 1),
			.next(450, 2),
			.next(670, 1),
			.next(680, 2),
			.error(690, testError)])

		// Provide simple predicate that always return true
		let res = scheduler.start(created: 0, subscribed: 0, disposed: 1000) {
			self.sampleValues.asObservable().retry(.immediate(maxCount: 3), scheduler: self.scheduler) { _ in
				true
			}
		}

		XCTAssertEqual(res.events, correctValues)
	}

    func testImmediateRetryWithPredicate_Limited() {
        let correctValues = Recorded.events([
            .next(210, 1),
            .next(220, 2),
            .next(440, 1),
            .next(450, 2),
            .error(460, testError)])

        // Provide simple predicate that always returns true
        var attempts = 0
        let res = scheduler.start(created: 0, subscribed: 0, disposed: 1000) {
            self.sampleValues.asObservable().retry(.immediate(maxCount: 3), scheduler: self.scheduler) { _ in
                attempts += 1
                return attempts == 1
            }
        }

        XCTAssertEqual(res.events, correctValues)
    }

	func testImmediateNotRetryWithPredicate() {
		let correctValues = Recorded.events([
			.next(210, 1),
			.next(220, 2),
			.error(230, testError)])

		// Provide simple predicate that always return false (so, sequence will not repeated)
		let res = scheduler.start(created: 0, subscribed: 0, disposed: 1000) {
			self.sampleValues.asObservable().retry(.immediate(maxCount: 3), scheduler: self.scheduler) { _ in
				false
			}
		}

		XCTAssertEqual(res.events, correctValues)
	}

	func testDelayedRetryWithoutPredicate() {
		let correctValues = Recorded.events([
			.next(210, 1),
			.next(220, 2),
			.next(445, 1),
			.next(455, 2),
			.next(680, 1),
			.next(690, 2),
			.error(700, testError)])

		let res = scheduler.start(created: 0, subscribed: 0, disposed: 1000) {
			self.sampleValues.asObservable().retry(.delayed(maxCount: 3, time: 5.0), scheduler: self.scheduler)
		}

		XCTAssertEqual(res.events, correctValues)
	}

	func testDelayedRetryWithPredicate() {
		let correctValues = Recorded.events([
			.next(210, 1),
			.next(220, 2),
			.next(445, 1),
			.next(455, 2),
			.next(680, 1),
			.next(690, 2),
			.error(700, testError)])

		let res = scheduler.start(created: 0, subscribed: 0, disposed: 1000) {
			self.sampleValues.asObservable().retry(.delayed(maxCount: 3, time: 5.0), scheduler: self.scheduler) { _ in
				true
			}
		}

		XCTAssertEqual(res.events, correctValues)
	}

	func testDelayedNotRetryWithPredicate() {
		let correctValues = Recorded.events([
			.next(210, 1),
			.next(220, 2),
			.error(230, testError)])

		let res = scheduler.start(created: 0, subscribed: 0, disposed: 1000) {
			self.sampleValues.asObservable().retry(.delayed(maxCount: 3, time: 5.0), scheduler: self.scheduler) { _ in
				false
			}
		}

		XCTAssertEqual(res.events, correctValues)
	}

	func testExponentialRetryWithoutPredicate() {
		let correctValues = Recorded.events([
			.next(210, 1),
			.next(220, 2),
			.next(445, 1),
			.next(455, 2),
			.next(685, 1),
			.next(695, 2),
			.next(935, 1),
			.next(945, 2),
			.error(955, testError)])

		let res = scheduler.start(created: 0, subscribed: 0, disposed: 1000) {
			self.sampleValues.asObservable().retry(.exponentialDelayed(maxCount: 4, initial: 5.0, multiplier: 1.0), scheduler: self.scheduler)
		}

		XCTAssertEqual(res.events, correctValues)
	}

	func testExponentialRetryWithPredicate() {
		let correctValues = Recorded.events([
			.next(210, 1),
			.next(220, 2),
			.next(445, 1),
			.next(455, 2),
			.next(685, 1),
			.next(695, 2),
			.next(935, 1),
			.next(945, 2),
			.error(955, testError)])

		let res = scheduler.start(created: 0, subscribed: 0, disposed: 1000) {
			self.sampleValues.asObservable().retry(.exponentialDelayed(maxCount: 4, initial: 5.0, multiplier: 1.0), scheduler: self.scheduler) { _ in
				true
			}
		}

		XCTAssertEqual(res.events, correctValues)
	}

	func testExponentialNotRetryWithPredicate() {
		let correctValues = Recorded.events([
			.next(210, 1),
			.next(220, 2),
			.error(230, testError)])

		let res = scheduler.start(created: 0, subscribed: 0, disposed: 1000) {
			self.sampleValues.asObservable().retry(.exponentialDelayed(maxCount: 4, initial: 5.0, multiplier: 1.0), scheduler: self.scheduler) { _ in
				false
			}
		}

		XCTAssertEqual(res.events, correctValues)
	}

	func testCustomTimerRetryWithoutPredicate() {
		let correctValues = Recorded.events([
			.next(210, 1),
			.next(220, 2),
			.next(450, 1),
			.next(460, 2),
			.next(710, 1),
			.next(720, 2),
			.next(990, 1),
			.next(1000, 2),
			.next(1300, 1),
			.next(1310, 2),
			.error(1320, testError)])

		// Custom delay calculator
		let customCalculator: (UInt) -> DispatchTimeInterval = { attempt in
			switch attempt {
			case 1: return .seconds(10)
			case 2: return .seconds(30)
			case 3: return .seconds(50)
			default: return .seconds(80)
			}
		}

		let res = scheduler.start(created: 0, subscribed: 0, disposed: 2000) {
			self.sampleValues.asObservable().retry(.customTimerDelayed(maxCount: 5, delayCalculator: customCalculator), scheduler: self.scheduler)
		}

		XCTAssertEqual(res.events, correctValues)
	}

	func testCustomTimerRetryWithPredicate() {
		let correctValues = Recorded.events([
			.next(210, 1),
			.next(220, 2),
			.next(450, 1),
			.next(460, 2),
			.next(710, 1),
			.next(720, 2),
			.next(990, 1),
			.next(1000, 2),
			.next(1300, 1),
			.next(1310, 2),
			.error(1320, testError)])

		// Custom delay calculator
		let customCalculator: (UInt) -> DispatchTimeInterval = { attempt in
			switch attempt {
			case 1: return .seconds(10)
			case 2: return .seconds(30)
			case 3: return .seconds(50)
			default: return .seconds(80)
			}
		}

        let res = scheduler.start(created: 0, subscribed: 0, disposed: 2000) {
			self.sampleValues.asObservable().retry(.customTimerDelayed(maxCount: 5, delayCalculator: customCalculator), scheduler: self.scheduler) { _ in
				true
			}
		}

		XCTAssertEqual(res.events, correctValues)
	}

	func testCustomTimerNotRetryWithPredicate() {
		let correctValues = Recorded.events([
			.next(210, 1),
			.next(220, 2),
			.error(230, testError)])

		// Custom delay calculator
		let customCalculator: ((UInt) -> DispatchTimeInterval) = { attempt in
			switch attempt {
			case 1: return .seconds(10)
			case 2: return .seconds(30)
			case 3: return .seconds(500)
			default: return .seconds(80)
			}
		}

		let res = scheduler.start(created: 0, subscribed: 0, disposed: 2000) {
			self.sampleValues.asObservable().retry(.customTimerDelayed(maxCount: 5, delayCalculator: customCalculator), scheduler: self.scheduler) { _ in
				false
			}
		}

		XCTAssertEqual(res.events, correctValues)
	}
}
