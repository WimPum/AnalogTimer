//
//  SettingsView.swift
//  Randomizer
//
//  Created by 虎澤謙 on 2023/12/23.
//

import SwiftUI

struct SettingsView: View { // will be called from ContentView
    @EnvironmentObject var configStore: SettingsStore // 設定 アクセスできるはず
    @Binding var isPresentedLocal: Bool
    
    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                Form{
                    SettingsList()
                    Section(header: Text("info")){
                        NavigationLink(destination: AboutView(isPresented: $isPresentedLocal)){
                            Text("About")
                        }
                    }
                }
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing){
                        Button(action: {
                            isPresentedLocal = false
                        }){//どうしよう？
                            Text("Done")
                                .bold()
                                .padding(5)
                        }
                    }
                }
            }
        }
        else {
            NavigationView{//iOS 15用
                Form{
                    SettingsList()
                    Section(header: Text("info")){
                        NavigationLink(destination: AboutView(isPresented: $isPresentedLocal)){
                            Text("About")
                        }
                    }
                }
                .background(Color(.systemGroupedBackground)) // なんでか真っ白になってた randomStore.init()のせい
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing){
                        Button(action: {
                            isPresentedLocal = false
                        }){//どうしよう？
                            Text("Done")
                                .bold()
                                .padding(5)
                        }
                    }
                }
            }
        }
    }
}

struct SettingsList: View{
    @EnvironmentObject var configStore: SettingsStore // EnvironmentObjectだから引数なしでいいよね。。。？
    
    var body: some View {
        Section(header: Text("general")){
            Toggle("Haptics", isOn: $configStore.isHapticsOn)
//            Toggle("Enable snapping", isOn: $configStore.isSnappEnabled)
            Toggle("Enable Alarm", isOn: $configStore.isAlarmEnabled)
            Picker("Background color", selection: $configStore.configBgNumber){ // selectionにはid(string)が含まれる。
                ForEach(0..<configStore.colorList.count, id: \.self) { index in
                    Text(LocalizedStringKey(configStore.colorList[index].name))
                }
            }
            .onChange(of: configStore.configBgNumber) { _ in
                withAnimation(){
                    configStore.giveRandomBgNumber()
                }
            }
            Button("Reset setting", action:{
                configStore.resetSettings()
            })
        }
    }
}
