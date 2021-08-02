//
//  SearchWrapperView.swift
//  PopcornTimetvOS SwiftUI
//
//  Created by Alexandru Tudose on 27.06.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import SwiftUI

struct SearchWrapperView: UIViewControllerRepresentable {
    @Binding var text: String
    @Binding var selection: SearchViewModel.SearchType
    var scopesTitles: [String] = []

     typealias UIViewControllerType = UINavigationController
     typealias Context = UIViewControllerRepresentableContext<SearchWrapperView>
     
    func makeUIViewController(context: Context) -> UIViewControllerType {
         let controller = UISearchController(searchResultsController: context.coordinator)
         controller.searchResultsUpdater = context.coordinator
         controller.searchBar.scopeButtonTitles = scopesTitles
         controller.searchBar.showsScopeBar = scopesTitles.count > 1
//         controller.hidesNavigationBarDuringPresentation = false
//        controller.edgesForExtendedLayout = []
         let navigationController = UINavigationController(rootViewController: UISearchContainerViewController(searchController: controller))
//        controller.searchControllerObservedScrollView = UIScrollView()
        return navigationController
     }

     func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        let container = uiViewController.viewControllers.first as? UISearchContainerViewController
//        container?.searchController.searchControllerObservedScrollView = nil
//        container?.searchController.tabBarObservedScrollView = nil
     }

     func makeCoordinator() -> SearchWrapperView.Coordinator {
         return Coordinator(text: $text, selection: $selection)
     }

     class Coordinator: UIViewController, UISearchResultsUpdating {
         
         @Binding var text: String
         @Binding var selection: SearchViewModel.SearchType
        var observer: Any?

        init(text: Binding<String>, selection: Binding<SearchViewModel.SearchType>) {
             _text = text
             _selection = selection
             super.init(nibName: nil, bundle: nil)
         }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
         func updateSearchResults(for searchController: UISearchController) {
             guard let searchText = searchController.searchBar.text else { return }
             text = searchText
             selection = .init(rawValue: searchController.searchBar.selectedScopeButtonIndex)!
         }
     }
}
