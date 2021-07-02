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

     typealias UIViewControllerType = UISearchContainerViewController

     typealias Context = UIViewControllerRepresentableContext<SearchWrapperView>
     
     func makeUIViewController(context: Context) -> UIViewControllerType {
         let controller = UISearchController(searchResultsController: context.coordinator)
         controller.searchResultsUpdater = context.coordinator
         return UISearchContainerViewController(searchController: controller)
     }

     func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) { }

     func makeCoordinator() -> SearchWrapperView.Coordinator {
         return Coordinator(text: $text)
     }

     class Coordinator: UIViewController, UISearchResultsUpdating {
         
         @Binding var text: String

         init(text: Binding<String>) {
             _text = text
             super.init(nibName: nil, bundle: nil)
         }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
         func updateSearchResults(for searchController: UISearchController) {
             guard let searchText = searchController.searchBar.text else { return }
             text = searchText
         }
     
     }
}
