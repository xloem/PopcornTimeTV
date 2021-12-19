
import Foundation
import Alamofire
import ObjectMapper

open class SubtitlesApi {
    
    /// Creates new instance of SubtitlesManager class
    public static let shared = SubtitlesApi()
    
    let client = HttpClient(config: .init(serverURL: OpenSubtitles.base, configuration: {
        let configuration = URLSessionConfiguration.default
        configuration.httpCookieAcceptPolicy = .never
        configuration.httpShouldSetCookies = false
        configuration.timeoutIntervalForResource = 30
//        configuration.urlCache = nil
//        configuration.requestCachePolicy = .returnCacheDataDontLoad
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        configuration.httpAdditionalHeaders = OpenSubtitles.defaultHeaders
        return configuration
    }()))
    
    /**
     Load subtitles from API. Use episode or ImdbId not both. Using ImdbId rewards better results.
     
     - Parameter episode:       The show episode.
     - Parameter imdbId:        The Imdb identification code of the episode or movie.
     - Parameter limit:         The limit of subtitles to fetch as a `String`. Defaults to 500.
     - Parameter videoFilePath: The path of the video for subtitle retrieval `URL`. Defaults to nil.
     */
    open func search(_ episode: Episode? = nil, imdbId: String? = nil,preferredLang: String? = nil,videoFilePath: URL? = nil, limit: String = "500") async throws -> Dictionary<String, [Subtitle]> {
        let params = getParams(episode, imdbId: imdbId, preferredLang: preferredLang, videoFilePath: videoFilePath, limit: limit)
        let path = OpenSubtitles.search + params.compactMap({"\($0)-\($1)"}).joined(separator: "/")
        let subtitles: [Subtitle] = try await client.request(.get, path: path, parameters: params).responseMapable()
        
        var allSubtitles = Dictionary<String, [Subtitle]>()
        for subtitle in subtitles {
            let language = subtitle.language
            var languageSubtitles = allSubtitles[language]
            if languageSubtitles == nil {
                languageSubtitles = [Subtitle]()
            }
            languageSubtitles?.append(subtitle)
            allSubtitles[language] = languageSubtitles
        }
        
        return self.removeDuplicates(sourceSubtitles: allSubtitles)
    }
    
    /**
     Remove duplicates from subtitles
     
     - Parameter sourceSubtitles:   The subtitles that may contain duplicate subtitles arranged per language in a Dictionary
     - Returns: A new dictionary with the duplicate subtitles removed
     */
    
    private func removeDuplicates(sourceSubtitles: Dictionary<String, [Subtitle]>) -> Dictionary<String, [Subtitle]> {
        var subtitlesWithoutDuplicates = Dictionary<String, [Subtitle]>()
        
        for (languageName, languageSubtitles) in sourceSubtitles {
            var seenSubtitles = Set<String>()
            var uniqueSubtitles = [Subtitle]()
            for subtitle in languageSubtitles {
                if !seenSubtitles.contains(subtitle.name) {
                    uniqueSubtitles.append(subtitle)
                    seenSubtitles.insert(subtitle.name)
                }
            }
            subtitlesWithoutDuplicates[languageName] = uniqueSubtitles
        }
        
        return subtitlesWithoutDuplicates
    }
    
    private func getParams(_ episode: Episode? = nil, imdbId: String? = nil,preferredLang: String? = nil,videoFilePath: URL? = nil, limit: String = "500") -> [String:Any] {
        var params = [String:Any]()
        if let videoFilePath = videoFilePath {
            let videohash = OpenSubtitlesHash.hashFor(videoFilePath)
            params["moviehash"] = videohash.fileHash
            params["moviebytesize"] = videohash.fileSize
        }else if let imdbId = imdbId {
            params["imdbid"] = imdbId.replacingOccurrences(of: "tt", with: "")
        } else if let episode = episode {
            params["episode"] = String(episode.episode)
            params["query"] = episode.title
            params["season"] = String(episode.season)
        }
        params["sublanguageid"] = preferredLang ?? "all"
        return params
    }
}
