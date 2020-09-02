//
//  ExpandableHeaderView.swift
//  IntegratedProject
//
//  Created by sabrina on 2020/1/7.
//  Copyright © 2020 JK. All rights reserved.
//

import UIKit

class ExpandableHeaderView: UITableViewHeaderFooterView {
    
    @IBOutlet weak var viewTop: UIStackView!

    func setupTitle(mTitle:[String], mScale:[Float]) {
        guard viewTop.arrangedSubviews.count == 0 else { return }
        for value in mTitle {
            let label = UILabel(frame: .zero)
            label.text = value
            label.textColor = UIColor.black
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 13)
            label.backgroundColor = UIColor.clear
            viewTop.addArrangedSubview(label)
        }
        
        viewTop.arrangedSubviews.enumerated().forEach { (index, element) in
            let scale = mScale[index]
            let multiplier = CGFloat(scale / Float(mTitle.count))
            element.widthAnchor.constraint(equalTo: viewTop.widthAnchor, multiplier: multiplier).isActive = true
        }
    }
}
