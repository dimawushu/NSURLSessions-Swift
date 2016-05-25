//
//  JSONRequest.swift
//  Session3
//
//  Created by Дмитрий Бондаренко on 23.05.16.
//  Copyright © 2016 Ihor. All rights reserved.
//

import UIKit

protocol JSONRequestDelegate {
    func jsonResponse(response: [NSObject: AnyObject]?, data: NSData?) -> Void
    func jsonResponseError(error: NSError)
}

enum method {
    case Post
    case Get
    case Delete
    case Put
    
    enum type {
        case upload
        case request
        case download
    }
}

class JSONRequest: NSObject {
    
    var delegate: JSONRequestDelegate?
    
    let urlForRequest: String!
    let requestMethod: method
    let parametrs: [String : String]!
    let typeRequest: method.type
    
    
    init(urlForRequest: String, requestMethod: method, parametrs: [String : String], delegate: JSONRequestDelegate, typeRequest: method.type) {
        self.urlForRequest = urlForRequest
        self.requestMethod = requestMethod
        self.parametrs = parametrs
        self.typeRequest = typeRequest
        super.init()
        self.delegate = delegate
    }
    
    convenience init(urlForRequest: String, requestMethod: method, delegate: JSONRequestDelegate, typeRequest: method.type) {
        self.init(urlForRequest: urlForRequest, requestMethod: requestMethod, delegate: delegate, typeRequest: .download)
    }
    
    private var metod = String()
    
    
    func startRequest() {
        switch requestMethod {
        case .Post:
            metod = "POST"
        case .Get:
            metod = "GET"
        case .Delete:
            metod = "DELETE"
        case .Put:
            metod = "PUT"
        }
        
        switch typeRequest {
        case .request:
            requestTask()
        case .upload:
            uploadTask()
        case .download:
            downloadTask()
        }
    }
    
    private func uploadTask() {
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config)
        if let url = NSURL(string: urlForRequest) {
            
            do {
                
                let request = NSMutableURLRequest(URL: url)
                request.HTTPMethod = metod
                print(parametrs)
                let uploadData = try? NSJSONSerialization.dataWithJSONObject(parametrs, options: NSJSONWritingOptions(rawValue: 0))
                
                let uploadTask = session.uploadTaskWithRequest(request, fromData: uploadData, completionHandler: { (data: NSData?, resp: NSURLResponse?, error: NSError?) -> Void in
                    
                    do {
                        let dict = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as! [NSObject: AnyObject]
                        //   print("request is" + dict.description)
                        self.delegate?.jsonResponse(dict, data: nil)
                        
                    } catch let err as NSError {
                        //      NSLog(err.localizedDescription)
                        self.delegate?.jsonResponseError(err)
                    }
                })
                uploadTask.resume()
            }
        }
    }
    
    private func requestTask() {
        var parmStringBody = ""
        
         let dictValues = Array(parametrs.keys)
        
        for i in 0..<parametrs.count {
            let dictKey = dictValues[i]
            let dictValue = parametrs[dictKey]
            parmStringBody += dictKey + "=" + dictValue!
            if i < parametrs.count - 1 {
                parmStringBody += "&"
            }
        }
        
        let session = NSURLSession.sharedSession()
        
        let url = NSURL(string: urlForRequest)!
        let request = NSMutableURLRequest(URL: url)
        
        request.HTTPMethod = metod
        let stringPost = parmStringBody // Key and Value
        
        let data = stringPost.dataUsingEncoding(NSUTF8StringEncoding)
        
        request.HTTPBody = data
        request.HTTPShouldHandleCookies = false
        
        let requestTask = session.dataTaskWithRequest(request) { (data, response, error) in
            do {
                let dict = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as! [NSObject: AnyObject]
                //   print("request is" + dict.description)
                self.delegate?.jsonResponse(dict, data: nil)
                
            } catch let err as NSError {
                //      NSLog(err.localizedDescription)
                self.delegate?.jsonResponseError(err)
            }
        }
        requestTask.resume()
    }
    
    private func downloadTask() {
        let downloadTask = NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: urlForRequest)!) { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            
            do {
                self.delegate?.jsonResponse(nil, data: data!)
            } catch let err as NSError {
                //      NSLog(err.localizedDescription)
                self.delegate?.jsonResponseError(err)
            }
            
        }
        downloadTask.resume()
    }
    
}
