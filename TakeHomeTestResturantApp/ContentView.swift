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
                            
                            if let photo = recipe.photo_url_small{
                                Text(photo).frame(maxWidth: .infinity)
                            }
//                            let _ = Task{await asyncFunc()}
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
//        let _ = print("HERE")
        if let request = jsonRequests[selectedJson]{
            let url = URL(string: request)!
            let (data, _) = try await URLSession.shared.data(from: url)
    //        let _ = print(data)
            let response = try JSONDecoder().decode(Response.self, from: data)
    //        let _ = print("TEST")
    //        let _ = print(response)
            return response.recipes
        }
        return []
    }
}

#Preview {
    ContentView()
}
