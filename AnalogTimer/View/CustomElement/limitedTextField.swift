//
//  limitedTextField.swift
//  Randomizer
//
//  Created by 虎澤謙 on 2024/03/23.
//

import SwiftUI

struct limitedTextField: View { // 数字用 入力制限をかけられる
    @Binding var value: String
    let placeHolder: String
    let maxLength: Int
    
    var body: some View {
        TextField(placeHolder, text: $value)
            .keyboardType(.numberPad)
            .onChange(of: value) { newValue in
                let filtered = newValue.filter { "0123456789".contains($0) }
                if filtered != newValue {
                    value = filtered
                }
                if value.count > maxLength {
                    value = String(value.prefix(maxLength))
                }
            }
    }
}

//#Preview {
//    limitedTextField(maxLength: 7,)
//}
