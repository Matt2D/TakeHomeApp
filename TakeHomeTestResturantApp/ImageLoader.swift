//
//  ImageLoader.swift
//  TakeHomeTestResturantApp
//
//  Created by Matthew Simoni on 5/6/25.
//
// Based on:
// https://www.donnywals.com/using-swifts-async-await-to-build-an-image-loader/

import SwiftUI

actor ImageLoader {
    private var images: [URLRequest: LoaderStatus] = [:]

    /**
     Fetches the image from the given URL
     Args:
        url: The requested URL
     Returns:
            The fetched UI image
     **/
    public func fetch(_ url: URL) async throws -> UIImage {
        let request = URLRequest(url: url)
        return try await fetch(request)
    }

    /**
     Fetches the image from the given URLRequest
     Args:
        urlRequest : The requested URLRequest
     Returns:
            The fetched UI image
     **/
    public func fetch(_ urlRequest: URLRequest) async throws -> UIImage {
        if let status = images[urlRequest] {
            switch status {
            case .fetched(let image):
                return image
            case .inProgress(let task):
                return try await task.value
            }
        }
        if let image = try? self.imageFromFileSystem(for: urlRequest) {
            images[urlRequest] = .fetched(image)
            return image
        }

        let task: Task<UIImage, Error> = Task {
            let (imageData, _) = try await URLSession.shared.data(for: urlRequest)
            let image = UIImage(data: imageData)!
            try self.persistImage(image, for: urlRequest)
            return image
        }

        images[urlRequest] = .inProgress(task)

        let image = try await task.value

        images[urlRequest] = .fetched(image)

        return image
    }

    
    private enum LoaderStatus {
        case inProgress(Task<UIImage, Error>)
        case fetched(UIImage)
    }
    
    /**
        Loads a requested image from the file system
     Args:
        urlRequest: The requested URL
     Returns:
            The fetched UI image
     **/
    public func imageFromFileSystem(for urlRequest: URLRequest) throws -> UIImage? {
        guard let url = fileName(for: urlRequest) else {
            assertionFailure("Unable to generate a local path for \(urlRequest)")
            return nil
        }
        
        guard let data = try? Data(contentsOf: url) else{
            return nil
        }
            
        return UIImage(data: data)
    }
    
    /**
        Returns the filename for a given URLRequest
     Args:
        urlRequest: The requested URL
     Returns:
            The appropriate file name URL
     **/
    private func fileName(for urlRequest: URLRequest) -> URL? {
        guard let fileName = urlRequest.url?.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
              let applicationSupport = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                return nil
                }
        if !FileManager.default.fileExists(atPath: applicationSupport.path) {
                do {
                    try FileManager.default.createDirectory(atPath: applicationSupport.path, withIntermediateDirectories: false, attributes: nil)
                } catch {
                }
        }
        
        //The file path splits on the "photos" folder
        let fileNameArr = fileName.components(separatedBy: "photos/")
        return applicationSupport.appending(path: fileNameArr[1].replacingOccurrences(of: "/", with: "_"))
    }
    
    /**
        Saves a image to the file system for a given urlRequest
     Args:
        image: Image to be saved to file
     urlRequest: The URL Request to be saved alongside
     Results:
            An image saved to file
     **/
    private func persistImage(_ image: UIImage, for urlRequest: URLRequest) throws {
        guard let url = fileName(for: urlRequest),
              let data = image.jpegData(compressionQuality: 1) else {
            assertionFailure("Unable to generate a local path for \(urlRequest)")
            return
        }
        try data.write(to: url)
    }
    
}
