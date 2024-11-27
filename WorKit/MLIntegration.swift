import UIKit

class MLIntegrationService {
    
    // Function to send an image to the FastAPI server and handle the result
    func sendImageToServer(image: UIImage, completion: @escaping (String?) -> Void) {
        // Define the FastAPI endpoint
        guard let url = URL(string: "https://obviously-generous-amoeba.ngrok-free.app/analyze/") else {
            print("Invalid URL")
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Generate a unique boundary for the multipart request
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Prepare the image data for upload
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Failed to convert image to JPEG format")
            completion(nil)
            return
        }
        
        // Create multipart form data body
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        // Send the request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error sending request: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            // Parse the response
            if let data = data, let responseDict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                completion(responseDict["ai_analysis"] as? String)
            } else {
                print("Failed to parse response")
                completion(nil)
            }
        }
        
        task.resume()
    }
}


