//
//  SJExpandableTableView.swift
//  IntegratedProject
//
//  Created by sabrina on 2020/1/8.
//  Copyright © 2020 JK. All rights reserved.
//

import UIKit
//import MJRefresh

extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}

typealias BindType = ((_ titles:[[HeaderData]], _ content:[[[ContentData]]]) -> Void)

struct HeaderData {
    let text:String
    var color:UIColor = UIColor.black
    var align:NSTextAlignment = .center
}

struct ContentData {
    let text:ContentText
    var color:UIColor = .black
    var align:NSTextAlignment = .center
    var attr:NSAttributedString?
    
    init(text:ContentText, color:UIColor = UIColor.black, align:NSTextAlignment = .center) {
        self.text = text
        self.color = color
        self.align = align
        switch text {
        case .attributed(let attrStr):
            print(attrStr.description)
            if attrStr.description.contains("</") {
                attr = attrStr.description.htmlToAttributedString
            }else{
                attr = attrStr
            }
        default: break
        }
    }
    enum ContentText {
        case string(String)
        case attributed(NSAttributedString)
    }
}

protocol SJExpandableTableViewAble {
    var onBind:BindType? { get set }
}

class SJExpandableTableView: UIView {

    @IBOutlet weak var tableView: UITableView!
    
    func registerClassCell(any:[AnyClass]) -> SJExpandableTableView {
        for cell in any {
            tableView.register(cell.self, forCellReuseIdentifier: String(describing: cell.self))
        }
        return self
    }
    
    func registerNibCell(cellIDs:[String]) -> SJExpandableTableView {
        for cellID in cellIDs {
            tableView.register(UINib(nibName: cellID, bundle: nil), forCellReuseIdentifier: cellID)
        }
        return self
    }
    
    func configuratorHeaderTitle(headerTitle:[String]) -> SJExpandableTableView {
        sj_header_title = headerTitle
        return self
    }
    
    /** 加起来要等于 HeaderTitle 的总数 */
    func configuratorItemWidthScale(itemScale:[Float]) -> SJExpandableTableView {
        guard itemScale.reduce(0, +) == Float(sj_header_title.count) else { fatalError("加起来要等于 HeaderTitle 的总数") }
        sj_item_width_scale = itemScale
        return self
    }
    
    func configuratorItemHeight(height:CGFloat) -> SJExpandableTableView {
        sj_item_height = height
        return self
    }
    
    func configuratorHeaderView(configureView:@escaping ((_ tb:UITableView, _ section:Int) -> UITableViewHeaderFooterView?)) -> SJExpandableTableView {
        sj_configure_header = configureView
        return self
    }
    
    func configuratorItemCell(configureCell:@escaping ((_ tb:UITableView, _ index:IndexPath) -> UITableViewCell? )) -> SJExpandableTableView {
        sj_configure_cell = configureCell
        return self
    }
    
    func configuratorItemCellForHeight(configureHeight:@escaping ((_ tb:UITableView, _ index:IndexPath, _ selected:Int?) -> CGFloat)) -> SJExpandableTableView {
        sj_height_for_row_at = configureHeight
        return self
    }
    
    func headerDidSelected(completed:((_ index:IndexPath) -> Void)) -> SJExpandableTableView {
        return self
    }
    
    func itemDidSelected(completed:@escaping ((_ index:IndexPath) -> Void)) -> SJExpandableTableView {
        sj_item_selected = completed
        return self
    }
    
    func pullToRefresh(header:(() -> Void)?, footer:(() -> Void)?) -> SJExpandableTableView {
        if let _ = header {
            sj_header_refresh = header
            setupHeaderRefreshView()
        }
        if let _ = footer {
            sj_footer_refresh = footer
            setupFooterRefreshView()
        }
        return self
    }
    
    func setupDataForTableViewDataSource(titles:[[HeaderData]], content:[[[ContentData]]]) {
        selectedIndex = nil
        mTitles = titles
        mContent = content
        refreshTableView()
    }
    
    func getBind() -> BindType {
        return sj_bind_data
    }
    
    func setDelegate(_ mDelegate:SJExpandableTableViewAble) -> SJExpandableTableView {
        delegate = mDelegate
        return self
    }
    
    func stopRefresh() {
        endRefresh()
    }

    func endRefreshingWithNoMoreData() {
        stopRefresh()
    }
    
    func resetNoMoreData() {
        stopRefresh()
    }
    
    
    //MARK: - private objective and proprety
    private var mTitles:[[HeaderData]] = []
    private var mContent:[[[ContentData]]] = []
    
