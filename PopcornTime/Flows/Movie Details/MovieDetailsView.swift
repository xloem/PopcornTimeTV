//
//  DetailView.swift
//  PopcornTimetvOS SwiftUI
//
//  Created by Alexandru Tudose on 19.06.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import SwiftUI
import PopcornKit
import Kingfisher
#if canImport(UIKit)
import UIKit
#endif

struct MovieDetailsView: View {
    @StateObject var viewModel: MovieDetailsViewModel
    @State var showPlayer: Bool = false
    @State var error: Error?
    
    @Environment(\.colorScheme) var colorScheme
    var isDark: Bool {
        return colorScheme == .dark
    }
    var movie: Movie {
        return viewModel.movie
    }
    @Namespace var section1
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                backgroundImage(size: geometry.size)
//                backgroundImage(size: UIScreen.main.bounds.size)
                Color(white: 0, opacity: 0.3)
                    .ignoresSafeArea()
                ScrollViewReader { scroll in
                    ScrollView {
                        VStack {
                            Text(movie.title)
                                .font(.title)
                                .padding(.bottom, 50)
                                .padding(.top, 200)
                            HStack(alignment: .top, spacing: 40) {
                                leftSection
                                rightSection(scroll: scroll)
                                Spacer()
                            }
                            .padding(.leading, 10)
                        }
                        .padding(.leading, 100)
                        .id(section1)
                        #if os(tvOS)
                        .focusSection()
                        #endif
                        
                        VStack {
                            if movie.related.count > 0 {
                                alsoWatchedSection
                                    .background(
                                        Color.init(white: 0, opacity: 0.3)
                                            .padding([.bottom], -10)
                                            .padding([.top], -30)
                                    )
                                    #if os(tvOS)
                                    .focusSection()
                                    #endif
                            }
                            if movie.actors.count > 0 {
                                ActorsCrewView(persons: movie.actors + movie.crew)
                                #if os(tvOS)
                                .focusSection()
                                #endif
                            }
                        }
                        .padding([.bottom, .top], 30)
                        .background(Color.init(white: 1, opacity: 0.3))
                        .padding(.top, 50)
                    }
                }
                if let error = error {
                    BannerView(error: error)
                        .padding([.top, .trailing], 60)
                        .transition(.move(edge: .top))
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                self.error = nil
                            }
                        }
                }
            }.onAppear {
                viewModel.playSongTheme()
                viewModel.load()
                viewModel.trailerModel.error = $error // bind error for displaying
            }.onDisappear {
                viewModel.stopTheme()
            }
        }
        .ignoresSafeArea()
    }
    
    func backgroundImage(size: CGSize) -> some View {
        return KFImage(viewModel.backgroundUrl)
            .resizable()
            .loadImmediately()
            .aspectRatio(contentMode: .fill)
            .padding(0)
            .ignoresSafeArea()
            .frame(width: size.width, height: size.height)
    }
    
    @ViewBuilder
    var leftSection: some View {
        VStack(alignment: .trailing, spacing: 40) {
            if let genre = movie.genres.first?.localizedCapitalized.localized {
                sectionText(title: "Genre".localized.localizedUppercase, description: [genre])
            }
            
            if let directors: [String] = movie.crew.filter({$0.roleType == .director}).compactMap{String($0.name)},
               directors.count > 0,
               let isSingular = directors.count == 1 {
                sectionText(title: (isSingular ? "Director".localized.localizedUppercase : "Directors".localized.localizedUppercase), description: directors)
            }
            
            let actors = movie.actors.prefix(5).compactMap{ String($0.name) }
            if !actors.isEmpty {
                sectionText(title: "Starring".localized.localizedUppercase, description: actors)
            }
            
            if viewModel.isLoading {
                ProgressView()
            }
        }
        .frame(width: 340)
    }
    
    @ViewBuilder
    func rightSection(scroll: ScrollViewProxy) -> some View {
        VStack(alignment: .leading, spacing: 50) {
            infoText
            ratings()
            Text(movie.summary)
                .frame(width: 920)
                .lineLimit(6)
            awards()
            if viewModel.movie.ratings?.awards == nil {
                Spacer()
                    .frame(height: 40)
            }
            HStack(spacing: 24) {
                TrailerButton(viewModel: viewModel.trailerModel)
                #if os(tvOS)
                PlayButton(viewModel: viewModel) {
                    withAnimation {
                        scroll.scrollTo(section1, anchor: .top)
                    }
                }
                #endif
                watchlistButton
                watchedButton
                #if os(tvOS)
                DownloadButton(viewModel: viewModel.downloadModel, onFocus: {
                    withAnimation {
                        scroll.scrollTo(section1, anchor: .top)
                    }
                })
                #endif
            }
            .buttonStyle(TVButtonStyle(onFocus: {
                withAnimation {
                    scroll.scrollTo(section1, anchor: .top)
                }
            }))
        }
    }
    
    var infoText: some View {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .short
        formatter.allowedUnits = [.hour, .minute]
        let runtime = formatter.string(from: TimeInterval(movie.runtime) * 60)
        let year = movie.year
        
        let items = [Text([runtime, year].compactMap({$0}).joined(separator: "\t"))]
            + ([movie.certification, "HD", "CC"]).map {
                Text(Image($0).renderingMode(.template))
            }
        return HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 25) {
            ForEach(0..<items.count) { item in
                items[item]
            }
            
            StarRatingView(rating: movie.rating / 20)
                .frame(height: 33)
                .padding(.top, -8)
        }
    }
    
    @ViewBuilder
    func sectionText(title: String, description: [String]) -> some View {
        VStack(alignment: .trailing) {
            Text(title)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(isDark ? Color(white: 1, opacity: 0.8) : Color(white: 0, opacity: 0.8))
            ForEach(description, id: \.self) { item in
                Text(item)
            }
            .font(.system(size: 31, weight: .medium))
            .foregroundColor(isDark ? Color(white: 1, opacity: 0.5) : Color(white: 0, opacity: 0.5))
        }
    }
    

    
    var seasonsButton: some View {
        return Button(action: {
            
        }, label: {
            VStack {
                VisualEffectBlur() {
                    Image("Seasons")
                }.cornerRadius(6)
                Text("Series".localized)
            }
        })
        .frame(width: 142, height: 115)
    }
    
    var watchlistButton: some View {
        return Button(action: {
            viewModel.movie.isAddedToWatchlist.toggle()
            print(#function, viewModel.movie.isAddedToWatchlist)
        }, label: {
            VStack {
                VisualEffectBlur() {
                    movie.isAddedToWatchlist ? Image("Remove") : Image("Add")
                }
                Text("Watchlist".localized)
            }
        })
        .frame(width: 142, height: 115)
    }
    
    var watchedButton: some View {
        return Button(action: {
            viewModel.movie.isWatched.toggle()
            print(#function, viewModel.movie.isWatched)
        }, label: {
            VStack {
                VisualEffectBlur() {
                    movie.isWatched ? Image("Watched On") : Image("Watched Off")
                }
                Text("Watched".localized)
            }
        })
        .frame(width: 142, height: 115)
    }
    
    var alsoWatchedSection: some View {
        VStack (alignment: .leading) {
            Text("Viewers Also Watched".localized)
                .font(.callout)
                .foregroundColor(.init(white: 1.0, opacity: 0.667)) // light text color
                .padding(.leading, 90)
                .padding(.top, 14)
            ScrollView(.horizontal, showsIndicators: false) {
//                Spacer() // on focus zoom will not be clipped
//                    .frame(height: 30)
                LazyHStack(alignment: .center, spacing: 90) {
                    Spacer(minLength: 90)
                    ForEach(movie.related, id: \.self) { movie in
                        NavigationLink(
                            destination: MovieDetailsView(viewModel: MovieDetailsViewModel(movie: movie)),
                            label: {
                                MovieView(movie: movie, lineLimit: 1)
                                    .frame(width: 220)
                            })
                            .buttonStyle(PlainNavigationLinkButtonStyle())
//                            .frame(width: 220)
//                            .padding([.leading, .trailing], 5)
                    }
                }
                .padding([.top, .bottom], 30) // on focus zoom will not be clipped
//                Spacer()
//                    .frame(height: 30)
//                .padding()
//                .background(Color.blue)
            }
//            .background(Color.gray)
        }
//        .background(Color.red)
        .frame(height: 450)
        .padding(0)
    }
    
    @ViewBuilder
    func awards() -> some View {
        if let awards = movie.ratings?.awards {
            Text("Awards: " + awards)
                .font(.caption)
        }
    }
    
    @ViewBuilder
    func ratings() -> some View {
        if let ratings = movie.ratings {
            HStack(spacing: 25) {
                if let metascore = ratings.metascore {
                    HStack(spacing: 8) {
                        Image("metacritic")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 32)
                        Text(metascore)
                    }
                }
                if let imdb = ratings.imdbRating {
                    HStack(spacing: 4) {
                        Image("imdb")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 32)
                        Text(imdb)
                    }
                }
                if let rotten = ratings.rottenTomatoes {
                    HStack(spacing: 4) {
                        Image("rotten-tomatoes")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 32)
                        Text(rotten)
                    }
                }
            }
            .font(.caption)
            .lineLimit(1)
        }
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        MovieDetailsView(viewModel: MovieDetailsViewModel(movie: Movie.dummy()))
//            .frame(height: 2000)
            .previewLayout(.fixed(width: 2000, height: 2000))
        
        MovieDetailsView(viewModel: MovieDetailsViewModel(movie: Movie.dummy()), error: NSError(domain: "", code: 1, userInfo: [NSLocalizedDescriptionKey: "This is an error text example"]))
    }
}
