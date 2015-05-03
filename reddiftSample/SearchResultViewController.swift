//
//  SearchResultViewController.swift
//  reddift
//
//  Created by sonson on 2015/05/03.
//  Copyright (c) 2015年 sonson. All rights reserved.
//

import UIKit
import reddift

class SearchResultViewController: BaseLinkViewController {
    var previousQuery = ""
    var originalViewController:LinkViewController? = nil
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchWithQuery(searchBar.text)
    }
    
    func searchWithQuery(query:String) {
        if loading {
            return
        }
        loading = true
        if previousQuery != query {
            paginator = nil
            links.removeAll(keepCapacity: false)
            contents.removeAll(keepCapacity: false)
            self.tableView.reloadData()
        }
        
        previousQuery = query
        session?.getSearch(self.subreddit, query: query, paginator:paginator, sort:SearchSort.Relevance, completion: { (result) -> Void in
            self.loading = false
            switch result {
            case let .Failure:
                println(result.error)
            case let .Success:
                println(result.value)
                if let listing = result.value as? Listing {
                    for obj in listing.children {
                        if let link = obj as? Link {
                            self.links.append(link)
                        }
                    }
                    self.paginator = listing.paginator
                }
                self.updateStrings()
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.tableView.reloadData()
                })
            }
        })
    }
    
    func reload() {
        if !previousQuery.isEmpty && paginator != nil {
            searchWithQuery(previousQuery)
        }
    }
}


// MARK:
// MARK:UITableViewDataSource

extension SearchResultViewController {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return links.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        if let cell = cell as? UZTextViewCell {
            if indices(contents) ~= indexPath.row {
                cell.textView?.attributedString = contents[indexPath.row].attributedString
            }
        }
        return cell
    }
    
}

// MARK:
// MARK:UITableViewDelegate

extension SearchResultViewController {

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indices(contents) ~= indexPath.row {
            if let originalViewController = originalViewController {
                if let con = originalViewController.storyboard?.instantiateViewControllerWithIdentifier("CommentViewController") as? CommentViewController {
                    let link = links[indexPath.row]
                    con.session = session
                    con.subreddit = subreddit
                    con.link = link
                    self.navigationController?.pushViewController(con, animated: true)
                }
            }
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indices(contents) ~= indexPath.row {
            return contents[indexPath.row].textHeight
        }
        return 0
    }
}
