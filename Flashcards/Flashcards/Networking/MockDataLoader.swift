//
//  MockDataLoader.swift
//  Flashcards
//
//  Created by Samantha Gatt on 9/26/18.
//  Copyright © 2018 Samantha Gatt. All rights reserved.
//

import Foundation

class MockDataLoader: NetworkDataLoader {
    
    // MARK: - Initializer
    
    init(data: Data? = nil, error: Error? = nil) {
        self.data = data
        self.error = error
    }
    
    
    // MARK: - Properties
    
    let data: Data?
    let error: Error?
    private(set) var request: URLRequest? = nil
    private(set) var url: URL? = nil
    
    
    // MARK: - NetworkDataLoader functions
    
    func loadData(from url: URL, completion: @escaping (Data?, Error?) -> Void) {
        self.url = url
        DispatchQueue.global().async {
            completion(self.data, self.error)
        }
    }
    
    func loadData(from request: URLRequest, completion: @escaping (Data?, Error?) -> Void) {
        self.request = request
        DispatchQueue.global().async {
            completion(self.data, self.error)
        }
    }
    
    func uploadData(to url: URL, completion: @escaping (Data?, Error?) -> Void) {
        self.url = url
        DispatchQueue.global().async {
            completion(self.data, self.error)
        }
    }
    
    func uploadData(to request: URLRequest, completion: @escaping (Data?, Error?) -> Void) {
        self.request = request
        DispatchQueue.global().async {
            completion(self.data, self.error)
        }
    }
    
    func deleteData(with url: URL, completion: @escaping (Data?, Error?) -> Void) {
        self.url = url
        DispatchQueue.global().async {
            completion(self.data, self.error)
        }
    }
    
    func deleteData(with request: URLRequest, completion: @escaping (Data?, Error?) -> Void) {
        self.request = request
        DispatchQueue.global().async {
            completion(self.data, self.error)
        }
    }
}
