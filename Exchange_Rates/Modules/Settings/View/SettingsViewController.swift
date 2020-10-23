//
//  SettingsViewController.swift
//  Exchange_Rates
//
//  Created by David Ali on 17/12/19.
//  Copyright © 2019 David Mendoza. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var decimalPositionStepper: UIStepper!
    @IBOutlet weak var decimalPositionLabel: UILabel!
    @IBOutlet weak var alternativeCurrencySwitch: UISwitch!
    
    private var presenter: SettingsPresenter!
    
    private var decimalPositions = 0 {
        didSet {
            decimalPositionLabel.text = "\(decimalPositions) decimal positions"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupControls()
        presenter = SettingsPresenter(view: self)
        title = "Settings"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        presenter.getUserSettings()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        presenter.saveSettings(decimalPositions: decimalPositions, showAlternativeCurrencies: alternativeCurrencySwitch.isOn)
    }
    
    func setupControls() {
        decimalPositionStepper.minimumValue = 1
        decimalPositionStepper.maximumValue = 6
        decimalPositionStepper.value = 2
        decimalPositions = 2
    }
    
    @IBAction func decimalPositionsChanged(_ sender: UIStepper) {
        decimalPositions = Int(sender.value)
    }
}

extension SettingsViewController: SettingsProtocol {
    
    func showUserSettings(defaults: SettingsModel) {
        decimalPositions = defaults.decimalPositions
        decimalPositionStepper.value = Double(decimalPositions)
        alternativeCurrencySwitch.isOn = defaults.showAlternativeCurrencies
    }
    
}
