//
//  DetailViewController.swift
//  Contacts
//
//  Created by Markus Varner on 9/28/18.
//  Copyright © 2018 Markus Varner. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    
    @IBOutlet var nameTF: UITextField!
    @IBOutlet var numberTF: UITextField!
    @IBOutlet var emailTF: UITextField!
    
    var contact: Contact?
    
    override func viewDidLoad() {
        super.viewDidLoad()

       updateViews()
    }
    
    
    func updateViews() {
        guard let contact = contact else { return }
        
        nameTF.text = contact.name
        numberTF.text = contact.phoneNumber
        emailTF.text = contact.email
        
    }
    
    
    //MARK: - IBActions
    
    @IBAction func saveBP(_ sender: UIBarButtonItem) {
        print("🐶 Save Tapped")
        guard let name = nameTF.text, !name.isEmpty, name != " " else {
            print("🤬Error with Saving")
            presentErrorAlert()
            return
        }
        
        if let contact = contact {
            ContactController.shared.update(contact: contact, withName: name, phoneNumber: numberTF.text, email: emailTF.text) { (success) in
                if success {
                    self.popCorn()
                }
            }
        } else {
            ContactController.shared.createNewContact(withName: name, phoneNumber: numberTF.text, email: emailTF.text) { (success) in
                if success {
                    self.popCorn()
                }
            }
        }
    }
    
    //MARK : - Helper Methods
    
    func popCorn() {
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func presentErrorAlert() {
        let alert = UIAlertController(title: "Oops don't forget to add your Contact's name!", message: nil, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        alert.addAction(dismissAction)
        present(alert, animated: true, completion: nil)
    }
    
    

}
