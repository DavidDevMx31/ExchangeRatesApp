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
    
    private let cellIdentifier = "CurrencyCell"
    
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
    
    func setupViewController() {
        title = "Currency List"
        presenter = CurrencyPresenter()
        presenter.attachView(view: self)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshCurrencies))
    }
    
    func setupSearchBar() {
        /*
         Initializing with searchResultsController set to nil means that searchController will use this view controller
         to display the search results
         */
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Enter the currency code or name"
        searchController.obscuresBackgroundDuringPresentation = false
        
        searchController.searchBar.sizeToFit()
        tableView.tableHeaderView = searchController.searchBar
        
        definesPresentationContext = true
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.currencies.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? CurrencyCell else {
            fatalError("Could not dequeue cell with name \(cellIdentifier)")
        }
        
        let currency = presenter.currencies[indexPath.row]
        let currencyFullName = (currency.code) + " - " + currency.name
        let isBaseCurrency = presenter.checkIfIsBaseCurrency(currencyCode: currency.code)
        let isFavoriteCurrency = presenter.checkIfIsFavoriteCurrency(currencyCode: currency.code)
        
        cell.fillCellData(name: currencyFullName, isBase: isBaseCurrency, isFavorite: isFavoriteCurrency)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var actions = [UIContextualAction]()
        let currencyCode = presenter.currencies[indexPath.row].code
        let isFavoriteCurrency = presenter.checkIfIsFavoriteCurrency(currencyCode: currencyCode)
        
        let actionTitle = isFavoriteCurrency ? "Unmark as Favorite" : "Mark as Favorite"
        let markAsFavorite = UIContextualAction(style: .normal, title: actionTitle) { [weak self] (action, view, completionHandler) in
            self?.presenter.markOrUnmarkFavoriteBy(currencyCode: currencyCode)
            self?.tableView.reloadRows(at: [indexPath], with: .fade)
            completionHandler(true)
        }
        markAsFavorite.backgroundColor = isFavoriteCurrency ? UIColor.red : UIColor.green
        actions.append(markAsFavorite)

        let configuration = UISwipeActionsConfiguration(actions: actions)
        return configuration
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
