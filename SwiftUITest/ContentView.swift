import SwiftUI

// Assuming definition of Post and NetworkManager are available elsewhere

struct ContentView: View {
    @ObservedObject var networkManager = NetworkManager()
    
    // Computed property to group posts by userId
    private var groupedPosts: [Int: [Post]] {
        Dictionary(grouping: networkManager.posts) { $0.userId }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(groupedPosts.keys.sorted(), id: \.self) { userId in
                    Section(header: Text("User \(userId)")) {
                        ForEach(groupedPosts[userId] ?? []) { post in
                            NavigationLink(destination: DualColumnView(post: post)) {
                                Text(post.title)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Posts")
            .onAppear {
                networkManager.fetchPosts()
            }
        }
    }
}




class DualColumnViewModel: ObservableObject {
    @Published var showModal: Bool = false
    @Published var selectedSquareIndex: Int? = nil
    @Published var temporaryImageName: String = "default"
    
    var squareImages: [Int: String] = [
        0: "API Gateway", 1: "EC2", 2: "Service Holder", 3: "Simple Storage Service"
    ]
    
    func updateSquareImage(for index: Int, with imageName: String) {
        DispatchQueue.main.async {
            self.squareImages[index] = imageName
        }
    }
    
    
    func selectSquare(at index: Int) {
        self.selectedSquareIndex = index
        // Ensuring this runs on the main thread, in case there are any threading issues.
        DispatchQueue.main.async {
            self.showModal = true
        }
    }
}

// DualColumnView.swift
struct DualColumnView: View {
    let post: Post
    @StateObject var viewModel = DualColumnViewModel()

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                DetailView(post: post) // Make sure DetailView is defined elsewhere
                    .frame(width: geometry.size.width / 2)
                    .background(Color.gray.opacity(0.2))
                
                VStack {
                    ForEach(Array(viewModel.squareImages.keys.sorted()), id: \.self) { index in
                        // Now using Image(imageName) for loading images from your assets
                        if let imageName = viewModel.squareImages[index] {
                            Image(imageName) // Correctly loading image by name from assets
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .onTapGesture {
                                    viewModel.selectedSquareIndex = index
                                    viewModel.showModal = true
                                }
                                .background(Color.blue.opacity(0.2))
                        }
                    }
                }
                .frame(width: geometry.size.width / 2)
            }
        }
        .sheet(isPresented: $viewModel.showModal) {
            // Ensure ImageSelectionModalView is correctly defined to accept these parameters
            if let selectedIndex = viewModel.selectedSquareIndex {
                ImageSelectionModalView(selectedSquareIndex: selectedIndex, temporaryImageName: $viewModel.temporaryImageName, squareImages: $viewModel.squareImages, viewModel: viewModel)
            }
        }
    }
}

// ImageSelectionModalView.swift
struct ImageSelectionModalView: View {
    var selectedSquareIndex: Int
    @Binding var temporaryImageName: String
    @Binding var squareImages: [Int: String]
    var viewModel: DualColumnViewModel
    
    // Ensure these image names match your assets
    let availableImages: [String] = ["API Gateway", "EC2", "Service Holder", "Simple Storage Service"]
    
    var body: some View {
        VStack {
            Text("Select an Image").font(.headline).padding()
            Divider()
            ScrollView(.horizontal) {
                HStack {
                    ForEach(availableImages, id: \.self) { imageName in
                        // Correctly loading image by name from assets
                        Image(imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .onTapGesture {
                                // This directly updates the square's image in the viewModel
                                viewModel.updateSquareImage(for: selectedSquareIndex, with: imageName)
                                viewModel.showModal = false // Close the modal after selection
                            }
                    }
                }
            }
        }
    }
}





struct ClickableSquare: View {
    @Binding var color: Color
    let action: () -> Void
    
    var body: some View {
        Rectangle()
            .frame(width: 100, height: 100)
            .foregroundColor(color)
            .onTapGesture(perform: action)
    }
}

struct DetailView: View {
    let post: Post

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text(post.title)
                    .font(.title)
                    .padding()
                Text(post.body)
                    .font(.body)
                    .padding()
            }
        }
    }
}

struct ModalView: View {
    var title: String
    @Binding var squareColor: Color
    
    var body: some View {
        VStack {
            Text(title)
                .font(.headline)
                .padding()
            
            Divider()
            
            HStack {
                ForEach([Color.red, Color.green, Color.blue, Color.orange], id: \.self) { color in
                    Rectangle()
                        .frame(width: 50, height: 50)
                        .foregroundColor(color)
                        .onTapGesture {
                            self.squareColor = color
                        }
                }
            }
            .padding()
        }
        .frame(width: 300, height: 200)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 10)
    }
}
