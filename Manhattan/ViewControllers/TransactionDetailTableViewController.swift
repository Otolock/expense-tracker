//
//  TransactionDetailTableViewController.swift
//  Manhattan
//
//  Created by Antonio Santos on 8/27/19.
//  Copyright © 2019 Antonio Santos. All rights reserved.
//

import UIKit
import CoreData
import os.log

class TransactionDetailTableViewController: UITableViewController, UITextFieldDelegate {
    weak var container: NSPersistentContainer!
    weak var transaction: Transaction!
    var payee: Payee!
    var category: Category!
    weak var account: NSManagedObject!
    
    // MARK: - IBOutlets
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var transactionTypeSwitch: UISwitch!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var payeeTextField: UITextField!
    @IBOutlet weak var categoryTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard container != nil else {
            fatalError("This view needs a persistent container.")
        }
        
        guard account != nil else {
            fatalError("This view needs an account.")
        }

        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        
        if let _ = transaction {
            if (transaction.amount > 0) {
                updateTextFieldColor(isOn: true)
                transactionTypeSwitch.isOn = true
                amountTextField.text = numberFormatter.string(from: NSNumber(value: transaction.amount))
            } else {
                updateTextFieldColor(isOn: false)
                transactionTypeSwitch.isOn = false
                // this is a dirty fix, but due to the design of the string converter,
                // negative numbers are not handled nicely. This makes sure no negative numbers
                // are displayed in the amountTextField as this will cause issues if the user only changes
                // the transaction type and does not edit the amount. 
                amountTextField.text = numberFormatter.string(from: NSNumber(value: (transaction.amount * -1)))
            }
            
            if let _ = transaction.payee {
                payee = transaction.payee
                payeeTextField.text = payee.name
            }
            
            if let _ = transaction.category {
                category = transaction.category
                categoryTextField.text = category.name
            }
            
            
        } else {
            updateTextFieldColor(isOn: transactionTypeSwitch.isOn)
            amountTextField.text = "$0.00"
        }
        
        
        // Configure amountTextField
        self.amountTextField.delegate = self
        amountTextField.becomeFirstResponder()
        amountTextField.addDoneButtonToKeyboard(myAction: #selector(self.amountTextField.resignFirstResponder))
        
        self.payeeTextField.delegate = self
        self.categoryTextField.delegate = self
        
    }
    
    // MARK: - IBActions
    @IBAction func switchToggled(_ sender: UISwitch) {
        updateTextFieldColor(isOn: sender.isOn)
    }
    
    // MARK: - Helper Functions
    private func updateTextFieldColor(isOn: Bool) {
        if (isOn) {
            amountTextField.textColor = .systemGreen
        } else {
            amountTextField.textColor = .systemRed
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
                    
                    // Allow a maximum of $999,999,999.99
                    if (digitCount <= 11) {
                        textField.text = try? Helper.convertStringNumeralToCurrency(from: text, add: string)
                        return false
                    } else { return false }
                }
            } else { return true }
        } else { return true }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField.tag {
        case 0:
            payeeTextField.becomeFirstResponder()
        case 1:
            categoryTextField.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        
        return true
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: segue)
        
        // Configure the destination view controller only when the save button is pressed.
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        
        // If Payee already exists, retrieve it from CoreData, else create new Payee
        if Helper.doesEntityExist(entity: "Payee", with: payeeTextField.text!, container: container) {
            let payeesFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Payee")
            payeesFetch.predicate = NSPredicate(format: "name == %@", payeeTextField.text!)
            
            do {
                let fetchedPayees = try container.viewContext.fetch(payeesFetch) as! [Payee]
                payee = fetchedPayees.first
            } catch {
                fatalError("Failed to fetch payees: \(error)")
            }
        } else {
            os_log("Creating new payee.", log: .default, type: .debug )
            payee = NSEntityDescription.insertNewObject(forEntityName: "Payee", into: container.viewContext) as? Payee
            payee.setValue(UUID(), forKey: "id")
            payee.setValue(payeeTextField.text, forKey: "name")
        }
        
        // If Category already exists, retrieve it from CoreData, else create new Category
        if Helper.doesEntityExist(entity: "Category", with: categoryTextField.text!, container: container) {
            let categoriesFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Category")
            categoriesFetch.predicate = NSPredicate(format: "name == %@", categoryTextField.text!)
            
            do {
                let fetchedCategories = try container.viewContext.fetch(categoriesFetch) as! [Category]
                category = fetchedCategories.first
            } catch {
                fatalError("Failed to fetch categories: \(error)")
            }
        } else {
            os_log("Creating new category.", log: .default, type: .debug )
            category = NSEntityDescription.insertNewObject(forEntityName: "Category", into: container.viewContext) as? Category
            category.setValue(UUID(), forKey: "id")
            category.setValue(categoryTextField.text, forKey: "name")
        }
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        guard let transactionAmount = numberFormatter.number(from: amountTextField.text!) else {
            fatalError("Unable to convert transaction amount to number.")
        }
        
        if let _ = transaction {
            // The transaction type switch determines if a transaction is a debit or a credit.
            if transactionTypeSwitch.isOn {
                transaction.amount = transactionAmount.doubleValue
            } else {
                transaction.amount = (transactionAmount.doubleValue * -1.0)
            }
            
            transaction.payee = payee
            transaction.category = category
        } else {
            // Create Transaction
            transaction = NSEntityDescription.insertNewObject(forEntityName: "Transaction", into: container.viewContext) as? Transaction
            
            // The transaction type switch determines if a transaction is a debit or a credit.
            if transactionTypeSwitch.isOn {
                transaction.amount = transactionAmount.doubleValue
            } else {
                transaction.amount = (transactionAmount.doubleValue * -1.0)
            }
            
            //        transaction.setValue(transactionAmount?.doubleValue, forKey: "amount")
            transaction.setValue(Date(), forKey: "date")
            transaction.setValue(UUID(), forKey: "id")
            
            transaction.setValue(payee, forKey: "payee")
            transaction.setValue(category, forKey: "category")
            transaction.setValue(account, forKey: "account")
        }
    }
}
