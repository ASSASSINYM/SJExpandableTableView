//
//  SJExpandableTableView.swift
//  IntegratedProject
//
//  Created by sabrina on 2020/1/8.
//  Copyright © 2020 JK. All rights reserved.
//

import UIKit

typealias BindType = ((_ titles:[[HeaderData]], _ content:[[[ContentData]]]) -> Void)

protocol SJExpandableTableDataSource {
    var binding:BindData { get set }
}

class CollapseTableView: UITableView {
    @discardableResult func configureCalssCell(any:[AnyClass]) -> CollapseTableView {
        for cell in any {
            self.register(cell.self, forCellReuseIdentifier: String(describing: cell.self))
        }
        return self
    }
    
}

class SJExpandableTableView: UIView {

    @IBOutlet weak var tableView: UITableView!
    
    @discardableResult func configureClassCell(any:[AnyClass]) -> SJExpandableTableView {
        for cell in any {
            tableView.register(cell.self, forCellReuseIdentifier: String(describing: cell.self))
        }
        return self
    }
    
    @discardableResult func configureNibCell(cellIDs:[String]) -> SJExpandableTableView {
        for cellID in cellIDs {
            tableView.register(UINib(nibName: cellID, bundle: nil), forCellReuseIdentifier: cellID)
        }
        return self
    }
    
    @discardableResult func configureHeader(titles:[String]) -> SJExpandableTableView {
        sj_header_title = titles
        return self
    }
    
    /** 加起来要等于 HeaderTitle 的总数 */
    @discardableResult func configureItemWidthScale(itemScale:[Float]) -> SJExpandableTableView {
        guard itemScale.reduce(0, +) == Float(sj_header_title.count) else { fatalError("加起来要等于 HeaderTitle 的总数") }
        sj_item_width_scale = itemScale
        return self
    }
    
    @discardableResult func configureItem(height:CGFloat) -> SJExpandableTableView {
        sj_item_height = height
        return self
    }
    
    @discardableResult func configureHeaderView(configureView:@escaping ((_ tb:UITableView, _ section:Int) -> UITableViewHeaderFooterView?)) -> SJExpandableTableView {
        sj_configure_header = configureView
        return self
    }
    
    @discardableResult func configureItemCell(configureCell:@escaping ((_ tb:UITableView, _ index:IndexPath, _ titles:[HeaderData], _ contents:[[ContentData]], _ currentIndex:Int?) -> UITableViewCell? )) -> SJExpandableTableView {
        sj_configure_cell = configureCell
        return self
    }
    
    @discardableResult func configureItemCellForHeight(configureHeight:@escaping ((_ tb:UITableView, _ index:IndexPath, _ selected:Int?, _ contents:[[ContentData]]) -> CGFloat)) -> SJExpandableTableView {
        sj_height_for_row_at = configureHeight
        return self
    }
    
    @discardableResult func itemTitleDidSelected(completed:@escaping ((_ index:IndexPath) -> Void)) -> SJExpandableTableView {
        sj_item_title_selected = completed
        return self
    }
    
    @discardableResult func itemContentDidSelected(completed: @escaping ((_ index:IndexPath) -> Void)) -> SJExpandableTableView {
        sj_item_selected = completed
        return self
    }
    
    @discardableResult func configureDelegate(_ mDelegate:SJExpandableTableDataSource) -> SJExpandableTableView {
        delegate = mDelegate
        return self
    }
    
    @discardableResult func configureMultipleCollapse(_ isOn:Bool) -> SJExpandableTableView {
        sj_multiple_selected = isOn
        return self
    }
    
    @discardableResult func pullToRefresh(header h:(() -> Void)?, footer f:(() -> Void)?) -> SJExpandableTableView {
        if let _ = h {
            sj_header_refresh = h
            createHeaderView()
        }
        if let _ = f {
            sj_footer_refresh = f
            createFooterView()
        }
        return self
    }
    
