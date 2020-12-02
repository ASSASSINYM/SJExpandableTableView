# SJExpandableTableView
A very simple to use Expandable Table, also could custom header or cell.

## Example
Just run the example project, or clone the repo.

## Requirements
* Xcode 12 or above
* iOS 14
* Swift 5.2

![GITHUB](https://github.com/SabrinaJiang14/SJExpandableTableView/blob/master/Example/demo.gif "demo")

## Basic Usage
- Example code
``` swift
// normal status's height
.configureItem(height: 45)

// top title
.configureHeader(titles: ["項目一","項目二","項目三"])

// allow mutilple selected, dafault is false
.configureMultipleCollapse(true)

// conform to the SJExpandableTableDataSource protocol
.configureDelegate(self)

// collapse tableView header
.itemTitleDidSelected { _ in }

// collapse tableView cell
.itemContentDidSelected { _ in }

// need pull refresh
.pullToRefresh(header: { [weak self] in
	//TODO: ...
}, footer: { [weak self]  in
	//TODO: ...
})
```
``` swift
// binding data
self.binding.bind(to: mainTableView)
```

## Customized Usage

```swift
// register custom cell by nib or class
.configureNibCell(cellIDs: ["TextViewCell"])
.configureClassCell(any: [TextViewCell.self])

// conform the (tableView: cellForRowAt:) protocol 
.configureItemCell { [weak self] (tb, indexPath, headers, contents, selectedIndex) -> UITableViewCell? in
	//TODO: Need return custom cell
	//      and the custom cell should conform **ExpandableItemCellDelegate** if want get cell tap event
}

// conform the (tableView: heightForRowAt:) protocol 
.configureItemCellForHeight { (tb, indexPath, selectedIndex, content) -> CGFloat in
	//TODO: Need return height for cell
}
```
# TODO
- [X] ~~Refresh with tableView header~~
- [X] ~~Collapse all / Expand all~~

---
# Licence
Licence MIT