//
//  SJExpandableTableView.swift
//  IntegratedProject
//
//  Created by sabrina on 2020/1/8.
//  Copyright © 2020 JK. All rights reserved.
//

import UIKit

protocol SJExpandableTableDataSource {
    var binding:BindData { get set }
}

class SJExpandableTableView: UITableView, SJExpandableTableViewable {

    var configure: Configure = Configure()
    
    //MARK: - private objective and proprety
    private var mTitles:[[HeaderData]] = []
    private var mContent:[[[ContentData]]] = []
    private var headerLoading:UIRefreshControl?
    private var footerLoading:UIView?
    private var selectedIndex:Int?
    private var selectedMultipleIndex:[Int:Bool] = [:]
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        initTableView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initTableView()
    }
    
    private func initTableView() {
        self.delegate = self
        self.dataSource = self
        self.tableFooterView = UIView()
        self.register(UINib(nibName: "ExpandableItemCell", bundle: nil), forCellReuseIdentifier: "ExpandableItemCell")
        self.register(UINib(nibName: "ExpandableHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "ExpandableHeaderView")
    }
    
    fileprivate func registerBind() {
        configure.sj_bind_data = { [unowned self] (titles, contents) in
            self.footerLoading?.isHidden = true
            self.headerLoading?.endRefreshing()
            self.selectedIndex = nil
            self.mTitles = titles
            self.mContent = contents
            self.refreshTableView()
        }
    }
    
    private func refreshTableView() {
        self.reloadData()
    }
    
    fileprivate func createFooterView() {
        footerLoading = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 30))
        footerLoading?.isHidden = true
        self.tableFooterView = footerLoading
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11)
        label.textColor = .gray
        label.text = "加載中..."
        label.sizeToFit()
        footerLoading?.addSubview(label)
        let loading = UIActivityIndicatorView(style: .medium)
        loading.color = .gray
        loading.startAnimating()
        footerLoading?.addSubview(loading)
        if let tableFooterView = self.tableFooterView {
            label.translatesAutoresizingMaskIntoConstraints = false
            label.centerXAnchor.constraint(equalTo: tableFooterView.centerXAnchor, constant: 10).isActive = true
            label.centerYAnchor.constraint(equalTo: tableFooterView.centerYAnchor).isActive = true
            loading.translatesAutoresizingMaskIntoConstraints = false
            loading.centerYAnchor.constraint(equalTo: tableFooterView.centerYAnchor).isActive = true
            loading.trailingAnchor.constraint(equalTo: label.leadingAnchor, constant: -5).isActive = true
        }
    }
    
    fileprivate func createHeaderView() {
        headerLoading = UIRefreshControl()
        headerLoading?.addTarget(self, action: #selector(headerRefresh(_:)), for: .valueChanged)
        self.refreshControl = headerLoading
    }
    
    @objc private func headerRefresh(_ sender:UIRefreshControl) {
        sender.beginRefreshing()
        configure.sj_header_refresh?()
    }
}

