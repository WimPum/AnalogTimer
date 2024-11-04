//
//  AboutView.swift
//  Randomizer
//
//  Created by 虎澤謙 on 2024/06/03.
//

import SwiftUI

struct AboutView: View {
    @EnvironmentObject var configStore: SettingsStore
    @Binding var isPresented: Bool
    
    // アプリバージョン
    private let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    
    var body: some View {
        VStack(){
            Spacer(minLength: 30)
            Text("AnalogTimer").font(.system(size: CGFloat(40), weight: .semibold, design: .default))
            //Spacer().frame(height: 100)
            HStack{
                Text("v\(appVersion)").padding(1)
                Text("iOS \(UIDevice.current.systemVersion)").padding(1)
            }
            Text("© 2024 Ulyssa").padding(1)
//            Link("MIT License", destination: URL(string: "https://opensource.org/license/mit")!).padding(1)
            Link("feedback", destination: URL(string: "https://forms.gle/aYxcCUKScGAzcp9Q6")!).padding(1)
            HStack{
                Link("Website", destination: URL(string: "https://wimpum.github.io/Stuffs.html")!).padding(1)
                Link("View code on GitHub", destination: URL(string: "https://github.com/WimPum/AnalogTimer")!).padding(1)
            }
            Spacer()
        }.toolbar {
            ToolbarItem(placement: .topBarTrailing){
                Button(action: {
                    isPresented = false
                }){//どうしよう？
                    Text("Done")
                        .bold()
                        .padding(5)
                }
            }
        }
    }
}

//#Preview {
//    AboutView()
//        .environmentObject(SettingsStore())
//}
