//
//  NetworkManager.swift
//  SwiftUITest
//
//  Created by user252611 on 2/10/24.
//

import Foundation
import Combine

class NetworkManager: ObservableObject {
    // Publishes the posts array so SwiftUI can observe changes
    @Published var posts: [Post] = []
    
    // Function to fetch posts from the API
    func fetchPosts() {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts") else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                // Handle the error appropriately in your app, e.g., by showing an alert
                print("Error fetching posts: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                // Handle the case where there is no data
                print("No data received")
                return
            }
            
            do {
                // Decode the JSON data into the array of Post objects
                let posts = try JSONDecoder().decode([Post].self, from: data)
                DispatchQueue.main.async {
                    // Update the published posts array
                    self?.posts = posts
                }
            } catch {
                // Handle JSON decoding errors
                print("Error decoding JSON: \(error.localizedDescription)")
            }
        }.resume()
    }
    
}


		// this is the struct for the post
struct Post: Decodable, Identifiable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
}
