//
//  ModelController.swift
//  Contacts
//
//  Created by Markus Varner on 9/28/18.
//  Copyright © 2018 Markus Varner. All rights reserved.
//

import Foundation
import CloudKit


class ContactController {
    
    //Singleton
    static let shared = ContactController()
    
    // MARK: - Database instance
    let privateDB = CKContainer.default().privateCloudDatabase
    
    //Source of Truth
    var contacts: [Contact] = []
    
    // MARK: - CRUD Methods
    
    //CREATE
    
    func createNewContact(withName name: String, phoneNumber: String?, email: String?, completion: @escaping (Bool) -> Void) {
        
        let contact = Contact(name: name, phoneNumber: phoneNumber, email: email)
        
        //assign contact CKRecord
        let contactRecord = CKRecord(contact: contact)
        privateDB.save(contactRecord) { (record, error) in
            if let error = error {
                print("Error occurred saving contact: \(error.localizedDescription).")
                completion(false)
                return
            }
            
            self.contacts.append(contact)
            completion(true)
        }
        
    }
    
    //FETCH
    
    func fetchContacts(completion: @escaping (Bool) -> Void) {
        //create predicate for the query
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: Contact.typeKey, predicate: predicate)
        //perform query to fetch ALL contacts
        privateDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("Error occurred saving contact: \(error.localizedDescription).")
                completion(false)
                return
            }
            
            guard let records = records else { completion(false) ; return }
            //Iterate through the contacts and pull them out by their record
            let contacts = records.compactMap { Contact(ckRecord: $0) }
            self.contacts = contacts
            completion(true)
        }
        
    }
    
    //UPDATE
    
    func update(contact: Contact, withName name: String, phoneNumber: String?, email: String?, completion: @escaping (Bool) -> Void) {
        //update contact values
        contact.name = name
        contact.phoneNumber = phoneNumber
        contact.email = email
        
        let contactRecord = CKRecord(contact: contact)
        
        guard let contactRecordID = contact.cloudKitRecordID else { completion(false) ; return }
        
        //MARK: - Define Modification Operation
        
        //CKModifyRecordsOperation takes in an array of CKRecords and CKRecords.IDs
        let operation = CKModifyRecordsOperation(recordsToSave: [contactRecord], recordIDsToDelete: [contactRecordID])
        //Delete Record by RecordID
        operation.recordIDsToDelete = [contactRecordID]
        //save any noted changes in the database
        operation.savePolicy = .changedKeys
        //process is heavy so it needs to be high priority on queue
        operation.queuePriority = .high
        //maintain resources for the user interface
        operation.qualityOfService = .userInteractive
        
        operation.completionBlock = {
            completion(true)
        }
        
        privateDB.add(operation)
    }
    
    //DELETE
    
    func delete(contact: Contact, completion: @escaping (Bool) -> Void) {
        guard let recordID = contact.cloudKitRecordID else { completion(false) ; return }
        
        privateDB.delete(withRecordID: recordID) { (record, error) in
            if let error = error {
                print("Error occurred deleting contact: \(error.localizedDescription).")
                completion(false)
                return
            }
            
            guard let contactIndex = self.contacts.index(of: contact) else { completion(false) ; return }
            
            self.contacts.remove(at: contactIndex)
            completion(true)
        }
    }
    
    
    
}
