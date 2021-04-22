//
//  Result.swift
//  BucketList
//
//  Created by admin on 21.04.2021.
//

import Foundation

struct Result: Codable {
    let query: Query
}

struct Query: Codable {
    let pages: [Int: Page]
}

struct Page: Codable, Comparable {
    let pageid: Int
    let title: String
    let terms: [String: [String]]?
    
    static func < (lsh: Page, rsh: Page) -> Bool {
        lsh.title < rsh.title
    }
    
    var description: String {
        terms?["description"]?.first ?? "NO information"
    }
}
