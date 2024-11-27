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
import FirebaseRemoteConfig
import UIKit

class AIIntegration {

    // Get the OpenAI API Key and Base URL from the environment variables (.xcconfig)
    let remoteConfig = RemoteConfig.remoteConfig()

        init() {
            // Set default values if necessary
            let defaults: [String: NSObject] = [
                "OPENAI_API_KEY": "default_key" as NSObject,
                "OPENAI_API_BASE": "https://api.openai.com/v1" as NSObject
            ]

            remoteConfig.setDefaults(defaults)

            // Fetch remote config values
            fetchRemoteConfig()
        }

        func fetchRemoteConfig() {
            let settings = RemoteConfigSettings()
            remoteConfig.configSettings = settings

            // Fetch the config data from Firebase
            remoteConfig.fetch { [weak self] (status, error) in
                if status == .success {
                    self?.remoteConfig.activate { _, _ in
                        print("Remote config fetched and activated.")
                    }
                } else {
                    print("Error fetching remote config: \(String(describing: error))")
                }
            }
        }

        var openai_api_key: String {
            return remoteConfig["OPENAI_API_KEY"].stringValue ?? ""
        }

        var openai_api_base: String {
            return remoteConfig["OPENAI_API_BASE"].stringValue ?? ""
        }

    let model_name = "qwen2-vl-7b"  // This can also come from .xcconfig if necessary

    // AI Analysis Function
    func someOAIstuff(url: [String], prompt: String) async -> String? {
        // Debug: Ensure the base URL and API key are correct
        print("OpenAI API Base URL: \(openai_api_base)")  // Should be "https://api.openai.com/v1"
        print("OpenAI API Key: \(openai_api_key)")  // Should not print in production for security reasons
        print("Model Name: \(model_name)")
        
        let service = OpenAIServiceFactory.service(apiKey: .apiKey(openai_api_key), baseURL: openai_api_base)
        
        guard let imageURL = URL(string: url[0]) else {
            print("Invalid image URL: \(url[0])")
            return nil
        }
        
        print("Image URL: \(imageURL.absoluteString)")
        
        let messageContent: [ChatCompletionParameters.Message.ContentType.MessageContent] = [
                    .text(prompt),
                    .imageUrl(.init(url: imageURL, detail: "high"))
                ]   
        
        let parameters = ChatCompletionParameters(
            messages: [.init(role: .user, content: .contentArray(messageContent))],
            model: .custom(model_name)
        )
        
        print("Parameters being sent to OpenAI: \(parameters)")
        
        do {
            let chatStream = try await service.startStreamedChat(parameters: parameters)
            
            var fullResponse = ""
            for try await chunk in chatStream {
                if let content = chunk.choices.first?.delta.content {
                    fullResponse += content
                    print("Received chunk: \(content)") // Print each response chunk for debugging
                }
            }
            
            print("Full AI Response: \(fullResponse)")
            
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
