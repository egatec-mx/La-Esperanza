//
//  WebApi.swift
//  La Esperanza
//
//  Created by Efrain Garcia Rocha on 02/07/20.
//  Copyright © 2020 Efrain Garcia Rocha. All rights reserved.
//

import UIKit

class WebApi: NSObject, URLSessionDelegate {
    var userDefaults: UserDefaults?
    var baseURL: String = ""
    
    override init() {
        userDefaults = UserDefaults(suiteName: "group.mx.com.egatec.esperanza")
        baseURL = userDefaults?.string(forKey: "SERVER_URL") ?? ""
    }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        completionHandler(URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
        
    }
        
    func DoPost(_ action: String, jsonData: Data, onCompleteHandler: @escaping (_ result: Data?, _ error: Error?) -> Void) {
        let composedURL: String = "\(baseURL)/\(action)"
        let configuration: URLSessionConfiguration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 600
        configuration.timeoutIntervalForResource = 600
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: .main)
                
        guard let postUrl: URL = URL(string: composedURL) else { return }
        
        var request: URLRequest = URLRequest(url: postUrl)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if userDefaults?.value(forKey: "JWTToken") != nil {
            request.addValue("Bearer \(userDefaults?.string(forKey: "JWTToken") ?? "")", forHTTPHeaderField: "Authorization")
        }
        
        request.httpBody = jsonData
        
        let task = session.dataTask(with: request) { (data, response, error) -> Void in
            guard error == nil else { onCompleteHandler(nil, error); return }
            
            if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                switch statusCode {
                case 200, 400:
                    onCompleteHandler(data, error)
                case 401, 404:
                    let nError = NSError(domain: "", code: statusCode, userInfo: nil)
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
        configuration.timeoutIntervalForResource = 600
        configuration.timeoutIntervalForRequest = 600
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: .main)
                
        guard let postUrl: URL = URL(string: composedURL) else { return }
        
        var request: URLRequest = URLRequest(url: postUrl)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if userDefaults?.value(forKey: "JWTToken") != nil{
            request.addValue("Bearer \(userDefaults?.string(forKey: "JWTToken") ?? "")", forHTTPHeaderField: "Authorization")
        }
                
        let task = session.dataTask(with: request) { (data, response, error) -> Void in
            guard error == nil else { onCompleteHandler(nil, error); return }
            
            if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                switch statusCode {
                case 200, 400:
                    onCompleteHandler(data, error)
                case 401, 404:
                    let nError = NSError(domain: "", code: statusCode, userInfo: nil)
                    onCompleteHandler(nil, nError)
                default:
                    onCompleteHandler(data, error)
                }
            }
        }
        
        task.resume()
    }
}
