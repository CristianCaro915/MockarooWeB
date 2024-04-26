//
//  ContentViewModel.swift
//  CryptoAsyncAwait
//
//  Created by Stephan Dowless on 1/5/23.
//

import Foundation

class ContentViewModel: ObservableObject {
    @Published var coins = [Coin]()
    @Published var error: Error?
    
    let BASE_URL = "https://api.coingecko.com/api/v3/coins/"
    
    var urlString: String {
        return  "\(BASE_URL)markets?vs_currency=usd&order=market_cap_desc&per_page=50&page=1&price_change_percentage=24h"
    }
    
    init() {
        //fetchCoinsWithURLSession()
        loadData()
    }
}

// mark. async await
extension ContentViewModel{
    @MainActor //check this is based on swift
    func fetchCoinsAsync() async throws{
        do{
            guard let url = URL(string: urlString) else {
                throw CoinError.invalidURL
                //print("DEBUG: Invalid URL")
                //return
            }
            let (data, response) = try await URLSession.shared.data(from: url) //we will wait for response
            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                throw CoinError.serverError
                //return
            }
            guard let coins = try? JSONDecoder().decode([Coin].self, from: data) else {
                throw CoinError.invalidData
                //return
            }
            self.coins = coins
        } catch{
            self.error = error
        }
    }
    func loadData(){
        Task(priority: .medium){
            try await fetchCoinsAsync()
        }
    }
}

// MARK: - URLSession

extension ContentViewModel {
    func fetchCoinsWithURLSession() {
        guard let url = URL(string: urlString) else {
            print("DEBUG: Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
                        
            DispatchQueue.main.async {
                if let error = error {
                    print("DEBUG: Error \(error)")
                    return
                }
                
                guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                    print("DEBUG: Server error")
                    return
                }
                
                guard let data = data else {
                    print("DEBUG: Invalid data")
                    return
                }
                
                guard let coins = try? JSONDecoder().decode([Coin].self, from: data) else {
                    print("DEBUG: Invalid data")
                    return
                }
                            
                self.coins = coins
            }
        }.resume()
    }
}