extension SJExpandableTableView: UITableViewDelegate,UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if configure.sj_header_title.count > 0 {
            return configure.sj_item_height
        }
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard configure.sj_configure_header == nil else {
            return configure.sj_configure_header?(tableView, section)
        }
        if let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "ExpandableHeaderView") as? ExpandableHeaderView, configure.sj_header_title.count != 0 {
            
            view.setupTitle(mTitle: configure.sj_header_title, mScale: configure.sj_item_width_scale)
            return view
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.mTitles.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let _content = mContent[indexPath.row]
        guard configure.sj_height_for_row_at == nil else {
            return configure.sj_height_for_row_at!(tableView, indexPath, selectedIndex, _content)
        }
        var rows : Int = 0
        if configure.sj_multiple_selected, isMultipleExpend(heightForRowAt: indexPath, contentCount: _content.count) {
            rows = _content.count
        }else if isSingleExpend(heightForRowAt: indexPath, contentCount: _content.count) {
            rows = _content.count
        }
        return CGFloat(rows+1) * configure.sj_item_height
    }
    
    private func isSingleExpend(heightForRowAt indexPath: IndexPath, contentCount:Int) -> Bool {
        if let f_index = selectedIndex , f_index == indexPath.row, mContent.count != 0 {
            return true
        }
        return false
    }
    
    private func isMultipleExpend(heightForRowAt indexPath: IndexPath, contentCount:Int) -> Bool {
        if let value = selectedMultipleIndex[indexPath.row] {
            return value
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let titles:[HeaderData] = mTitles[indexPath.row]
        var contests:[[ContentData]] = []
        
        if mContent.count != 0 {
            contests = mContent[indexPath.row]
        }
        
        guard configure.sj_configure_cell == nil else {
            return configure.sj_configure_cell!(tableView, indexPath, titles, contests, selectedIndex)!
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExpandableItemCell", for: indexPath) as! ExpandableItemCell
        
        var isExp:Bool = false
        if let value = selectedMultipleIndex[indexPath.row] {
            isExp = value
        }else{
            if let mSelectIndex = selectedIndex, mSelectIndex == indexPath.row {
                isExp = true
            }
        }
        
        cell.setupData(mTitles: titles, mContent: contests, index: indexPath.row, isExpand: isExp, mDelegate: self, itemHeight: configure.sj_item_height, mScale: configure.sj_item_width_scale)
        cell.backgroundColor = .clear
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard indexPath.row + 5 == mTitles.count else { return }
        Log.info(indexPath.row)
        footerLoading?.isHidden = false
        configure.sj_footer_refresh?()
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard indexPath.row + 5 == mTitles.count else { return }
        Log.error(indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        configure.sj_item_selected?(indexPath)
    }
}

extension SJExpandableTableView : ExpandableItemCellDelegate {
    func tapExpandableItemCell(_ index: Int?) {
        guard let _ = configure.sj_item_title_selected, let section = index else { return }
        var arr:[IndexPath] = []
        if configure.sj_multiple_selected {
            arr = multipleSelected(index)
        }else{
            arr = singleSelected(index)
        }

        self.beginUpdates()
        self.reloadRows(at: arr, with: .automatic)
        self.endUpdates()
        configure.sj_item_title_selected?(IndexPath(item: section, section: 0))
    }

    private func singleSelected(_ index: Int?) -> [IndexPath]{
        guard let section = index else { return [] }
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
        return arr
    }

    private func multipleSelected(_ index: Int?) -> [IndexPath] {
        guard let section = index else { return [] }
        if let _ = selectedMultipleIndex[section] {
            selectedMultipleIndex[section]?.toggle()
        }else{
            selectedMultipleIndex[section] = true
        }
        return [IndexPath(row: section, section: 0)]
    }
}
extension SJExpandableTableViewable where Self : SJExpandableTableView {
    
    /// Register callback in table view
    /// - Returns: BindType
    func getBind() -> BindType? {
        registerBind()
        return configure.sj_bind_data
    }
    
    /// Register UITableViewCell by class
    /// - Parameter any: Put class array, default is ExpandableItemCell
    /// - Returns: SJExpandableTableView
    @discardableResult
    func configureClassCell(any:[AnyClass]) -> Self {
        for cell in any {
            self.register(cell.self, forCellReuseIdentifier: String(describing: cell.self))
        }
        return self
    }
    
    /// Register UITableViewCell by cell id
    /// - Parameter cellIDs: Put cell id array, default is ExpandableItemCell
    /// - Returns: SJExpandableTableView
    @discardableResult
    func configureNibCell(cellIDs: [String]) -> Self {
        for cellID in cellIDs {
            self.register(UINib(nibName: cellID, bundle: nil), forCellReuseIdentifier: cellID)
        }
        return self
    }
    
    /// Set TableView header title
    /// - Parameter titles: put string array
    /// - Returns: SJExpandableTableView
    @discardableResult
    func configureHeader(titles: [String]) -> Self {
        configure.sj_header_title = titles
        return self
    }
    
    /// Set columns width scale
    /// - Parameter itemScale: Default is equal width. If want a different scale, please fill in double array,
    ///   like as: [1.0, 0.5, 1.5]
    ///   Tips: The sum is equal to title count -> 1.0+0.5+1.5 = 3
    /// - Returns: SJExpandableTableView
    @discardableResult
    func configureItemWidthScale(itemScale: [Float]) -> Self {
        guard itemScale.reduce(0, +) == Float(configure.sj_header_title.count) else { fatalError("加起来要等于 HeaderTitle 的总数") }
        configure.sj_item_width_scale = itemScale
        return self
    }
    
    /// Set each rows height
    /// - Parameter height: put number
    /// - Returns: SJExpandableTableView
    @discardableResult
    func configureItem(height: CGFloat) -> Self {
        configure.sj_item_height = height
        return self
    }
    
    /// Set custom header view
    /// - Parameter configureView: Default header view is ExpandableHeaderView.
    ///   If want custom header view, return your custom header view in this block
    /// - Returns: SJExpandableTableView
    /**
     ## Example
     ///    tableView
     ///   .configureHeaderView(configureView: { (tb, index) -> UITableViewHeaderFooterView? in
     ///     let v = UITableViewHeaderFooterView()
     ///     return v
     ///    })
     ///
     */
    @discardableResult
    func configureHeaderView(configureView: @escaping ((UITableView, Int) -> UITableViewHeaderFooterView?)) -> Self {
        configure.sj_configure_header = configureView
        return self
    }
    
    /// Set custom tableView cell
    /// - Parameter configureCell:(UITableView, IndexPath, [HeaderData], [[ContentData]], Int?)
    /// - Returns: SJExpandableTableView
    @discardableResult
    func configureItemCell(configureCell: @escaping ((UITableView, IndexPath, [HeaderData], [[ContentData]], Int?) -> UITableViewCell?)) -> Self {
        configure.sj_configure_cell = configureCell
        return self
    }
    
    @discardableResult
    func configureItemCellForHeight(configureHeight: @escaping ((UITableView, IndexPath, Int?, [[ContentData]]) -> CGFloat)) -> Self {
        configure.sj_height_for_row_at = configureHeight
        return self
    }
    
    @discardableResult
    func itemTitleDidSelected(completed: @escaping ((IndexPath) -> Void)) -> Self {
        configure.sj_item_title_selected = completed
        return self
    }
    
    @discardableResult
    func itemContentDidSelected(completed: @escaping ((IndexPath) -> Void)) -> Self {
        configure.sj_item_selected = completed
        return self
    }
    
    @discardableResult
    func configureDelegate(_ mDelegate: SJExpandableTableDataSource) -> Self {
        configure.mDelegate = mDelegate
        return self
    }
    
    @discardableResult
    func configureMultipleCollapse(_ isOn: Bool) -> Self {
        configure.sj_multiple_selected = isOn
        return self
    }
    
    @discardableResult
    func pullToRefresh(header h: (() -> Void)?, footer f: (() -> Void)?) -> Self {
        if let _ = h {
            configure.sj_header_refresh = h
            createHeaderView()
        }
        if let _ = f {
            configure.sj_footer_refresh = f
            createFooterView()
        }
        return self
    }
}
