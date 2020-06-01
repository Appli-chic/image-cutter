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
    let onChange : () -> Void
    @Binding var value : Int

    var body: some View {
        return TextField("", text: $enteredValue)
            .onReceive(Just(enteredValue)) { typedValue in
                let newValue = typedValue.trimmingCharacters(in: CharacterSet(charactersIn: "0123456789.").inverted)
                var intValue = Int(newValue)
                
                if intValue == 0 {
                    intValue = 1
                }
                
                self.enteredValue = newValue
                
                if self.value != intValue {
                    self.value = intValue ?? 1
                    self.onChange()
                } else {
                    self.value = intValue ?? 1
                }
        }.onAppear(perform:{self.enteredValue = "\(self.value)"})
    }
}
