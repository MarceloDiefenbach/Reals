//
//  CoreDataService.swift
//  RealsUIKit
//
//  Created by Marcelo Diefenbach on 06/10/22.
//

import Foundation
import UIKit

class CoreDataService: UIViewController {
    
    var savedVideosURL: [String] = []
    
    let coreDataQueue = DispatchQueue(label: "CoreDataQueue", qos: .utility, attributes: [.concurrent], autoreleaseFrequency: .workItem)
    let captionReactionObserver = CaptionReactionObserver()
    
    func saveDataCoreData(videoUrl: String) {
        do {
            guard let folderURL = URL.createFolder(folderName: "StoredVideos") else {
                print("Can't create url")
                return
            }

            var invalidCharacters = CharacterSet(charactersIn: ":/")
            invalidCharacters.formUnion(.newlines)
            invalidCharacters.formUnion(.illegalCharacters)
            invalidCharacters.formUnion(.controlCharacters)

            let newFilename = videoUrl
                .components(separatedBy: invalidCharacters)
                .joined(separator: "")
            
            let permanentFileURL = folderURL.appendingPathComponent(newFilename).appendingPathExtension("mp4")
            let videoData = try Data(contentsOf: URL(string: videoUrl)!)
            try videoData.write(to: permanentFileURL, options: .atomic)

            
        } catch {
            fatalError()
        }
    }
    
    func deleteYesterdayReals() {
        
        guard let folderURL = URL.createFolder(folderName: "StoredVideos") else {
            print("Can't create url")
            return
        }
        
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(at: folderURL)
        } catch {
            print("Could not clear temp folder: \(error)")
        }
        
    }
    
}

extension URL {
    static func createFolder(folderName: String) -> URL? {
        let fileManager = FileManager.default
        // Get document directory for device, this should succeed
        if let documentDirectory = fileManager.urls(for: .documentDirectory,
                                                    in: .userDomainMask).first {
            // Construct a URL with desired folder name
            let folderURL = documentDirectory.appendingPathComponent(folderName)
            // If folder URL does not exist, create it
            if !fileManager.fileExists(atPath: folderURL.path) {
                do {
                    // Attempt to create folder
                    try fileManager.createDirectory(atPath: folderURL.path,
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)
                } catch {
                    // Creation failed. Print error & return nil
                    print(error.localizedDescription)
                    return nil
                }
            }
            // Folder either exists, or was created. Return URL
            return folderURL
        }
        // Will only be called if document directory not found
        return nil
    }
}
