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
    var container: NSPersistentContainer!
    var transaction: Transaction!
    var payee: NSManagedObject!
    var category: NSManagedObject!
    var account: NSManagedObject!
    
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
        
        updateTextFieldColor(isOn: transactionTypeSwitch.isOn)
        
        // Configure amountTextField
        self.amountTextField.delegate = self
        amountTextField.becomeFirstResponder()
        amountTextField.addDoneButtonToKeyboard(myAction: #selector(self.amountTextField.resignFirstResponder))
        
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
        textField.resignFirstResponder()
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
            payee = NSEntityDescription.insertNewObject(forEntityName: "Payee", into: container.viewContext) as! Payee
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
            category = NSEntityDescription.insertNewObject(forEntityName: "Category", into: container.viewContext) as! Category
            category.setValue(UUID(), forKey: "id")
            category.setValue(categoryTextField.text, forKey: "name")
        }
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        let transactionAmount = numberFormatter.number(from: amountTextField.text!)
        
        // Create Transaction
        transaction = NSEntityDescription.insertNewObject(forEntityName: "Transaction", into: container.viewContext) as? Transaction
        transaction.setValue(transactionAmount?.doubleValue, forKey: "amount")
        transaction.setValue(Date(), forKey: "date")
        transaction.setValue(UUID(), forKey: "id")
        
        transaction.setValue(payee, forKey: "payee")
        transaction.setValue(category, forKey: "category")
        transaction.setValue(account, forKey: "account")
    }
}
