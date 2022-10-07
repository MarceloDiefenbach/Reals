//
//  CoreDataService.swift
//  RealsUIKit
//
//  Created by Marcelo Diefenbach on 06/10/22.
//

import Foundation
import CoreData
import UIKit

class CoreDataService: UIViewController {
    
    var savedVideosURL: [String] = []
    
    let coreDataQueue = DispatchQueue(label: "CoreDataQueue", qos: .utility, attributes: [.concurrent], autoreleaseFrequency: .workItem)
    let captionReactionObserver = CaptionReactionObserver()
    
    var persistentContainer: NSPersistentContainer = {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError()
        }
        
        return appDelegate.persistentContainer
    }()
    
    private func save(videoData: Data, videoURL: String) {
        let reals = RealsVideoClass(context: persistentContainer.viewContext)
        
        reals.videoData = videoData
        reals.videoUrl = videoURL
        reals.date = Date.now
        
        DispatchQueue.main.async {
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
        }
    }
    
    func saveDataCoreData(videoUrl: String) {
        coreDataQueue.async {
            do {
                let realsVideoClassFetchRequest = RealsVideoClass.fetchRequest()
                let predicate = NSPredicate(format: "videoUrl == '\(videoUrl)'")
                realsVideoClassFetchRequest.predicate = predicate
                
                let videos = try self.persistentContainer.viewContext.fetch(realsVideoClassFetchRequest)
                let formatted = videos.map {"\($0)"}.joined(separator: "\n")
                
                if formatted == "" {
                    let data = try? Data.init(contentsOf: URL(string: videoUrl)!)
                    let videoURL = videoUrl
                    if let data = data, !self.savedVideosURL.contains(videoURL) {
                        self.savedVideosURL.append(videoURL)
                        self.save(videoData: data, videoURL: videoURL)
                    }
                }
            } catch {
                fatalError()
            }
        }
    }
    
}
