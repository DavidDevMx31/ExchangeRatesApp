//
//  RatesViewController.swift
//  Exchange_Rates
//
//  Created by David Ali on 01/01/20.
//  Copyright © 2020 David Mendoza. All rights reserved.
//

import UIKit

class RatesViewController: UIViewController {

    @IBOutlet weak var currencyCodeLabel: UILabel!
    @IBOutlet weak var currencyNameLabel: UILabel!
    @IBOutlet weak var amountTextField: UITextField!
    
    @IBOutlet weak var lastUpdateLabel: UILabel!
    @IBOutlet weak var ratesTableView: UITableView!
    
    
    var presenter: RatesPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViewController()
        setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        presenter.getBaseCurrency()
    }
    
    func setupViewController() {
        presenter = RatesPresenter()
        presenter.attachView(view: self)
        amountTextField.text = "1.0"
    }

    func setupNavigationBar() {
        title = "Exchange rates"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(showSettingsView))
    }
    
    @objc func showSettingsView() {
        if let settingsVC = storyboard?.instantiateViewController(identifier: "SettingsView") {
            navigationController?.pushViewController(settingsVC, animated: true)
        }
    }
    
    @IBAction func manageCurrenciesTouched(_ sender: UIButton) {
        pushCurrenciesView()
    }
    
    func pushCurrenciesView() {
        if let currenciesVC = storyboard?.instantiateViewController(identifier: "CurrencyView") {
            navigationController?.pushViewController(currenciesVC, animated: true)
        }
    }
}

extension RatesViewController: RatesProtocol {
    
    func showBaseCurrencyData(code: String, name: String) {
        currencyCodeLabel.text = code
        currencyNameLabel.text = name
    }
    
    func noCurrencyCatalog() {
        pushCurrenciesView()
    }
}
