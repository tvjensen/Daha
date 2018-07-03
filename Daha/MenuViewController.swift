//
//  MenuViewController.swift
//  Daha
//
//  Created by Thomas Jensen on 6/22/18.
//  Copyright © 2018 Thomas Jensen. All rights reserved.
//

import UIKit
import Foundation

class MenuViewController: UIViewController {
    
    var selected = "search"
    
    @IBOutlet weak var userImage: UIButton!
    @IBOutlet weak var userName: UIButton!
    @IBOutlet weak var searchItemsButton: UIButton!
    @IBOutlet weak var categoriesButton: UIButton!
    @IBOutlet weak var myProfileButton: UIButton!
    @IBOutlet weak var notificationsButton: UIButton!
    @IBOutlet weak var historyButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    
    override func viewDidLoad() {
        userName.setTitle((Current.user?.firstName)! + " " + (Current.user?.lastName)!, for: .normal)
        setSelected()
    }
    
    func setSelected() {
        switch selected {
        case "search":
            searchItemsButton.isSelected = true
            break
        case "categories":
            categoriesButton.isSelected = true
            break
        case "myProfile":
            myProfileButton.isSelected = true
            break
        case "notifications":
            notificationsButton.isSelected = true
            break
        case "history":
            historyButton.isSelected = true
            break
        case "settings":
            settingsButton.isSelected = true
            break
        default:
            break
        }
    }
    
    
    
    var interactor:Interactor? = nil
    
    @IBAction func handleGesture(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        let progress = MenuHelper.calculateProgress(
            translationInView: translation,
            viewBounds: view.bounds,
            direction: .Left
        )
        MenuHelper.mapGestureStateToInteractor(
            gestureState: sender.state,
            progress: progress,
            interactor: interactor){
                self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func closeMenu(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
