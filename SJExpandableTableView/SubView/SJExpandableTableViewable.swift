//
//  SJExpandableTableViewable.swift
//  SJExpandableTableView
//
//  Created by sabrina on 2020/12/3.
//  Copyright © 2020 sabrina. All rights reserved.
//

import UIKit

typealias BindType = ((_ titles:[[HeaderData]], _ content:[[[ContentData]]]) -> Void)


protocol SJExpandableTableViewable : NSObjectProtocol {
    var configure : Configure { get set }
    func getBind() -> BindType?
}

struct Configure {
    var sj_header_title:[String] = []
    var sj_item_selected:((_ index:IndexPath) -> Void)?
    var sj_item_title_selected:((_ index:IndexPath) -> Void)?
    var sj_configure_header:((_ tb:UITableView, _ section:Int) -> UITableViewHeaderFooterView?)?
    var sj_configure_cell:((_ tb:UITableView, _ index:IndexPath, _ titles:[HeaderData], _ contents:[[ContentData]], _ currentIndex:Int?) -> UITableViewCell?)?
    var sj_height_for_row_at:((_ tb:UITableView, _ index:IndexPath, _ selectedIndex:Int?, _ contests:[[ContentData]]) -> CGFloat)?
    var sj_item_height:CGFloat = 30
    var sj_header_refresh:(() -> Void)?
    var sj_footer_refresh:(() -> Void)?
    var sj_item_width_scale:[Float] = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0]
    var sj_bind_data:BindType?
    var sj_multiple_selected:Bool = false
    var mDelegate:SJExpandableTableDataSource?
}
