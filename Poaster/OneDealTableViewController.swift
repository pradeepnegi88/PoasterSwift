//
//  OneDealTableViewController.swift
//  poaster
//
//  Created by Vinod Sobale on 4/9/16.
//  Copyright © 2016 Vinod Sobale. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class OneDealTableViewController: UITableViewController {

    var PoastID: Int! = nil
    var SellerCustomerListArr: [SellerCustomerListModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        GetOneDeal(PoastID)
    }

    func GetOneDeal(poastid: Int) {
        let prefs = NSUserDefaults.standardUserDefaults()
        if let AToken = prefs.stringForKey("authtoken"){
            print("Token \(AToken)")

            let hosturl = "\(HOST)/api/v1/user/seller_customer_list.json?id=\(poastid)&auth_token=\(AToken)"
            
            Alamofire.request(.GET, hosturl, encoding: .JSON)
                .responseJSON {
                    response in debugPrint(response)// prints detailed description of all response properties
                    if let value = response.result.value {
                        let json = JSON(value)
                        if json["success"] == true {
                            
                            let data = json["data"]
                            
                            for i in 0 ..< data.count {
                                
                                let SellerCustomer = SellerCustomerListModel()
                                
                                SellerCustomer.order_id = String(data[i]["order_id"])
                                SellerCustomer.email = String(data[i]["email"])
                                SellerCustomer.item_quantity = (data[i]["item_quantity"]).int!
                                
                                self.SellerCustomerListArr.append(SellerCustomer)
                            }
                            self.tableView.reloadData()
                        } else {

                            // Create alert
                            let alertController = UIAlertController(title: "No sales yet!", message: "", preferredStyle: .Alert)
                            
                            let dismissAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Cancel) {
                                UIAlertAction in
                                self.navigationController?.popViewControllerAnimated(true)
                            }
                            alertController.addAction(dismissAction)
                            self.presentViewController(alertController, animated: true, completion: nil)

                        }
                    } // saving response in // let value
            }// Alamofire request
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SellerCustomerListArr.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
        let cell = self.tableView.dequeueReusableCellWithIdentifier("Cell") as! SellerCustomerListTableViewCell
        
        cell.UniqueID.text = String(SellerCustomerListArr[indexPath.row].order_id)
        cell.Email.text = String(SellerCustomerListArr[indexPath.row].email)
        cell.Quantity.text = String(SellerCustomerListArr[indexPath.row].item_quantity)
        
        return cell
    }
}
