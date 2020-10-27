//
//  RatesViewController.swift
//  Exchange_Rates
//
//  Created by David Ali on 01/01/20.
//  Copyright © 2020 David Mendoza. All rights reserved.
//

import UIKit

class RatesViewController: UIViewController {

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
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "settings")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(showSettingsView))
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
        if presenter.fullRatesArray.section.count > 0 {
            return presenter.fullRatesArray.section[section].sectionName
        }
        return ""
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if presenter.fullRatesArray.section.count > 0 {
            return presenter.fullRatesArray.section[section].rows.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RatesCell", for: indexPath) as? RatesCell else {
            fatalError("Couldn't dequeue RatesCell")
        }
        
        let currentRate = presenter.fullRatesArray.section[indexPath.section].rows[indexPath.row]
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
        currencyNameLabel.text = "Base currency: \(code) - \(name)"
        presenter.getRates()
    }
    
    func showRates() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        let lastupdated = UserSettings.getRatesLastUpdateDate()
        lastUpdateLabel.text = "Last update: \(dateFormatter.string(from: lastupdated))"
        self.ratesTableView.reloadData()
    }
    
    func noCurrencyCatalog() {
        pushCurrenciesView()
    }
    
    func enteredInvalidAmount() {
        amountTextField.text = "\(lastAmount)"
        let ac = UIAlertController(title: "Not valid amount", message: "The amount that you typed is not a valid number", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ok", style: .default))
        present(ac, animated: true)
    }
    
    func showError(message: String) {
        let ac = UIAlertController(title: "Something happened", message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Got it", style: .default))
        present(ac, animated: true)
    }
}

// <a target="_blank" href="https://iconos8.es/icons/set/settings">Settings</a>, <a target="_blank" href="https://iconos8.es/icons/set/coins">Coins</a> and other icons by <a target="_blank" href="https://iconos8.es">Icons8</a>
