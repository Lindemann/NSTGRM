//
//  TableViewController.swift
//  NSTGRM
//
//  Created by Lindemann on 23/06/15.
//  Copyright (c) 2015 Lindemann. All rights reserved.
//

import UIKit
import Alamofire
import SimpleAuth
import SwiftyJSON
import Locksmith

private let kKeychainAccountName = "Instagram"
private let kKeychainKeyName = "accessToken"

class TableViewController: UITableViewController {
	
	var data: [JSON] = []
	var accessToken: String?
	var nextPageURL: String?
	var isLoadingData = false
	

    override func viewDidLoad() {
        super.viewDidLoad()
		
		refreshControl = UIRefreshControl()
		refreshControl?.addTarget(self, action: "refreshData", forControlEvents: UIControlEvents.ValueChanged)
		
		let (dictionary, error) = Locksmith.loadDataForUserAccount(kKeychainAccountName)
		if error == nil {
			accessToken = dictionary?.valueForKey(kKeychainKeyName) as? String
			if accessToken != nil {
				loadPhotos()
			} else {
				instagramOAuth()
			}
		} else {
			instagramOAuth()
		}
	}
	
	func instagramOAuth() {
		SimpleAuth.configuration()["instagram"] = [
			"client_id" : "b9b36a40f64440a29ae5f532d8780069",
			SimpleAuthRedirectURIKey : "http://nstgrm.awwapps.com"
		]
		
		SimpleAuth.authorize("instagram", completion: { responseObject, error in
			if responseObject != nil {
				let json = JSON(responseObject)
				self.accessToken = json["credentials"]["token"].string!
				if self.accessToken != nil {
					Locksmith.saveData([kKeychainKeyName: self.accessToken!], forUserAccount: kKeychainAccountName)
					self.loadPhotos()
				}
			}
		})
	}
	
	@IBAction func logout(sender: UIBarButtonItem) {
		Locksmith.deleteDataForUserAccount(kKeychainAccountName)
		data = []
		tableView.reloadData()
		accessToken = nil
		instagramOAuth()
	}
	
	func refreshData() {
		loadPhotos { (success) -> Void in
			if success {
				self.data = []
			}
		}
	}
	
	func loadPhotos(var url: String? = nil, completionHandler: ((success: Bool) -> ()) = { (success) -> () in }) {
		if url == nil {
			if accessToken != nil {
				url = "https://api.instagram.com/v1/tags/cat/media/recent?access_token=\(accessToken!)"
			} else {
				instagramOAuth()
				self.refreshControl?.endRefreshing()
				return
			}
		}
		isLoadingData = true
		UIApplication.sharedApplication().networkActivityIndicatorVisible = true
		Alamofire.request(.GET, url!).responseJSON { (_, _, json, _) in
			if json != nil {
				var jsonObject = JSON(json!)
				//println(json!)
				if let newData = jsonObject["data"].array {
					completionHandler(success: true)
					self.data += newData
					dispatch_async(dispatch_get_main_queue(),{
						self.tableView.reloadData()
						self.isLoadingData = false
						UIApplication.sharedApplication().networkActivityIndicatorVisible = false
						self.refreshControl?.endRefreshing()
					})
				}
				if let nextPageURL = jsonObject["pagination"]["next_url"].string {
					self.nextPageURL = nextPageURL
					//println(self.nextPageURL!)
				}
			}
		}
	}
	
	func loadMorePhotos() {
		if nextPageURL != nil {
			loadPhotos(url: nextPageURL)
		}
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count ?? 0
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! TableViewCell
		cell.photoInfo = data[indexPath.row]
		if indexPath.row == data.count - 1 && isLoadingData == false {
			loadMorePhotos()
		}
		return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
