//
//  CurrencyTableViewController.swift
//  Exchange_Rates
//
//  Created by David Ali on 18/12/19.
//  Copyright © 2019 David Mendoza. All rights reserved.
//

import UIKit

class CurrencyTableViewController: UITableViewController {

    var presenter: CurrencyPresenter!
    var searchController: UISearchController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewController()
        setupSearchBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        presenter.getCurrencies()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        presenter.detachView()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.currencies.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CurrencyCell", for: indexPath) as? CurrencyCell {
            let currency = presenter.currencies[indexPath.row]
            cell.fillCellData(name: "\(currency.code) - \(currency.name)",
                isBase: presenter.checkIfIsBaseCurrency(currencyCode: currency.code),
                isFavorite: presenter.checkIfIsFavoriteCurrency(currencyCode: currency.code))
            return cell
        }
        fatalError("Error cargarndo la celda CurrencyCell")
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var actions = [UIContextualAction]()
        let currencyCode = presenter.currencies[indexPath.row].code
        let isFavorite = presenter.checkIfIsFavoriteCurrency(currencyCode: currencyCode)
        let isBase = presenter.checkIfIsBaseCurrency(currencyCode: currencyCode)
        
        let title = isFavorite ? "Unmark as Favorite" : "Mark as Favorite"
        let favoriteAction = UIContextualAction(style: .normal, title: title) { (action, view, completionHandler) in
            self.presenter.markOrUnmarkFavoriteBy(currencyCode: currencyCode)
            self.tableView.reloadRows(at: [indexPath], with: .fade)
            completionHandler(true)
        }
        favoriteAction.backgroundColor = isFavorite ? UIColor.red : UIColor.green
        actions.append(favoriteAction)
        
        if !isBase {
            let setBaseCurrencyAction = UIContextualAction(style: .normal, title: "Set as base") { (action, view, completionHandler) in
                self.presenter.setBaseCurrency(currencyCode: currencyCode)
                self.tableView.reloadRows(at: [indexPath], with: .fade)
                completionHandler(true)
            }
            setBaseCurrencyAction.backgroundColor = .blue
            //actions.append(setBaseCurrencyAction)
        }
        
        let configuration = UISwipeActionsConfiguration(actions: actions)
        return configuration
    }
    
    func setupViewController() {
        title = "Currency List"
        presenter = CurrencyPresenter()
        presenter.attachView(view: self)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshCurrencies))
    }
    
    func setupSearchBar() {
        // Initializing with searchResultsController set to nil means that
        // searchController will use this view controller to display the search results
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Enter the currency code or name"
        searchController.obscuresBackgroundDuringPresentation = false
        
        searchController.searchBar.sizeToFit()
        tableView.tableHeaderView = searchController.searchBar
        
        definesPresentationContext = true
    }
    
    @objc func refreshCurrencies() {
        presenter.refreshCurrenciesData()
    }
}

extension CurrencyTableViewController: CurrencyProtocol {
    
    func showCurrencies() {
        self.tableView.reloadData()
    }
    
    func showError(errorMessage: String) {
        let ac = UIAlertController(title: "Something happened!", message: errorMessage, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Got it!", style: .default))
            
        self.present(ac, animated: true)
    }
}

extension CurrencyTableViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        
        if searchText.replacingOccurrences(of: " ", with: "").isEmpty == true {
            presenter.getCurrencies()
        } else {
            presenter.filterCurrenciesBy(currencyCode: searchText)
        }
    }
}
