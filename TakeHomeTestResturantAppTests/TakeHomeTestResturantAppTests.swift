//
//  TakeHomeTestResturantAppTests.swift
//  TakeHomeTestResturantAppTests
//
//  Created by Matthew Simoni on 5/2/25.
//

import SwiftUI
import Testing
@testable import TakeHomeTestResturantApp

struct ImageLoaderRequestTests {
    
    @Test func verifyCorrectLoader() async throws {
        let recipeController = RecipeController()

        try #require(recipeController.currentMessage == RecipeController().initilizedStringDisplayMessage)
        try #require(recipeController.selectedJson == RecipeController().correctStringJson)
        try #require(recipeController.recipes.count == 0)
        
        await recipeController.asyncFetchRecipes()
        
        #expect(recipeController.recipes.count > 0)
        #expect(recipeController.currentMessage == RecipeController().initilizedStringDisplayMessage)
        
    }
    @Test func verifyEmptyLoader() async throws {
        let recipeController = RecipeController()
        
        try #require(recipeController.currentMessage == RecipeController().initilizedStringDisplayMessage)
        try #require(recipeController.selectedJson == RecipeController().correctStringJson)
        try #require(recipeController.recipes.count == 0)
        
        recipeController.selectedJson = RecipeController().emptyStringJson
        
        await recipeController.asyncFetchRecipes()
        
        #expect(recipeController.recipes.count == 0)
        #expect(recipeController.currentMessage == RecipeController().stringEmptyDisplayMessage)
    }
    
    @Test func verifyMalformedLoader() async throws {
        let recipeController = RecipeController()
        
        try #require(recipeController.currentMessage == RecipeController().initilizedStringDisplayMessage)
        try #require(recipeController.selectedJson == RecipeController().correctStringJson)
        try #require(recipeController.recipes.count == 0)
        
        recipeController.selectedJson = RecipeController().malformedStringJson
        
        await recipeController.asyncFetchRecipes()
        
        #expect(recipeController.recipes.count == 0)
        #expect(recipeController.currentMessage == RecipeController().stringErrorDisplayMessage)
    }
    
    @Test func verifyChangeInLoader() async throws {
        let recipeController = RecipeController()
        
        try #require(recipeController.currentMessage == RecipeController().initilizedStringDisplayMessage)
        try #require(recipeController.selectedJson == RecipeController().correctStringJson)
        try #require(recipeController.recipes.count == 0)
        
        await recipeController.asyncFetchRecipes()
        
        #expect(recipeController.recipes.count > 0)
        #expect(recipeController.currentMessage == RecipeController().initilizedStringDisplayMessage)
        
        //Checks the empty attempt on selection
        recipeController.selectedJson = RecipeController().emptyStringJson
        
        await recipeController.asyncFetchRecipes()
        
        #expect(recipeController.recipes.count == 0)
        #expect(recipeController.currentMessage == RecipeController().stringEmptyDisplayMessage)
        
        //Checks the malformed attempt on selection
        recipeController.selectedJson = RecipeController().malformedStringJson
        
        await recipeController.asyncFetchRecipes()
        
        #expect(recipeController.recipes.count == 0)
        #expect(recipeController.currentMessage == RecipeController().stringErrorDisplayMessage)
        
        //Checks the correct refresh returns properly
        recipeController.selectedJson = RecipeController().correctStringJson
        
        await recipeController.asyncFetchRecipes()
        
        #expect(recipeController.recipes.count > 0)
        #expect(recipeController.currentMessage == RecipeController().initilizedStringDisplayMessage)
    }

}

struct ImageLoaderCacheTests {
    
    func compareImages(image1: UIImage, isEqualTo image2: UIImage) -> Bool {
        let data1: Data = image1.jpegData(compressionQuality: 1)!
        let data2: Data = image2.jpegData(compressionQuality: 1)!
        return data1 == data2
    }
    
    @Test func saveImageLoad() async throws {
        let urlString = "https://d3jbb8n5wk0qxi.cloudfront.net/photos/7276e9f9-02a2-47a0-8d70-d91bdb149e9e/small.jpg"
        let imageLoader = ImageLoader()
        
        guard let imageUrl = URL(string: urlString)else {
            assertionFailure("Test URL is no longer valid")
            return
        }
        
        //fetches image from a given URL
        let image = try await imageLoader.fetch(imageUrl)
    
        //Fetches the saved image from file
        let loadedImage = try await imageLoader.imageFromFileSystem(for: URLRequest(url: imageUrl))
        
        #expect(compareImages(image1: image, isEqualTo: loadedImage!))
        
    }
}
