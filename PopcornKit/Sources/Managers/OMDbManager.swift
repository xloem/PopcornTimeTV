//
//  OMDb.swift
//  
//
//  Created by Alexandru Tudose on 07.08.2021.
//

import Foundation

open class OMDbManager: NetworkManager {
    
    /// Creates new instance of OMDbManager class
    public static let shared = OMDbManager()
    
    
    func loadInfo(imdbId: String, completion: @escaping (OMDbMedia?, Error?) -> Void) {
        var params = OMDb.defaultParameters
        params[OMDb.info] = imdbId
        
        self.manager.request(OMDb.base, method: .get, parameters: params).validate().responseData { response in
            guard let value = response.result.value else {
                completion(nil, response.result.error)
                return
            }
            
            let media = try? JSONDecoder().decode(OMDbMedia.self, from: value)
            completion(media, nil)
        }
    }
    
    open func loadCachedInfo(imdbId: String, completion: @escaping (OMDbMedia?, Error?) -> Void) {
        let key = "ombd/\(imdbId)"
        if let data = UserDefaults.standard.data(forKey: key),
           let media = try? JSONDecoder().decode(OMDbMedia.self, from: data) {
            completion(media, nil)
        } else {
            loadInfo(imdbId: imdbId) { media, error in
                if let media = media {
                    let data = try? JSONEncoder().encode(media)
                    UserDefaults.standard.setValue(data, forKey: key)
                }
                
                completion(media, error)
            }
        }
    }
}


public struct OMDbMedia: Codable {
    public struct Ratings: Codable {
        public var value: String
        public var source: String
        
        enum CodingKeys: String, CodingKey {
            case value = "Value", source = "Source"
        }
    }
    public var title: String
    public var awards: String
    public var imdbRating: String
    public var metascore: String
    public var ratings: [OMDbMedia.Ratings]
    
    enum CodingKeys: String, CodingKey {
        case title = "Title", awards = "Awards", imdbRating, metascore = "Metascore", ratings = "Ratings"
    }
    
    public func transform() -> PopcornKit.Ratings {
        let item = ratings.first(where: {$0.source == "Rotten Tomatoes"})
        return .init(awards: awards, imdbRating: imdbRating, metascore: metascore, rottenTomatoes: item?.value)
    }
}


//"""
//    "Title": "Guardians of the Galaxy Vol. 2",
//    "Year": "2017",
//    "Rated": "PG-13",
//    "Released": "05 May 2017",
//    "Runtime": "136 min",
//    "Genre": "Action, Adventure, Comedy",
//    "Director": "James Gunn",
//    "Writer": "James Gunn, Dan Abnett, Andy Lanning",
//    "Actors": "Chris Pratt, Zoe Saldana, Dave Bautista",
//    "Plot": "The Guardians struggle to keep together as a team while dealing with their personal family issues, notably Star-Lord's encounter with his father the ambitious celestial being Ego.",
//    "Language": "English",
//    "Country": "United States",
//    "Awards": "Nominated for 1 Oscar. 15 wins & 58 nominations total",
//    "Poster": "https://m.media-amazon.com/images/M/MV5BNjM0NTc0NzItM2FlYS00YzEwLWE0YmUtNTA2ZWIzODc2OTgxXkEyXkFqcGdeQXVyNTgwNzIyNzg@._V1_SX300.jpg",
//    "Ratings": [
//      {
//        "Source": "Internet Movie Database",
//        "Value": "7.6/10"
//      },
//      {
//        "Source": "Rotten Tomatoes",
//        "Value": "85%"
//      },
//      {
//        "Source": "Metacritic",
//        "Value": "67/100"
//      }
//    ],
//    "Metascore": "67",
//    "imdbRating": "7.6",
//    "imdbVotes": "593,526",
//    "imdbID": "tt3896198",
//    "Type": "movie",
//    "DVD": "10 Jul 2017",
//    "BoxOffice": "$389,813,101",
//    "Production": "Marvel Studios, Walt Disney Pictures",
//    "Website": "N/A",
//    "Response": "True"
//"""
