//
//  NewTransactionViewController.swift
//  expenses
//
//  Created by Antonio Santos on 7/26/19.
//  Copyright © 2019 Antonio Santos. All rights reserved.
//

import UIKit

class NewTransactionViewController: UIViewController, UITextFieldDelegate {
    /*
     This value is either passed by `TransactionTableViewController` in `prepare(for:sender:)`
     or constructed as part of adding a new transaction.
     */
    var entry: Entry?
    
    // MARK: - IBOutlets
    @IBOutlet weak var transactionDescriptionLabel: UILabel!
    @IBOutlet var transactionDescriptionTextField: UITextField!
    @IBOutlet var transactionAmountLabel: UILabel!
    @IBOutlet var transactionAmountTextField: UITextField!
    
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
    
    // MARK: - IBActions
    @IBAction func cancelButtonTapped(sender: UIBarButtonItem) {
    }
    
    @IBAction func saveButtonTapped(sender: UIBarButtonItem) {
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}
