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
    @IBOutlet weak var payeeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard container != nil else {
            fatalError("This view needs a persistent container.")
        }
        
        // Set the switch to OFF position
        transactionTypeSwitch.isOn = false
        
        self.transactionAmountTextField.delegate = self
        transactionAmountTextField.text = "$0.00"
        
        updateTextFieldColor(isOn: transactionTypeSwitch.isOn)
        
        transactionAmountTextField.becomeFirstResponder()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    /*
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }
    */

    /*
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
    */

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch segue.identifier! {
        case "SelectPayee":
            os_log("Selecting payee.", log: OSLog.default, type: .debug)
            
            guard let destination = segue.destination as? UINavigationController else {
                fatalError("Unexpected Destination: \(segue.destination)")
            }
            
            guard let targetDestination = destination.topViewController as? PayeesTableViewController else {
                fatalError("Unexpected Destination: \(segue.destination)")
            }
            
            targetDestination.container = container
            
            if let _ = payee {
                targetDestination.payee = payee as? Payee
            }
        default:
            print("Unknown segue: \(segue.identifier!)")
        }
    }
    
    @IBAction func unwindToTransactionDetail(sender: UIStoryboardSegue) {
        let payeeView = sender.source as? PayeesTableViewController
        if sender.source is PayeesTableViewController {
            // Receive the transaction back from the TransactionDetailViewController, save it to the persistent storage and
            // update Persistent Storage.
            payee = payeeView?.payee
            do {
                try container.viewContext.save()
//                updatePersistentStorage()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
            
            payeeLabel.text = payee.value(forKey: "name") as? String

//            // reset the tableView to defaults if no data message was displayed before loading data.
//            if self.tableView.backgroundView != nil {
//                self.tableView.backgroundView = nil
//                self.tableView.separatorStyle = .singleLine
//            }
//            self.tableView.reloadData()
        }
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
    }
}
