/*:
 > # IMPORTANT: To use `RxSwiftExtPlayground.playground`, please:
 
1. Make sure you have [Carthage](https://github.com/Carthage/Carthage) installed
1. Fetch Carthage dependencies from shell: `carthage bootstrap --platform ios`
1. Build scheme `RxSwiftExt (playground)` scheme for a simulator target
1. Choose `View > Show Debug Area`
 */

/*:
 # Introduction
 
 ## Additional operators for RxSwift
 
 The core RxSwift distribution provides an extensive set of operators to transform observables. RxSwiftExt aims at providing those less needed or convenience operators that do not necessarily fit in the core distribution, while being useful to many.
 We think that these additional operators will help beginners and intermediate Rx users alike by offering straightforward solutions to some of the common problems Rx users need to solve.
 
 ## About this playground
 
 Each page in the playground provides examples of use for each operator RxSwiftExt provides.
 
 ## Index:
 
 - [apply()](apply) operator, allows for factoring out repeated Observable chain transformations
 - [unwrap()](unwrap) operator, takes a sequence of optional elements and returns a sequence of non-optional elements, filtering out any `nil` values
 - [withUnretained(_:)](withUnretained) operator provides an unretained, safe to use (i.e. not implicitly unwrapped), reference to an object along with the events emitted by the sequence.
 - [ignore(Any...)](ignore) operator, filters out any of the elements passed in parameters
 - [Observable.once(Element)](once) contructor, creates a sequence that delivers an element *once* to the first subscriber then completes. The same sequence will complete immediately without delivering any element to all further subscribers.
 - [mapAt(KeyPath)](mapAt) operator transforms a sequence of elements where each element is mapped to its value at the provided key path
 - [mapTo(Any)](mapTo) operator, takes a sequence of elements and returns a sequence of the same constant provided as a parameter
 - [not()](not) operator, applies a the boolean not (!) to a `Bool`
 - [and()](and) operator, combines Bool values from one or more sequences and emits a single `Bool` value.
 - [Observable.cascade([Observable])](cascade) contructor, takes a ordinary sequence (i.e. Array) of observables and cascades through them
 - [distinct()](distinct) operator, suppress duplicate items emitted by an Observable
 - [retry()](retryWithBehavior) operator, retry on error with various delay / predicate options
 - [repeatWithBehavior()](repeatWithBehavior) operator, repeat on completion with various delay / predicate options
 - [nwise(), pairwise()](nwise) operators, which group the items emitted by an Observable into arrays of N or pairs of consecutive items
 - [catchErrorJustComplete()](catchErrorJustComplete) ignore any error and complete the sequence instead
 - [pausable()](pausable) operator, pauses emission of elements unless the most recent element from the provided sequence is `true`
 - [pausableBuffered()](pausableBuffered) operator, pauses emission of elements unless the most recent element from the provided sequence is `true`; buffers elements that arrive while paused; emits buffered elements on resume.
 - [filterMap()](filterMap) operator, filters out some values and maps the rest (replaces `filter` + `map` combo)
 - [Observable.fromAsync()](fromAsync) constructor, translates an async function that returns data through a completionHandler in a function that returns data through an Observable
 - [ofType()](ofType) operator, filters the elements of an observable sequence, if that is an instance of the supplied type.
 - **UIViewPropertyAnimator** [animate()](UIViewPropertyAnimator.animate) operator, returns a Completable that completes as soon as the animation ends.
 - **UIViewPropertyAnimator** [fractionComplete](UIViewPropertyAnimator.fractionComplete) binder, provides a reactive way to bind to `UIViewPropertyAnimator.fractionComplete`.
*/

//: [Next >>](@next)
