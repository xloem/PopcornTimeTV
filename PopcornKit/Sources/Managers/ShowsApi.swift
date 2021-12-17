
import Foundation
import ObjectMapper

open class ShowsApi: NetworkManager {
    
    /// Creates new instance of ShowApi class
    public static let shared = ShowsApi()
    
    let client = HttpClient(config: .init(serverURL: PopcornShows.base))
    
    /**
     Load TV Shows from API.
     
     - Parameter page:       The page number to load.
     - Parameter filterBy:   Sort the response by Popularity, Year, Date Rating, Alphabet or Trending.
     - Parameter genre:      Only return shows that match the provided genre.
     - Parameter searchTerm: Only return shows that match the provided string.
     - Parameter orderBy:    Ascending or descending.
     */
    open func load(_ page: Int, filterBy filter: Filters, genre: Genres, searchTerm: String?, orderBy order: Orders) async throws -> [Show] {
        var params: [String: Any] = ["sort": filter.rawValue,
                                     "genre": genre.rawValue.replacingOccurrences(of: " ", with: "-").lowercased(),
                                     "order": order.rawValue]
        if let searchTerm = searchTerm , !searchTerm.isEmpty {
            params["keywords"] = searchTerm
        }
        return try await client.request(.get, path: PopcornShows.shows + "/\(page)", parameters: params).responseMapable()
    }
    
    /**
     Get more show information.
     
     - Parameter imdbId:        The imdb identification code of the show.
     */
    open func getInfo(_ imdbId: String) async throws -> Show {
        return try await client.request(.get, path: PopcornShows.show + "/\(imdbId)").responseMapable()
    }
}
