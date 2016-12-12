//
//  FBPagesViewController.swift
//  poaster
//
//  Created by Vinod Sobale on 5/31/16.
//  Copyright © 2016 Vinod Sobale. All rights reserved.
//

import UIKit

class FBPagesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var PageNames: [String] = []
    
    @IBOutlet weak var PagesTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        PageNames = ["Page Name 1", "Page Name 2", "Page Name 3" , "Page Name 4", "Page Name 5"]
        
        // Do any additional setup after loading the view.
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PageNames.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CELL") as UITableViewCell!
        
        cell.textLabel?.text = PageNames[indexPath.row]
        
        return cell
    }

}
