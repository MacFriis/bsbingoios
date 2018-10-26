//
//  SettingTableViewController.swift
//  BS Bingo
//
//  Created by Per Friis on 22/10/2018.
//  Copyright © 2018 Per Friis. All rights reserved.
//

import UIKit

class SettingTableViewController: UITableViewController {
    
    @IBOutlet var infoView:UIView!
    
    @IBOutlet var infoStack:UIStackView!
    
    @IBOutlet var registreView:UIView!
    @IBOutlet weak var newUserNameTextField:UITextField!
    @IBOutlet weak var newPasswordTextField:UITextField!
    @IBOutlet weak var newPasswordConfirmTextField:UITextField!
    @IBOutlet weak var firstNameTextField:UITextField!
    @IBOutlet weak var lastNameTextField:UITextField!
    @IBOutlet weak var titleTextField:UITextField!
    
    @IBOutlet weak var submitButton:UIButton!
    
    
    @IBOutlet var loginView:UIView!
    @IBOutlet weak var userNameTextField:UITextField!
    @IBOutlet weak var passwordTextField:UITextField!
    
    @IBOutlet weak var loginButton:UIButton!
    
    
    @IBOutlet weak var userNameLabel:UILabel!
    @IBOutlet weak var nameLabel:UILabel!
    @IBOutlet weak var titleLabel:UILabel!
    
    var isLoggedIn:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        
        
        if let visualEffectView = registreView.subviews.filter({$0 is UIVisualEffectView}).first as? UIVisualEffectView {
            visualEffectView.layer.borderColor = UIColor(named: "main")?.cgColor
            visualEffectView.layer.borderWidth = 0.5
            
            visualEffectView.layer.cornerRadius = 8
            visualEffectView.clipsToBounds = true
        }
        
        registreView.layer.cornerRadius = 8
        registreView.layer.shadowOffset = CGSize(width: -15, height: 20)
        registreView.layer.shadowRadius = 5
        registreView.layer.shadowOpacity = 0.15
        
        
        if let visualEffectView = loginView.subviews.filter({$0 is UIVisualEffectView}).first as? UIVisualEffectView {
            visualEffectView.layer.borderColor = UIColor(named: "main")?.cgColor
            visualEffectView.layer.borderWidth = 0.5
            
            visualEffectView.layer.cornerRadius = 8
            visualEffectView.clipsToBounds = true
        }
        
        loginView.layer.cornerRadius = 8
        loginView.layer.shadowOffset = CGSize(width: -15, height: 20)
        loginView.layer.shadowRadius = 5
        loginView.layer.shadowOpacity = 0.15
        
        
        
