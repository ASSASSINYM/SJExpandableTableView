//
//  FixedHeightViewController.swift
//  SJExpandableTableView
//
//  Created by sabrina on 2020/12/1.
//  Copyright © 2020 sabrina. All rights reserved.
//

import UIKit

class FixedHeightViewController: UIViewController, SJExpandableTableDataSource {
    
    var binding: BindData = BindData()
    private var num : Int = 1
    
    @IBOutlet weak var mainTableView: SJExpandableTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(mainTableView)
        mainTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([mainTableView.topAnchor.constraint(equalTo: self.view.topAnchor),
                                     mainTableView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
                                     mainTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
                                     mainTableView.rightAnchor.constraint(equalTo: self.view.rightAnchor)])
        
        mainTableView
            .configureHeaderView(configureView: { (tb, index) -> UITableViewHeaderFooterView? in
                let v = UITableViewHeaderFooterView()
                return v
            })
            // normal status's height
            .configureItem(height: 45)
            // top title
            .configureHeader(titles: ["項目一","項目二","項目三"])
            // allow mutilple selected, dafault is false
            .configureMultipleCollapse(true)
            // conform to the SJExpandableTableDataSource protocol
            .configureDelegate(self)
            // need pull refresh
            .pullToRefresh(header: { [weak self] in
                self?.perform(#selector(self?.getData), with: nil, afterDelay: 1.0)
            }, footer: { [weak self]  in
                self?.perform(#selector(self?.getData2), with: nil, afterDelay: 1.0)
            })
            // collapse tableView header
            .itemTitleDidSelected { _ in }
            // collapse tableView cell
            .itemContentDidSelected { [weak self] (index) in
                Log.info(index.row)
                self?.showDialog("\(index.row)")
            }

        // binding data
        self.binding.bind(to: mainTableView)
        
        getData()
    }
    
    private func showDialog(_ msg:String) {
        let alert = UIAlertController(title: "Tap", message: String(format: "%@", msg), preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc private func getData() {
        var totalTitles:[[HeaderData]] = []
        var totalContents:[[[ContentData]]] = []
        (0..<10).forEach { (index) in
            totalTitles.append([HeaderData(text: "AAA"),
                                HeaderData(text: "BBB"),
                                HeaderData(text: "CCC")])
            var datas:[[ContentData]] = []
            datas.append([ContentData(text: .string(String(format: "Content1: %.2f", 0.5555))),
                          ContentData(text: .string(String(format: "Content1: %.2f", 0.666))),
                          ContentData(text: .string(String(format: "Content1: %.2f", 0.7777)))])
            datas.append([ContentData(text: .string(String(format: "Content2: %d", 1.1))),
                          ContentData(text: .string(String(format: "Content2: %d", 1.2))),
                          ContentData(text: .string(String(format: "Content2: %.2f", 1.33)))])
            totalContents.append(datas)
        }
        self.binding.onBind?(totalTitles, totalContents)
    }
    
    @objc private func getData2() {
        num += 1
        var totalTitles:[[HeaderData]] = []
        var totalContents:[[[ContentData]]] = []
        (0..<((10*num)+20)).forEach { (index) in
            totalTitles.append([HeaderData(text: "AAA"),
                                HeaderData(text: "BBB"),
                                HeaderData(text: "CCC")])
            var datas:[[ContentData]] = []
            datas.append([ContentData(text: .string(String(format: "Content1: %.2f", 0.5555))),
                          ContentData(text: .string(String(format: "Content1: %.2f", 0.666))),
                          ContentData(text: .string(String(format: "Content1: %.2f", 0.7777)))])
            datas.append([ContentData(text: .string(String(format: "Content2: %d", 1.1))),
                          ContentData(text: .string(String(format: "Content2: %d", 1.2))),
                          ContentData(text: .string(String(format: "Content2: %.2f", 1.33)))])
            totalContents.append(datas)
        }
        self.binding.onBind?(totalTitles, totalContents)
    }
}
