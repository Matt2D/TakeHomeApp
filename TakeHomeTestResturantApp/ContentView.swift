//
//  ContentView.swift
//  TakeHomeTestResturantApp
//
//  Created by Matt2D on 5/2/25.
//

import SwiftUI

struct Response: Decodable{
    let recipes: [Recipe]
}

struct Recipe: Decodable{
    let cuisine: String
    let name: String
    let photo_url_large: String?
    let photo_url_small: String?
    let uuid: String
    let source_url: String?
    let youtube_url: String?
}

struct RemoteImage: View {
    @State private var image: UIImage?
    private let source: URLRequest
    private let imageLoader: ImageLoader
    
    init(source: URL, imageLoader: ImageLoader) {
            self.init(source: URLRequest(url: source), imageLoader: imageLoader)
        }

    init(source: URLRequest, imageLoader: ImageLoader) {
        self.source = source
        self.imageLoader = imageLoader
    }

    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
            } else {
                Rectangle()
                    .background(Color.red)
            }
        }
        .task {
            await loadImage(at: source)
        }
    }

    func loadImage(at source: URLRequest) async {
        do {
            image = try await imageLoader.fetch(source)
        } catch {
            print(error)
        }
    }
}


struct ContentView: View {
    @Environment(\.refresh) private var refresh
//    var body: some View {
//        VStack {
//            Image(systemName: "globe")
//                .imageScale(.large)
//                .foregroundStyle(.tint)
//            Text("Hello, world!")
//        }
//        .padding()
//    }
    private var stringEmptyDisplayMessage : String = "This list is empty due to no recipes being found."
    private var stringErrorDisplayMessage : String = "The recipe list failed to load."
    
    let imageLoader = ImageLoader()
    
    var jsonRequests = ["Correct" : "https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json", "Malformed" : "https://d3jbb8n5wk0qxi.cloudfront.net/recipes-malformed.json", "Empty" : "https://d3jbb8n5wk0qxi.cloudfront.net/recipes-empty.json"]
    
    @State var recipes: [Recipe] = []
    @State var count = 0
    @State private var selectedJson: String = "Correct"
    @State private var currentMessage: String = "No issues"
    
    var body: some View {
        HStack{
            Picker("jsonRequests", selection: $selectedJson){
                ForEach(jsonRequests.sorted(by: >), id: \.key) { key, value in
                    Section(header: Text(key)) {
                        Text(value)
                    }
                }
            }
            Button("Refresh") {
                let _ = print("1")
                let _ = Task {
                    await asyncFetchRecipes()
                }
            }
//            .disabled(refresh == nil)
        }
        let _ = print("RUN")
        if (recipes.count == 0){
            let _ = print("0")
            let _ = Task{
                await asyncFetchRecipes()
            }
            
    
//            let _ = Task{
//                recipes = (try? await                             fetchRecipes()) ?? []
//            }
        }
        
        if recipes.count != 0{
            ScrollView{
                VStack(spacing:10){
                    ForEach(recipes, id: \.name) { recipe in
                        HStack(alignment: .center){
                            VStack(alignment: .center){
                                Text(recipe.name)
                                Text(recipe.cuisine)
                                HStack(alignment: .top, spacing: 10){
                                    if let source = recipe.source_url{
                                        Link(destination: URL(string: source)!){
                                            Image(systemName: "globe").font(.largeTitle)
                                        }
                                    }
                                    
                                    if let youtube = recipe.youtube_url{
                                        Link(destination: URL(string: youtube)!){
                                            Image(systemName: "globe").font(.largeTitle)
                                        }
                                    }
                                }.frame(maxWidth: .infinity)
                            }
                            VStack{
                                if let photo = recipe.photo_url_small{
                                    let photo_url = URL(string: photo)!
                                    RemoteImage(source: photo_url, imageLoader: imageLoader)
  
                                    }
                                    
                                }
                        }
                    }.border(Color.black)
                }
            }
            
        }
        else{
         Text(currentMessage)
        }
    }
    
    func asyncFunc() async {
        let _ = print(count)
        count = count + 1
    }
    
    func asyncFetchRecipes() async {
            do{
                recipes = try await fetchRecipes()
                currentMessage = stringEmptyDisplayMessage;
            }catch{
                currentMessage = stringErrorDisplayMessage;
                recipes = []
            }
    }
    
    func fetchRecipes() async throws -> [Recipe]{
        if let request = jsonRequests[selectedJson]{
            let url = URL(string: request)!
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(Response.self, from: data)
            return response.recipes
        }
        return []
    }
    
}

#Preview {
    ContentView()
}
