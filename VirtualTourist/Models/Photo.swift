//
//  Photo.swift
//  VirtualTourist
//
//  Created by Sanjib Ahmad on 8/17/15.
//  Copyright (c) 2015 Object Coder. All rights reserved.
//

import Foundation
import UIKit
import CoreData

@objc(Photo)

class Photo: NSManagedObject {
    @NSManaged var imageName: String
    @NSManaged var remotePath: String
    @NSManaged var pin: Pin?
    @NSManaged var didFetchImageData: Bool
    
    private let noPhotoAvailableImageData = NSData(data: UIImagePNGRepresentation(UIImage(named: "noPhotoAvailable")))
    var fetchInProgress = false
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(imageName: String, remotePath: String, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.imageName = imageName
        self.remotePath = remotePath
        didFetchImageData = false
    }
    
    var localURL: NSURL {
        let url = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).first as! NSURL
        return url.URLByAppendingPathComponent(imageName)
    }
    
    var imageData: NSData? {
        var imageData: NSData? = nil
        if NSFileManager.defaultManager().fileExistsAtPath(localURL.path!) {
            imageData = NSData(contentsOfURL: localURL)
        }
        return imageData
    }
    
    func fetchImageData(completionHandler: (fetchComplete: Bool) -> Void) {
        if didFetchImageData == false && fetchInProgress == false {
            fetchInProgress = true
            var localURL = self.localURL
            if let url = NSURL(string: remotePath) {
                NSURLSession.sharedSession().dataTaskWithURL(url) { data, response, error in
                    println("self.managedObjectContext: \(self.managedObjectContext)")                    
                    if self.managedObjectContext != nil {
                        if error != nil {
                            NSFileManager.defaultManager().createFileAtPath(self.localURL.path!, contents: self.noPhotoAvailableImageData, attributes: nil)
                        } else {
                            NSFileManager.defaultManager().createFileAtPath(self.localURL.path!, contents: data, attributes: nil)
                        }
                        self.didFetchImageData = true
                        completionHandler(fetchComplete: true)
                    } else {
                        completionHandler(fetchComplete: false)
                    }
                    self.fetchInProgress = false
                }.resume()
            }
        }
    }
    
    override func prepareForDeletion() {
        super.prepareForDeletion()
        if NSFileManager.defaultManager().fileExistsAtPath(localURL.path!) {
            var error: NSError? = nil
            NSFileManager.defaultManager().removeItemAtURL(localURL, error: &error)
            if error != nil {
                println("couldn't remove image at: \(imageName)")
            } else {
                println("removed image at: \(imageName)")
            }
        }
    }
}