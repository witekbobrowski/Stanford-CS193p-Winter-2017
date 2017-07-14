//
//  TweetDetailTableViewController.swift
//  Smashtag
//
//  Created by Witek on 12/07/2017.
//  Copyright © 2017 Witek Bobrowski. All rights reserved.
//

import UIKit
import Twitter

class DetailTableViewController: UITableViewController {

    var dataSource: TweetDetailViewDataSouce?
    
    var tweet: Tweet? {
        willSet {
            dataSource = TweetDetailViewDataSouce(tweet: newValue!)
            title = newValue?.user.name
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource!.numberOfSections
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource!.numberOfRowsInSection(section: section)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch dataSource!.dataForRowAt(indexPath: indexPath) {
        // Programming Assingment 4 : Task 3
        case .image(let image):
            return view.bounds.width / CGFloat(image.aspectRatio)
        case .hashtag, .userMention, .url:
            return UITableViewAutomaticDimension
        }

    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        switch dataSource!.dataForRowAt(indexPath: indexPath) {
        case .image(let image):
            cell = tableView.dequeueReusableCell(withIdentifier: "imageCell", for: indexPath)
            if let cell = cell as? DetailImageTableViewCell {
                cell.imageURL = image.url
            }
        case .hashtag(let mention), .userMention(let mention), .url(let mention):
            cell = tableView.dequeueReusableCell(withIdentifier: "mentionCell", for: indexPath)
            if let cell = cell as? DetailMentionTableViewCell {
                cell.mentionLabel.text = mention.keyword
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Programming Assingment 4 : Task 7
        switch dataSource!.dataForRowAt(indexPath: indexPath) {
        case .image(let image):
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let imageView = storyboard.instantiateViewController(withIdentifier: "imageView") as! ImageViewController
            imageView.imageURL = image.url
            self.navigationController?.pushViewController(imageView, animated: true)
        // Programming Assingment 4 : Task 5
        case .hashtag(let mention), .userMention(let mention):
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let tweetsTableView = storyboard.instantiateViewController(withIdentifier: "tweetsTableView") as! TweetTableViewController
            tweetsTableView.searchText = mention.keyword
            self.navigationController?.pushViewController(tweetsTableView, animated: true)
        // Programming Assingment 4 : Task 6
        case .url(let url):
            UIApplication.shared.open(URL(string: url.keyword)!, options: [:], completionHandler: { print($0)})
        }
    }
    
    // Programming Assingment 4 : Task 4
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dataSource!.titleForHeaderInSection(section: section)
    }
}
