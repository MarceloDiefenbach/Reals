//
//  ServiceUpload.swift
//  RealsUIKit
//
//  Created by Marcelo Diefenbach on 15/09/22.
//

import Foundation

class ServiceUpload {
//
//    func uploadPandaVideo() {
//
//        let headers = [
//          "accept": "application/json",
//          "content-type": "application/json"
//        ]
//        let parameters = [
//          "endpoint": "https://uploader-fr01.pandavideo.com.br/files/",
//          "protocol": "tus",
//          "metadata": [
//            "authorization": "panda-35a4078ff050e7c71c4ec6a75cc90b67be7f605d4c2362a4d4559545494e1903",
//            "name": "nome do arquivo",
//            "type": "Type returned on meta request",
//            "description": "the description of the file",
//            "folder_id": "Folder id if exists",
//            "video_id": "Video ID if (uuid v4)"
//          ],
//          "fileId": "The url of the file",
//          "size": 123,
//          "url": "Url of the mp4 file"
//        ] as [String : Any]
//
//        let postData = JSONSerialization.data(withJSONObject: parameters, options: [])
//
//        let request = NSMutableURLRequest(url: NSURL(string: "https://uploader-us01.pandavideo.com.br:3020/url/get")! as URL,
//                                                cachePolicy: .useProtocolCachePolicy,
//                                            timeoutInterval: 10.0)
//        request.httpMethod = "POST"
//        request.allHTTPHeaderFields = headers
//        request.httpBody = postData as Data
//
//        let session = URLSession.shared
//        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
//          if (error != nil) {
//            print(error as Any)
//          } else {
//            let httpResponse = response as? HTTPURLResponse
//            print(httpResponse)
//          }
//        })
//
//        dataTask.resume()
//    }
//
}
