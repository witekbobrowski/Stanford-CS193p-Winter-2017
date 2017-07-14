//
//  TweetTableViewController.swift
//  Smashtag
//
//  Created by Witek on 12/05/2017.
//  Copyright © 2017 Witek Bobrowski. All rights reserved.
//

import UIKit
import Twitter


class TweetTableViewController: UITableViewController, UITextFieldDelegate {

    private var tweets = [Array<Twitter.Tweet>]()
    var recents = Recents()
    
    var searchText: String? {
        didSet {
            fetchRecents()
            recents.append(keyword: searchText!)
            let encodedData = NSKeyedArchiver.archivedData(withRootObject: recents)
            UserDefaults.standard.set(encodedData, forKey: "recents")
            searchTextField?.text = searchText
            searchTextField?.resignFirstResponder()
            lastTwitterRequest = nil
            tweets.removeAll()
            tableView.reloadData()
            searchForTweets()
            title = searchText
        }
    }
    
    func insertTweets(_ newTweets: [Twitter.Tweet]) {
        self.tweets.insert(newTweets, at: 0)
        self.tableView.insertSections([0], with: .fade)
    }
    
    private func twitterRequest() -> Twitter.Request? {
        if let query = searchText, !query.isEmpty {
            return Twitter.Request(search: "\(query) - filter:safe -filter:retweets", count: 100)
        }
        return nil
    }
    
    private var lastTwitterRequest: Twitter.Request?
    
    private func searchForTweets() {
        if let request = lastTwitterRequest?.newer ?? twitterRequest() {
            lastTwitterRequest = request
            request.fetchTweets { [weak self] newTweets in
                // Programming Assingment 4 : Task 9
                DispatchQueue.main.async {
                    if request == self?.lastTwitterRequest{
                        self?.insertTweets(newTweets)
                    }
                    self?.refreshControl?.endRefreshing()
                }
            }
        } else {
            self.refreshControl?.endRefreshing()
        }
    }
    
    @IBAction func refresh(_ sender: UIRefreshControl) {
        searchForTweets()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        fetchRecents()
    }
    
    
    private func fetchRecents() {
        if let data = UserDefaults.standard.data(forKey: "recents"),
            let fetchedRecents = NSKeyedUnarchiver.unarchiveObject(with: data) as? Recents {
            recents = fetchedRecents
        }
    }

    @IBOutlet weak var searchTextField: UITextField! {
        didSet {
            searchTextField.delegate = self
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == searchTextField {
            searchText = searchTextField.text
        }
        return true
    }
    
    // MARK: - UITableViewDataSource
   
    override func numberOfSections(in tableView: UITableView) -> Int {
        return tweets.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets[section].count
    }
    
    // Programming Assingment 4 : Task 2
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! TweetTableViewCell
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let detailTableViewController = storyboard.instantiateViewController(withIdentifier: "tweetDetailTableView") as! DetailTableViewController
        detailTableViewController.tweet = cell.tweet
        self.navigationController?.pushViewController(detailTableViewController, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Tweet", for: indexPath)
        let tweet: Twitter.Tweet = tweets[indexPath.section][indexPath.row]
        if let tweetCell = cell as? TweetTableViewCell {
            tweetCell.tweet = tweet
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "\(tweets.count-section)"
    }
    

}
