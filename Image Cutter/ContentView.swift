//
//  ContentView.swift
//  Image Cutter
//
//  Created by Lazyos on 5/31/20.
//  Copyright © 2020 Lazyos. All rights reserved.
//

import SwiftUI
import CoreImage

struct ContentView: View {
    @State var selectedName = ""
    @State var image = NSImage()
    @State var oldImage = NSImage()
    @State var blockWidth: Int = 1
    @State var blockHeight: Int = 1
    
    var body: some View { 
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 8.0) {
                HStack(alignment: .center) {
                    Button(
                        "Select image",
                        action: self.onSelectImage
                    )
                    Text(self.selectedName)
                }.padding([.top, .leading, .trailing], 8.0)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                HStack(alignment: .center) {
                    Text("Block width: ")
                    NumberEntryField(value: self.$blockWidth)
                        .padding(.leading, 5.0)
                        .frame(width: 55.0)
                }.padding([.top, .leading, .trailing], 8.0)
                HStack(alignment: .center) {
                    Text("Block height: ")
                    NumberEntryField(value: self.$blockHeight)
                        .frame(width: 50.0)
                    Button(
                        "Cut image",
                        action: self.onCutImage
                    ).frame(maxWidth: .infinity, alignment: .trailing)
                }.padding([.top, .leading, .trailing], 8.0)
                Image(nsImage: self.image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width)
            }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
        }
    }
    
    func onSelectImage() {
        let panel = NSOpenPanel()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let result = panel.runModal()
            if result == .OK {
                self.selectedName = panel.url!.lastPathComponent
                self.image = NSImage(contentsOf: panel.url!)!
                self.oldImage = NSImage(contentsOf: panel.url!)!
                self.addLines()
            }
        }
    }
    
    func onCutImage() {
        let desktopURL = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first!
//        let folderPath = desktopURL.appendingPathComponent("images")
        let size = image.size
        var index = 0
        
        // Cut and save each images
        for i in 0...(Int(size.width) / self.blockWidth) {
            for j in 0...(Int(size.height) / self.blockHeight) {
                let destinationURL = desktopURL.appendingPathComponent("img\(index).png")
                
                let cgImage = self.oldImage.cgImage(forProposedRect: nil, context: NSGraphicsContext(), hints: nil)?.cropping(to: CGRect(x: i * self.blockWidth, y: j * self.blockHeight, width: self.blockWidth, height: self.blockHeight))
                let image = NSImage(cgImage:cgImage!, size: NSSize(width: self.blockWidth, height: self.blockHeight))
                
                if image.pngWrite(to: destinationURL, options: .withoutOverwriting) {
                    print("File saved")
                }
                
                index+=1
            }
        }
    }
    
    func addLines() {
        let size = image.size
        
        // Add vertical lines
        for i in 0...(Int(size.width) / self.blockWidth) {
            addLine(isVertical: true, x: i * self.blockWidth, y: 0)
        }
        
        // Add Horizontal lines
        for i in 0...(Int(size.height) / self.blockHeight) {
            addLine(isVertical: false, x: 0, y: i * self.blockHeight)
        }
    }
    
    func addLine(isVertical: Bool, x: Int, y: Int) {
        let size = image.size
        
        self.image.lockFocus()

        NSColor.red.setStroke()
        
        if isVertical {
            NSBezierPath.strokeLine(
                from: NSPoint(x: x, y: 0),
                to: NSPoint(x: x, y: Int(size.height))
            )
        } else {
            NSBezierPath.strokeLine(
                from: NSPoint(x: 0, y: y),
                to: NSPoint(x: Int(size.width), y: y)
            )
        }

        self.image.unlockFocus()
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
    }
}

extension NSImage {
    var pngData: Data? {
        guard let tiffRepresentation = tiffRepresentation, let bitmapImage = NSBitmapImageRep(data: tiffRepresentation) else { return nil }
        return bitmapImage.representation(using: .png, properties: [:])
    }
    func pngWrite(to url: URL, options: Data.WritingOptions = .atomic) -> Bool {
        do {
            try pngData?.write(to: url, options: options)
            return true
        } catch {
            print(error)
            return false
        }
    }
}
