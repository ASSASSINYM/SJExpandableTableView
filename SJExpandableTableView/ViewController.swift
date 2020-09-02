//
//  ViewController.swift
//  SJExpandableTableView
//
//  Created by sabrina on 2020/9/2.
//  Copyright © 2020 sabrina. All rights reserved.
//

import UIKit

class ViewController: UIViewController,SJExpandableTableViewAble {
    var onBind: BindType?
    
    private lazy var mainTableView:SJExpandableTableView = {
        return SJExpandableTableView(frame: self.view.frame)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.addSubview(mainTableView)
        mainTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([mainTableView.topAnchor.constraint(equalTo: self.view.topAnchor),
                                     mainTableView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
                                     mainTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
                                     mainTableView.rightAnchor.constraint(equalTo: self.view.rightAnchor)])
        
        mainTableView = mainTableView.configuratorItemHeight(height: 45)
            .configuratorHeaderTitle(headerTitle: ["項目一","項目二","項目三"])
            .itemDidSelected { (index) in
                print(index.row)
        }.pullToRefresh(header: {
            print("pullToRefresh")
        }, footer: {
            print("footer")
        }).setDelegate(self)
        onBind = mainTableView.getBind()
        getData()
    }


    func getData() {
        var totalTitles:[[HeaderData]] = []
        var totalContents:[[[ContentData]]] = []
        (0..<4).forEach { (index) in
            totalTitles.append([HeaderData(text: "AAA"),
                                HeaderData(text: "BBB"),
                                HeaderData(text: "CCC")])
            var datas:[[ContentData]] = []
            datas.append([ContentData(text: .string(String(format: "Content1 %.2f", 0.5555))),
                          ContentData(text: .string(String(format: "Content1: %.2f", 0.666))),
                          ContentData(text: .string(String(format: "Content1: %.2f", 0.7777)))]
            )
            datas.append([ContentData(text: .string(String(format: "Content2: %d", 1.1))),
                          ContentData(text: .string(String(format: "Content2: %d", 1.2))),
                          ContentData(text: .string(String(format: "Content2: %.2f", 1.33)))])
            totalContents.append(datas)
        }
        self.onBind?(totalTitles, totalContents)
    }
}

