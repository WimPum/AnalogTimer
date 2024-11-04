// from https://zenn.dev/ikeh1024/articles/815b9e6fd6609f

// 段階が見れるようにできたらする

import SwiftUI

struct IntSlider<Label>: View where Label: View {
    
    @Binding private var value: Int
    
    private let bounds: ClosedRange<Double>
    private let step: Int
    private let label: () -> Label
        
    private var intProxy: Binding<Double> {
        Binding<Double>(
            get: {
                Double(value)
            }, set: {
                value = Int($0)
            })
    }
    
    var body: some View {
        
        Slider(value: self.intProxy,
               in: self.bounds,
               step: Double.Stride(self.step)) {
            label()
        } minimumValueLabel: {
            Text("\(Int(self.bounds.lowerBound))")
        } maximumValueLabel: {
            Text("\(Int(self.bounds.upperBound))")
        }
    }
    
    init(
        value: Binding<Int>,
        in bounds: ClosedRange<Double> = 0...10,
        step: Int = 0,
        @ViewBuilder label: @escaping () -> Label = { EmptyView() }
    ) {
        self._value = value
        self.bounds = bounds
        self.step = step
        self.label = label
    }
}

//#Preview {
//    @State var refreshRate = 50
//    
//    return IntSlider(value: $refreshRate,
//                     in: 45...120,
//                     step: 5) {
//        Text("Refresh rate")
//    }.padding()
//}
