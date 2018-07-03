//
//  SettingsViewController.swift
//  Daha
//
//  Created by Thomas Jensen on 6/22/18.
//  Copyright © 2018 Thomas Jensen. All rights reserved.
//

import UIKit

class SettingsViewController: MenuClass {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func logout(_ sender: Any) {
        let alert = UIAlertController(title: "Log Out", message: "Are you sure that you want to log out?", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { [weak alert] (_) in
//            SessionManager.refreshState()
            self.performSegue(withIdentifier: "backToLoginSegue", sender: nil)
            Current.user = nil
        }))
        alert.addAction(UIAlertAction(title: "Nevermind", style: UIAlertActionStyle.default, handler: { [weak alert] (_) in
            //do nothing
        }))
        alert.view.tintColor = UIColor.flatWatermelonDark
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func reportProblem(_ sender: Any) {
        let alertReport = UIAlertController(title: "Report Problem", message: "Please let us know what issues you might have encountered with the Daha app", preferredStyle: UIAlertControllerStyle.alert)
        alertReport.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "Description of problem"
        })
        alertReport.addAction(UIAlertAction(title: "Report problem", style: UIAlertActionStyle.default, handler: { [weak alertReport] (_) in
            // Store report
//            Firebase.report(reportType: "general", reporterID: (Current.user?.email)!, reportedContentID: "", posterID: "", report: (alertReport?.textFields![0].text)!)
        }))
        alertReport.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: { [weak alertReport] (_) in
            // do nothing
        }))
        alertReport.view.tintColor = UIColor.flatWatermelonDark
        self.present(alertReport, animated: true, completion: nil)
    }
    
    @IBAction func deleteAccount(_ sender: Any) {
        let alert = UIAlertController(title: "Delete Account", message: "Please enter your password to delete your account.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "password"
        })
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { [weak alert] (_) in
//            Firebase.deleteCurrentUser(password: (alert?.textFields![0].text)!) { success in
//                if success {
//                    SessionManager.refreshState()
//                    self.performSegue(withIdentifier: "backToLoginSegue", sender: nil)
//                    self.email.text = nil
//                    Current.user = nil
//                } else {
//                    let alertError = UIAlertController(title: "Error Deleting Account", message: "Please try again. Confirm you entered a correct password. ", preferredStyle: UIAlertControllerStyle.alert)
//                    alertError.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { [weak alert] (_) in
//                        //do nothing
//                    }))
//                    self.present(alertError, animated: true, completion: nil)
//                }
//            }
        }))
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: { [weak alert] (_) in
            //do nothing
        }))
        alert.view.tintColor = UIColor.flatWatermelon
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func openMenu(_ sender: Any) {
        setMenuClassSelected(sel: "settings")
        self.performSegue(withIdentifier: "openMenuFromSettings", sender: nil)
    }
    
    @IBAction func edgePanGesture(sender: UIScreenEdgePanGestureRecognizer) {
        setMenuClassSelected(sel: "settings")
        let translation = sender.translation(in: view)
        
        let progress = MenuHelper.calculateProgress(translationInView: translation, viewBounds: view.bounds, direction: .Right)
        
        MenuHelper.mapGestureStateToInteractor(
            gestureState: sender.state,
            progress: progress,
            interactor: interactor){
                self.performSegue(withIdentifier: "openMenuFromSettings", sender: nil)
        }
    }
}
