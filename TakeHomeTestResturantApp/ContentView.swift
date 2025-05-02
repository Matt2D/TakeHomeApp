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

//    var body: some View {
//        VStack {
//            Image(systemName: "globe")
//                .imageScale(.large)
//                .foregroundStyle(.tint)
//            Text("Hello, world!")
//        }
//        .padding()
//    }
    
    @State var recipes: [Recipe] = []
    @State var count = 0
    
    var body: some View {
        let _ = print("RUN")
        if recipes.count == 0{
            let _ = Task{
                recipes = (try? await fetchRecipes()) ?? []
            }
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
                            let _ = Task{await asyncFunc()}
                        }
                    }.border(Color.black)
                }
            }
        }
    }
    
    func asyncFunc() async {
        let _ = print(count)
        count = count + 1
    }
    
    func fetchRecipes() async throws -> [Recipe]{
//        let _ = print("HERE")
        let url = URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json")!
        let (data, _) = try await URLSession.shared.data(from: url)
//        let _ = print(data)
        let response = try JSONDecoder().decode(Response.self, from: data)
//        let _ = print("TEST")
//        let _ = print(response)
        return response.recipes
    }
}

#Preview {
    ContentView()
}
