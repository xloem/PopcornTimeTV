
import Foundation
import Alamofire

/**
 Load TV Shows from API.
 
 - Parameter page:       The page number to load.
 - Parameter filterBy:   Sort the response by Popularity, Year, Date Rating, Alphabet or Trending.
 - Parameter genre:      Only return shows that match the provided genre.
 - Parameter searchTerm: Only return shows that match the provided string.
 - Parameter orderBy:    Ascending or descending.
 
 - Parameter completion: Completion handler for the request. Returns array of shows upon success, error upon failure.
 */
public func loadShows(
    _ page: Int = 1,
    filterBy filter: ShowsApi.Filters = .popularity,
    genre: ShowsApi.Genres = .all,
    searchTerm: String? = nil,
    orderBy order: ShowsApi.Orders = .descending) async throws -> [Show] {
    return try await ShowsApi.shared.load(
        page,
        filterBy: filter,
        genre: genre,
        searchTerm: searchTerm,
        orderBy: order)
}

/**
 Get more show information.
 
 - Parameter imdbId:        The imdb identification code of the show.
 */
public func getShowInfo(_ imdbId: String) async throws -> Show {
    return try await ShowsApi.shared.getInfo(imdbId)
}

///**
// Get more episode information.
// 
// - Parameter tvdbId:        The tvdb identification code of the episode.
// 
// - Parameter completion:    Completion handler for the request. Returns episode upon success, error upon failure.
// */
//public func getEpisodeInfo(_ tvdbId: Int, completion: @escaping (Episode?, NSError?) -> Void) {
//    DispatchQueue.global(qos: .background).async {
//        TraktManager.shared.getEpisodeInfo(forTvdb: tvdbId, completion: completion)
//    }
//}


/**
 Load Movies from API.
 
 - Parameter page:       The page number to load.
 - Parameter filterBy:   Sort the response by Popularity, Year, Date Rating, Alphabet or Trending.
 - Parameter genre:      Only return movies that match the provided genre.
 - Parameter searchTerm: Only return movies that match the provided string.
 - Parameter orderBy:    Ascending or descending.
 */
public func loadMovies(
    _ page: Int = 1,
    filterBy filter: MoviesApi.Filters = .popularity,
    genre: MoviesApi.Genres = .all,
    searchTerm: String? = nil,
    orderBy order: MoviesApi.Orders = .descending) async throws -> [Movie] {
    try await MoviesApi.shared.load(
        page,
        filterBy: filter,
        genre: genre,
        searchTerm: searchTerm,
        orderBy: order)
}

/**
 Get more movie information.
 
 - Parameter imdbId:        The imdb identification code of the movie.
 */
public func getMovieInfo(_ imdbId: String) async throws -> Movie {
    try await MoviesApi.shared.getInfo(imdbId)
}

/**
 Download torrent file from link.
 
 - Parameter path:          The path to the torrent file you would like to download.
 
 - Parameter completion:    Completion handler for the request. Returns downloaded torrent url upon success, error upon failure.
 */
public func downloadTorrentFile(_ path: String, completion: @escaping (String?, NSError?) -> Void) {
    var finalPath: URL!
    Alamofire.download(path) { (temporaryURL, response) -> (destinationURL: URL, options: DownloadRequest.DownloadOptions) in
        finalPath = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(response.suggestedFilename!)
        return (finalPath, .removePreviousFile)
    }.validate().response { response in
        guard response.error == nil else {completion(nil, response.error as NSError?); return }
        completion(finalPath.path, nil)
    }
}

/**
 Download subtitle file from link.
 
 - Parameter path:              The path to the subtitle file you would like to download.
 - Parameter fileName:          An optional file name you can provide.
 - Parameter downloadDirectory: You can opt to change the download location of the file. Defaults to `NSTemporaryDirectory/Subtitles`.
 
 - Parameter completion:    Completion handler for the request. Returns downloaded subtitle url upon success, error upon failure.
 */
public func downloadSubtitleFile(
    _ path: String,
    fileName suggestedName: String? = nil,
    downloadDirectory directory: URL = URL(fileURLWithPath: NSTemporaryDirectory()),
    completion: @escaping (URL?, NSError?) -> Void) {
    var fileUrl: URL!
    Alamofire.download(path) { (temporaryURL, response) -> (destinationURL: URL, options: DownloadRequest.DownloadOptions) in
        let fileName = suggestedName ?? response.suggestedFilename!
        let downloadDirectory = directory.appendingPathComponent("Subtitles")
        if !FileManager.default.fileExists(atPath: downloadDirectory.path) {
            try? FileManager.default.createDirectory(at: downloadDirectory, withIntermediateDirectories: true, attributes: nil)
        }
        fileUrl = downloadDirectory.appendingPathComponent(fileName)
        return (fileUrl, .removePreviousFile)
    }.validate().response { response in
        if let error = response.error as NSError? {
            completion(nil, error)
            return
        }
        completion(fileUrl, nil)
    }
}


