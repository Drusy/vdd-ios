//
//  AppDelegate.swift
//  VolantDesDomes
//
//  Created by Drusy on 17/08/2018.
//  Copyright © 2018 Openium. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import Siren
import AlamofireNetworkActivityIndicator
import RealmSwift
import RxSwift
import SwiftyUserDefaults
import FirebaseCore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let disposeBag = DisposeBag()
    
    lazy var loadingViewController: LoadingViewController = {
       return LoadingViewController()
    }()
    lazy var homeViewController: TabBarViewController = {
       return TabBarViewController()
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        NetworkActivityIndicatorManager.shared.isEnabled = true
        
        // Realm
        performRealmMigration()
        #if DEBUG
            printRealmPath()
        #endif
        
        // Background fetch 12h
        application.setMinimumBackgroundFetchInterval(60 * 60 * 12)
        
        // Notifications
        _ = NotificationUtils.shared
        
        // Style
        StyleManager.shared.setupApplicationAppearance()
        
        // Window
        window = UIWindow(frame: UIScreen.main.bounds)
        setupLoadingController()
        window?.makeKeyAndVisible()
        
        // Siren
        Siren.shared.wail()

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // MARK: - Background fetch
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        guard let realm = try? Realm() else {
            completionHandler(.failed)
            return
        }
        
        let oldPosts = realm.objects(WPPost.self)
        let oldPostsIdentifiers = oldPosts.map { $0.id }

        ApiRequest.request(with: WPPost.Router.getPage(page: 1, count: 10)).rx
            .objectArray()
            .retry(.exponentialDelayed(maxCount: 3, initial: 1, multiplier: 1))
            .flatMap { (posts: [WPPost]) -> Observable<[WPPost]> in
                return ApiRequest.mediasRequestObservable(for: posts).map { _ in posts }
            }
            .observeOn(MainScheduler.instance)
            .subscribe(
                onNext: { (items: [WPPost]) in
                    let newPosts = items.filter { newPost in
                        return oldPostsIdentifiers.contains(newPost.id) == false
                    }
                    
                    print("Background fetch: \(newPosts.count) new posts")
                    
                    if Defaults[.newPostsNotification] {
                        if newPosts.isEmpty == false {
                            if let post = newPosts.first, newPosts.count == 1 {
                                NotificationUtils.shared.scheduleLocalNotification(
                                    withTitle: post.titleHtmlStripped ?? "Nouvel article",
                                    body: post.excerptHtmlStripped ?? "Un nouvel article a été publié")
                            } else {
                                NotificationUtils.shared.scheduleLocalNotification(
                                    withTitle: "Nouveaux articles",
                                    body: "\(newPosts.count) nouveaux articles ont été publiés")
                            }
                        }
                    }
                    
                    try! realm.write {
                        realm.add(items, update: .all)
                    }
                    
                    completionHandler(newPosts.count == 0 ? .noData : .newData)
            },
                onError: { error in
                    print(error)
                    completionHandler(.failed)
            })
            .disposed(by: disposeBag)
    }

    // MARK: -
    
    func setupLoadingController() {
        setupController(loadingViewController,
                        animated: false,
                        animationOptions: .transitionCrossDissolve,
                        completion: nil)
        
        loadingViewController.refresh { _ in
            self.setupHomeViewcontroller()
        }
    }
    
    func setupHomeViewcontroller() {
        setupController(homeViewController,
                        animated: true,
                        animationOptions: .transitionCrossDissolve,
                        completion: nil)
    }
    
    func setupController(_ viewController: UIViewController, animated: Bool, animationOptions: UIViewAnimationOptions, completion: ((_ finished: Bool) -> Void)?) {
        if animated {
            UIView.transition(
                with: self.window!,
                duration: 0.5,
                options: animationOptions,
                animations: {
                    let oldState = UIView.areAnimationsEnabled
                    
                    UIView.setAnimationsEnabled(false)
                    self.window?.rootViewController = viewController
                    UIView.setAnimationsEnabled(oldState)
            },
                completion: { finished in
                    if let completion = completion {
                        completion(finished)
                    }
            })
        } else {
            self.window?.rootViewController = viewController
            
            if let completion = completion {
                completion(true)
            }
        }
    }
    
    // MARK: - Realm
    
    func printRealmPath() {
        guard let realm = try? Realm() else { return }
        guard let path = realm.configuration.fileURL?.path else { return }
        
        print(path)
    }
    
    @discardableResult
    func deleteRealmIfMigrationNeeded() -> Bool {
        var didPerformMigration = false
        
        do {
            _ = try Realm()
        } catch {
            print("Realm schema mismatch, deleting realm")
            
            Realm.Configuration.defaultConfiguration.deleteRealmIfMigrationNeeded = true
            _ = try! Realm()
            didPerformMigration = true
        }
        
        return didPerformMigration
    }
    
    func performRealmMigration() {
        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: 2,
            
            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if oldSchemaVersion < 1 {
                    // Nothing to do!
                    // Realm will automatically detect new properties and removed properties
                    // And will update the schema on disk automatically
                }
        })
        
        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config
        
        // Now that we've told Realm how to handle the schema change, opening the file
        // will automatically perform the migration
        _ = try? Realm()
    }
}
