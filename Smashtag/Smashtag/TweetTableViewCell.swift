//
//  TweetTableViewCell.swift
//  Smashtag
//
//  Created by Witek on 12/05/2017.
//  Copyright © 2017 Witek Bobrowski. All rights reserved.
//

import UIKit
import Twitter

class TweetTableViewCell: UITableViewCell {
    
    @IBOutlet weak var tweetProfileImageView: UIImageView!
    @IBOutlet weak var tweetCreatedLabel: UILabel!
    @IBOutlet weak var tweetUserLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    
    var tweet: Twitter.Tweet? { didSet { updateUI() } }
    
    private func updateUI() {
        tweetTextLabel?.attributedText = tweet?.attributedText
        tweetUserLabel?.text = tweet?.user.description
        if let profileImageURL = tweet?.user.profileImageURL {
            DispatchQueue.global(qos: .userInitiated).async{ [weak self] in
                if let imageData = try? Data(contentsOf: profileImageURL) {
                    DispatchQueue.main.async {
                        self?.tweetProfileImageView?.image = UIImage(data: imageData)
                    }
                }
            }
        } else {
            tweetProfileImageView?.image = nil
        }
        if let created = tweet?.created {
            let formatter = DateFormatter()
            if Date().timeIntervalSince(created) > 24*60*60 {
                formatter.dateStyle = .short
            } else {
                formatter.timeStyle = .short
            }
            tweetCreatedLabel?.text = formatter.string(from: created)
        } else {
            tweetCreatedLabel?.text = nil
        }
    }

}

// Programming Assingment 4 : Task 1
extension Twitter.Tweet {

    var attributedText: NSAttributedString {
        
        let text = NSMutableAttributedString(string: self.text)
        
        for hashtag in self.hashtags {
            text.addAttribute(NSForegroundColorAttributeName, value: UIColor.cyan, range: hashtag.nsrange)
        }
        
        for userMention in self.userMentions {
            text.addAttribute(NSForegroundColorAttributeName, value: UIColor.orange, range: userMention.nsrange)
        }
        
        for url in self.urls {
            text.addAttribute(NSForegroundColorAttributeName, value: UIColor.blue, range: url.nsrange)
        }
        
        return text
    }
}
