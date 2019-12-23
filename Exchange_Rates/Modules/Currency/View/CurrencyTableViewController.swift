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
        presenter = CurrencyPresenter()
        presenter.attachView(view: self)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "CurrencyCell", for: indexPath)
        let currency = presenter.currencies[indexPath.row]
        cell.textLabel?.text = "\(currency.code) - \(currency.name)"
        
        return cell
    }
}

extension CurrencyTableViewController: CurrencyProtocol {
    
    func showCurrencies() {
        //DispatchQueue.main.async { [weak self] in
            self.tableView.reloadData()
        //}
    }
    
    func showError(errorMessage: String) {
        //DispatchQueue.main.async { [weak self] in
        let ac = UIAlertController(title: "Something happened!", message: errorMessage, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Got it!", style: .default))
            
            //self?.present(ac, animated: true)
        self.present(ac, animated: true)
        //}
    }
}
