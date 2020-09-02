//
//  ExpandableItemCell.swift
//  IntegratedProject
//
//  Created by sabrina on 2020/1/8.
//  Copyright © 2020 JK. All rights reserved.
//

import UIKit
protocol ExpandableItemCellDelegate : class {
    func tapExpandableItemCell(_ index:Int?)
}

class ExpandableItemCell: UITableViewCell {

    @IBOutlet weak var stackBottomBorderLine: UIView!
    @IBOutlet weak var viewBack: UIStackView!
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    @IBOutlet weak var viewTop: UIStackView!
    @IBOutlet weak var viewBottom: UIStackView!
    @IBOutlet weak var imgArrow: UIImageView!
    @IBOutlet weak var btnExpand: UIButton!
    @IBOutlet weak var viewTopHeight: NSLayoutConstraint!
    
    weak var delegate:ExpandableItemCellDelegate?
    private var cellIndex:Int?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
        
        self.imgArrow.transform = CGAffineTransform(rotationAngle: -CGFloat(Double.pi/2))
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func setupData(mTitles:[HeaderData], mContent:[[ContentData]], index:Int, isExpand:Bool ,mDelegate:ExpandableItemCellDelegate?, itemHeight:CGFloat = 30, mScale:[Float]) {

        self.viewTopHeight.constant = itemHeight
        self.viewHeight.constant = itemHeight
        self.viewBack.needsUpdateConstraints()
        
        for view in viewTop.arrangedSubviews {
            viewTop.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        for view in viewBottom.arrangedSubviews {
            viewBottom.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        if isExpand {
            self.imgArrow.transform = .identity
            self.viewBottom.isHidden = false

        }else{
            self.imgArrow.transform = CGAffineTransform(rotationAngle: -CGFloat(Double.pi/2))
            self.viewBottom.isHidden = true
        }

        delegate = mDelegate
        cellIndex = index
        setupView(index: index)

        for title in mTitles {
            if title.text.contains("</"), let attrStr = title.text.htmlToAttributedString {
                let textView = UITextView()
                textView.font = UIFont.systemFont(ofSize: 13)
                textView.backgroundColor = getBackgroundColor(index: index)
                textView.attributedText = attrStr
                viewTop.addArrangedSubview(textView)
            }else{
                let label = UILabel()
                label.text = title.text
                label.textColor = title.color
                label.font = UIFont.systemFont(ofSize: 13)
                label.textAlignment = .center
                label.backgroundColor = getBackgroundColor(index: index)
                // scale text size if it doesn't not fit in
                label.adjustsFontSizeToFitWidth = true
                label.minimumScaleFactor = 0.5
                viewTop.addArrangedSubview(label)
            }
        }
        for i in 0..<mContent.count {
            let data = mContent[i]
            let backView = UIView()

            backView.backgroundColor = .clear
            let stack = createNewStackView(itemHeight: itemHeight)
            for item in data {
                stack.addArrangedSubview(getNewLabel(item: item, itemHeight: itemHeight))
            }
            backView.addSubview(stack)
            stack.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([stack.topAnchor.constraint(equalTo: backView.topAnchor),
                                         stack.leftAnchor.constraint(equalTo: backView.leftAnchor),
                                         stack.rightAnchor.constraint(equalTo: backView.rightAnchor),
                                         stack.bottomAnchor.constraint(equalTo: backView.bottomAnchor)])
            backView.backgroundColor = .clear
            viewBottom.addArrangedSubview(backView)
        }
        
        if viewBottom.arrangedSubviews.count == 0 {
            imgArrow.isHidden = true
        }
        
        if viewTop.arrangedSubviews.count != 0 {
            viewTop.arrangedSubviews.enumerated().forEach { (index, element) in
                let scale = mScale[index]
                let multiplier = CGFloat(scale / Float(mTitles.count))
                element.widthAnchor.constraint(equalTo: viewTop.widthAnchor, multiplier: multiplier).isActive = true
            }
        }
        
    }

    private func setupView(index:Int) {
        if index % 2 == 0 {
            self.backgroundColor = UIColor.white
        }else{
            self.backgroundColor = UIColor.clear
        }
    }
    
    private func getBackgroundColor(index:Int) -> UIColor {
        if index % 2 == 0 {
            return UIColor(red: 233/255, green: 233/255, blue: 233/255, alpha: 1)
        }else{
            return UIColor(red: 214/255, green: 214/255, blue: 214/255, alpha: 1)
        }
    }
    
    private func createNewStackView(itemHeight:CGFloat) -> UIStackView {
        let stack = UIStackView()
        stack.distribution = .fillEqually
        stack.axis = .horizontal
        stack.frame.size.height = itemHeight
        stack.spacing = 10
        return stack
    }
    
    private func getNewLabel(item:ContentData, itemHeight:CGFloat) -> UILabel {
        let label = UILabel()
        switch item.text {
        case .string(let str):
            label.text = str
            label.textColor = item.color
        case .attributed(_):
            label.attributedText = item.attr
        }
        label.textAlignment = item.align
        label.font = UIFont.systemFont(ofSize: 12)
        label.frame.size.height = itemHeight
        label.numberOfLines = 0
        return label
    }
    
    @IBAction func tapAction(_ sender: Any) {
        if imgArrow.transform == .identity {
            hideExpandView()
        }else{
            showExpandView()
        }
        delegate?.tapExpandableItemCell(cellIndex)
    }
    
    private func showExpandView() {
        self.imgArrow.transform = CGAffineTransform(rotationAngle: -CGFloat(Double.pi/2)) //打開
        UIView.animate(withDuration: 0.3) { [unowned self] in
            self.layoutIfNeeded()
        }
    }
    
    private func hideExpandView() {
        self.imgArrow.transform = .identity //收起來
        UIView.animate(withDuration: 0.3) { [unowned self] in
            self.layoutIfNeeded()
        }
    }
    
    deinit {
        cellIndex = nil
    }
}

