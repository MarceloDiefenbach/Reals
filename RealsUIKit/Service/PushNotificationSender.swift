//
//  Notification.swift
//  RealsUIKit
//
//  Created by Marcelo Diefenbach on 25/09/22.
//

import Foundation

class PushNotificationSender {

    var service = ServiceSocial()

    func sendPushNotification(to tokens: String, title: String, body: String) {
        let urlString = "https://fcm.googleapis.com/fcm/send"
        let url = NSURL(string: urlString)!
        let paramString: [String : Any] = ["registration_ids" : tokens,
                                           "notification" : [
                                            "title" : title,
                                            "body" : body,
                                            "sound" : "default"
                                           ]
        ]
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject:paramString, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=AAAA8qf-3KU:APA91bGR78vOanjJRc50x2-_FGi2KhJvWifnXZVdhcdUp_mmc_MBWhSlIfm61KHvu-6SfpKP_gHhtjHsmwChqjmPjd8uQ8SztgfyvDUmEeVq6AdIlQXXbhCpxbN439Jmw5pog8aeiXV3", forHTTPHeaderField: "Authorization")
        let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
            do {
                if let jsonData = data {
                    if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                        NSLog("Received data:\n\(jsonDataDict))")
                    }
                }
            } catch let err as NSError {
                print(err.debugDescription)
            }
        }
        task.resume()
    }

    func sendNotificationPost() {

        var receivers: [String] = []

        service.getFcmTokenOfFollowers(completionHandler: { (receivers) in

            let urlString = "https://fcm.googleapis.com/fcm/send"
            let url = NSURL(string: urlString)!
            let paramString: [String : Any] = ["registration_ids" : receivers,
                                               "notification" : [
                                                "title" : "@\(UserDefaults.standard.string(forKey: "username") ?? "A friend") just posted",
                                                "body" : "Click here to see now",
                                                "sound" : "default"
                                               ]
            ]
            let request = NSMutableURLRequest(url: url as URL)
            request.httpMethod = "POST"
            request.httpBody = try? JSONSerialization.data(withJSONObject:paramString, options: [.prettyPrinted])
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("key=AAAA8qf-3KU:APA91bGR78vOanjJRc50x2-_FGi2KhJvWifnXZVdhcdUp_mmc_MBWhSlIfm61KHvu-6SfpKP_gHhtjHsmwChqjmPjd8uQ8SztgfyvDUmEeVq6AdIlQXXbhCpxbN439Jmw5pog8aeiXV3", forHTTPHeaderField: "Authorization")
            let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
                do {
                    if let jsonData = data {
                        if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                            NSLog("Received data:\n\(jsonDataDict))")
                        }
                    }
                } catch let err as NSError {
                    print(err.debugDescription)
                }
            }
            task.resume()
        })
    }

    func sendFollowNotification(user: User) {
        let urlString = "https://fcm.googleapis.com/fcm/send"
        let url = NSURL(string: urlString)!
        let paramString: [String : Any] = ["to" : user.fcmToken,
                                           "notification" : [
                                            "title" : "@\(UserDefaults.standard.string(forKey: "username") ?? "") follow you",
                                            "body" : "",
                                            "sound" : "default"
                                           ]
        ]
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject:paramString, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=AAAA8qf-3KU:APA91bGR78vOanjJRc50x2-_FGi2KhJvWifnXZVdhcdUp_mmc_MBWhSlIfm61KHvu-6SfpKP_gHhtjHsmwChqjmPjd8uQ8SztgfyvDUmEeVq6AdIlQXXbhCpxbN439Jmw5pog8aeiXV3", forHTTPHeaderField: "Authorization")
        let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
            do {
                if let jsonData = data {
                    if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                        NSLog("Received data:\n\(jsonDataDict))")
                    }
                }
            } catch let err as NSError {
                print(err.debugDescription)
            }
        }
        task.resume()
    }
    
    func sendReactionNotification(username: String) {
        
        service.getFcmTokenOfUser(username: username, completionHandler: { (receiver) in
          print(receiver)
            let urlString = "https://fcm.googleapis.com/fcm/send"
            let url = NSURL(string: urlString)!
            let paramString: [String : Any] = ["to" : receiver[0],
                                               "notification" : [
                                                "title" : "@\(UserDefaults.standard.string(forKey: "username") ?? "") reacted to your Real",
                                                "body" : "",
                                                "sound" : "default"
                                               ]
            ]
            
            let request = NSMutableURLRequest(url: url as URL)
            request.httpMethod = "POST"
            request.httpBody = try? JSONSerialization.data(withJSONObject:paramString, options: [.prettyPrinted])
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("key=AAAA8qf-3KU:APA91bGR78vOanjJRc50x2-_FGi2KhJvWifnXZVdhcdUp_mmc_MBWhSlIfm61KHvu-6SfpKP_gHhtjHsmwChqjmPjd8uQ8SztgfyvDUmEeVq6AdIlQXXbhCpxbN439Jmw5pog8aeiXV3", forHTTPHeaderField: "Authorization")
            let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
                do {
                    if let jsonData = data {
                        if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                            NSLog("Received data:\n\(jsonDataDict))")
                        }
                    }
                } catch let err as NSError {
                    print(err.debugDescription)
                }
            }
            task.resume()
            
        })
    }
    
    func sendItsTimeNotificaion() {

        service.getAllFcmToken(completionHandler: { (receivers) in

            self.service.changeDateOnFirebaseToSwitchDayPosts()
            
            let urlString = "https://fcm.googleapis.com/fcm/send"
            let url = NSURL(string: urlString)!
            let paramString: [String : Any] = ["registration_ids" : receivers,
                                               "notification" : [
                                                "title" : "🎬 Reals time has arrived ",
                                                "body" : "Be the first person to post",
                                                "sound" : "default"
                                               ]
            ]
            let request = NSMutableURLRequest(url: url as URL)
            request.httpMethod = "POST"
            request.httpBody = try? JSONSerialization.data(withJSONObject:paramString, options: [.prettyPrinted])
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("key=AAAA8qf-3KU:APA91bGR78vOanjJRc50x2-_FGi2KhJvWifnXZVdhcdUp_mmc_MBWhSlIfm61KHvu-6SfpKP_gHhtjHsmwChqjmPjd8uQ8SztgfyvDUmEeVq6AdIlQXXbhCpxbN439Jmw5pog8aeiXV3", forHTTPHeaderField: "Authorization")
            let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
                do {
                    if let jsonData = data {
                        if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                            NSLog("Received data:\n\(jsonDataDict))")
                        }
                    }
                } catch let err as NSError {
                    print(err.debugDescription)
                }
            }
            task.resume()
        })
    }
}
