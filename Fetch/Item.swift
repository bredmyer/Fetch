//
//  Item.swift
//  Fetch
//
//  Created by Brennon Redmyer on 10/12/20.
//

import Foundation

struct Item: Codable, Hashable {
    let id: Int
    let listId: Int
    let name: String?
}
