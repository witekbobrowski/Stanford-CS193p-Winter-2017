//
//  RecentsTableViewController.swift
//  Smashtag
//
//  Created by Witek on 14/07/2017.
//  Copyright © 2017 Witek Bobrowski. All rights reserved.
//

import UIKit

// Programming Assingment 4 : Task 8
class RecentsTableViewController: UITableViewController {

    var recents: Recents?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
    }

    @IBAction func refresh(_ sender: UIRefreshControl) {
        fetchData()
        tableView.reloadData()
    }
    
    private func fetchData() {
        if let data = UserDefaults.standard.data(forKey: "recents"),
            let fetchedRecents = NSKeyedUnarchiver.unarchiveObject(with: data) as? Recents {
            recents = fetchedRecents
        } else {
            recents = nil
        }
        self.refreshControl?.endRefreshing()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return recents == nil ? 0 : 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recents?.numberOfRows() ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mentionCell") as! DetailMentionTableViewCell
        cell.mentionLabel.text = recents?.dataForRowAt(indexPath: indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! DetailMentionTableViewCell
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let tweetsTableView = storyboard.instantiateViewController(withIdentifier: "tweetsTableView") as! TweetTableViewController
        tweetsTableView.searchText = cell.mentionLabel.text
        self.navigationController?.pushViewController(tweetsTableView, animated: true)
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if recents != nil {
            return "Searched keywords: \(recents!.numberOfRows()) "
        } else {
            return nil
        }
    }
}