    private func createFooterView() {
        footerLoading = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 30))
        footerLoading?.isHidden = true
        tableView.tableFooterView = footerLoading
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
        if let tableFooterView = tableView.tableFooterView {
            label.translatesAutoresizingMaskIntoConstraints = false
            label.centerXAnchor.constraint(equalTo: tableFooterView.centerXAnchor, constant: 10).isActive = true
            label.centerYAnchor.constraint(equalTo: tableFooterView.centerYAnchor).isActive = true
            loading.translatesAutoresizingMaskIntoConstraints = false
            loading.centerYAnchor.constraint(equalTo: tableFooterView.centerYAnchor).isActive = true
            loading.trailingAnchor.constraint(equalTo: label.leadingAnchor, constant: -5).isActive = true
        }
    }
    
    private func createHeaderView() {
        headerLoading = UIRefreshControl()
        headerLoading?.addTarget(self, action: #selector(headerRefresh(_:)), for: .valueChanged)
        tableView.refreshControl = headerLoading
    }
    
    @objc private func headerRefresh(_ sender:UIRefreshControl) {
        sender.beginRefreshing()
        sj_header_refresh?()
    }
    
    func getBind() -> BindType? {
        registerBind()
        return sj_bind_data
    }
    
    
    //MARK: - private objective and proprety
    private var mTitles:[[HeaderData]] = []
    private var mContent:[[[ContentData]]] = []
    private var headerLoading:UIRefreshControl?
    private var footerLoading:UIView?
    private var sj_item_selected:((_ index:IndexPath) -> Void)?
    private var sj_item_title_selected:((_ index:IndexPath) -> Void)?
    private var sj_configure_header:((_ tb:UITableView, _ section:Int) -> UITableViewHeaderFooterView?)?
    private var sj_configure_cell:((_ tb:UITableView, _ index:IndexPath, _ titles:[HeaderData], _ contents:[[ContentData]], _ currentIndex:Int?) -> UITableViewCell?)?
    private var sj_height_for_row_at:((_ tb:UITableView, _ index:IndexPath, _ selectedIndex:Int?, _ contests:[[ContentData]]) -> CGFloat)?
    private var sj_item_height:CGFloat = 30
    private var sj_header_refresh:(() -> Void)?
    private var sj_footer_refresh:(() -> Void)?
    private var sj_header_title:[String] = []
    private var sj_item_width_scale:[Float] = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0]
    private var sj_bind_data:BindType?
    private var sj_multiple_selected:Bool = false
    private var selectedIndex:Int?
    private var selectedMultipleIndex:[Int:Bool] = [:]
    private var delegate:SJExpandableTableDataSource?
    
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
    }
    
    private func registerBind() {
        sj_bind_data = { [unowned self] (titles, contents) in
            self.footerLoading?.isHidden = true
            self.headerLoading?.endRefreshing()
            self.selectedIndex = nil
            self.mTitles = titles
            self.mContent = contents
            self.refreshTableView()
        }
    }
    
    private func refreshTableView() {
        tableView.reloadData()
    }
}

extension SJExpandableTableView : ExpandableItemCellDelegate {
    func tapExpandableItemCell(_ index: Int?) {
        guard let _ = sj_item_title_selected else { return }
        if sj_multiple_selected {
            multipleSelected(index)
        }else{
            singleSelected(index)
        }
    }
    
    private func singleSelected(_ index: Int?) {
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
        sj_item_title_selected?(IndexPath(item: section, section: 0))
    }
    
    private func multipleSelected(_ index: Int?) {
        guard let section = index else { return }
        if let _ = selectedMultipleIndex[section] {
            selectedMultipleIndex[section]?.toggle()
        }else{
            selectedMultipleIndex[section] = true
        }
        tableView.beginUpdates()
        tableView.reloadRows(at: [IndexPath(row: section, section: 0)], with: .automatic)
        tableView.endUpdates()
        sj_item_title_selected?(IndexPath(item: section, section: 0))
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
        let _content = mContent[indexPath.row]
        guard sj_height_for_row_at == nil else {
            return sj_height_for_row_at!(tableView, indexPath, selectedIndex, _content)
        }
        var rows : Int = 0
        if sj_multiple_selected, isMultipleExpend(heightForRowAt: indexPath, contentCount: _content.count) {
            rows = _content.count
        }else if isSingleExpend(heightForRowAt: indexPath, contentCount: _content.count) {
            rows = _content.count
        }
        return CGFloat(rows+1) * sj_item_height
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
        
        guard sj_configure_cell == nil else {
            return sj_configure_cell!(tableView, indexPath, titles, contests, selectedIndex)!
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
        
        cell.setupData(mTitles: titles, mContent: contests, index: indexPath.row, isExpand: isExp, mDelegate: self, itemHeight: sj_item_height, mScale: sj_item_width_scale)
        cell.backgroundColor = .clear
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard indexPath.row + 5 == mTitles.count else { return }
        Log.info(indexPath.row)
        footerLoading?.isHidden = false
        sj_footer_refresh?()
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard indexPath.row + 5 == mTitles.count else { return }
        Log.error(indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        sj_item_selected?(indexPath)
    }
}
