//
//  ContentView.swift
//  TakeHomeTestResturantApp
//
//  Created by Matt2D on 5/2/25.
//

import SwiftUI

//Representation of a typical jsonRequest for recipe list
struct Response: Decodable{
    let recipes: [Recipe]
}

//Representation of a typical recipe
struct Recipe: Decodable{
    let cuisine: String
    let name: String
    let photo_url_large: String?
    let photo_url_small: String?
    let uuid: String
    let source_url: String?
    let youtube_url: String?
}

// A view around a image aquired via remote request
struct RemoteImage: View {
    @State private var image: UIImage?
    private let source: URLRequest
    private let imageLoader: ImageLoader
    
    /**
     Initialzation of the image through URL
     Args:
        source : The requested URL
        imageLoader: The actor responsible for managing images
     **/
    init(source: URL, imageLoader: ImageLoader) {
            self.init(source: URLRequest(url: source), imageLoader: imageLoader)
        }
    
    /**
     Initialzation of the image through URLRequest
     Args:
        source : The requested URL
        imageLoader: The actor responsible for managing images
     **/
    init(source: URLRequest, imageLoader: ImageLoader) {
        self.source = source
        self.imageLoader = imageLoader
    }

    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image).resizable().scaledToFit()
            } else {
                Rectangle()
                    .background(Color.red)
            }
        }
        .task {
            await loadImage(at: source)
        }
    }
    
    /**
     Loads the images from the given URLRequest
     Args:
        source : The requested URL
     **/
    func loadImage(at source: URLRequest) async {
        do {
            image = try await imageLoader.fetch(source)
        } catch {
            print(error)
        }
    }
}


class RecipeController: ObservableObject {
    var stringEmptyDisplayMessage : String = "This list is empty due to no recipes being found."
    var stringErrorDisplayMessage : String = "The recipe list failed to load."
    var initilizedStringDisplayMessage : String = "No issues"
    
    var correctStringJson : String = "Correct"
    var emptyStringJson : String = "Empty"
    var malformedStringJson : String = "Malformed"
    
    
    var jsonRequests: Dictionary<String, String>
    
    
    
    @Published var recipes: [Recipe] = []
    @Published var currentMessage: String
    @Published var selectedJson: String
    
    init(){
        self.currentMessage = initilizedStringDisplayMessage
        self.selectedJson = correctStringJson
        self.jsonRequests = [correctStringJson : "https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json", malformedStringJson : "https://d3jbb8n5wk0qxi.cloudfront.net/recipes-malformed.json", emptyStringJson : "https://d3jbb8n5wk0qxi.cloudfront.net/recipes-empty.json"]
        
        let _ = Task {
            await asyncFetchRecipes()
        }
    }
    
    /**
        Asyncronous call to find recipes
     Results:
            An updated recipe list, or error and correct message describing situation
     **/
    @MainActor func asyncFetchRecipes() async {
            do{
                recipes = try await fetchRecipes()
                if(recipes.count > 0) {
                    currentMessage = initilizedStringDisplayMessage;
                }else{
                    currentMessage = stringEmptyDisplayMessage;
                }
            }catch{
                currentMessage = stringErrorDisplayMessage;
                recipes = []
            }
    }
    
    /**
     Attempts a jsonRequest to load recipes
        Returns:
                A list of decoded recipes
     **/
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


struct ContentView: View {
    @Environment(\.refresh) private var refresh

    let imageLoader = ImageLoader()
    @ObservedObject var recipeController = RecipeController()
    
    var body: some View {
    
        HStack{
            Picker("Selected Data", selection: $recipeController.selectedJson){
                ForEach(recipeController.jsonRequests.sorted(by: >), id: \.key) { key, value in
                    Section(header: Text(key)) {
                        Text(value)
                    }
                }
            }
            Button("Refresh") {
                let _ = Task {
                    await recipeController.asyncFetchRecipes()
                }
            }
        }
        if recipeController.recipes.count != 0{
            ScrollView{
                VStack(spacing:10){
                    ForEach(recipeController.recipes, id: \.name) { recipe in
                        HStack(alignment: .center){
                            VStack(alignment: .center){
                                Text(recipe.name)
                                Text("Cuisine: " + recipe.cuisine)
                                HStack(alignment: .top, spacing: 10){
                                    if let source = recipe.source_url{
                                        Link(destination: URL(string: source)!){
                                            Image(systemName: "globe").font(.largeTitle)
                                        }
                                    }
                                    
                                    if let youtube = recipe.youtube_url{
                                        Link(destination: URL(string: youtube)!){
                                            Image("YT_Logo").resizable().frame(width: 40, height: 40)
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
            Text(recipeController.currentMessage)
        }
    }
    
}

#Preview {
    ContentView()
}
