//
//  ContactsTVC.swift
//  Contacts
//
//  Created by Markus Varner on 9/28/18.
//  Copyright © 2018 Markus Varner. All rights reserved.
//

import UIKit

class ContactsTVC: UITableViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchEntries()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateViews()
    }
    
    
    func fetchEntries() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        ContactController.shared.fetchContacts { (success) in
            if success {
                self.updateViews()
            }
        }
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
    
    func updateViews() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return ContactController.shared.contacts.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath)
        let contact = ContactController.shared.contacts[indexPath.row]
        cell.textLabel?.text = contact.name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let contact = ContactController.shared.contacts[indexPath.row]
            ContactController.shared.delete(contact: contact) { (success) in
                if success {
                    DispatchQueue.main.async {
                        self.tableView.deleteRows(at: [indexPath], with: .fade)
                    }
                }
            }
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToViewContact" {
            guard let destinationvc = segue.destination as? DetailViewController,
                let indexPath = tableView.indexPathForSelectedRow else { return }
            
            let contact = ContactController.shared.contacts[indexPath.row]
            destinationvc.contact = contact
        }
        
    }
    
    
}
