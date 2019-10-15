Changelog
=========

- added `reachedBottom(offset:)` for `UIScrollView`
- `once` now uses a `NSRecursiveLock` instead of the deprecated `OSAtomicOr32OrigBarrier`
- Simplify `filterMap(_:)` implementation and make callback throwing
- `once` now uses a `NSRecursiveLock` instead of the deprecated `OSAtomicOr32OrigBarrier`
- added `merge(with:)` for `Observable`
- removed `flatMapSync` operator
- added `apply` for `Completable` and `Maybe` 
- added `mapTo` for `Single` and `Maybe`
- added SPM support

5.0.0
-----
- Update to RxSwift 5.0.
- Requires the Swift 5 compiler (Xcode 10.2 and up).i
- added `partition(_:)` operator
- added `bufferWithTrigger` operator
- added `fromAsync` operator for `Single`

4.0.0
------
Version 4.x has been skipped to align with RxSwift versioning.

RxSwiftExt 5.x supports Swift 5.x
RxSwiftExt 3.x supports Swift 4.x

3.4.0
-----
- Fix `withUnretained` so it allows proper destructuring
- added `mapMany` operator
- added `toSortedArray` operator
- rolled `map(to:)` back to `mapTo(_:)` for `SharedSequenceConvertibleType`
- added `unwrap()` operator for SharedSequence
- added `apply(_:)` for `Single`
- added `count` operator

3.3.0
-----
- added UIViewPropertyAnimator `fractionComplete` reactive binder
- added `withUnretained(_:)` operator
- added UIViewPropertyAnimator Reactive Extensions (`animate()` operator)

3.2.0
-----
- added `mapAt(keyPath:)` operator
- added `zip(with:)` operator
- added `ofType(_:)` operator

3.1.0
-----
- added `pairwise()` and `nwise(_:)` operators
- added `and()` operators
- added support for compiling in an iOS App Extension

3.0.0
-----
- added support for Swift 4, RxSwift 4.0

2.5.1
-----
- added support for macOS

2.5.0
-----
- new operator: `filterMap`
- new operator: `flatMapSync`
- new operator: `pausableBuffered`
- fixed issues with the demo Playground

2.4.0
-----
- re-added `errors()` and `elements()` operators for materialized sequences
- fixed Carthage and CI issues

2.3.0
-----
- removed `materialize` and `dematerialize` operators as they now are part of RxSwift 3.4.0 and later

2.2.1
-----
- fixed compilation warning with Swift 3.1

2.2.0
-----
- new operator: `apply`
- added `not`, `mapTo` and `distinct` support for RxCocoa units (`Driver` et al.)

2.1.0
-----
- new operators: `materialize` / `dematerialize`
- extract Playground to use Carthage instead of CocoaPods

2.0.0
-----
- Support Swift 3.0 / RxSwift 3.0

1.2
-----
- new operator: `pausable`
- Tweaked `Podfile` to fix an issue with running the demo playground

1.1
-----
- new operator: `retry` with four different behaviors
- new operator: `catchErrorJustComplete`
- new operator: `ignoreErrors`

1.0.1
-----
- new operator: `distinct` with predicate
- updated to CocoaPods 1.0

1.0
-----
- Initial release.
