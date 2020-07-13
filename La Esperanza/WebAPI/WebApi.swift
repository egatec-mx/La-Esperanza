//
//  WebApi.swift
//  La Esperanza
//
//  Created by Efrain Garcia Rocha on 02/07/20.
//  Copyright © 2020 Efrain Garcia Rocha. All rights reserved.
//

import UIKit

class WebApi: NSObject, URLSessionDelegate {
    let baseURL: String = "https://localhost:5001/api"
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        completionHandler(URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
        
    }
        
    func DoPost(_ action: String, jsonData: Data, onCompleteHandler: @escaping (_ result: Data?, _ error: Error?) -> Void) {
        let composedURL: String = "\(baseURL)/\(action)"
        let configuration: URLSessionConfiguration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: .main)
                
        guard let postUrl: URL = URL(string: composedURL) else { return }
        
        var request: URLRequest = URLRequest(url: postUrl)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if UserDefaults.standard.value(forKey: "JWTToken") != nil {
            request.addValue("Bearer \(UserDefaults.standard.string(forKey: "JWTToken")!)", forHTTPHeaderField: "Authorization")
        }
        
        request.httpBody = jsonData
        
        let task = session.dataTask(with: request) { (data, response, error) -> Void in
            guard error == nil else { onCompleteHandler(nil, error); return }
            
            if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                switch statusCode {
                case 200:
                    onCompleteHandler(data, error)
                case 401:
                    let nError = NSError(domain: "", code: 401, userInfo: nil)
                    onCompleteHandler(nil, nError)
                default:
                    onCompleteHandler(data, error)
                }
            }
        }
        
        task.resume()
    }
    
    func DoGet(_ action: String, onCompleteHandler: @escaping (_ result: Data?, _ error: Error?) -> Void) {
        let composedURL: String = "\(baseURL)/\(action)"
        let configuration: URLSessionConfiguration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: .main)
                
        guard let postUrl: URL = URL(string: composedURL) else { return }
        
        var request: URLRequest = URLRequest(url: postUrl)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if UserDefaults.standard.value(forKey: "JWTToken") != nil{
            request.addValue("Bearer \(UserDefaults.standard.string(forKey: "JWTToken")!)", forHTTPHeaderField: "Authorization")
        }
                
        let task = session.dataTask(with: request) { (data, response, error) -> Void in
            guard error == nil else { onCompleteHandler(nil, error); return }
            
            if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                switch statusCode {
                case 200:
                    onCompleteHandler(data, error)
                case 401:
                    let nError = NSError(domain: "", code: 401, userInfo: nil)
                    onCompleteHandler(nil, nError)
                default:
                    onCompleteHandler(data, error)
                }
            }
        }
        
        task.resume()
    }
}
