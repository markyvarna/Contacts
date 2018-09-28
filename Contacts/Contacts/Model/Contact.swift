//
//  Contact.swift
//  Contacts
//
//  Created by Markus Varner on 9/28/18.
//  Copyright © 2018 Markus Varner. All rights reserved.
//

import Foundation
import CloudKit

class Contact {
    
    // MARK: - Constant Keys
    static let typeKey = "Contact"
    fileprivate static let nameKey = "name"
    fileprivate static let phoneNumberKey = "phoneNumber"
    fileprivate static let emailKey = "email"
    
    
    var name: String
    var phoneNumber: String?
    var email: String?
    
    // MARK: - CloudKit Properties
    var cloudKitRecordID: CKRecord.ID?
    
    
    init(name: String, phoneNumber: String?, email: String?) {
        self.name = name
        self.phoneNumber = phoneNumber
        self.email = email
    }
    
    //MARK: - Failable Initializer
    init?(ckRecord: CKRecord) {
        //assign constant keys
        guard let name = ckRecord[Contact.nameKey] as? String,
            let phoneNumber = ckRecord[Contact.phoneNumberKey] as? String,
            let email = ckRecord[Contact.emailKey] as? String else { return nil }
        
        self.name = name
        self.phoneNumber = phoneNumber
        self.email = email
        self.cloudKitRecordID = ckRecord.recordID
    }
    
}

// MARK: - Equatable Conformance
extension Contact: Equatable {
    
    static func ==(lhs: Contact, rhs: Contact) -> Bool {
        return lhs.name == rhs.name && lhs.phoneNumber == rhs.phoneNumber && lhs.email == rhs.email && lhs.cloudKitRecordID == rhs.cloudKitRecordID
    }
    
}

// MARK: - CKRecord Extension

extension CKRecord {
    
    //MARK: - Convenience Initializer
    convenience init(contact: Contact) {
        //let the contact recordID be their cloudKitRecordID or Assign them one
        let recordID = contact.cloudKitRecordID ?? CKRecord.ID(recordName: UUID().uuidString)
        self.init(recordType: Contact.typeKey)
        self.setValue(contact.name, forKey: Contact.nameKey)
        self.setValue(contact.phoneNumber, forKey: Contact.phoneNumberKey)
        self.setValue(contact.email, forKey: Contact.emailKey)
        
        contact.cloudKitRecordID = recordID
    }
    
}
