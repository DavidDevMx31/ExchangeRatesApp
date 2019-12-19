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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Currency List"
        presenter = CurrencyPresenter(view: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        presenter.getCurrencies()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.currencies.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CurrencyCell", for: indexPath)
        let currency = presenter.currencies[indexPath.row]
        cell.textLabel?.text = "\(currency.code) - \(currency.name)"
        
        return cell
    }
}

extension CurrencyTableViewController: CurrencyProtocol {
    
    func showCurrencies() {
        self.tableView.reloadData()
    }
}
