//
//  SettingsViewController.swift
//  VolantDesDomes
//
//  Created by Drusy on 29/08/2018.
//  Copyright © 2018 Openium. All rights reserved.
//

import UIKit
import Eureka
import SwiftyUserDefaults
import MessageUI
import SVProgressHUD
import UserNotifications
import RxSwift

class SettingsViewController: FormViewController {

    enum SettingTag: String {
        case licence
        case categoryParallax
        case forceCategoryLoading
        case newPostNotifications
        case notificationNotAuthorized
        case systemSettingsButton
        case darkTheme
    }
    
    var authorized = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Paramètres"
        
        setupForm()
        update()
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
            .notification(Notification.Name.themeUpdated)
            .startWith(Notification(name: .themeUpdated))
            .takeUntil(rx.methodInvoked(#selector(viewWillDisappear(_:))))
            .subscribe(onNext: { [weak self] notification in
                self?.setupFormStyle()
                self?.tableView.reloadData()
                self?.tableView.backgroundColor = StyleManager.shared.groupTableViewBackgroundColor
            })
    }
    
    // MARK: - Form
    
    func setupFormStyle() {
        TextRow.defaultCellUpdate = { cell, row in
            cell.tintColor = cell.titleLabel?.textColor
            cell.textField.textColor = StyleManager.shared.tintColor
            cell.titleLabel?.textColor = StyleManager.shared.textColor
            cell.backgroundColor = StyleManager.shared.backgroundContentColor
            
            row.placeholderColor = StyleManager.shared.subtitleColor
        }
        
        SwitchRow.defaultCellUpdate = { cell, row in
            cell.switchControl?.onTintColor = StyleManager.shared.tintColor
            cell.textLabel?.textColor = StyleManager.shared.textColor
            cell.backgroundColor = StyleManager.shared.backgroundContentColor
        }
        
        LabelRow.defaultCellUpdate = { cell, row in
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.textColor = StyleManager.shared.textColor
            cell.backgroundColor = StyleManager.shared.backgroundContentColor
        }
        
        ButtonRow.defaultCellUpdate = { cell, row in
            cell.tintColor = StyleManager.shared.tintColor
            cell.backgroundColor = StyleManager.shared.backgroundContentColor
        }
    }
    
    func setupForm() {
        let appName = Bundle.main.infoDictionary!["CFBundleDisplayName"] as! String
        let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        let build = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
        
        form +++ Section("⚙️ Général")
            <<< TextRow(SettingTag.licence.rawValue) {
                $0.title = "Licence FFBad"
                $0.placeholder = "Numero de licence"
                $0.placeholderColor = StyleManager.shared.subtitleColor
                $0.value = Defaults[.userFFBadLicence]
            }.onChange { row in
                Defaults[.userFFBadLicence] = row.value
            }
            <<< SwitchRow(SettingTag.categoryParallax.rawValue) {
                $0.title = "Effets parallax"
                $0.value = Defaults[.categoryParallax]
            }.onChange { row in
                Defaults[.categoryParallax] = row.value ?? false
            }
            <<< SwitchRow(SettingTag.newPostNotifications.rawValue) {
                $0.title = "Notifications"
                $0.value = Defaults[.newPostsNotification]
            }.onChange { row in
                Defaults[.newPostsNotification] = row.value ?? false
            }
            <<< SwitchRow(SettingTag.forceCategoryLoading.rawValue) {
                $0.title = "Forcer le rafraichissement"
                $0.value = Defaults[.forceCategoryLoading]
                }.onChange { row in
                    Defaults[.forceCategoryLoading] = row.value ?? false
                    
                    if Defaults[.forceCategoryLoading] {
                        SVProgressHUD.showInfo(withStatus: "Le téléchargement des articles se fera au premier plan")
                    } else {
                        SVProgressHUD.showInfo(withStatus: "Le téléchargement des articles se fera en tâche de fond")
                    }
            }
            <<< LabelRow(SettingTag.notificationNotAuthorized.rawValue) {
                $0.title = "Veuillez autoriser les notifications dans les paramètres systèmes"
                $0.hidden = Condition(booleanLiteral: self.authorized)
            }.cellUpdate { cell, row in
                cell.textLabel?.font = UIFont.italicSystemFont(ofSize: UIFont.systemFontSize)
            }
            <<< ButtonRow(SettingTag.systemSettingsButton.rawValue) {
                $0.title = "Aller dans les paramètres"
                $0.hidden = Condition(booleanLiteral: self.authorized)
            }.onCellSelection { _, _ in
                self.systemSettings()
            }
        
        form +++ Section("🎨 Apparence")
            <<< SwitchRow(SettingTag.forceCategoryLoading.rawValue) {
                $0.title = "Thème sombre"
                $0.value = Defaults[.darkTheme]
            }.onChange { row in
                Defaults[.darkTheme] = row.value ?? false
                NotificationCenter.default.post(name: Defaults[.darkTheme] ? .darkModeEnabled : .darkModeDisabled, object: nil)
                NotificationCenter.default.post(name: .themeUpdated, object: nil)
            }
            
        form +++ Section(header: "🏸 \(appName)", footer: "Version \(version) (\(build))")
            <<< LabelRow() {
                $0.title = "À propos"
            }.onCellSelection { _, _ in
                self.showAbout()
            }.cellUpdate { cell, _ in
                cell.accessoryType = .disclosureIndicator
            }
            <<< LabelRow() {
                $0.title = "Remarque / Suggestion"
            }.onCellSelection { _, _ in
                self.help()
            }.cellUpdate { cell, _ in
                cell.accessoryType = .disclosureIndicator
            }
            <<< LabelRow() {
                $0.title = "Noter l'application"
            }.onCellSelection { _, _ in
                self.rateApp()
            }.cellUpdate { cell, _ in
                cell.accessoryType = .disclosureIndicator
            }
    }
    
    // MARK: -
    
    func update() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            self?.authorized = settings.authorizationStatus == .authorized
            
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                
                let notAuthorizedRow = strongSelf.form.rowBy(tag: SettingTag.notificationNotAuthorized.rawValue)
                let settingsButtonRow = strongSelf.form.rowBy(tag: SettingTag.systemSettingsButton.rawValue)

                [notAuthorizedRow, settingsButtonRow].forEach {
                    $0?.hidden = Condition(booleanLiteral: strongSelf.authorized)
                    $0?.evaluateHidden()
                }
            }
        }
    }
    
    func systemSettings() {
        guard let url = URL(string: UIApplicationOpenSettingsURLString) else { return }
        guard UIApplication.shared.canOpenURL(url) else { return }

        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    func help() {
        guard MFMailComposeViewController.canSendMail() else {
            SVProgressHUD.showError(withStatus: "Aucun compte email n'est configuré sur votre smartphone")
            return
        }
        
        let mail = MFMailComposeViewController()
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let appBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
        let appName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? ""
        
        mail.modalPresentationStyle = .overCurrentContext
        mail.mailComposeDelegate = self
        mail.setSubject("\(appName) - v\(appVersion) (\(appBuild))")
        mail.setToRecipients(["kevin.renella@gmail.com"])
        
        present(mail, animated: true)
    }
    
    func rateApp() {
        guard let url = URL(string : "itms-apps://itunes.apple.com/app/id1431822237") else { return }
        guard UIApplication.shared.canOpenURL(url) else { return }
        
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    func showAbout() {
        let aboutViewController = AboutViewController()
        navigationController?.pushViewController(aboutViewController, animated: true)
    }
}

// MARK: - MFMailComposerDelegate

extension SettingsViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if let error = error {
            print(error)
        }
        
        controller.dismiss(animated: true)
    }
}
