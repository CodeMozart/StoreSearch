//
//  ViewController.swift
//  StoreSearch
//
//  Created by officeWanPlus on 2017/7/2.
//  Copyright © 2017年 Strawberry. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
    struct TableViewCellIdentifiers {
        static let searchResultCell = "SearchResultCell"
        static let nothingFoundCell = "NothingFoundCell"
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var searchResults: [SearchResult] = []
    var hasSearched = false
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0)
        tableView.rowHeight = 80
//        tableView.keyboardDismissMode = .interactive;
        
        var cellNib = UINib(nibName: TableViewCellIdentifiers.searchResultCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.searchResultCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothingFoundCell)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        print("The search text is: '\(searchBar.text!)'")
        
        searchBar.resignFirstResponder()
        
        searchResults = []
        
        if searchBar.text! != "jb" {
            for i in 0...2 {
                let searchResult = SearchResult()
                searchResult.name = String(format: "Fake Result %d for",i)
                searchResult.artistName = searchBar.text!
                searchResults.append(searchResult)
            }
        }
        
        
        hasSearched = true
        tableView.reloadData()
    }
    
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count > 0 || !hasSearched ? searchResults.count : 1
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if searchResults.count == 0 {
            return tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.nothingFoundCell, for: indexPath)
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.searchResultCell, for: indexPath) as! SearchResultCell
        
        let searchResult = searchResults[indexPath.row]
        cell.nameLabel.text = searchResult.name
        cell.artistNameLabel.text = searchResult.artistName
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if searchResults.count == 0 {
            return nil
        }
        return indexPath
    }
}

extension SearchViewController: UITableViewDelegate {
    
}

