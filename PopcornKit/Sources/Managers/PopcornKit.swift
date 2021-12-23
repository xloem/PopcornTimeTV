
import Foundation

/**
 Load TV Shows from API.
 
 - Parameter page:       The page number to load.
 - Parameter filterBy:   Sort the response by Popularity, Year, Date Rating, Alphabet or Trending.
 - Parameter genre:      Only return shows that match the provided genre.
 - Parameter searchTerm: Only return shows that match the provided string.
 - Parameter orderBy:    Ascending or descending.
 */
public func loadShows(
    _ page: Int = 1,
    filterBy filter: PopcornApi.Filters = .popularity,
    genre: PopcornApi.Genres = .all,
    searchTerm: String? = nil,
    orderBy order: PopcornApi.Orders = .descending) async throws -> [Show] {
    return try await PopcornApi.shared.load(page, filterBy: filter, genre: genre, searchTerm: searchTerm, orderBy: order)
}

/**
 Get more show information.
 
 - Parameter imdbId:        The imdb identification code of the show.
 */
public func getShowInfo(_ imdbId: String) async throws -> Show {
    return try await PopcornApi.shared.getInfo(imdbId)
}


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
    filterBy filter: PopcornApi.Filters = .popularity,
    genre: PopcornApi.Genres = .all,
    searchTerm: String? = nil,
    orderBy order: PopcornApi.Orders = .descending) async throws -> [Movie] {
    try await PopcornApi.shared.load(page, filterBy: filter, genre: genre, searchTerm: searchTerm, orderBy: order)
}

/**
 Get more movie information.
 
 - Parameter imdbId:        The imdb identification code of the movie.
 */
public func getMovieInfo(_ imdbId: String) async throws -> Movie {
    try await PopcornApi.shared.getInfo(imdbId)
}

/**
 Download torrent file from link.
 
 - Parameter path:          The path to the torrent file you would like to download.
 */
public func downloadTorrentFile(_ url: String) async throws -> URL {
    let request = URLRequest(url: URL(string: url)!)
    let (fileUrl, _) = try await URLSession.shared.download(for: request)
    return fileUrl
}

/**
 Download subtitle file from link.
 
 - Parameter path:              The path to the subtitle file you would like to download.
 - Parameter downloadDirectory: You can opt to change the download location of the file. Defaults to `NSTemporaryDirectory/Subtitles`.
 */
public func downloadSubtitleFile(_ url: String,
    downloadDirectory directory: URL = URL(fileURLWithPath: NSTemporaryDirectory())) async throws -> URL {
        let request = URLRequest(url: URL(string: url)!)
        let (fileUrl, response) = try await URLSession.shared.download(for: request)

        let fileName = response.suggestedFilename ?? UUID().uuidString
        let downloadDirectory = directory.appendingPathComponent("Subtitles")
        if !FileManager.default.fileExists(atPath: downloadDirectory.path) {
            try? FileManager.default.createDirectory(at: downloadDirectory, withIntermediateDirectories: true, attributes: nil)
        }
        
        let destinationUrl = downloadDirectory.appendingPathComponent(fileName)
        _ = try FileManager.default.replaceItemAt(destinationUrl, withItemAt: fileUrl)
        return destinationUrl
}


