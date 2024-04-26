//
//  ContentView.swift
//  CryptoAsyncAwait
//
//  Created by Stephan Dowless on 1/5/23.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    @State private var showAlert = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.coins) { coin in
                    CoinRowView(coin: coin)
                }
            }
            .navigationTitle("Live Prices")
        }
        .onReceive(viewModel.$error, perform: { error in
            if error != nil{
                showAlert.toggle()
            }
        })
        .alert(isPresented: $showAlert, content: {
            Alert(title: Text("Error"), 
                  message: Text(viewModel.error?.localizedDescription ?? "")
            )
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
