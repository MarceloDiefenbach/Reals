//
//  http.swift
//  RealsUIKit
//
//  Created by Marcelo Diefenbach on 14/09/22.


import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

class ServiceUploadPanda {
    
    func uploadPandaVideo() {
        
        let str: String = "panda-35a4078ff050e7c71c4ec6a75cc90b67be7f605d4c2362a4d4559545494e1903"

        let utf8str = str.data(using: .utf8)

        if let base64Encoded = utf8str?.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0)) {
            print("Encoded: \(base64Encoded)")

            if let base64Decoded = Data(base64Encoded: base64Encoded, options: Data.Base64DecodingOptions(rawValue: 0))
            .map({ String(data: $0, encoding: .utf8) }) {
                // Convert back to a string
                print("Decoded: \(base64Decoded ?? "")")
            }
        }
        
        let headers = [
            "accept": "text/plain",
            "Tus-Resumable": "1.0.0",
            "Upload-Length": "100",
            "Content-Type": "application/offset+octet-stream"
//            "Upload-Metadata": "authorization \(base64Encoded)==, filename bm9tZV90ZXN0ZQ=="
        ]

        let request = NSMutableURLRequest(url: NSURL(string: "https://uploader-us01.pandavideo.com.br/files")! as URL,
                                                cachePolicy: .useProtocolCachePolicy,
                                            timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
          if (error != nil) {
            print(error as Any)
          } else {
            let httpResponse = response as? HTTPURLResponse
            print(httpResponse)
          }
        })

        dataTask.resume()
        
    }
    
}
