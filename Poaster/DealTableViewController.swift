//
//  DealTableViewController.swift
//  poaster
//
//  Created by Vinod Sobale on 3/21/16.
//  Copyright © 2016 Vinod Sobale. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class DealTableViewController: UITableViewController {
    
    var arr: [DealModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        get1PayDeals()
    }
    
    func get1PayDeals() {
        let prefs = NSUserDefaults.standardUserDefaults()
        if let AToken = prefs.stringForKey("authtoken"){
            print("Token \(AToken)")

            let hosturl = "\(HOST)/api/v1/user/poast_lists.json?auth_token=\(AToken)"
            
            Alamofire.request(.GET, hosturl, encoding: .JSON)
                .responseJSON {
                    response in debugPrint(response)// prints detailed description of all response properties
                    if let value = response.result.value {
                        let json = JSON(value)
                        if json["success"] == true {
                            
                            let data = json["data"]
                            
                            for i in 0 ..< data.count {
                                let poastname = String(data[i]["poast_name"])
                                let quantity = (data[i]["quantity"]).int
                                let availablestock = (data[i]["available_stock"]).int
                                let poastid = (data[i]["poast_id"]).int
                                
                                let deal = DealModel()
                                
                                deal.poast_name = poastname
                                deal.quantity = quantity!
                                deal.available_stock = availablestock!
                                deal.poast_id = poastid!
                                
                                self.arr.append(deal)
                            }
                            
                            self.tableView.reloadData()
                            
                            print("API Call Successful!")
                            
                        } else {
                            print("API Call Failed!")
                            let alert = UIAlertController(title: "Oops!", message: "No 1Pay deals available", preferredStyle: .Alert)
                            let firstAction = UIAlertAction(title: "Dismiss", style: .Default) { (alert: UIAlertAction!) -> Void in
                                self.navigationController!.popViewControllerAnimated(true)
                            }
                            
                            alert.addAction(firstAction)
                            self.presentViewController(alert, animated: true, completion:nil)
                        }
                    } // saving response in // let value
            }// Alamofire request
        }
    } // get1PayDeals
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("Cell") as! DealTableViewCell
        
        cell.PoastName.text = arr[indexPath.row].poast_name
        cell.Quantity.text = String(arr[indexPath.row].quantity)
        cell.AvailableStock.text = String(arr[indexPath.row].available_stock)
        
        return cell
    }
    
    /*
     // MARK: - Navigation
     
     */
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
        if segue.identifier == "OneDetailView" {
            let indexPath = self.tableView.indexPathForSelectedRow!
            let theSelectedRow = arr[indexPath.row]
            let PoastIDToBeSent = theSelectedRow.poast_id
            let OneDealTableVC = segue.destinationViewController as! OneDealTableViewController
            OneDealTableVC.PoastID = PoastIDToBeSent
        }
     }
 
    
}
