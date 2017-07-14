//
//  RecentsDataSource.swift
//  Smashtag
//
//  Created by Witek on 14/07/2017.
//  Copyright © 2017 Witek Bobrowski. All rights reserved.
//

import Foundation

class Recents: NSObject, NSCoding {

    typealias Keyword = String
    typealias Index = Int

    fileprivate var history: [Keyword]
    fileprivate var keywords: [Keyword:Index]
    
    override init() {
        self.history = []
        self.keywords = [:]
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.history = aDecoder.decodeObject(forKey: "history") as? Array<Keyword> ?? []
        self.keywords = aDecoder.decodeObject(forKey: "keywords") as? Dictionary<Keyword, Index> ?? [:]
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(history, forKey: "history")
        aCoder.encode(keywords, forKey: "keywords")
    }
    
    public func append(keyword: Keyword) {
        if let index = keywords[keyword.lowercased()] {
            history.remove(at: index)
        }
        if history.count < 100 {
            keywords[keyword.lowercased()] = history.count
            history.append(keyword)
        }
    }
    
}

//  UITableView supporting methods
extension Recents {

    public func numberOfRows() -> Int {
        return history.count
    }
    
    public func dataForRowAt(indexPath: IndexPath) -> Keyword {
        return history[history.count - indexPath.row - 1]
    }
}
