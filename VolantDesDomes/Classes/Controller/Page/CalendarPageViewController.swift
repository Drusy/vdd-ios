//
//  CalendarPageViewController.swift
//  VolantDesDomes
//
//  Created by Drusy on 01/09/2018.
//  Copyright © 2018 Openium. All rights reserved.
//

import UIKit
import SwiftyAttributes
import EventKit

class CalendarPageViewController: AbstractViewController {

    @IBOutlet var roundedViews: [UIView]!
    @IBOutlet weak var calendarDeniedView: UIView! {
        didSet {
            calendarDeniedView.isHidden = true
        }
    }
    @IBOutlet weak var brugiereButton: UIButton!
    @IBOutlet weak var soulierButton: UIButton!
    @IBOutlet weak var perrierButton: UIButton!
    @IBOutlet weak var aubiereButton: UIButton!
    @IBOutlet weak var calendarButton: UIButton!
    
    let eventStore = EKEventStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        roundedViews.forEach {
            $0.layer.cornerRadius = 4
            $0.layer.masksToBounds = true
        }
        
        navigationItem.title = "Calendriers"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        _ = NotificationCenter.default.rx
            .notification(NSNotification.Name.UIApplicationWillEnterForeground)
            .takeUntil(rx.methodInvoked(#selector(viewWillDisappear(_:))))
            .subscribe(onNext: { [weak self] notification in
                self?.update()
            })
        
        _ = NotificationCenter.default.rx
            .notification(NSNotification.Name.EKEventStoreChanged)
            .takeUntil(rx.methodInvoked(#selector(viewWillDisappear(_:))))
            .subscribe(onNext: { [weak self] notification in
                self?.update()
            })
    }
    
    // MARK: -
    
    override func update() {
        super.update()
        
        eventStore.requestAccess(to: .event) { (granted, error) -> Void in
            DispatchQueue.main.async {
                self.calendarDeniedView.isHidden = granted
                
                if let error = error {
                    print(error)
                } else if granted {
                    self.updateButton(title: "Soulier",
                                      button: self.soulierButton,
                                      registered: self.isRegisteredToCalendar("Créneaux Soulier"))
                    
                    self.updateButton(title: "Aubière",
                                      button: self.aubiereButton,
                                      registered: self.isRegisteredToCalendar("Créneaux Aubière"))
                    
                    self.updateButton(title: "Brugière",
                                      button: self.brugiereButton,
                                      registered: self.isRegisteredToCalendar("Créneaux Brugière"))
                    
                    self.updateButton(title: "Perrier",
                                      button: self.perrierButton,
                                      registered: self.isRegisteredToCalendar("Créneaux Perrier"))
                }
            }
        }
    }
    
    func isRegisteredToCalendar(_ name: String) -> Bool {
        let matched = eventStore.calendars(for: .event).filter { calendar in
            return calendar.type == .subscription && calendar.title.contains(name)
        }
        
        return !matched.isEmpty
    }
    
    func updateButton(title: String, button: UIButton, registered: Bool) {
        var attributedTitle: NSAttributedString
        
        if registered {
            attributedTitle = "Calendrier ajouté".withFont(UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.light))
        } else {
            attributedTitle = "Toucher pour ajouter aux calendriers".withFont(UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.light))
        }
        
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.textAlignment = .center
        button.setAttributedTitle(
            title.withFont(UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.semibold))
                + "\n".attributedString
                + attributedTitle,
            for: .normal)
    }
    
    func open(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        guard UIApplication.shared.canOpenURL(url) else { return }
        
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    // MARK: - Actions
    
    @IBAction func onSoulierTouched(_ sender: Any) {
        open(urlString: "https://calendar.google.com/calendar/ical/qs4pbl7s4hi5ce3kvh2ihmdh6k%40group.calendar.google.com/public/basic.ics")
    }
    
    @IBAction func onBrugiereTouched(_ sender: Any) {
        open(urlString: "https://calendar.google.com/calendar/ical/9vd13dnmrmml52evlret7c3nqk%40group.calendar.google.com/public/basic.ics")
    }
    
    @IBAction func onPerrierTouched(_ sender: Any) {
        open(urlString: "https://calendar.google.com/calendar/ical/mumtr9n2oksa9sbjnb49b53fi0%40group.calendar.google.com/public/basic.ics")
    }
    
    @IBAction func onAubiereTouched(_ sender: Any) {
        open(urlString: "https://calendar.google.com/calendar/ical/ipc9sc9dosm6bqkt755evf0sj0%40group.calendar.google.com/public/basic.ics")
    }
    
    @IBAction func onCalendarTouched(_ sender: Any) {
        guard let url = URL(string: "\(AlamofireService.hostURL)/index.php/creneaux") else { return }
        
        let pageViewController = PageDetailViewController(title: "Créneaux", url: url)
        navigationController?.pushViewController(pageViewController, animated: true)
    }
}
