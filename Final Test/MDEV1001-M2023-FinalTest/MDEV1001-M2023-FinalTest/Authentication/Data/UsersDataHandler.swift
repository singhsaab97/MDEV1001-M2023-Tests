//
//  UsersDataHandler.swift
//  MDEV1001-M2023-FinalTest
//
//  Created by Abhijit Singh on 16/08/23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

typealias UsersDefaultCompletion = (_ error: String?) -> Void

final class UsersDataHandler {
    
    static let instance = UsersDataHandler()
    
    private let collection: CollectionReference
    
    private var userEmails: [String]
        
    private init() {
        self.collection = Firestore.firestore().collection(Constants.usersCollectionName)
        self.userEmails = []
    }
        
}

// MARK: - Exposed Helpers
extension UsersDataHandler {
    
    func fetchUsers() {
        collection.getDocuments { [weak self] (snapshot, error) in
            guard error == nil else { return }
            if let documents = snapshot?.documents {
                documents.forEach { document in
                    if let emailId = document.data()[Constants.userEmailIdCodingKey] as? String {
                        self?.userEmails.append(emailId)
                    }
                }
            }
        }
    }
    
    func signUp(with username: String, emailId: String, password: String, completion: @escaping UsersDefaultCompletion) {
        guard !userEmails.contains(emailId) else {
            completion(Constants.registrationFailedMessage)
            return
        }
        Auth.auth().createUser(withEmail: emailId, password: password) { [weak self] (_, error) in
            if let error = error {
                completion(error.localizedDescription)
            }
            let data = [Constants.userEmailIdCodingKey: emailId]
            self?.collection.document(username).setData(data) { error in
                guard let error = error else {
                    completion(nil)
                    return
                }
                completion(error.localizedDescription)
            }
        }
    }
    
    func signIn(with username: String, password: String, completion: @escaping UsersDefaultCompletion) {
        collection.document(username).getDocument { (snapshot, error) in
            if let error = error {
                completion(error.localizedDescription)
            } else if let emailId = snapshot?.data()?[Constants.userEmailIdCodingKey] as? String {
                Auth.auth().signIn(withEmail: emailId, password: password) { (result, error) in
                    guard let error = error else {
                        // User can be signed in
                        completion(nil)
                        return
                    }
                    completion(error.localizedDescription)
                }
            } else {
                completion(Constants.authenticationFailedMessage)
            }
        }
    }
    
}
