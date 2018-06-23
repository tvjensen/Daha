//
//  MyItemsViewController.swift
//  Daha
//
//  Created by Thomas Jensen on 6/22/18.
//  Copyright © 2018 Thomas Jensen. All rights reserved.
//

import UIKit

class MyItemsViewController: MenuClass {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func openMenu(_ sender: Any) {
        setMenuClassSelected(sel: "myItems")
        self.performSegue(withIdentifier: "openMenuFromMyItems", sender: nil)
    }
    
    
    @IBAction func edgePanGesture(sender: UIScreenEdgePanGestureRecognizer) {
        setMenuClassSelected(sel: "myItems")
        let translation = sender.translation(in: view)
        
        let progress = MenuHelper.calculateProgress(translationInView: translation, viewBounds: view.bounds, direction: .Right)
        
        MenuHelper.mapGestureStateToInteractor(
            gestureState: sender.state,
            progress: progress,
            interactor: interactor){
                self.performSegue(withIdentifier: "openMenuFromMyItems", sender: nil)
        }
    }
}
