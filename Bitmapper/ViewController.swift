//
//  ViewController.swift
//  Bitmapper
//
//  Created by Alex on 01-03-15.
//  Copyright (c) 2015 Balancing Rock. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, DropZoneDelegate {

    @IBOutlet var dropView: DropZoneView!
    @IBOutlet weak var imageView: NSImageView!
    @IBOutlet var textView: NSTextView!
    @IBOutlet weak var dragHereLabel: NSTextField!
    @IBOutlet weak var bitsBox: NSComboBox!
    @IBOutlet weak var checkUseProgmem: NSButton!
    
    var selectedImage: NSImage?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // setup dropView
        dropView.registerForFileExtensions(["bmp"])
        dropView.defaultDragOperation = .copy
        dropView.dropDelegate = self
        
    }
    
    override func viewWillAppear() {
        
        // setup textView
        textView.font = NSFont(name: "Menlo", size: 11)
        
        let defaults = UserDefaults.standard
        checkUseProgmem.state = defaults.integer(forKey: "Use Progmem")
        bitsBox.integerValue = defaults.integer(forKey: "Bits per Pixels")
    }
    
    override func viewWillDisappear()
    {
        let defaults = UserDefaults.standard
      
        defaults.set(checkUseProgmem.state, forKey: "Use Progmem")
        defaults.set(bitsBox.integerValue, forKey: "Bits per Pixels")
        
        // Use this to clear the defaults..
        //UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        //UserDefaults.standard.synchronize()
    }
    
    override func viewDidDisappear()
    {
        exit(0);
        
    }
    
    fileprivate func getImageFromURL(_ url: URL) {
        
        if url.pathExtension == "bmp" {
            
            // change selectedImage
            selectedImage = NSImage(contentsOf: url)
            
            // UI
            imageView.image = selectedImage
            dragHereLabel.isHidden = true
            
            // update window title
            view.window!.title = "Bitmap to C array: \(url.lastPathComponent) (width: \(Int(selectedImage!.size.width)) height: \(Int(selectedImage!.size.height)))"
            
        }

    }
    
    fileprivate func valueForColor(_ color: NSColor) -> Int {
        
        // if it is dark, return 1, and if it is light, return 0
        return color.whiteComponent < 0.5 ? 1 : 0
        
    }
    
    func performDragOperation(_ info: NSDraggingInfo) -> Bool {
        
        let urls = DropZoneView.fileUrlsFromDraggingInfo(info)
        
        if urls != nil && urls!.count > 0 {
            
            getImageFromURL(urls![0])
            
        }
        
        return true
        
    }
    
    @IBAction func convertBitmapToCHorizontal(_ sender: AnyObject) {
        
        if let img = selectedImage {
            
            // get neccesary data: bitmaprep & dimensions
            let rep = NSBitmapImageRep(data: img.tiffRepresentation!)!
            let height = Int(img.size.height)
            let width = Int(img.size.width)
            let progmem = (checkUseProgmem.state == NSOnState ? "PROGMEM " : "")
        
            // amount of pixel values in one array item
            let bitsPerItem = bitsBox.integerValue
            if bitsPerItem == 0 { return }
            
            // output string
            var output = "// width: \(width) height: \(height) (Horizontal encoding)\n\(progmem)const unsigned char YOUR_NAME[] = {"
            
            // y loop
            for row in 0 ..< height {
                
                output += "\n" // add line break
                var currentValue = 0 // the current array item
                var posInCurrentValue = 0 // current bit in current array item
                
                // x loop
                for col in 0 ..< width {
                    
                    // add 1 or 0 at correct position in currentValue
                    let lsl = bitsPerItem - posInCurrentValue - 1
                    let bit = valueForColor(rep.colorAt(x: col, y: row)!) << lsl
                    currentValue += bit
                    
                    
                    posInCurrentValue += 1
                    
                    if posInCurrentValue == bitsPerItem {
                        
                        // add to output string as hexadecimal with at least two digits, it still looks messy with more than 8 bits per array item
                        let valueString = String(currentValue, radix: 16)
                        output +=  "0x\(valueString.leftPadding(toLength: 2, withPad: "0"))"
                        
                        // if it isn't the last object, add a comma
                        if row != height-1 || col != width-1 { output += ", " }
                        
                        // reset
                        currentValue = 0
                        posInCurrentValue = 0
                        
                    }
                    
                }
                
                
            }
            
            // finish array
            output += "\n\n};"
            
            // show it to the user
            textView.string = output
            
        }
        
    }
    
    @IBAction func convertBitmapToCVertical(_ sender: AnyObject) {
        
        if let img = selectedImage {
            
            // get neccesary data: bitmaprep & dimensions
            let rep = NSBitmapImageRep(data: img.tiffRepresentation!)!
            let height = Int(img.size.height)
            let width = Int(img.size.width)
            let progmem = (checkUseProgmem.state == NSOnState ? "PROGMEM " : "")
            
            // amount of pixel values in one array item
            let bitsPerItem = bitsBox.integerValue
            if bitsPerItem == 0 { return }
            
            // output string
            var output = "// width: \(width) height: \(height) (Vertical encoding)\n\(progmem)const unsigned char YOUR_NAME[] = {"
            
            // y loop
            for col in 0 ..< width {
                
                output += "\n" // add line break
                var currentValue = 0 // the current array item
                var posInCurrentValue = 0 // current bit in current array item
                
                // x loop
                for row in 0 ..< height {
                    
                    // add 1 or 0 at correct position in currentValue
                    let lsl = bitsPerItem - posInCurrentValue - 1
                    let bit = valueForColor(rep.colorAt(x: col, y: row)!) << lsl
                    currentValue += bit
                    
                    
                    posInCurrentValue += 1
                    
                    if posInCurrentValue == bitsPerItem {
                        
                        // add to output string as hexadecimal with at least two digits, it still looks messy with more than 8 bits per array item
                        let valueString = String(currentValue, radix: 16)
                        output +=  "0x\(valueString.leftPadding(toLength: 2, withPad: "0"))"
                        
                        // if it isn't the last object, add a comma
                        if row != height-1 || col != width-1 { output += ", " }
                        
                        // reset
                        currentValue = 0
                        posInCurrentValue = 0
                        
                    }
                    
                }
                
                
            }
            
            // finish array
            output += "\n\n};"
            
            // show it to the user
            textView.string = output
            
        }
        
    }
    
    
