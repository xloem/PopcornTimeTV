
import Foundation
import ObjectMapper

open class PopcornApi {
    
    /// Creates new instance of PopcornApi class
    public static var shared = PopcornApi()
    
    let client: HttpClient
    
    public init() {
        let url = Session.popcornBaseUrl ?? Popcorn.base
        client = HttpClient(config: .init(serverURL: url, apiErrorDecoder: { data in
            return try? JSONDecoder().decode(Popcorn.APIError.self, from: data)
        }))
    }
    
    public var customBaseURL: String { // empty if default
        return client.config.serverURL != Popcorn.base ? client.config.serverURL : ""
    }
    
    public static func changeBaseUrl(newUrl: String?) {
        Session.popcornBaseUrl = newUrl
        shared = PopcornApi()
    }
    
    /**
     Load Movies from API.
     
     - Parameter page:       The page number to load.
     - Parameter filterBy:   Sort the response by Popularity, Year, Date Rating, Alphabet or Trending.
     - Parameter genre:      Only return movies that match the provided genre.
     - Parameter searchTerm: Only return movies that match the provided string.
     - Parameter orderBy:    Ascending or descending.
     */
    open func load(_ page: Int, filterBy filter: Popcorn.Filters, genre: Popcorn.Genres, searchTerm: String?, orderBy order: Popcorn.Orders) async throws -> [Movie] {
        var params: [String: Any] = ["sort": filter.rawValue,
                                     "order": order.rawValue,
                                     "genre": genre.rawValue.replacingOccurrences(of: " ", with: "-").lowercased()]
        if let searchTerm = searchTerm , !searchTerm.isEmpty {
            params["keywords"] = searchTerm
        }
        
        return try await client.request(.get, path: Popcorn.movies + "/\(page)", parameters: params).responseMapable()
    }
    
    /**
     Get more movie information.
     
     - Parameter imdbId:        The imdb identification code of the movie.
     */
    open func getInfo(_ imdbId: String) async throws -> Movie {
        return try await client.request(.get, path: Popcorn.movie + "/\(imdbId)").responseMapable()
    }
    
    
    
    /**
     Load TV Shows from API.
     
     - Parameter page:       The page number to load.
     - Parameter filterBy:   Sort the response by Popularity, Year, Date Rating, Alphabet or Trending.
     - Parameter genre:      Only return shows that match the provided genre.
     - Parameter searchTerm: Only return shows that match the provided string.
     - Parameter orderBy:    Ascending or descending.
     */
    open func load(_ page: Int, filterBy filter: Popcorn.Filters, genre: Popcorn.Genres, searchTerm: String?, orderBy order: Popcorn.Orders) async throws -> [Show] {
        var params: [String: Any] = ["sort": filter.rawValue,
                                     "genre": genre.rawValue.replacingOccurrences(of: " ", with: "-").lowercased(),
                                     "order": order.rawValue]
        if let searchTerm = searchTerm , !searchTerm.isEmpty {
            params["keywords"] = searchTerm
        }
        return try await client.request(.get, path: Popcorn.shows + "/\(page)", parameters: params).responseMapable()
    }
    
    /**
     Get more show information.
     
     - Parameter imdbId:        The imdb identification code of the show.
     */
    open func getInfo(_ imdbId: String) async throws -> Show {
        return try await client.request(.get, path: Popcorn.show + "/\(imdbId)").responseMapable()
    }
}
