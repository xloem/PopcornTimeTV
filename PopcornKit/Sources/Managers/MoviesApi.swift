
import Foundation
import ObjectMapper

open class MoviesApi: NetworkManager {
    
    /// Creates new instance of MoviesAPI class
    public static let shared = MoviesApi()
    
    let client = HttpClient(config: .init(serverURL: PopcornMovies.base))
    
    /**
     Load Movies from API.
     
     - Parameter page:       The page number to load.
     - Parameter filterBy:   Sort the response by Popularity, Year, Date Rating, Alphabet or Trending.
     - Parameter genre:      Only return movies that match the provided genre.
     - Parameter searchTerm: Only return movies that match the provided string.
     - Parameter orderBy:    Ascending or descending.
     */
    open func load(_ page: Int, filterBy filter: Filters, genre: Genres, searchTerm: String?, orderBy order: Orders) async throws -> [Movie] {
        var params: [String: Any] = ["sort": filter.rawValue,
                                     "order": order.rawValue,
                                     "genre": genre.rawValue.replacingOccurrences(of: " ", with: "-").lowercased()]
        if let searchTerm = searchTerm , !searchTerm.isEmpty {
            params["keywords"] = searchTerm
        }
        
        return try await client.request(.get, path: PopcornMovies.movies + "/\(page)", parameters: params).responseMapable()
    }
    
    /**
     Get more movie information.
     
     - Parameter imdbId:        The imdb identification code of the movie.
     */
    open func getInfo(_ imdbId: String) async throws -> Movie {
        return try await client.request(.get, path: PopcornMovies.movie + "/\(imdbId)").responseMapable()
    }
    
}
