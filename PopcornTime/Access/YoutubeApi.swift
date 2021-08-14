//
//  YoutubeApi.swift
//  PopcornTime
//
//  Created by Alexandru Tudose on 04.08.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import Foundation

//https://stackoverflow.com/questions/67615278/get-video-info-youtube-endpoint-suddenly-returning-404-not-found/67629882#67629882
class YoutubeApi {
    struct Video: Decodable {
        struct Streaming: Decodable {
            struct Formats: Decodable {
                var url: URL
                var qualityLabel: String
                var width: Int
            }
            var formats: [Formats]
        }
        
        var streamingData: Streaming
    }
    
    static func getVideo(id: String, completion: @escaping (_ video: Video?, _ error: Error?) -> Void) {
        let body = """
            {
             "context": {
               "client": {
                "hl": "en",
                "clientName": "WEB",
                "clientVersion": "2.20210721.00.00",
                "mainAppWebInfo": {
                    "graftUrl": "/watch?v={VIDEO_ID}"
                }
               }
              },
              "videoId": "{VIDEO_ID}"
            }
            """.replacingOccurrences(of: "{VIDEO_ID}", with: id)
        let url = "https://youtubei.googleapis.com/youtubei/v1/player?key=AIzaSyAO_FJ2SlqU8Q4STEHLGCilw_Y9_11qcW8"
        
        let unknowError = NSError(domain: "popcorn", code: 2, userInfo: [NSLocalizedDescriptionKey: "Trailer not found!".localized])
        
        if var request = try? URLRequest(url: url, method: .post) {
            request.httpBody = body.data(using: .utf8)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    do {
                        if let data = data {
                            let video = try JSONDecoder().decode(Video.self, from: data)
                            completion(video, nil)
                        } else {
                            completion(nil, unknowError)
                        }
                    } catch let error {
                        completion(nil, error)
                    }
                }
            }.resume()
        } else {
            completion(nil, unknowError)
        }
        
    }
}
