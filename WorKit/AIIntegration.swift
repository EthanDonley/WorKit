//
//  AIIntegration.swift
//  WorKit
//
//  Created by Ethan Donley on 10/6/24.
//

import Foundation
import SwiftOpenAI

let openai_api_key = "sk-TzG0Ufez9ZMO7e1ltKvVUA"
let openai_api_base = "https://oai.cdonley.com/v1"
let model_name = "qwen2-vl-7b"

func someOAIstuff(url: [String], prompt: String) async {
    let service = OpenAIServiceFactory.service(apiKey: .apiKey(openai_api_key), baseURL: openai_api_base)
    
    let imageURL = URL(string: url[0])
    
    let messageContent: [ChatCompletionParameters.Message.ContentType.MessageContent] = [.text(prompt), .imageUrl(.init(url: imageURL!))] // Users can add as many `.imageUrl` instances to the service.
    
    let parameters = ChatCompletionParameters(messages: [.init(role: .user, content: .contentArray(messageContent))], model: .custom(model_name))
    do {
        let chatCompletionObject = try await service.startStreamedChat(parameters: parameters)
        // return the message
    } catch {
        // Handle any errors
    }
}
