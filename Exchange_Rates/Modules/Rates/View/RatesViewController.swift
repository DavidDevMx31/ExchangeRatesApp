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
    
    private var presenter: RatesPresenter!
    private var lastAmount = 1.0
    
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
        amountTextField.text = "\(lastAmount)"
        ratesTableView.delegate = self
        ratesTableView.dataSource = self
        amountTextField.keyboardType = .decimalPad
        setKeyboardToolbar()
    }

    func setupNavigationBar() {
        title = "Exchange rates"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(showSettingsView))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshRates))
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
        //presenter.validateAmount(userAmount: amountTextField.text ?? "")
    }
    
    @objc func showSettingsView() {
        if let settingsVC = storyboard?.instantiateViewController(identifier: "SettingsView") {
            navigationController?.pushViewController(settingsVC, animated: true)
        }
    }
    
    @objc func refreshRates() {
        presenter.refreshRatesData()
    }
    
    @IBAction func manageCurrenciesTouched(_ sender: UIButton) {
        pushCurrenciesView()
    }
    
    @IBAction func editingBegin(_ sender: UITextField) {
        if let userAmount = amountTextField.text {
            lastAmount = Double(userAmount) ?? 1.0
        }
        amountTextField.text = ""
    }
    
    @IBAction func finishedEditing(_ sender: UITextField) {
        if let userAmount = amountTextField.text {
            if userAmount.isEmpty {
                amountTextField.text = "\(lastAmount)"
            } else {
                presenter.validateAmount(userAmount: userAmount)
            }
        } else {
            amountTextField.text = "\(lastAmount)"
        }
    }
    
    func pushCurrenciesView() {
        if let currenciesVC = storyboard?.instantiateViewController(identifier: "CurrencyView") {
            navigationController?.pushViewController(currenciesVC, animated: true)
        }
    }
}

extension RatesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return presenter.fullRatesArray.section[section].sectionName
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.fullRatesArray.section[section].rows.count
        //return presenter.ratesCellArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RatesCell", for: indexPath) as? RatesCell else {
            fatalError("Couldn't dequeue RatesCell")
        }
        
        let currentRate = presenter.fullRatesArray.section[indexPath.section].rows[indexPath.row]
        //let currentRate = presenter.ratesCellArray[indexPath.row]
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
        amountTextField.text = "\(lastAmount)"
        let ac = UIAlertController(title: "Not valid amount", message: "The amount that you typed is not a valid number", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ok", style: .default))
        present(ac, animated: true)
    }
}
