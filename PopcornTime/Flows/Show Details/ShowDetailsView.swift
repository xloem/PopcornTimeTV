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
    struct Theme {
        let buttonWidth: CGFloat = value(tvOS: 142, macOS: 100)
        let buttonHeight: CGFloat = value(tvOS: 115, macOS: 81)
        
        let starHeight: CGFloat = value(tvOS: 33, macOS: 18)
        let ratingHeight: CGFloat = value(tvOS: 32, macOS: 24)
        let watchedSection: (height: CGFloat, cellWidth: CGFloat, cellHeight: CGFloat, spacing: CGFloat)
            = (height: value(tvOS: 450, macOS: 240),
               cellWidth: value(tvOS: 220, macOS: 150),
               cellHeight: value(tvOS: 460, macOS: 180),
               spacing: value(tvOS: 90, macOS: 30))
    }
    let theme = Theme()
    
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
        GeometryReader { geometry in
        ZStack {
            backgroundImage(size: geometry.size)
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
                                #if os(tvOS)
                                    .frame(width: 1200, height: 200)
                                #endif
                                HStack(spacing: 24) {
                                    watchlistButton
                                    if viewModel.show.seasonNumbers.count > 1 {
                                        seasonsButton
                                    }
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
                                #if os(tvOS)
                                .padding(.top, 50)
                                .padding(.bottom, 100)
                                #else
                                .padding(.bottom, 20)
                                #endif
                            }
                        }
                        .id(section1)
                        #if os(tvOS)
                        .padding(.leading, 100)
                        #else
                        .padding([.leading, .trailing], 50)
                        #endif
                        Spacer()
                    }
                    #if os(tvOS)
                    .focusSection()
                    #endif
                    
                    VStack(alignment: .center) {
                        EpisodesView(show: viewModel.show, episodes: viewModel.seasonEpisodes(), currentSeason: viewModel.currentSeason, onFocus: {
                            withAnimation() {
                                scroll.scrollTo(section2, anchor: .top)
                            }
                        })
                        #if os(tvOS)
                        .focusSection()
                        #endif
                        
                        if show.related.count > 0 {
                            alsoWatchedSection(scroll: scroll)
                                .background(
                                    Color.init(white: 0, opacity: 0.3)
                                        .padding([.top, .bottom], -10)
                                )
                                #if os(tvOS)
                                .focusSection()
                                #endif
                        }
                        if show.actors.count > 0 {
                            ActorsCrewView(persons: show.actors + show.crew)
                            #if os(tvOS)
                            .focusSection()
                            #endif
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
        .environmentObject(viewModel)
        }
    }
    
    func backgroundImage(size: CGSize) -> some View {
        return KFImage(viewModel.backgroundUrl)
            .resizable()
            .loadImmediately()
            .aspectRatio(contentMode: .fill)
            .padding(0)
            .ignoresSafeArea()
            .frame(width: size.width, height: size.height)
            .clipped()
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
        }
        .font(.system(size: 31, weight: .medium))
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
                    }
                    Text("Series".localized)
                }
            })
            .frame(width: theme.buttonWidth, height: theme.buttonHeight)
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
        .frame(width: theme.buttonWidth, height: theme.buttonHeight)
    }
    
    func alsoWatchedSection(scroll: ScrollViewProxy) -> some View {
        VStack (alignment: .leading) {
            Text("Viewers Also Watched".localized)
                .font(.callout)
                .foregroundColor(.init(white: 1.0, opacity: 0.667)) // light text color
                .padding(.leading, theme.watchedSection.spacing)
                .padding(.top, 14)
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(alignment: .center, spacing: theme.watchedSection.spacing) {
                    Spacer(minLength: theme.watchedSection.spacing)
                    ForEach(show.related, id: \.self) { show in
                        NavigationLink(
                            destination: ShowDetailsView(viewModel: ShowDetailsViewModel(show: show)),
                            label: {
                                ShowView(show: show)
                                    .frame(width: theme.watchedSection.cellWidth, height: theme.watchedSection.cellHeight)
                            })
                            .buttonStyle(PlainNavigationLinkButtonStyle(onFocus: {
//                                withAnimation {
//                                    scroll.scrollTo(section3, anchor: .top)
//                                }
                            }))
                    }
                }
                .padding([.top, .bottom], 30) // on focus zoom will not be clipped
//                .background(Color.blue)
            }
//            .background(Color.gray)
        }
//        .background(Color.red)
        .frame(height: theme.watchedSection.height)
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
            #if os(tvOS)
            .previewLayout(.fixed(width: 2000, height: 1800))
            #else
            .previewLayout(.fixed(width: 1024, height: 1800))
            #endif
            .preferredColorScheme(.dark)
    }
}
