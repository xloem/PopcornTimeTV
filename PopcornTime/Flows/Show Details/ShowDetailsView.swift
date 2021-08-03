//
//  ShowDetailsView.swift
//  PopcornTimetvOS SwiftUI
//
//  Created by Alexandru Tudose on 04.07.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import SwiftUI
import PopcornKit
import Kingfisher

struct ShowDetailsView: View {
    @StateObject var viewModel: ShowDetailsViewModel
    @State var showPlayer: Bool = false
    @State var error: Error?
    @State var showSeasonPicker: Bool = false
    
    @Environment(\.colorScheme) var colorScheme
    var isDark: Bool {
        return colorScheme == .dark
    }
    var show: Show {
        return viewModel.show
    }
    
    @Namespace var section1
    @Namespace var section2
    @Namespace var section3
    
    var body: some View {
        ZStack {
            backgroundImage
            Color(white: 0, opacity: 0.3)
                .ignoresSafeArea()
            ScrollViewReader { scroll in
                ScrollView {
                    HStack {
                        VStack() {
                            Text(show.title)
                                .font(.title)
                                .padding(.bottom, 50)
                                .padding(.top, 200)
                            VStack(alignment: .leading, spacing: 50) {
                                infoText
                                Text(show.summary)
                                    .lineLimit(5)
                                    .frame(width: 1200, height: 200)
                                HStack(spacing: 24) {
                                    if viewModel.show.seasonNumbers.count > 1 {
                                        seasonsButton
                                    }
                                    watchlistButton
                                    if viewModel.isLoading {
                                        ProgressView()
                                            .padding(.leading, 50)
                                            .padding(.bottom, 40)
                                    }
                                }
                                .buttonStyle(TVButtonStyle(onFocus: {
                                    withAnimation {
                                        scroll.scrollTo(section1, anchor: .top)
                                    }
                                }))
                                .padding(.top, 50)
                                .padding(.bottom, 100)
                            }
                        }
                        .id(section1)
                        .padding(.leading, 100)
                        Spacer()
                    }
                    
                    VStack {
                        EpisodesView(show: viewModel.show, episodes: viewModel.seasonEpisodes(), currentSeason: viewModel.currentSeason, onFocus: {
                            withAnimation() {
                                scroll.scrollTo(section2, anchor: .top)
                            }
                        })
                        if show.related.count > 0 {
                            alsoWatchedSection(scroll: scroll)
                        }
                        if show.actors.count > 0 {
                            ActorsCrewView(persons: show.actors + show.crew)
                        }
                    }
                    .padding([.bottom, .top], 30)
                    .background(Color.init(white: 0, opacity: 0.3))
//                    .padding(.top, 50)
                    .id(section2)
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
        }.onDisappear {
            viewModel.stopTheme()
        }
    }
    
    var backgroundImage: some View {
        KFImage(viewModel.backgroundUrl)
            .resizable()
            .loadImmediately()
            .aspectRatio(contentMode: .fill)
            .padding(0)
            .ignoresSafeArea()
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    }
    
    
    var infoText: some View {
        let localizedSeason = NumberFormatter.localizedString(from: NSNumber(value: viewModel.currentSeason), number: .none)
        let title = "Season".localized + " \(localizedSeason)"
        
        let genre = show.genres.first?.localizedCapitalized.localized
        let year = show.year
        
        let items = [Text([genre, year].compactMap({$0}).joined(separator: "\t"))]
            + (["HD", "CC"]).map {
                Text(Image($0).renderingMode(.template))
            }
        
        let watchOn: String = .localizedStringWithFormat("Watch %@ on %@".localized, show.title, show.network ?? "TV")
        
        return VStack(alignment: .leading) {
            Text(title)
                .font(.system(size: 43, weight: .medium))
            HStack(alignment: .center, spacing: 25) {
                ForEach(0..<items.count) { item in
                    items[item]
                }
                StarRatingView(rating: show.rating / 20)
                    .frame(height: 33)
                    .padding(.top, -8)
            }
            Text(watchOn)
                .foregroundColor(Color.init(white: 1, opacity: 0.67))
        }.font(.system(size: 31, weight: .medium))
    }
    
    var seasonsButton: some View {
        Group {
            NavigationLink(
                destination: SeasonPickerView(viewModel: SeasonPickerViewModel(show: show), selectedSeasonNumber: $viewModel.currentSeason),
                isActive: $showSeasonPicker,
                label: {
                    EmptyView()
                })
            
            Button(action: {
                showSeasonPicker = true
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
    }
    
    var watchlistButton: some View {
        return Button(action: {
            viewModel.show.isAddedToWatchlist.toggle()
        }, label: {
            VStack {
                VisualEffectBlur() {
                    show.isAddedToWatchlist ? Image("Remove") : Image("Add")
                }
                Text("Watchlist".localized)
            }
        })
        .frame(width: 142, height: 115)
    }
    
    func alsoWatchedSection(scroll: ScrollViewProxy) -> some View {
        VStack (alignment: .leading) {
            Text("Viewers Also Watched".localized)
                .font(.callout)
                .foregroundColor(.init(white: 1.0, opacity: 0.667)) // light text color
                .padding(.leading, 90)
                .padding(.top, 14)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack() {
                    Spacer(minLength: 90)
                    ForEach(show.related, id: \.self) { show in
                        NavigationLink(
                            destination: ShowDetailsView(viewModel: ShowDetailsViewModel(show: show)),
                            label: {
                                ShowView(show: show)
                            })
                            .buttonStyle(PlainNavigationLinkButtonStyle(onFocus: {
                                withAnimation {
                                    scroll.scrollTo(section3, anchor: .center)
                                }
                            }))
                            .frame(maxWidth: 200)
//                            .padding([.leading, .trailing], 5)
                    }
                }
                .padding() // on focus zoom will not be clipped
//                .background(Color.blue)
            }
//            .background(Color.gray)
        }
//        .background(Color.red)
        .frame(height: 380)
        .padding(0)
        .id(section3)
    }
}

struct ShowDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        let show = Show.dummy()
        let model = ShowDetailsViewModel(show: show)
        model.currentSeason = show.latestUnwatchedEpisode()?.season ?? show.seasonNumbers.first ?? -1
            
        return ShowDetailsView(viewModel: model)
            .previewLayout(.fixed(width: 2000, height: 1800))
    }
}
