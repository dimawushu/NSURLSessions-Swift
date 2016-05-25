//
//  ViewController.swift
//  Session1
//
//  Created by Ihor on 10/3/15.
//  Copyright © 2015 Ihor. All rights reserved.
//

import UIKit

class ViewController: UIViewController, JSONRequestDelegate {
	// Upload task
	
	@IBOutlet weak var imageView: UIImageView!
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
        //1
        let ourUrl = "https://kneu.edu.ua/journal/api/device.register.json"
        //2
        let reqPar = ["platform": "ios",
                      "device_token": "[noPush]124567890",
                      "lang" : "ru_RU",
                      "client_secret" : "ts13KZolYT7McH4yeYA8L6IbH2Z7sTj2",
                      "student_id" : "135921",
                      "lastname" : "Бондаренко",
                      "device_name" : "iPhone 5"]
        //3
        let JSONreq = JSONRequest(urlForRequest: ourUrl, requestMethod: .Post, parametrs: reqPar, delegate: self, typeRequest: .request)
        //4
        JSONreq.startRequest()
        
    }
    
    func jsonResponseError(error: NSError) {
        print(error)
    }
    
    func jsonResponse(response: [NSObject : AnyObject]?, data: NSData?) {
        guard data == nil else {
            print("It is: " + ("\(data)"))
            return
        }
        print("Data isnt nil: \(response)")
    }

}

