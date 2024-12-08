//
//  Navigations.swift
//  AnalogTimer
//
//  Created by 虎澤謙 on 2024/12/04.
//

// Navigation that works for 15 and up

import SwiftUI

struct Navigations<Content: View>: View {
    @ViewBuilder var content: () -> Content
    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack(root: content)
        } else {
            NavigationView(content: content)
                .background(Color(.systemGroupedBackground)) // なんでか真っ白になってた randomStore.init()のせい
        }
    }
}
