//
//  DynamicStack.swift
//  AnalogTimer
//
//  Created by 虎澤謙 on 2024/11/06.
//

// https://www.swiftbysundell.com/articles/switching-between-swiftui-hstack-vstack/

import SwiftUI

struct DynamicStack<Content: View>: View {
    // 横画面検出(横にしたら縦の大きさ(Vertical)はみんな .compact)
    @Environment(\.verticalSizeClass) private var vSizeClass
    
    // なんでかみんなHorizontalを使うけどできるの？？ randomizerでも使えなかった
//    @Environment(\.horizontalSizeClass) private var vSizeClass
    
    var spacing: CGFloat?
    @ViewBuilder var content: () -> Content // ????????????
    
    var body: some View {
        switch vSizeClass {
        case .regular:
            vStack
        case .compact, .none:
            hStack
        @unknown default:
            vStack
        }
    }
}

private extension DynamicStack {
    var hStack: some View {
        HStack(
            alignment: .center,
            spacing: spacing,
            content: content
        )
    }
    var vStack: some View {
        VStack(
            alignment: .center,
            spacing: spacing,
            content: content
        )
    }
}
    
#Preview {
    DynamicStack{
        Text("A")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.cyan)
        Text("B")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.yellow)
    }
}
