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
        
        presenter.getBaseCurrencyData()
    }
    
    func setupViewController() {
        presenter = RatesPresenter()
        presenter.attachView(view: self)
        amountTextField.text = "1.0"
        ratesTableView.delegate = self
        ratesTableView.dataSource = self
        amountTextField.keyboardType = .decimalPad
        setKeyboardToolbar()
    }

    func setupNavigationBar() {
        title = "Exchange rates"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(showSettingsView))
    }
    
    private func setKeyboardToolbar() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(amountEntered))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolBar.items = [space, doneButton]
        self.amountTextField.inputAccessoryView = toolBar
    }
    
    @objc func amountEntered() {
        view.endEditing(true)
        presenter.validateAmount(userAmount: amountTextField.text ?? "")
    }
    
    @objc func showSettingsView() {
        if let settingsVC = storyboard?.instantiateViewController(identifier: "SettingsView") {
            navigationController?.pushViewController(settingsVC, animated: true)
        }
    }
    
    @IBAction func manageCurrenciesTouched(_ sender: UIButton) {
        pushCurrenciesView()
    }
    
    @IBAction func finishedEditing(_ sender: UITextField) {
        print("Finished editing")
    }
    
    func pushCurrenciesView() {
        if let currenciesVC = storyboard?.instantiateViewController(identifier: "CurrencyView") {
            navigationController?.pushViewController(currenciesVC, animated: true)
        }
    }
}

extension RatesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.ratesCellArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RatesCell", for: indexPath) as? RatesCell else {
            fatalError("Couldn't dequeue RatesCell")
        }
        
        let currentRate = presenter.ratesCellArray[indexPath.row]
        cell.fillCellData(baseRate: currentRate.rate,
                          totalRate: currentRate.calculatedRate,
                          currencyCode: currentRate.currencyCode,
                          currencyName: currentRate.currencyName,
                          baseCode: UserSettings.getBaseCurrencyCode())
        
        return cell
    }
    
}

extension RatesViewController: RatesProtocol {
    
    func fillBaseCurrencyData(code: String, name: String) {
        currencyCodeLabel.text = code
        currencyNameLabel.text = name
        
        presenter.getRates()
    }
    
    func showRates() {
        self.ratesTableView.reloadData()
    }
    
    func noCurrencyCatalog() {
        pushCurrenciesView()
    }
    
    func noValidAmount() {
        let ac = UIAlertController(title: "Not valid amount", message: "The amount that you typed is not a valid number", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ok", style: .default))
        present(ac, animated: true)
    }
}
