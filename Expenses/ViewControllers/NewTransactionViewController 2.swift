//
//  NewTransactionViewController.swift
//  expenses
//
//  Created by Antonio Santos on 7/26/19.
//  Copyright © 2019 Antonio Santos. All rights reserved.
//

import UIKit
import CoreData
import os.log

class NewTransactionViewController: UIViewController, UITextFieldDelegate {
    var container: NSPersistentContainer!
    /*
     This value is either passed by `TransactionTableViewController` in `prepare(for:sender:)`
     or constructed as part of adding a new transaction.
     */
    weak var entry: Entry?
    
    // MARK: - IBOutlets
    @IBOutlet weak var transactionDescriptionLabel: UILabel!
    @IBOutlet var transactionDescriptionTextField: UITextField!
    @IBOutlet var transactionAmountLabel: UILabel!
    @IBOutlet var transactionAmountTextField: UITextField!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    let TRANSACTION_DESCRIPTION_TEXT_FIELD_TAG = 0
    let TRANSACTION_AMOUNT_TEXT_FIELD_TAG = 1
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Handle textfield input through delegate callbacks.
        transactionDescriptionTextField.delegate = self
        transactionAmountTextField.delegate = self
        
        // Adds done button to keypad
        transactionAmountTextField.addDoneButtonToKeyboard(myAction: #selector(self.transactionAmountTextField.resignFirstResponder))
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // If the First Responder is the Description Text Field, transfer First Responder to Amount Text Field
        if (textField.tag == TRANSACTION_DESCRIPTION_TEXT_FIELD_TAG) {
            transactionAmountTextField.becomeFirstResponder()
        }
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: segue)
        
        // Configure the destination view controller only when the save button is pressed.
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        
        let transactionDescription = transactionDescriptionTextField.text ?? ""
        let transactionAmount = transactionAmountTextField.text ?? ""
        
        
        
    }
    
    // MARK: - IBActions
    @IBAction func cancelButtonTapped(sender: UIBarButtonItem) {
    }
    
    @IBAction func saveButtonTapped(sender: UIBarButtonItem) {
    }
}
