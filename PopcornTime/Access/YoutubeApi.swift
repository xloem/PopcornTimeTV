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
    
    class func getVideo(id: String) async throws -> Video {
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
        let url = URL(string: "https://youtubei.googleapis.com/youtubei/v1/player?key=AIzaSyAO_FJ2SlqU8Q4STEHLGCilw_Y9_11qcW8")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body.data(using: .utf8)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let video = try JSONDecoder().decode(Video.self, from: data)
    
        return video
        
    }
}
