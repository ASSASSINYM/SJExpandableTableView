//
//  ViewController.swift
//  SJExpandableTableView
//
//  Created by sabrina on 2020/9/2.
//  Copyright © 2020 sabrina. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
   
    @IBOutlet weak var tableView: UITableView!
    
    private let datasource:[String] = ["Fixed Height with Default cell", "Dynamic Height with Custom cell"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.textLabel?.text = datasource[indexPath.row]
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 1:
            let dynamic = self.storyboard?.instantiateViewController(identifier: "DynamicViewController") as! DynamicViewController
            self.navigationController?.show(dynamic, sender: nil)
        default:
            let fixed = self.storyboard?.instantiateViewController(identifier: "FixedHeightViewController") as! FixedHeightViewController
            self.navigationController?.show(fixed, sender: nil)
        }
    }
}
