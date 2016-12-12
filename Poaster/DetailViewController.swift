//
//  DetailViewController.swift
//  poaster
//
//  Created by Vinod Sobale on 4/1/16.
//  Copyright © 2016 Vinod Sobale. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var PoastID: Int! = nil
    
    @IBOutlet weak var TableView: UITableView!
    

    struct Customer {
        
        let customer_id: Int
        let poast_id: Int
        let email: String
        let order_id: String
        let poast_name: String
        let item_quantity: Int
    }
    
    var customers = [Customer]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        print(PoastID)
        
        getCustomerList()
        
        customers = [
            Customer(customer_id: 132, poast_id: 0, email: "vinod@poaster.us", order_id: "ab43533", poast_name: "Rolling Stones", item_quantity: 2),
            Customer(customer_id: 132, poast_id: 0, email: "sobale@poaster.us", order_id: "bc43533", poast_name: "Rolling Stones", item_quantity: 4),
            Customer(customer_id: 132, poast_id: 10, email: "chris@poaster.us", order_id: "cd43533", poast_name: "Rolling Stones", item_quantity: 6),
            Customer(customer_id: 132, poast_id: 0, email: "vinod@sobale.com", order_id: "de43533", poast_name: "Rolling Stones", item_quantity: 8),
            Customer(customer_id: 132, poast_id: 0, email: "vinod@poasterapp.com", order_id: "ef43533", poast_name: "Rolling Stones", item_quantity: 10),
            Customer(customer_id: 132, poast_id: 10, email: "sobale.sunita@poaster.us", order_id: "fg43533", poast_name: "Rolling Stones", item_quantity: 12),
            Customer(customer_id: 132, poast_id: 6, email: "vinod@poaster.us", order_id: "gh43533", poast_name: "Rolling Stones", item_quantity: 14),
            Customer(customer_id: 132, poast_id: 1, email: "vinod@poaster.us", order_id: "hi43533", poast_name: "Rolling Stones", item_quantity: 16),
            Customer(customer_id: 132, poast_id: 10, email: "vinod@poaster.us", order_id: "ij43533", poast_name: "Rolling Stones", item_quantity: 18),
            Customer(customer_id: 132, poast_id: 2, email: "vinod@poaster.us", order_id: "jk43533", poast_name: "Rolling Stones", item_quantity: 20),
            Customer(customer_id: 132, poast_id: 1, email: "vinod@poaster.us", order_id: "kl43533", poast_name: "Rolling Stones", item_quantity: 32),
        ]
        
    }
    
    func getCustomerList() {
        let prefs = NSUserDefaults.standardUserDefaults()
        if let AToken = prefs.stringForKey("authtoken"){
            print("Token \(AToken)")
            let hosturl = "\(HOST)/api/v1/user/seller_customer_list.json?id=\(PoastID)&auth_token=\(AToken)"
            
            Alamofire.request(.GET, hosturl,
                parameters: ["auth_token": AToken, "id": PoastID], encoding: .JSON)
                .responseJSON {
                    response in debugPrint(response)// prints detailed description of all response properties
                    if let value = response.result.value {
                        let json = JSON(value)
                        if json["success"] == true {
                            
                            print(json)
                            
                            print("API Call Successful!")
                            
                        } else {
                            print("API Call Failed!")
                        }
                    } // saving response in // let value
            }// Alamofire request
        }
    } // getCustomerList
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return customers.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.TableView.dequeueReusableCellWithIdentifier("CustomerCell", forIndexPath: indexPath) as! CustomerListTableViewCell
        
        cell.UniqueID.text = customers[indexPath.row].order_id
        cell.EmailAddress.text = customers[indexPath.row].email
        cell.Quantity.text = String(customers[indexPath.row].item_quantity)
        
        return cell
        
    }
}
