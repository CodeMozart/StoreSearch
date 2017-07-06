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
        static let loadingCell = "LoadingCell"
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    let search = Search()
    
    var landscapeViewController: LandscapeViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsetsMake(108, 0, 0, 0)
        
        var cellNib = UINib(nibName: TableViewCellIdentifiers.searchResultCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.searchResultCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothingFoundCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.loadingCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.loadingCell)
        
        searchBar.becomeFirstResponder()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        
        switch newCollection.verticalSizeClass {
        case .compact:
            showLandscape(with: coordinator)
        case .regular, .unspecified:
            hideLandscape(with: coordinator)
        }
    }
    
    
    func showLandscape(with coordinator: UIViewControllerTransitionCoordinator) {
        
        guard landscapeViewController == nil else { return }
        
        landscapeViewController = storyboard!.instantiateViewController(withIdentifier: "LandscapeViewController") as? LandscapeViewController
        if let controller = landscapeViewController {
            controller.view.frame = view.bounds
            controller.view.alpha = 0
            controller.search = search
            
            view.addSubview(controller.view)
            addChildViewController(controller)
            
            coordinator.animate(alongsideTransition: { (_) in
                controller.view.alpha = 1
                self.searchBar.resignFirstResponder()
                
                if self.presentedViewController != nil {
                    self.dismiss(animated: true, completion: nil)
                }
                
            }, completion: { _ in
                controller.didMove(toParentViewController: self)
            })
            
            
        }
    }
    
    
    func hideLandscape(with coordinator: UIViewControllerTransitionCoordinator) {
        
        if let controller = landscapeViewController {
            controller.willMove(toParentViewController: nil)
            
            coordinator.animate(alongsideTransition: { (_) in
                controller.view.alpha = 0
            }, completion: { (_) in
                controller.view.removeFromSuperview()
                controller.removeFromParentViewController()
                self.landscapeViewController = nil
            })
        }
    }
    
    

    
    
    func showNetworkError() {
        let alert = UIAlertController(title: "Whoops...",
                                      message: "There was an error reading from the iTunes Store. Please try again.",
                                      preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        print("Segment changed: \(sender.selectedSegmentIndex)")
        performSearch()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            if case .results(let list) = search.state {
                let detailViewController = segue.destination as! DetailViewController
                let indexPath = sender as! NSIndexPath
                let searchResult = list[indexPath.row]
                detailViewController.searchResult = searchResult
            }
        }
    }

}

extension SearchViewController: UISearchBarDelegate {
    
    func performSearch() {
        
        if let category = Search.Category(rawValue: segmentedControl.selectedSegmentIndex) {
            
            search.performSearch(for: searchBar.text!, category: category, completion: {
                success in
                
                if !success {
                    self.showNetworkError()
                }
                self.tableView.reloadData()
            })
            
            tableView.reloadData()
            searchBar.resignFirstResponder()
        }
        
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        performSearch()
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        switch search.state {
        case .notSearchedYet:
            return 0
        case .loading:
            return 1
        case .noResults:
            return 1
        case .results(let list):
            return list.count
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch search.state {
        case .loading:
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.loadingCell, for: indexPath)
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
            
        case .notSearchedYet:
            fatalError("Should never get here")
            
        case .noResults:
            return tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.nothingFoundCell, for: indexPath)
            
        case .results(let list):
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.searchResultCell, for: indexPath) as! SearchResultCell
            let searchResult = list[indexPath.row]
            cell.configure(for: searchResult)
            return cell
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "ShowDetail", sender: indexPath)
    }
    
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        switch search.state {
        case .loading,.noResults,.notSearchedYet:
            return nil
        case .results:
            return indexPath
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 80.0
    }
}

extension SearchViewController: UITableViewDelegate {
    
}

