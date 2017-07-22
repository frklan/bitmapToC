//
//  StringExtention.swift
//  Bitmapper
//
//  Created by Fredrik Andersson on 2017-07-22.
//  Copyright © 2017 Fredrik Andersson. All rights reserved.
//
//  Copied from https://stackoverflow.com/questions/32338137/padding-a-swift-string-for-printing

import Foundation

extension String {
    func leftPadding(toLength: Int, withPad character: Character) -> String {
        let newLength = self.characters.count
        if newLength < toLength {
            return String(repeatElement(character, count: toLength - newLength)) + self
        } else {
            return self.substring(from: index(self.startIndex, offsetBy: newLength - toLength))
        }
    }
}

