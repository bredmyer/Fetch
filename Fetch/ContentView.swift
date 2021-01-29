//
//  ContentView.swift
//  Fetch
//
//  Created by Brennon Redmyer on 10/12/20.
//

import SwiftUI

struct ItemRow: View {
    var item: Item;
    
    var body: some View {
        Text(item.name!)
    }
}

struct ContentView: View {
    @State private var items = [Item]()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(listIds(), id: \.self) { listId in
                    Section(header: Text("\(listId)")) {
                        ForEach(items(for: listId), id: \.self) { item in
                            ItemRow(item: item)
                        }
                    }
                }
            }
            .onAppear(perform: loadData)
            .navigationBarTitle(Text("Items"))
        }
    }
}

extension ContentView {
    func loadData() {
        // Set up the URLSession
        let urlString = "https://fetch-hiring.s3.amazonaws.com/hiring.json"
        guard let url = URL(string: urlString) else {
            print("Error converting \(urlString) to URL object")
            return
        }
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                // Define the type we expect the data to be formatted as and decode it
                // In this case, it will be an array of Codable type 'Item'
                let type = [Item].self
                if let responseObject = try? JSONDecoder().decode(type, from: data) {
                    DispatchQueue.main.async {
                        // Filter any items with 'null' or blank name value
                        self.items = responseObject.filter { $0.name != nil && $0.name != ""}
                    }
                } else {
                    // 'error' may be nil; in case of unspecified problems provide a generic error
                    print(error?.localizedDescription ?? "Error decoding JSON into \(type)")
                }
            } else {
                // 'error' may be nil; in case of unspecified problems provide a generic error
                print(error?.localizedDescription ?? "Error loading data from URL")
            }
        }.resume()
    }
    
    func listIds() -> [Int] {
        var listIds: [Int] = []
        // Iterate thru every item and when we encounter a unique listId, add it to the 'listIds' array
        for item in self.items {
            if !listIds.contains(item.listId) {
                listIds.append(item.listId)
            }
        }
        // Return the listIds sorted in ascending order
        return listIds.sorted { $0 < $1 }
    }
    
    func items(for listId: Int) -> [Item] {
        var items: [Item] = []
        // Iterate thru every item with the specified listId and add it to the local 'items' array
        for item in self.items {
            if item.listId == listId {
                items.append(item)
            }
        }
        // Return the items with the specified listId sorted in ascending order by name
        return items.sorted { $0.name!.localizedStandardCompare($1.name!) == .orderedAscending }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
