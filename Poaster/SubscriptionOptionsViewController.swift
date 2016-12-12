//
//  SubscriptionOptionsViewController.swift
//  poaster
//
//  Created by Poaster.
//  Copyright © 2016 Vinod Sobale. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import StoreKit
import BXProgressHUD


class SubscriptionOptionsViewController : UIViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    let prefs = NSUserDefaults.standardUserDefaults()
    var subscriptionType: Int! = nil
    
    var productsRequest : SKProductsRequest! = nil
    var products : [SKProduct] = []
    let paymentQueue = SKPaymentQueue.defaultQueue()
    var progressHud = BXProgressHUD()

    // @IBOutlet weak var yearlySubsButton: UIButton!
    @IBOutlet weak var monthlySubsButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        monthlySubsButton.layer.cornerRadius = 20
        monthlySubsButton.layer.borderColor = monthlySubsButton.titleLabel?.textColor.CGColor
        monthlySubsButton.layer.borderWidth = 2
        monthlySubsButton.clipsToBounds = true
        // Do any additional setup after loading the view.
        
        let productIdentifiers : Set<String> = ["poasterapp.monthly.subscription"]
        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        productsRequest.delegate = self
        productsRequest.start()
        
        view.addSubview(progressHud)
        progressHud.show()
        
        paymentQueue.restoreCompletedTransactions()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - IBActions
    
    
//    @IBAction func yearlyButtonTapped(sender: AnyObject) {
//        let payment = SKPayment(product: products[0])
//        paymentQueue.addTransactionObserver(self)
//        subscriptionType = 1
//        paymentQueue.addPayment(payment)
//        progressHud.show()
//    }
    
    // JUST KEEP THIS ONE
    @IBAction func monthlyButtonTapped(sender: AnyObject) {
        let payment = SKPayment(product: products[0])
        paymentQueue.addTransactionObserver(self)
        subscriptionType = 2
        paymentQueue.addPayment(payment)
        progressHud.show()
    }

    // MARK: - SKPaymentTransactionObserver
    
    func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) -> Void {
        progressHud.hide()
        print("went in at least")
        for transaction : SKPaymentTransaction in transactions {
            switch transaction.transactionState {
            case .Purchasing:
                    print("Purchasing")
                    break
            case .Purchased:
                paymentQueue.finishTransaction(transaction)
                print("Purchased")
                UpdateSubscriptionStatus("purchased")
                    break
            case .Restored:
                paymentQueue.finishTransaction(transaction)
                print("Restored")
                // UpdateSubscriptionStatus("restored")
                    break
            case .Failed:
                print("Failed")
                    break
            case .Deferred:
                print("Deferred")
                    break
            }
        }
    }
    
    // MARK: - SKProductsRequestDelegate

    func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) -> Void {
        progressHud.hide()
        for product in response.products {
            if products.contains(product) == false {
                products.append(product)
            }
        }
    }

    func UpdateSubscriptionStatus(TransactionType: String) {
        if let AToken = prefs.stringForKey("authtoken"){
            Alamofire.request(.POST, "\(HOST)/api/v1/user/create_subscription.json?subscription[device_type]=2&subscription[subscription_type]=\(subscriptionType)&subscription[plan_id]=\(subscriptionType)&auth_token=\(AToken)", encoding: .JSON)
                .responseJSON {
                    response in debugPrint(response)
                    // prints detailed description of all response properties
                    print(response.result.value)
                    if let value = response.result.value {
                        let json = JSON(value)
                        print(json)
                        if json["success"] == true {
                            print("SuccessFul")
                            if TransactionType == "purchased" {
                                self.performSegueWithIdentifier("BackToSetupSegue", sender: self)
                            } else if TransactionType == "restored" {
                                self.performSegueWithIdentifier("BackToCameraSegue", sender: self)
                            }
                        } else {
                            print("UnsuccessFul")
                        }
                    } // saving response in // let value
            }// Alamofire request
        }
    }

}
