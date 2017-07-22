//
//  DropZoneView.swift
//  Bitmapper
//
//  Created by Alex on 01-03-15.
//  Copyright (c) 2015 Balancing Rock. All rights reserved.
//

import Cocoa

@objc protocol DropZoneDelegate: NSObjectProtocol, NSDraggingDestination {
    
    /// Redirect of the draggingEntered function (optional)
    @objc optional func draggingEntered(_ info: NSDraggingInfo) -> NSDragOperation
    
    /// Redirect of the draggingUpdated function (optional)
    @objc optional func draggingUpdated(_ info: NSDraggingInfo) -> NSDragOperation
    
    /// Redirect of the draggingExited function (optional)
    @objc optional func draggingExited(_ info: NSDraggingInfo)
    
    /// Redirect of the prepareForDragOperation (optional)
    @objc optional func prepareForDragOperation(_ info: NSDraggingInfo) -> Bool
    
    /// Redirect of the performDragOperations (required)
    func performDragOperation(_ info: NSDraggingInfo) -> Bool
    
}

class DropZoneView: NSView {

//MARK: - Instance variables
    
    @IBOutlet var dropDelegate: DropZoneDelegate?
    
    /// The array holding the file extensions that are accepted (e.g. ["mp3", "aac"])
    var acceptedFiles: [String] = []
    
    /// The dragOperation that will de returned if an optoinal DropZoneDelegate function has not been implemented
    var defaultDragOperation = NSDragOperation.copy
    
    
//MARK: - Functions
    
    /// A helper function, to make it easier to register for specific file types. The array should look like ["mp3", "aac", "psd"] etc.
    func registerForFileExtensions(_ extensions: [String]) {
        
        var types: [String] = []
        
        for ext in extensions {
            types.append("NSTypedFilenamesPboardType:\(ext)")
        }
        
        register(forDraggedTypes: [NSFilenamesPboardType])
        acceptedFiles = extensions
        
    }
    
    /// Returns the file urls from the given DraggingInfo
    class func fileUrlsFromDraggingInfo(_ info: NSDraggingInfo) -> [URL]? {
        
        let pboard = info.draggingPasteboard()
        
        if (pboard.types! as NSArray).contains(NSURLPboardType) {
            let urls = pboard.readObjects(forClasses: [NSURL.self], options: nil) as? [NSURL]
            var realUrls = [URL]()
            
            for url in urls! {
                
                realUrls.append((url as NSURL).filePathURL!) // use filePathURL to avoid file:// file id's
                
            }
            
            return realUrls
            
        }
        
        return nil
        
    }
    
    /// Returns whether the dragginginfo has any valid files
    fileprivate func hasValidFiles(_ info: NSDraggingInfo) -> Bool {
        
        var hasValidFiles = false
        let pboard = info.draggingPasteboard()
        
        var urls = DropZoneView.fileUrlsFromDraggingInfo(info)
        if urls == nil { return false }
        
        for url in urls! {
            
            if (acceptedFiles.contains(url.pathExtension)) { hasValidFiles = true }
                
        }
        
        return hasValidFiles
        
    }

    
//MARK: - Dragging functions
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        
        if dropDelegate != nil && dropDelegate!.responds(to: #selector(NSDraggingDestination.draggingEntered(_:))) {
            
            return dropDelegate!.draggingEntered!(sender)
            
        } else {
            
            if !hasValidFiles(sender) {
                return NSDragOperation()
            } else {
                return defaultDragOperation
            }
        
        }
        
    }
    
    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        
        if dropDelegate != nil && dropDelegate!.responds(to: #selector(NSDraggingDestination.draggingUpdated(_:))) {
            
            return dropDelegate!.draggingUpdated!(sender)
            
        } else {
            
            if !hasValidFiles(sender) {
                return NSDragOperation()
            } else {
                return defaultDragOperation
            }
            
        }
        
    }
    
    override func draggingExited(_ sender: NSDraggingInfo?) {
        
        if dropDelegate != nil && dropDelegate!.responds(to: #selector(NSDraggingDestination.draggingExited(_:))) {
            
            dropDelegate!.draggingExited!(sender!)
            
        }
        
    }
    
    override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        
        if dropDelegate != nil && dropDelegate!.responds(to: #selector(NSDraggingDestination.prepareForDragOperation(_:))) {
            
            return dropDelegate!.prepareForDragOperation!(sender)
            
        }
        
        return true
        
    }

    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        
        if let del = dropDelegate {
            return dropDelegate!.performDragOperation(sender)
        }
        
        return true
        
    }
 
}
