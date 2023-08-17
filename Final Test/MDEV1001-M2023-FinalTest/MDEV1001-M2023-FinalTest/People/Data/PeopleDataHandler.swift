//
//  PeopleDataHandler.swift
//  MDEV1001-M2023-FinalTest
//
//  Created by Abhijit Singh on 16/08/23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

typealias PeopleFetchCompletion = (_ people: [Person], _ error: String?) -> Void
typealias PeopleDefaultCompletion = (_ error: String?) -> Void

final class PeopleDataHandler {
    
    static let instance = PeopleDataHandler()
    
    private let collection: CollectionReference
        
    private init() {
        self.collection = Firestore.firestore().collection(Constants.peopleCollectionName)
    }
    
}

// MARK: - Exposed Helpers
extension PeopleDataHandler {
    
    func fetchPeople(completion: @escaping PeopleFetchCompletion) {
        collection.getDocuments { (snapshot, error) in
            if let error = error {
                completion([], error.localizedDescription)
            } else if let documents = snapshot?.documents {
                var people = [Person]()
                documents.forEach { document in
                    do {
                        var person = try Firestore.Decoder().decode(
                            Person.self,
                            from: document.data()
                        )
                        // Don't forget this necessary step
                        person.documentId = document.documentID
                        people.append(person)
                    } catch {
                        completion([], error.localizedDescription)
                    }
                }
                completion(people, nil)
            }
        }
    }
    
    func addPerson(_ person: Person, completion: @escaping PeopleDefaultCompletion) {
        guard let documentId = person.documentId else { return }
        do {
            try collection.document(documentId).setData(from: person) { error in
                completion(error?.localizedDescription)
            }
        } catch {
            completion(error.localizedDescription)
        }
    }
    
    func updatePerson(at documentId: String, with person: Person, completion: @escaping PeopleDefaultCompletion) {
        do {
            try collection.document(documentId).setData(from: person)
            completion(nil)
        } catch {
            completion(error.localizedDescription)
        }
    }
    
    func deletePerson(at documentId: String, completion: @escaping PeopleDefaultCompletion) {
        collection.document(documentId).delete { error in
            completion(error?.localizedDescription)
        }
    }
    
}
