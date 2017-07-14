//
//  TweetDetailViewDataSource.swift
//  Smashtag
//
//  Created by Witek on 12/07/2017.
//  Copyright © 2017 Witek Bobrowski. All rights reserved.
//

import Foundation
import Twitter

class TweetDetailViewDataSouce {
    
    public var sections: [TweetDetailViewSection] = []

    public var numberOfSections: Int {
        return sections.count
    }
    
    public func numberOfRowsInSection(section: Int) -> Int {
        switch sections[section] {
        case .images(let images):
            return images.count
        case .hashtags(let hashtags):
            return hashtags.count
        case .userMentions(let userMentions):
            return userMentions.count
        case .urls(let urls):
            return urls.count
        }
    }
    
    public func titleForHeaderInSection(section: Int) -> String {
        switch sections[section] {
        case .images:
            return "Images"
        case .hashtags:
            return "Hashtags"
        case .userMentions:
            return "User Mentions"
        case .urls:
            return "URLs"
        }
    }
    
    public func dataForRowAt(indexPath: IndexPath) -> TweetDetailViewRow {
        switch sections[indexPath.section] {
        case .images(let images):
            return TweetDetailViewRow.image(images[indexPath.row])
        case .hashtags(let hashtags):
            return TweetDetailViewRow.hashtag(hashtags[indexPath.row])
        case .userMentions(let userMentions):
            return TweetDetailViewRow.userMention(userMentions[indexPath.row])
        case .urls(let urls):
            return TweetDetailViewRow.url(urls[indexPath.row])
        }
    }
    
    init(tweet: Twitter.Tweet) {
        if !tweet.media.isEmpty {
            sections.append(TweetDetailViewSection.images(tweet.media))
        }
        if !tweet.hashtags.isEmpty {
            sections.append(TweetDetailViewSection.hashtags(tweet.hashtags))
        }
        if !tweet.userMentions.isEmpty {
            sections.append(TweetDetailViewSection.userMentions(tweet.userMentions))
        }
        if !tweet.urls.isEmpty {
            sections.append(TweetDetailViewSection.urls(tweet.urls))
        }
    }
    
    
}

enum TweetDetailViewSection {
    case images([MediaItem])
    case hashtags([Mention])
    case userMentions([Mention])
    case urls([Mention])
}

enum TweetDetailViewRow {
    case image(MediaItem)
    case hashtag(Mention)
    case userMention(Mention)
    case url(Mention)
}