        if isLoggedIn {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "sign-out"), style: .plain, target: self, action: #selector(self.logOut(sender:)))
        } else {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "sign-in"), style: .plain, target: self, action: #selector(self.logIn(sender:)))
        }
        updateBackgoundView()
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return isLoggedIn ? 2 : 0
    }
    
    
    @IBAction func submitUserRegistration(sender:Any) {
        submitButton.isEnabled = false
        print("register")
        guard let username = newUserNameTextField.text,
            username.count > 0,
            let password = newPasswordTextField.text,
            password.count >= 8 ,
            let retypePassword = newPasswordConfirmTextField.text,
            retypePassword == password else
        {
            return
        }
        
        
        
        let registration = RegistreUserDTO(
            firstname: firstNameTextField.text ?? "",
            lastName: lastNameTextField.text ?? "",
            email: username,
            password: password)
        
        
        Cloud.shared.registreUser(userDTO: registration) { (success, obj, error) -> (Void) in
            guard success else {
                DispatchQueue.main.async {
                    let alertController = UIAlertController(
                        title: NSLocalizedString("login error", comment: "login error - title"),
                        message: NSLocalizedString("The login failed, make sure you are using the correct user name and password\nalso make sure you have access to the internet", comment: "login error - message"),
                        preferredStyle: .alert)
                    
                    alertController.addAction(UIAlertAction(
                        title: NSLocalizedString("close", comment: "login error - close alert action"),
                        style: .cancel,
                        handler:nil))
                    
                    self.present(alertController, animated: true, completion: {
                        // TODO: reset the login view
                    })
                    
                }
                return
            }
            
            
            Cloud.shared.login(username: username, password: password, complete: { (success, obj, error) -> (Void) in
                Cloud.shared.getUserInfo(complete: { (success, obj, error) -> (Void) in
                    if success, let userInfo = obj as? UserInfoDTO {
                        DispatchQueue.main.async {
                            self.userNameLabel.text = Cloud.shared.username
                            self.nameLabel.text = "\(userInfo.givenName) \(userInfo.familyName)"
                            self.titleLabel.text = "not as a part at the moment"
                        }
                    }
                })
                
                DispatchQueue.main.async{
                    self.isLoggedIn = success
                    self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "sign-out"), style: .plain, target: self, action: #selector(self.logOut(sender:)))
                    self.tableView.reloadData()
                    self.loginView.removeFromSuperview()
                    self.registreView.removeFromSuperview()
                    self.updateBackgoundView()}
                
            })
            
        }
        
    }
    
    @IBAction func submitLogin(sender:Any) {
        guard let username = userNameTextField.text,
            username.count > 0,
            let password = passwordTextField.text,
            password.count >= 8 else {
                return
        }
        
        Cloud.shared.login(username: username, password: password) { (success, object, error) -> (Void) in
            DispatchQueue.main.async {
                self.isLoggedIn = success
                if success {
                    Cloud.shared.username = username
                    Cloud.shared.password = password
                    
                    self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "sign-out"), style: .plain, target: self, action: #selector(self.logOut(sender:)))
                    self.tableView.reloadData()
                    self.loginView.removeFromSuperview()
                    self.updateBackgoundView()
                } else {
                    let alertController = UIAlertController(
                        title: NSLocalizedString("login error", comment: "login error - title"),
                        message: NSLocalizedString("The login failed, make sure you are using the correct user name and password\nalso make sure you have access to the internet", comment: "login error - message"),
                        preferredStyle: .alert)
                    
                    alertController.addAction(UIAlertAction(
                        title: NSLocalizedString("close", comment: "login error - close alert action"),
                        style: .cancel,
                        handler:nil))
                    
                    self.present(alertController, animated: true, completion: {
                        // TODO: reset the login view
                    })
                }
            }
            
            Cloud.shared.getUserInfo(complete: { (success, obj, error) -> (Void) in
                if success, let userInfo = obj as? UserInfoDTO {
                    DispatchQueue.main.async {
                        self.userNameLabel.text = Cloud.shared.username
                        self.nameLabel.text = "\(userInfo.givenName) \(userInfo.familyName)"
                        self.titleLabel.text = "not as a part at the moment"
                    }
                }
            })
        }
    }
    
    
    
    @IBAction func cancelLogin(sender:Any) {
        navigationItem.rightBarButtonItem?.isEnabled = true;
        
        loginView.removeFromSuperview()
        registreView.removeFromSuperview()
        updateBackgoundView()
    }
    
    
    @IBAction func registreNewUser(sender:Any) {
        
        
        
        infoView.addSubview(registreView)
        registreView.center  = CGPoint(x: infoView.bounds.midX, y: infoView.bounds.midY)
    }
    
    @IBAction func privacyPolicy(sender:Any) {
        UIApplication.shared.open(URL(string: "https://friisconsult.com")!, options: [:], completionHandler: nil)
    }
    
    
    @IBAction func logIn(sender:Any) {
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        newUserNameTextField.text = Cloud.shared.username ?? ""
        newPasswordTextField.text = Cloud.shared.password ?? ""
        
        infoView.addSubview(loginView)
        loginView.center  = CGPoint(x: infoView.bounds.midX, y: infoView.bounds.midY)
    }
    
    @IBAction func logOut(sender:Any) {
        isLoggedIn = false
        navigationItem.rightBarButtonItem?.isEnabled = false
        Cloud.shared.username = nil
        Cloud.shared.password = nil
        Cloud.shared.authentication = nil
        Cloud.shared.tokenExpire = Date()
        
        userNameLabel.text = ""
        nameLabel.text = ""
        titleLabel.text = ""
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "sign-in"), style: .plain, target: self, action: #selector(self.logIn(sender:)))
        self.tableView.reloadData()
        self.updateBackgoundView()
        
    }
    
    func updateBackgoundView(){
        if isLoggedIn {
            
            self.tableView.backgroundView = nil
            //infoView.removeFromSuperview()
            tableView.backgroundView = nil
        } else {
            submitButton.isEnabled = true
            infoView.frame = tableView.bounds
            tableView.backgroundView = infoView
            infoStack.isHidden = false
        }
    }
}

