//
//  HomeTableViewController.swift
//  Twitter
//
//  Created by Thu Do on 10/8/20.
//  Copyright © 2020 Dan. All rights reserved.
//

import UIKit

class HomeTableViewController: UITableViewController {
    
    var tweets = [NSDictionary]()
    var numTweets: Int!
    let tweetRefreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        loadTweets()
        tweetRefreshControl.addTarget(self, action: #selector(loadTweets), for: .valueChanged)
        tableView.refreshControl = tweetRefreshControl
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 150
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.loadTweets()
    }
    
    @objc func loadTweets(){
        numTweets = 20
        let tweetsUrl = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        let params = ["count":numTweets]
        TwitterAPICaller.client?.getDictionariesRequest(url: tweetsUrl, parameters: params, success: {
            (tweeties: [NSDictionary]) in
            
            self.tweets.removeAll()
            for tweet in tweeties{
                self.tweets.append(tweet)
            }
            self.tableView.reloadData()
            self.tweetRefreshControl.endRefreshing()
            
        }, failure: { (Error) in
            print("Could not retrieve tweets")
        })
    }
    
    func loadMoreTweets(){
        let tweetsUrl = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        numTweets = numTweets + 20
        let params = ["count":numTweets]
        TwitterAPICaller.client?.getDictionariesRequest(url: tweetsUrl, parameters: params, success: {
            (tweeties: [NSDictionary]) in
            
            self.tweets.removeAll()
            for tweet in tweeties{
                self.tweets.append(tweet)
            }
            self.tableView.reloadData()
            
        }, failure: { (Error) in
            print("Could not retrieve tweets")
        })
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == tweets.count{
            loadMoreTweets()
        }
    }
    
    @IBAction func onLogout(_ sender: Any) {
        TwitterAPICaller.client?.logout()
        self.dismiss(animated: true, completion: nil)
        UserDefaults.standard.set(false, forKey: "userLoggedIn")
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tweetCell", for: indexPath) as! TweetTableViewCell
        let user = tweets[indexPath.row]["user"] as! NSDictionary
        let username = user["name"] as? String
        let content = tweets[indexPath.row]["text"] as? String
        cell.tweetLabel.text = content
        cell.nameLabel.text = username
        let imageUrl = URL(string: (user["profile_image_url_https"] as? String)!)
        let data = try? Data(contentsOf: imageUrl!)
        if let imageData = data {
            cell.profileImageView.image = UIImage(data: imageData)
        }
        cell.setFavorite(tweets[indexPath.row]["favorited"] as! Bool)
        cell.tweetId = tweets[indexPath.row]["id"] as! Int
        cell.setRetweet(tweets[indexPath.row]["retweeted"] as! Bool)
        return cell
        
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tweets.count
    }

}
