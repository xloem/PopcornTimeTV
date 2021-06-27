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
import UIKit

struct DetailView: View {
    @StateObject var viewModel: DetailViewModel
    @State var showPlayer: Bool = false
    
    @Environment(\.colorScheme) var colorScheme
    var isDark: Bool {
        return colorScheme == .dark
    }
    var movie: Movie {
        return viewModel.movie
    }
    
    var body: some View {
        ZStack {
            KFImage(viewModel.backgroundUrl)
//                .resizable()
                .aspectRatio(contentMode: .fill)
                .padding(0)
                .ignoresSafeArea()
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            Color(white: 0, opacity: 0.3)
                .ignoresSafeArea()
            ScrollView {
                VStack {
                    Text(movie.title)
                        .font(.title)
                        .padding(.bottom, 50)
                        .padding(.top, 200)
                    HStack(alignment: .top, spacing: 40) {
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
                        VStack(alignment: .leading, spacing: 50) {
                            infoText
                            Text(movie.summary)
                                .frame(width: 920)
                                .lineLimit(5)
                            Spacer(minLength: 40)
                            HStack(spacing: 24) {
                                TrailerButton(viewModel: viewModel.trailerModel)
                                PlayButton(viewModel: viewModel)
//                                seasonsButton
                                watchlistButton
                                watchedButton
                                DownloadButton(viewModel: viewModel.downloadModel)
                            }
                            .buttonStyle(TVButtonStyle())
                        }
                        Spacer()
                    }
                    .padding(.leading, 10)
                    
                    
                }
                .padding(.leading, 100)
            }
        }.onAppear {
//            ThemeSongManager.shared.playMovieTheme(movie.title)
            viewModel.load()
        }.onDisappear {
            ThemeSongManager.shared.stopTheme()
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
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(viewModel: DetailViewModel(movie: Movie.dummy()))
    }
}
