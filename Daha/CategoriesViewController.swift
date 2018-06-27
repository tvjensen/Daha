//
//  CategoriesViewController.swift
//  Daha
//
//  Created by Thomas Jensen on 6/22/18.
//  Copyright © 2018 Thomas Jensen. All rights reserved.
//

import UIKit

class CategoriesViewController: MenuClass {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func openMenu(_ sender: Any) {
        setMenuClassSelected(sel: "categories")
        self.performSegue(withIdentifier: "openMenuFromCategories", sender: nil)
    }
    
    @IBAction func edgePanGesture(sender:
        UIScreenEdgePanGestureRecognizer) {
        setMenuClassSelected(sel: "categories")
        let translation = sender.translation(in: view)
        
        let progress = MenuHelper.calculateProgress(translationInView: translation, viewBounds: view.bounds, direction: .Right)
        
        MenuHelper.mapGestureStateToInteractor(
            gestureState: sender.state,
            progress: progress,
            interactor: interactor){
                self.performSegue(withIdentifier: "openMenuFromCategories", sender: nil)
        }
    }
    
    
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if (segue.identifier == "openMenuFromCategories") {
//            let secondViewController = segue.destination as! MenuViewController
//            let selected = self.selected
//            secondViewController.selected = selected
//        }
//    }
}
