//
//  DynamicViewController.swift
//  SJExpandableTableView
//
//  Created by sabrina on 2020/12/1.
//  Copyright © 2020 sabrina. All rights reserved.
//

import UIKit

class DynamicViewController: UIViewController, SJExpandableTableDataSource {
    var binding: BindData = BindData()

    
    private lazy var mainTableView:SJExpandableTableView = {
        return SJExpandableTableView(frame: self.view.frame, style: .plain)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(mainTableView)
        mainTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([mainTableView.topAnchor.constraint(equalTo: self.view.topAnchor),
                                     mainTableView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
                                     mainTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
                                     mainTableView.rightAnchor.constraint(equalTo: self.view.rightAnchor)])
        
        mainTableView
            .configureItem(height: 45)
            .configureHeader(titles: ["項目一","項目二","項目三"])
            .configureNibCell(cellIDs: ["TextViewCell"])
            .configureDelegate(self)
            .configureItemCell { [weak self] (tb, indexPath, headers, contents, selectedIndex) -> UITableViewCell? in
                guard let weak = self else { return nil }
                let cell = tb.dequeueReusableCell(withIdentifier: "TextViewCell", for: indexPath) as! TextViewCell
                cell.setupData(index: indexPath.row, mDelegate: weak.mainTableView)
                return cell
            }.configureItemCellForHeight { (tb, indexPath, selectedIndex, content) -> CGFloat in
                if let current = selectedIndex, current == indexPath.row {
                    return indexPath.row % 2 == 0 ? 90 : 270
                }
                return 45
            }.itemTitleDidSelected(completed: { _ in })

        self.binding.bind(to: mainTableView)
        
        getData()
    }

    private func getData() {
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
        self.binding.onBind?(totalTitles, totalContents)
    }
}
