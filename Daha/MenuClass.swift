//
//  MenuClass.swift
//  Daha
//
//  Created by Thomas Jensen on 6/22/18.
//  Copyright © 2018 Thomas Jensen. All rights reserved.
//

import UIKit

class MenuClass: UIViewController, UIViewControllerTransitioningDelegate {
    
    let interactor = Interactor()
    
    var selected = "search"
    
    func setMenuClassSelected(sel: String) {
        self.selected = sel
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? MenuViewController {
            destinationViewController.transitioningDelegate = self
            destinationViewController.interactor = interactor
        }
        let secondViewController = segue.destination as! MenuViewController
        let selected = self.selected
        secondViewController.selected = selected
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentMenuAnimator()
    }
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissMenuAnimator()
    }
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
    func interactionControllerForPresentation(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
}
