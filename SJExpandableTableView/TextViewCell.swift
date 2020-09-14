//
//  TextViewCell.swift
//  SJExpandableTableView
//
//  Created by Eileen on 2020/9/14.
//  Copyright © 2020 sabrina. All rights reserved.
//

import UIKit

class TextViewCell: UITableViewCell {
    
    
    weak var delegate:ExpandableItemCellDelegate?
    private var cellIndex:Int?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            delegate?.tapExpandableItemCell(cellIndex)
        }
    }
    
    func setupData(index:Int, mDelegate:ExpandableItemCellDelegate) {
        cellIndex = index
        delegate = mDelegate
    }
    
}
