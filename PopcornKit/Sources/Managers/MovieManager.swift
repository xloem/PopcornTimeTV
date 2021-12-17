
import Foundation
import ObjectMapper

open class MovieManager: NetworkManager {
    
    /// Creates new instance of MovieManager class
    public static let shared = MovieManager()
    
    let client = HttpClient(config: .init(serverURL: PopcornMovies.base))
    
    /**
     Load Movies from API.
     
     - Parameter page:       The page number to load.
     - Parameter filterBy:   Sort the response by Popularity, Year, Date Rating, Alphabet or Trending.
     - Parameter genre:      Only return movies that match the provided genre.
     - Parameter searchTerm: Only return movies that match the provided string.
     - Parameter orderBy:    Ascending or descending.
     */
    open func load(
        _ page: Int,
        filterBy filter: Filters,
        genre: Genres,
        searchTerm: String?,
        orderBy order: Orders) async throws -> [Movie] {
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
     
     - Parameter completion:    Completion handler for the request. Returns movie upon success, error upon failure.
     */
    open func getInfo(_ imdbId: String, completion: @escaping (Movie?, NSError?) -> Void) {
        self.manager.request(PopcornMovies.base + PopcornMovies.movie + "/\(imdbId)").validate().responseJSON { response in
            guard let value = response.result.value else {completion(nil, response.result.error as NSError?); return}
            DispatchQueue.global(qos: .background).async {
                let mappedItem = Mapper<Movie>().map(JSONObject: value)
                DispatchQueue.main.sync{completion(mappedItem, nil)}
            }
            
        }
    }
    
}
