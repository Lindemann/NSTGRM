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

private let CLIENT_ID = "b9b36a40f64440a29ae5f532d8780069"
private let REDIRECT_URI = "http://nstgrm.awwapps.com"

private let keychainAccountName = "Instagram"

class TableViewController: UITableViewController {
	
	var data: [JSON] = []
	var accessToken: String?
	var userID: String?
	var nextPageURL: String?
	var isLoadingData = false
	
	// MARK: - Lifecycle

	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Add pull to refresh
		refreshControl = UIRefreshControl()
		refreshControl?.addTarget(self, action: "refreshData", forControlEvents: UIControlEvents.ValueChanged)
		
		// Define TableViewCell height
		tableView.rowHeight = tableView.bounds.width / 2
		tableView.separatorColor = UIColor.clearColor()
		
		// Add icon to NavBar
		var titleView : UIImageView
		let maxSize: CGFloat = 26
		titleView = UIImageView(frame:CGRectMake(0, 0, maxSize, maxSize))
		titleView.contentMode = .ScaleAspectFit
		titleView.image = UIImage(named: "camera")
		self.navigationItem.titleView = titleView
		
		getAccessTokenFromKeychain()
	}
	
	// MARK: - Table view data source
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return data.count ?? 0
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! TableViewCell
		
		if let urlString = data[indexPath.row]["images"]["standard_resolution"]["url"].string {
			let url = NSURL(string: urlString)
			cell.imageView!.frame = CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)
			cell.imageView!.hnk_setImageFromURL(url!)
		}
		
		let likes = data[indexPath.row]["likes"]["count"]
		cell.likesView.likes = likes.int!
		
		if indexPath.row == data.count - 1 && !isLoadingData {
			loadMorePhotos()
		}
		return cell
	}
	
	// MARK: - Fullscreen for images
	
	var fullscreenImageBackgroundView = UIView()
	let animationDuration = 0.4
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let window = UIApplication.sharedApplication().keyWindow

		fullscreenImageBackgroundView.frame = window!.frame
		fullscreenImageBackgroundView.backgroundColor = UIColor(red:0, green:0, blue:0, alpha:0.95)
		
		
		let imageView = UIImageView(frame: CGRectMake(0, 0, fullscreenImageBackgroundView.bounds.size.width, fullscreenImageBackgroundView.bounds.size.width))
		imageView.center = fullscreenImageBackgroundView.center
		fullscreenImageBackgroundView.addSubview(imageView)
		
		if let urlString = data[indexPath.row]["images"]["standard_resolution"]["url"].string {
			let url = NSURL(string: urlString)
			imageView.hnk_setImageFromURL(url!)
		}

		let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("handleTap"))
		fullscreenImageBackgroundView.addGestureRecognizer(tapGestureRecognizer)

		fullscreenImageBackgroundView.frame.origin.y = window!.frame.size.height * 2
		window?.addSubview(fullscreenImageBackgroundView)
		
		UIView.animateWithDuration(animationDuration, animations: {
			self.fullscreenImageBackgroundView.frame.origin.y = window!.frame.origin.y
			self.tableView.allowsSelection = false
			}, completion: { finished in
		})
	}
	
	func handleTap() {
		let window = UIApplication.sharedApplication().keyWindow
		
		UIView.animateWithDuration(animationDuration, animations: {
			self.fullscreenImageBackgroundView.frame.origin.y = window!.frame.size.height * 2
			}, completion: { finished in
				self.fullscreenImageBackgroundView.removeFromSuperview()
				self.tableView.allowsSelection = true
		})
	}
	
	// MARK: - Get Access to API and Fetching Data Stuff
	
	func getAccessTokenFromKeychain() {
		let (dictionary, error) = Locksmith.loadDataForUserAccount(keychainAccountName)
		if error == nil {
			userID = dictionary?.allKeys[0] as? String
			accessToken = dictionary?.valueForKey(userID!) as? String
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
			"client_id" : CLIENT_ID,
			SimpleAuthRedirectURIKey : REDIRECT_URI
		]
		
		SimpleAuth.authorize("instagram", completion: { responseObject, error in
			if responseObject != nil {
				let json = JSON(responseObject)
				self.accessToken = json["credentials"]["token"].string!
				self.userID = json["uid"].string!
				if self.accessToken != nil && self.userID != nil {
					Locksmith.saveData([self.userID!: self.accessToken!], forUserAccount: keychainAccountName)
					self.loadPhotos()
				}
			}
		})
	}
	
	@IBAction func logout(sender: UIBarButtonItem) {
		Locksmith.deleteDataForUserAccount(keychainAccountName)
		data = []
		tableView.reloadData()
		accessToken = nil
		instagramOAuth()
	}
	
	func refreshData() {
		loadPhotos { (success) -> () in
			if success {
				self.data = []
			}
		}
	}
	
	func loadPhotos(var url: String? = nil, completionHandler: ((success: Bool) -> ()) = { (success) -> () in }) {
		if url == nil {
			if accessToken != nil {
				// Cats
				//url = "https://api.instagram.com/v1/tags/cat/media/recent?access_token=\(accessToken!)"
				// Gernot
				url = "https://api.instagram.com/v1/users/342262/media/recent/?access_token=\(accessToken!)"
				// User
				//url = "https://api.instagram.com/v1/users/\(userID!)/media/recent/?access_token=\(accessToken!)"
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
				}
			}
		}
	}
	
	func loadMorePhotos() {
		if nextPageURL != nil {
			loadPhotos(url: nextPageURL)
		}
	}
}
