//
//  ViewController.swift
//  TempleNews
//
//  Created by Brijesh Nayak on 3/7/17.
//  Copyright © 2017 Brijesh Nayak. All rights reserved.
//

import UIKit
import Alamofire

// Struct to store news title, subtitle, content, postDate and image
struct feeds {
    let newsImage: UIImage!
    let newsTitle: String!
    let newsSubtitle: String!
    let newsContent: String!
}

class NewsTableViewController: UITableViewController {
    
    // typealias
    typealias JSONStandard = [String: AnyObject]
    
    // Storing array of struct "feeds" in an array for each news
    var allFeeds = [feeds]()
    
    var newsURL:String = "https://prd-mobile.temple.edu/banner-mobileserver/rest/1.2/feed?namekeys=feed1357134273663,feed1358196258785,feed1358197717016,feed1360620171888,feed1362405229000,feed1362406369942,feed1362405688434,feed1362405586009,feed1383143213597,feed1383143223191,feed1383143236812,feed1383143243155,feed1383143253860,feed1383143263909,feed1383143274415,feed1383143285101,feed1383143312318,feed1383143507786"

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Get json data from the temple news api
        Alamofire.request(newsURL).responseJSON { (response) in
            
            // calling parseData function to parse json
            self.parseData(JSONData: response.data!)
        }
        
    }
    
    // Function to parseJson returned by request
    func parseData (JSONData: Data) {
        
        do {
            
            // Storing JSON returned by the request as Dictionary of [String: AnyObject] 
            // Here using typeAlias "JSONStandard" instead of "[String: AnyObject]'
            var readableJSON = try JSONSerialization.jsonObject(with: JSONData, options: .mutableContainers) as! JSONStandard
            
            // Getting all the entries from the returned JSON, and storing it in a dictionary
            if let newsEntries = readableJSON["entries"] as? [JSONStandard]{
                
// "HOW?"       Here I want to load 10 news feed at a time but don't know how
                for i in 0..<11 {
                    
                    // Lopping through each entry
                    let entries = newsEntries[i]
                    
                    // Get news title
                    let newsTitle = entries["title"] as! String
                    
                    // Get news Subtitle
                    let newsSubtitle = entries["content"] as! String
                    
                    // Get news Image url
                    let newsImageURL = URL(string: entries["logo"] as! String)
                    let newsImageData = NSData(contentsOf: newsImageURL!)
                    
                    // Get actual image
                    let newsImage = UIImage(data: newsImageData as! Data)
                    
                    // Calling parseNewsContent function to parse news "content"
                    // parseNewsContent function is all the way down
                    let formatedContent = parseNewsContent(newsContent: newsSubtitle)

//                    print(formatedContent)
                    
                    // Adding newsTitle, newsImage, newsSubtile to allFeeds array as struct
                    allFeeds.append(feeds.init(newsImage: newsImage, newsTitle: newsTitle, newsSubtitle: formatedContent))
                    
                    // Reload table
                    self.tableView.reloadData()
                }
            }
            
            
//            print(readableJSON)
            
        }
        catch {
            print(error)
        }
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allFeeds.count
    }
    
    
    // use tag "1" for newsTitle
    // use tag "2" for newsImage
    // use tag "3" for newsSubtitle
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        
        let newsTitle = cell?.viewWithTag(1) as! UILabel
        let newsImage = cell?.viewWithTag(2) as! UIImageView
        let newsSubtitle = cell?.viewWithTag(3) as! UILabel
        
        // Make sure to check "clip to bounds" in Main.storyboard > attribute inspector for image view in table
        // Round corners
        newsImage.layer.cornerRadius = 8
        // Display image
        newsImage.image = allFeeds[indexPath.row].newsImage
        
        // Display Title
        newsTitle.text = allFeeds[indexPath.row].newsTitle
        
        // Display Subtitle
        newsSubtitle.text = allFeeds[indexPath.row].newsSubtitle
        
        return cell!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func parseNewsContent(newsContent: String) -> String {
        
        // This get rids of almost all HTML tags
        var formatedText = newsContent.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
        
        // This deletes "Subtitle:&nbsp;" which is in front of the subtitle/news description
        // TRY IT BY COMMENTING THIS STATEMENT AND PEINTING "formatedTExt" ON THE SCREEN
         formatedText = formatedText.replacingOccurrences(of: "Subtitle:&nbsp;", with: "", options: .regularExpression, range: nil)
    
        // To get the subtitle of the newsFeed
        // This returns an array which we can use to get news, we can loop through array starting from index 1 to get all the text
        formatedText = formatedText.components(separatedBy: "\n")[0]
//        print(formatedText)
        
        return formatedText;
    }

}