/*    @IBAction func convertBitmapToCVertical(_ sender: AnyObject) {
        
        if let img = selectedImage {
            
            // amount of pixel values in one array item
            let bitsPerItem = bitsBox.integerValue
            if bitsPerItem == 0 { return }
            
            // get neccesary data: bitmaprep & dimensions
            let rep = NSBitmapImageRep(data: img.tiffRepresentation!)!
            let bmpHeight = Int(img.size.height)
            let bmpWidth = Int(img.size.width)
            let arrayHeight = Int(ceil(Double(bmpHeight) / Double(bitsPerItem))) * bitsPerItem

            let arrayWidth = Int(ceil(Double(bmpWidth) / Double(bitsPerItem))) * bitsPerItem
            
            // output string
            var output = "// width: \(bmpWidth) height: \(bmpHeight) (vertical encoding)\nPROGMEM const unsigned char YOUR_NAME[] = {"
            
            // y loop
            for col in 0 ..< arrayWidth {
                
                output += "\n" // add line break
                var currentValue = 0 // the current array item
                var posInCurrentValue = 0 // current bit in current array item
                
                // x loop
                for row in 0 ..< arrayHeight {
                    
                    // add 1 or 0 at correct position in currentValue
                    let lsl = bitsPerItem - posInCurrentValue - 1
                    var bit = 0
                    if(col < bmpWidth && row < bmpHeight)
                    {
                        bit = valueForColor(rep.colorAt(x: col, y: row)!) << lsl
                    }
                    currentValue += bit
                    
                    
                    posInCurrentValue += 1
                    
                    if posInCurrentValue == bitsPerItem {
                        
                        // add to output string as hexadecimal with at least two digits, it still looks messy with more than 8 bits per array item
                        let valueString = String(currentValue, radix: 16)
                        output +=  "0x\(valueString.leftPadding(toLength: 2, withPad: "0"))"
                        
                        // if it isn't the last object, add a comma
                        if row != arrayHeight - 1 || col != arrayWidth - 1 { output += ", " }
                        
                        // reset
                        currentValue = 0
                        posInCurrentValue = 0
                    }
                }
                
            }
            
            // finish array
            output += "\n\n};"
            
            // show it to the user
            textView.string = output
            
        }
        
    }
*/

    @IBAction func openFile(_ sender: AnyObject) {
        
        // show open panel
        let panel = NSOpenPanel()
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowsMultipleSelection = false
        panel.allowedFileTypes = ["bmp"]
        
        panel.begin( completionHandler: { (result) -> Void in
            if result == NSFileHandlingPanelOKButton {
                
                self.getImageFromURL(panel.url!)
                
            }
        })
        
    }

    @IBAction func copyOutput(_ sender: AnyObject) {
        
        // copy contents of textView to generalPasteBoard
        let pasteBoard = NSPasteboard.general()
        pasteBoard.declareTypes([NSStringPboardType], owner: nil)
        pasteBoard.setString(textView.string!, forType: NSStringPboardType)
        
    }
}

