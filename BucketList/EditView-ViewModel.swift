//
//  EditView-ViewModel.swift
//  BucketList
//
//  Created by Yuri Gerasimchuk on 30.06.2022.
//

import Foundation

extension EditView {
    @MainActor class ViewModel: ObservableObject {
        enum LoadingState {
            case loading, loaded, failed
        }
        @Published var loadingState = LoadingState.loading
        @Published var pages = [Page]()
        @Published var name: String
        @Published var description: String
        
        var location: Location
        
        init(location: Location) {
            self.location = location
            
            _name = Published(initialValue: location.name)
            _description = Published(initialValue: location.description)
        }
        
        func fetchNearbyPlaces() async {
            let urlString = "https://en.wikipedia.org/w/api.php?ggscoord=\(location.coordinate.latitude)%7C\(location.coordinate.longitude)&action=query&prop=coordinates%7Cpageimages%7Cpageterms&colimit=50&piprop=thumbnail&pithumbsize=500&pilimit=50&wbptterms=description&generator=geosearch&ggsradius=10000&ggslimit=50&format=json"
            
            guard let url = URL(string: urlString) else {
                print("Bad URL: \(urlString)")
                return
            }
            
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                // We got some data back!
                let items = try JSONDecoder().decode(Result.self, from: data)
                // Success - convert the array values to our pages array
                pages = items.query.pages.values.sorted()
                loadingState = .loaded
            } catch {
                // If we are still here it means the request failed
                loadingState = .failed
            }
            
        }
        
        func updateTagLocation() -> Location {
            var newLocation = location
            newLocation.id = UUID()
            newLocation.name = name
            newLocation.description = description
            return newLocation
        }
    }
    
}
