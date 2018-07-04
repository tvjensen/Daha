//
//  MyProfileViewController.swift
//  Daha
//
//  Created by Thomas Jensen on 6/22/18.
//  Copyright © 2018 Thomas Jensen. All rights reserved.
//

import UIKit
import FirebaseStorage

class MyProfileViewController: MenuClass, UITextFieldDelegate {
    
    var filterButton = dropDownBtn()
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var userImage: UIButton!
    @IBOutlet weak var yourItemsLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    
    
    @IBAction func saveInfo(_ sender: Any) {
        if firstNameField.text != Current.user?.firstName || lastNameField.text != Current.user?.lastName {
            print("save hit")
            saveButton.backgroundColor = UIColor.lightGray
            var updatedUser = Current.user
            updatedUser?.firstName = firstNameField.text!
            updatedUser?.lastName = lastNameField.text!
            Firebase.updateCurrentUser(user: updatedUser!)
        }
    }
    
    @IBAction func addImage(_ sender: Any) {
        CameraHandler.shared.showActionSheet(vc: self)
        CameraHandler.shared.imagePickedBlock = { (image) in
            self.userImage.imageView?.contentMode = UIViewContentMode.scaleAspectFill
            self.userImage.setImage(image, for: .normal)
            self.dismiss(animated: true, completion: nil)
            var data = NSData()
            data = UIImageJPEGRepresentation(image, 1.0)! as NSData
            // set upload path
            let filePath = "\((Current.user?.email)!)/\("profileImage")"
            let metadata = StorageMetadata()
            metadata.cacheControl = "public,max-age=300";
            metadata.contentType = "image/jpeg";
            Firebase.addImage(filePath: filePath, data: data, metadata: metadata) { (success) in
                if success {
                    print("Image saved")
                }
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstNameField.text = Current.user?.firstName
        firstNameField.delegate = self
        firstNameField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        lastNameField.delegate = self
        lastNameField.text = Current.user?.lastName
        lastNameField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        
        Firebase.fetchProfileImage() { (image) in
            self.userImage.imageView?.contentMode = UIViewContentMode.scaleAspectFill
            self.userImage.setImage(image, for: .normal)
        }
        
        //Configure the button
        filterButton = dropDownBtn.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        filterButton.setTitle("Filter By", for: .normal)
        filterButton.translatesAutoresizingMaskIntoConstraints = false
        
        //Add Button to the View Controller
        self.view.addSubview(filterButton)
        
        //button Constraints
        filterButton.rightAnchor.constraint(equalTo: usernameField.rightAnchor).isActive = true
        filterButton.centerYAnchor.constraint(equalTo: yourItemsLabel.centerYAnchor).isActive = true
        filterButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        filterButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        //Set the drop down menu's options
        filterButton.dropView.dropDownOptions = ["Time","Price", "ABC"]
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        if firstNameField.text != Current.user?.firstName || lastNameField.text != Current.user?.lastName {
            saveButton.backgroundColor = UIColor.flatWatermelonDark
        } else {
            saveButton.backgroundColor = UIColor.lightGray
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func openMenu(_ sender: Any) {
        setMenuClassSelected(sel: "myProfile")
        self.performSegue(withIdentifier: "openMenuFromMyProfile", sender: nil)
    }
    
    
    @IBAction func edgePanGesture(sender: UIScreenEdgePanGestureRecognizer) {
        setMenuClassSelected(sel: "myProfile")
        let translation = sender.translation(in: view)
        
        let progress = MenuHelper.calculateProgress(translationInView: translation, viewBounds: view.bounds, direction: .Right)
        
        MenuHelper.mapGestureStateToInteractor(
            gestureState: sender.state,
            progress: progress,
            interactor: interactor){
                self.performSegue(withIdentifier: "openMenuFromMyProfile", sender: nil)
        }
    }
}

protocol dropDownProtocol {
    func dropDownPressed(string : String)
}

class dropDownBtn: UIButton, dropDownProtocol {

    func dropDownPressed(string: String) {
        self.setTitle(string, for: .normal)
        self.dismissDropDown()
    }

    var dropView = dropDownView()

    var height = NSLayoutConstraint()


    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = 5.0
        self.backgroundColor = UIColor.flatWatermelonDark

        dropView = dropDownView.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        dropView.delegate = self
        dropView.translatesAutoresizingMaskIntoConstraints = false
    }

    override func didMoveToSuperview() {
        self.superview?.addSubview(dropView)
        self.superview?.bringSubview(toFront: dropView)
        dropView.topAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        dropView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        dropView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        height = dropView.heightAnchor.constraint(equalToConstant: 0)
    }

    var isOpen = false
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isOpen == false {

            isOpen = true

            NSLayoutConstraint.deactivate([self.height])

            if self.dropView.tableView.contentSize.height > 300 {
                self.height.constant = 300
            } else {
                self.height.constant = self.dropView.tableView.contentSize.height
            }


            NSLayoutConstraint.activate([self.height])

            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
                self.dropView.layoutIfNeeded()
                self.dropView.center.y += self.dropView.frame.height / 2
            }, completion: nil)

        } else {
            isOpen = false

            NSLayoutConstraint.deactivate([self.height])
            self.height.constant = 0
            NSLayoutConstraint.activate([self.height])
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
                self.dropView.center.y -= self.dropView.frame.height / 2
                self.dropView.layoutIfNeeded()
            }, completion: nil)

        }
    }

    func dismissDropDown() {
        isOpen = false
        NSLayoutConstraint.deactivate([self.height])
        self.height.constant = 0
        NSLayoutConstraint.activate([self.height])
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
            self.dropView.center.y -= self.dropView.frame.height / 2
            self.dropView.layoutIfNeeded()
        }, completion: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class dropDownView: UIView, UITableViewDelegate, UITableViewDataSource  {
    
    var dropDownOptions = [String]()
    
    var tableView = UITableView()
    
    var delegate : dropDownProtocol!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        tableView.backgroundColor = UIColor.flatWatermelon
        self.backgroundColor = UIColor.flatWatermelon
        
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(tableView)
        
        tableView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dropDownOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        cell.textLabel?.text = dropDownOptions[indexPath.row]
        cell.textLabel?.textColor = UIColor.flatWatermelonDark
        cell.backgroundColor = UIColor.white
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate.dropDownPressed(string: dropDownOptions[indexPath.row])
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
