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
    struct Theme {
        let buttonWidth: CGFloat = value(tvOS: 142, macOS: 100)
        let buttonHeight: CGFloat = value(tvOS: 115, macOS: 81)
        let leftSectionTitle: CGFloat = value(tvOS: 24, macOS: 16)
        let leftSectionTitleContent: CGFloat = value(tvOS: 31, macOS: 18)
        let leftSectionWidth: CGFloat = value(tvOS: 340, macOS: 200)
        let leftSectionLeading: CGFloat = value(tvOS: 100, macOS: 30)
        let starSize: CGSize = value(tvOS: CGSize(width: 220, height: 40), macOS: CGSize(width: 110, height: 20))
        let starOffset: CGFloat = value(tvOS: -8, macOS: -4)
        let ratingHeight: CGFloat = value(tvOS: 32, macOS: 24)
        let watchedSection: (height: CGFloat, cellWidth: CGFloat, spacing: CGFloat) = (height: value(tvOS: 450, macOS: 240),
                                                                                        cellWidth: value(tvOS: 220, macOS: 150),
                                                                                        spacing: value(tvOS: 90, macOS: 30))
        let backgroundOpacity = value(tvOS: 0.3, macOS: 0.5)
    }
    let theme = Theme()
    
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
            ZStack {
                backgroundImage()
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
                            #if os(iOS)
                            actionButtons(scroll: nil)
                            .padding(.top, 10)
                            #endif
                        }
                        .padding(.leading, theme.leftSectionLeading)
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
                                        #if os(tvOS)
                                            .padding([.top], -30)
                                        #endif
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
                        #if os(tvOS)
                        .padding([.bottom, .top], 30)
                        #else
                        .padding([.bottom], 30)
                        #endif
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
        .ignoresSafeArea()
    }
    
    func backgroundImage() -> some View {
        Color.clear
            .background(
                KFImage(viewModel.backgroundUrl)
                    .resizable()
                    .loadImmediately()
                    .aspectRatio(contentMode: .fill)
                    .padding(0)
            )
            .overlay(
                Color(white: 0, opacity: theme.backgroundOpacity))
            .clipped()
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
        .frame(width: theme.leftSectionWidth)
    }
    
    @ViewBuilder
    func rightSection(scroll: ScrollViewProxy) -> some View {
        VStack(alignment: .leading, spacing: 50) {
            infoText
            ratings()
            Text(movie.summary)
            #if os(tvOS)
                .frame(width: 920)
                .lineLimit(6)
            #endif
            awards()
            if viewModel.movie.ratings?.awards == nil {
                Spacer()
                    .frame(height: 40)
            }
            #if os(tvOS) || os(macOS)
            actionButtons(scroll: scroll)
            #endif
        }
    }
    
    @ViewBuilder
    func actionButtons(scroll: ScrollViewProxy?) -> some View {
        HStack(spacing: 24) {
            TrailerButton(viewModel: viewModel.trailerModel)
            PlayButton(viewModel: viewModel, onFocus: {
                withAnimation {
                    scroll?.scrollTo(section1, anchor: .top)
                }
            })
            watchlistButton
            watchedButton
            DownloadButton(viewModel: viewModel.downloadModel, onFocus: {
                withAnimation {
                    scroll?.scrollTo(section1, anchor: .top)
                }
            })
        }
        .buttonStyle(TVButtonStyle(onFocus: {
            withAnimation {
                scroll?.scrollTo(section1, anchor: .top)
            }
        }))
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
                .frame(width: theme.starSize.width, height: theme.starSize.height)
                .padding(.top, theme.starOffset)
        }
    }
    
    @ViewBuilder
    func sectionText(title: String, description: [String]) -> some View {
        VStack(alignment: .trailing) {
            Text(title)
                .font(.system(size: theme.leftSectionTitle, weight: .bold))
                .foregroundColor(isDark ? Color(white: 1, opacity: 0.8) : Color(white: 0, opacity: 0.8))
            ForEach(description, id: \.self) { item in
                Text(item)
            }
            .font(.system(size: theme.leftSectionTitleContent, weight: .medium))
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
        .frame(width: theme.buttonWidth, height: theme.buttonHeight)
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
        .frame(width: theme.buttonWidth, height: theme.buttonHeight)
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
        .frame(width: theme.buttonWidth, height: theme.buttonHeight)
    }
    
    var alsoWatchedSection: some View {
        VStack (alignment: .leading) {
            Text("Viewers Also Watched".localized)
                .font(.callout)
                .foregroundColor(.init(white: 1.0, opacity: 0.667)) // light text color
                .padding(.leading, theme.watchedSection.spacing)
                .padding(.top, 14)
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(alignment: .center, spacing: theme.watchedSection.spacing) {
                    Spacer(minLength: theme.watchedSection.spacing)
                    ForEach(movie.related, id: \.self) { movie in
                        NavigationLink(
                            destination: MovieDetailsView(viewModel: MovieDetailsViewModel(movie: movie)),
                            label: {
                                MovieView(movie: movie, lineLimit: 1)
                                    .frame(width: theme.watchedSection.cellWidth)
                            })
                            .buttonStyle(PlainNavigationLinkButtonStyle())
                    }
                }
                #if os(tvOS)
                .padding([.top, .bottom], 30) // on focus zoom will not be clipped
                #endif
            }
        }
        .frame(height: theme.watchedSection.height)
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
                    ratingItem(image: "metacritic", value: metascore)
                }
                if let imdb = ratings.imdbRating {
                    ratingItem(image: "imdb", value: imdb)
                }
                if let rotten = ratings.rottenTomatoes {
                    ratingItem(image: "rotten-tomatoes", value: rotten)
                }
            }
            .font(.caption)
            .lineLimit(1)
        }
    }
    
    func ratingItem(image: String, value: String) -> some View {
        HStack(spacing: 4) {
            Image(image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: theme.ratingHeight)
            Text(value)
            #if os(macOS)
                .font(.title2)
            #endif
        }
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        MovieDetailsView(viewModel: MovieDetailsViewModel(movie: Movie.dummy()))
//            .frame(height: 2000)
        #if os(tvOS)
            .previewLayout(.fixed(width: 2000, height: 2000))
        #endif
            .preferredColorScheme(.dark)
        
        MovieDetailsView(viewModel: MovieDetailsViewModel(movie: Movie.dummy()), error: NSError(domain: "", code: 1, userInfo: [NSLocalizedDescriptionKey: "This is an error text example"]))
            .preferredColorScheme(.dark)
    }
}
