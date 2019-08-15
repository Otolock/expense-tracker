//
//  TransactionDetailTableViewController.swift
//  expenses
//
//  Created by Antonio Santos on 8/1/19.
//  Copyright © 2019 Antonio Santos. All rights reserved.
//

import UIKit
import CoreData
import os.log

class TransactionDetailTableViewController: UITableViewController, UITextFieldDelegate {
    var transaction: NSManagedObject!
    var payee: NSManagedObject!
    var container: NSPersistentContainer!
    
    // MARK: - IBOutlets
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var transactionTypeSwitch: UISwitch!
    @IBOutlet weak var transactionAmountTextField: UITextField!
    @IBOutlet weak var payeeTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard container != nil else {
            fatalError("This view needs a persistent container.")
        }
        
        // Set the switch to OFF position
        transactionTypeSwitch.isOn = false
        
        self.transactionAmountTextField.delegate = self
        transactionAmountTextField.text = "$0.00"
        transactionAmountTextField.addDoneButtonToKeyboard(myAction: #selector(self.transactionAmountTextField.resignFirstResponder))
        
        updateTextFieldColor(isOn: transactionTypeSwitch.isOn)
        
        transactionAmountTextField.becomeFirstResponder()
        
        self.payeeTextField.delegate = self

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - IBActions
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func switchToggled(_ sender: UISwitch) {
        updateTextFieldColor(isOn: sender.isOn)
    }
    
    // MARK: - Helper Functions
    private func updateTextFieldColor(isOn: Bool) {
        if (isOn) {
            transactionAmountTextField.textColor = .systemGreen
        } else {
            transactionAmountTextField.textColor = .systemRed
        }
    }
    
    // MARK: - UITextFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (textField.tag == 0) {
            let char = string.cString(using: String.Encoding.utf8)
            let isBackSpace = strcmp(char, "\\b") == -92
            
            if let text = textField.text {
                if (isBackSpace) {
                    textField.text = try? Helper.convertStringNumeralToCurrency(from: String(text.dropLast()), add: "")
                    return false
                } else {
                    let digitCount = Helper.removePunctuation(textField.text!).count + string.count
                    
                    if (digitCount <= 11) {
                        textField.text = try? Helper.convertStringNumeralToCurrency(from: text, add: string)
                        return false
                    } else { return false }
                }
            } else { return true }
        } else { return true }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}