    private var sj_item_selected:((_ index:IndexPath) -> Void)?
    private var sj_configure_header:((_ tb:UITableView, _ section:Int) -> UITableViewHeaderFooterView?)?
    private var sj_configure_cell:((_ tb:UITableView, _ index:IndexPath) -> UITableViewCell?)?
    private var sj_height_for_row_at:((_ tb:UITableView, _ index:IndexPath, _ selectedIndex:Int?) -> CGFloat)?
    private var sj_item_height:CGFloat = 30
    private var sj_header_title:[String] = []
    private var sj_item_width_scale:[Float] = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0]
    private var sj_header_refresh:(() -> Void)?
    private var sj_footer_refresh:(() -> Void)?
    private var sj_bind_data:BindType = { (_ ,_ ) in }
//    private let refreshHeader = MJRefreshNormalHeader()
//    private let refreshFooter = MJRefreshBackNormalFooter()
    private var selectedIndex:Int?
    private var delegate:SJExpandableTableViewAble?
    
    lazy var xibView:UIView = {
        return Bundle.main.loadNibNamed("SJExpandableTableView", owner: self, options: nil)?.first as! UIView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        xibView.frame = bounds
        addSubview(xibView)
        initTableView()
    }
    
    private func initTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: "ExpandableItemCell", bundle: nil), forCellReuseIdentifier: "ExpandableItemCell")
        tableView.register(UINib(nibName: "ExpandableHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "ExpandableHeaderView")
        sj_bind_data = { [unowned self] (titles, contents) in
            self.endRefresh()
            self.selectedIndex = nil
            self.mTitles = titles
            self.mContent = contents
            self.refreshTableView()
        }
    }
    
    private func refreshTableView() {
        tableView.reloadData()
    }
    
    private func endRefresh() {
//        if let _ = sj_header_refresh {
//            self.tableView.mj_header.endRefreshing()
//        }
//        if let _ = sj_footer_refresh {
//            self.tableView.mj_footer.endRefreshing()
//        }
    }
    
    private func noMoreDataStatusRefresh(noMoreData: Bool = true) {
//        if noMoreData {
//            self.tableView.mj_footer.endRefreshingWithNoMoreData()
//        }else {
//            self.tableView.mj_footer.resetNoMoreData()
//        }
    }
    
    private func setupHeaderRefreshView() {
//        refreshHeader.setRefreshingTarget(self, refreshingAction: #selector(headerRefresh))
//        self.tableView.mj_header = refreshHeader
    }
    
    private func setupFooterRefreshView() {
//        refreshFooter.setRefreshingTarget(self, refreshingAction: #selector(footerRefresh))
//        self.tableView.mj_footer = refreshFooter
    }
    
    @objc fileprivate func headerRefresh() {
        guard let _ = sj_header_refresh else { return }
        sj_header_refresh?()
    }
    
    @objc fileprivate func footerRefresh() {
        guard let _ = sj_footer_refresh else { return }
        sj_footer_refresh?()
    }
}

extension SJExpandableTableView : ExpandableItemCellDelegate {
    func tapExpandableItemCell(_ index: Int?) {
        guard let _ = sj_item_selected else { return }
        guard let section = index else { return }
        var arr:[IndexPath] = []
        if selectedIndex == section {
            selectedIndex = nil
        }else{
            if let _ = selectedIndex {
                arr.append(IndexPath(row: selectedIndex!, section: 0))
            }
            selectedIndex = section
        }
        arr.append(IndexPath(row: section, section: 0))
        tableView.beginUpdates()
        tableView.reloadRows(at: arr, with: .automatic)
        tableView.endUpdates()
        sj_item_selected?(IndexPath(item: section, section: 0))
    }
}

extension SJExpandableTableView: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if sj_header_title.count > 0 {
            return sj_item_height
        }
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard sj_configure_header == nil else {
            return sj_configure_header?(tableView, section)
        }
        if let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "ExpandableHeaderView") as? ExpandableHeaderView, sj_header_title.count != 0 {
            view.setupTitle(mTitle: sj_header_title, mScale: sj_item_width_scale)
            return view
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.mTitles.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard sj_height_for_row_at == nil else {
            return sj_height_for_row_at!(tableView, indexPath, selectedIndex)
        }
        if let f_index = selectedIndex , f_index == indexPath.row, mContent.count != 0 {
            let rows = mContent[indexPath.row].count
            return CGFloat(rows+1) * sj_item_height
        }
        return sj_item_height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard sj_configure_cell == nil else {
            return (sj_configure_cell?(tableView, indexPath))!
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExpandableItemCell", for: indexPath) as! ExpandableItemCell
        
        let titles:[HeaderData] = mTitles[indexPath.row]
        var contests:[[ContentData]] = []
        
        if mContent.count != 0 {
            contests = mContent[indexPath.row]
        }
        
        var isExp:Bool = false
        
        if let mSelectIndex = selectedIndex, mSelectIndex == indexPath.row {
            isExp = true
        }
        
        cell.setupData(mTitles: titles, mContent: contests, index: indexPath.row, isExpand: isExp, mDelegate: self, itemHeight: sj_item_height, mScale: sj_item_width_scale)
        cell.backgroundColor = .clear
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        return cell
    }
}
