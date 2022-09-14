//
//  http.swift
//  RealsUIKit
//
//  Created by Marcelo Diefenbach on 14/09/22.
//
//
//import Foundation
//#if canImport(FoundationNetworking)
//import FoundationNetworking
//#endif
//
//var semaphore = DispatchSemaphore (value: 0)
//
//let parameters = "{\r\n    \"username\": \"johnsmith\",\r\n    \"firstName\": \"John\",\r\n    \"lastName\": \"Smith\",\r\n    \"email\": \"johnsmith@gmail.com\",\r\n    \"password\": \"12345\"\r\n}"
//let postData = parameters.data(using: .utf8)
//
//var request = URLRequest(url: URL(string: "{{baseURL}}/api/v1/register")!,timeoutInterval: 5)
//request.httpMethod = "POST"
//request.httpBody = postData
//
//let task = URLSession.shared.dataTask(with: request) { data, response, error in
//  guard let data = data else {
//    print(String(describing: error))
//    semaphore.signal()
//    return
//  }
//  print(String(data: data, encoding: .utf8)!)
//  semaphore.signal()
//}
//
//task.resume()
//semaphore.wait()
