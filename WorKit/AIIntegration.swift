//
//  AIIntegration.swift
//  WorKit
//
//  Created by Ethan Donley on 10/6/24.
//

import Foundation
import SwiftOpenAI
import Firebase
import FirebaseStorage
import UIKit

class AIIntegration {
    
    let openai_api_key = "sk-TzG0Ufez9ZMO7e1ltKvVUA"
    let openai_api_base = "https://oai.cdonley.com/v1"
    let model_name = "qwen2-vl-7b"  

    // AI Analysis Function
    func someOAIstuff(url: [String], prompt: String) async -> String? {
        let service = OpenAIServiceFactory.service(apiKey: .apiKey(openai_api_key), baseURL: openai_api_base)
        
        guard let imageURL = URL(string: url[0]) else {
            print("Invalid image URL")
            return nil
        }
        
        let messageContent: [ChatCompletionParameters.Message.ContentType.MessageContent] = [
            .text(prompt),
            .imageUrl(.init(url: imageURL))
        ]
        
        let parameters = ChatCompletionParameters(
            messages: [.init(role: .user, content: .contentArray(messageContent))],
            model: .custom(model_name)  // Use the correct model for AI analysis
        )
        
        do {
            // Start the streamed chat and iterate through the response stream
            let chatStream = try await service.startStreamedChat(parameters: parameters)
            
            // Collect the full response from the stream
            var fullResponse = ""
            
            for try await chunk in chatStream {
                // Each chunk contains a part of the response
                if let content = chunk.choices.first?.delta.content {
                    fullResponse += content
                }
            }
            
            return fullResponse.isEmpty ? "No valid response from AI" : fullResponse
            
        } catch {
            print("Error performing AI analysis: \(error)")
            return nil
        }
    }

    // Helper function to upload image to Firebase and get a URL
    func uploadImageToFirebase(_ image: UIImage, completion: @escaping (String?) -> Void) {
        let storageRef = Storage.storage().reference().child("images/\(UUID().uuidString).jpg")
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Failed to convert image to data")
            completion(nil)
            return
        }
        
        storageRef.putData(imageData, metadata: nil) { (metadata, error) in
            guard error == nil else {
                print("Failed to upload image: \(error!.localizedDescription)")
                completion(nil)
                return
            }
            
            storageRef.downloadURL { (url, error) in
                guard let url = url else {
                    print("Failed to get download URL: \(error!.localizedDescription)")
                    completion(nil)
                    return
                }
                completion(url.absoluteString)
            }
        }
    }
}
