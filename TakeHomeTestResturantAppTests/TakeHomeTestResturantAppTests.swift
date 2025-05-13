//
//  TakeHomeTestResturantAppTests.swift
//  TakeHomeTestResturantAppTests
//
//  Created by Matthew Simoni on 5/2/25.
//

import Testing
@testable import TakeHomeTestResturantApp

struct TakeHomeTestResturantAppTests {

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }
    
    @Test func verifyLoader() async throws {
        let recipeController = RecipeController()
        let _ = Task {
            await recipeController.asyncFetchRecipes()
        }
    }

}
