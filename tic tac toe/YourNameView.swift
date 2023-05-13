//
//  YourNameView.swift
//  tic tac toe
//
//  Created by Ash on 13/05/2023.
//

import SwiftUI

struct YourNameView: View {
    @AppStorage("yourName") var yourName = ""
    @State private var userName = ""
    
    var body: some View {
        VStack {
            Text("Please enter a name that will be associated to your device when looking for other players")
            TextField("Your name", text: $userName)
                .textFieldStyle(.roundedBorder)
            Button("Set") {
                yourName = userName
            }
            .buttonStyle(.borderedProminent)
            .disabled(userName.isEmpty)
        }
        .padding()
        .navigationTitle("Tic tae toe")
        .inNavigationStack()
    }
}

struct YourNameView_Previews: PreviewProvider {
    static var previews: some View {
        YourNameView()
    }
}
