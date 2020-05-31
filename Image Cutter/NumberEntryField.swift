//
//  NumberEntryField.swift
//  Image Cutter
//
//  Created by Lazyos on 5/31/20.
//  Copyright © 2020 Lazyos. All rights reserved.
//
import SwiftUI
import Combine

struct NumberEntryField : View {
    @State private var enteredValue : String = ""
    @Binding var value : Int

    var body: some View {
        return TextField("", text: $enteredValue)
            .onReceive(Just(enteredValue)) { typedValue in
                if var newValue = Int(typedValue) {
                    if newValue == 0 {
                        newValue = 1
                    }
                    
                    self.value = newValue
                }
        }.onAppear(perform:{self.enteredValue = "\(self.value)"})
    }
}
