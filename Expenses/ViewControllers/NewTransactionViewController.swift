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
    
    // MARK: Constants
    let TRANSACTION_DESCRIPTION_TEXT_FIELD_TAG = 0
    let TRANSACTION_AMOUNT_TEXT_FIELD_TAG = 1
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Handle textfield input through delegate callbacks.
        transactionDescriptionTextField.delegate = self
        transactionAmountTextField.delegate = self
        
        // Adds done button to keypad
        transactionAmountTextField.addDoneButtonToKeyboard(myAction: #selector(self.transactionAmountTextField.resignFirstResponder))
        
        // Enable the save button only if it has a valid Transaction name.
        updateSaveButtonState()
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
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Change color of label describing text field to highlight focus
        switch textField.tag {
        case TRANSACTION_DESCRIPTION_TEXT_FIELD_TAG:
            transactionDescriptionLabel.textColor = .systemBlue
            saveButton.isEnabled = false // disable save button while text is being edited.
        case TRANSACTION_AMOUNT_TEXT_FIELD_TAG:
            transactionAmountLabel.textColor = .systemBlue
        default:
            break
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // Restore color of label describing text field
        switch textField.tag {
        case TRANSACTION_DESCRIPTION_TEXT_FIELD_TAG:
            transactionDescriptionLabel.textColor = .secondaryLabel
            updateSaveButtonState()
            
            // Only change the navigationItem title if the transactionDescriptionTextField is not empty
            let text = textField.text ?? ""
            if !text.isEmpty {
                navigationItem.title = transactionDescriptionTextField.text
            } else {
                navigationItem.title = "New Transaction"
            }
            
        case TRANSACTION_AMOUNT_TEXT_FIELD_TAG:
            transactionAmountLabel.textColor = .secondaryLabel
        default:
            break
        }
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
        let transactionAmount = Double(transactionAmountTextField.text!) ?? 0.00

        // Set the entry to be passed to TransactionTableViewController after the unwind segue.
        entry?.setValue(transactionDescription, forKey: "entryDescription")
        entry?.setValue(transactionAmount, forKey: "amount")
        entry?.setValue(UUID(), forKey: "id")
        entry?.setValue(Date(), forKey: "date")
    }
    
    // MARK: - IBActions
    @IBAction func cancelButtonTapped(sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Private Methods
    private func updateSaveButtonState() {
        // Disable the Save button if the text field is empty.
        let text = transactionDescriptionTextField.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }
}
