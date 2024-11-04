//
//  AboutView.swift
//  Randomizer
//
//  Created by 虎澤謙 on 2024/06/03.
//

import SwiftUI

struct AboutView: View {
    @EnvironmentObject var configStore: SettingsStore
    @EnvironmentObject var randomStore: RandomizerState // 実行中かどうか＋今の出目
    @Binding var isPresented: Bool
    
    // アプリバージョン
    private let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    
    var body: some View {
        VStack(){
            Spacer(minLength: 30)
            Icon()
            Text("Randomizer").font(.system(size: CGFloat(40), weight: .semibold, design: .default))
            //Spacer().frame(height: 100)
            HStack{
                Text("v\(appVersion)").padding(1)
                Text("iOS \(UIDevice.current.systemVersion)").padding(1)
            }
            Text("© 2024 Ulyssa").padding(1)
            Link("MIT License", destination: URL(string: "https://opensource.org/license/mit")!).padding(1)
            Link("feedback", destination: URL(string: "https://forms.gle/aYxcCUKScGAzcp9Q6")!).padding(1)
            HStack{
                Link("Website", destination: URL(string: "https://WimPum.github.io/Rndsite/")!).padding(1)
                Link("View code on GitHub", destination: URL(string: "https://github.com/WimPum/Randomizer")!).padding(1)
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

struct Icon: View {
    @EnvironmentObject var configStore: SettingsStore
    @EnvironmentObject var randomStore: RandomizerState // 実行中かどうか＋今の出目
    let rectSize: CGFloat = 160
    var body: some View{
        ZStack(){
            if #available(iOS 17, *){
                RoundedRectangle(cornerRadius: CGFloat(rectSize/6.4*1.5))
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: configStore.giveBackground()),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: rectSize, height: rectSize)
                    .animation(.easeInOut, value: configStore.giveBackground())
            } else {
                AnimGradient(gradient: Gradient(colors: configStore.giveBackground()))
                    .frame(width: rectSize, height: rectSize)
                    .clipShape(RoundedRectangle(cornerRadius: CGFloat(rectSize / 6.4 * 1.5)))
                    .animation(.easeInOut, value: configStore.giveBackground())
            }
            VStack(){
                Text("No.\(randomStore.drawCount)")
                    .fontLight(size: 18)
                    .frame(height: 18)
                    //.border(.yellow)
                Spacer().frame(height: 0.1)
                Text(verbatim: "\(randomStore.rollDisplaySeq![randomStore.rollListCounter-1])")
                    .fontSemiBoldRound(size: 88, rolling: randomStore.isTimerRunning)
                    .frame(width: rectSize, height:83)
                    .minimumScaleFactor(0.2)
                    //.border(.yellow)
                Spacer().frame(height: 0.1)
                HStack(){
                    Text("Next")
                        .fontSemiBold(size: 18)
                        .padding(2)
                        .frame(width: 55, height: 30)
                        .glassIconMaterial(cornerRadius: 8)
                    Spacer().frame(width: 18)
                    Text("Reset")
                        .fontSemiBold(size: 18)
                        .padding(2)
                        .frame(width: 55, height: 30)
                        .glassIconMaterial(cornerRadius: 8)
                }
            }
        }
        
    }
}

//#Preview {
//    AboutView()
//        .environmentObject(SettingsStore())
//}
