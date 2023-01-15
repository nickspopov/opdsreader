//
//  View+Extension.swift
//  opdsreader
//
//  Created by Николай Попов on 13.01.2023.
//

import SwiftUI

import SwiftUI

extension View {
    func hAlign(_ alignment: Alignment) -> some View {
        self
            .frame(maxWidth: .infinity, alignment: alignment)
    }
    func vAlign(_ alignment: Alignment) -> some View {
        self
            .frame(maxHeight: .infinity, alignment: alignment)
    }
}
