//
//  ViewController.swift
//  Manhattan
//
//  Created by Antonio Santos on 8/23/19.
//  Copyright © 2019 Antonio Santos. All rights reserved.
//

import UIKit
import CoreData
import os.log

class TransactionsViewController: UITableViewController {
    var container: NSPersistentContainer!
    var transactions = [Transaction]()
    var account: Account!
    var accountBalance = 0.0
    
    let numberFormatter = NumberFormatter()
    
    @IBOutlet weak var accountBalanceTextField: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        accountBalance = 0.0
        
        // Create Default Account on first launch
        if Helper.isFirstLaunch() {
            os_log("Creating Default account.", log: .default, type: .debug)
            account = NSEntityDescription.insertNewObject(forEntityName: "Account", into: container.viewContext) as? Account
            account.setValue(UUID(), forKey: "id")
            account.setValue("Default", forKey: "name")
            account.setValue(0.00, forKey: "balance")
            saveContext()
        } else {
            os_log("Loading Default account.", log: .default, type: .debug)
            
            account = fetchAccount(accountName: "Default")
            
            guard account != nil else {
                fatalError("Unable to fetch default account.")
            }
            
            print("Got \(account.transactions?.count ?? 0) transaction(s)")
            
            transactions = fetchTransactions(account: account)
            
            for transaction in transactions {
                accountBalance += transaction.amount
                numberFormatter.numberStyle = .currency
                accountBalanceTextField.text = numberFormatter.string(from: NSNumber(value: accountBalance))
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard container != nil else {
            fatalError("This view needs a persistent container.")
        }
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 55
    }
    
    // MARK: - CoreData Related Functions
    // save the current container context
    private func saveContext() {
        if container.viewContext.hasChanges {
            do {
                os_log("Saving context...", log: OSLog.default, type: .debug)
                try container.viewContext.save()
            } catch {
                print("An error occurred while saving: \(error)")
            }
        }
    }
    
    // fetch the requested account
    private func fetchAccount(accountName: String) -> Account? {
        let accountsFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Account")
        accountsFetch.predicate = NSPredicate(format: "name == %@", accountName)
        
        do {
            let fetchedAccounts = try container.viewContext.fetch(accountsFetch) as! [Account]
            return fetchedAccounts.first ?? nil
        } catch {
            fatalError("Failed to fetch employees: \(error)")
        }
    }
    
    private func fetchTransactions(account: Account) -> [Transaction] {
        var fetchedTransactions = [Transaction]()
        if let _ = account.transactions {
            for transaction in (account.transactions?.sortedArray(using: [NSSortDescriptor(key: "date", ascending: false)]))! {
                fetchedTransactions.append(transaction as! Transaction)
            }
        }
        
        return fetchedTransactions
    }

    
    // MARK: - Table view data source
    
    //    override func numberOfSections(in tableView: UITableView) -> Int {
    //        // #warning Incomplete implementation, return the number of sections
    //        return 0
    //    }
    //
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath) as! TransactionTableViewCell
        
        let transaction = transactions[indexPath.row]
        guard let payee = transaction.value(forKey: "payee") as? Payee else {
            print("Transaction: \(transaction)")
            fatalError("No Payee object referenced by Transaction")
        }
        guard let category = transaction.value(forKey: "category") as? Category else {
            print("Transaction: \(transaction)")
            fatalError("No Category object referenced by Transaction")
        }
        
        cell.payeeLabel!.text = payee.value(forKey: "name") as? String
        cell.categoryLabel!.text = category.value(forKey: "name") as? String
        
        // format transactionAmount to currency.
        numberFormatter.numberStyle = .currency
        
        guard let transactionAmount = transaction.value(forKey: "amount") as? Double else {
            print("Transaction: \(transaction)")
            fatalError("No Amount object referenced by Transaction")
        }
        
        cell.amountLabel.text = numberFormatter.string(from: transactionAmount as NSNumber? ?? 0.00)
        
        // Change text color for dollar amounts.
        if transactionAmount > 0 {
            cell.amountLabel.textColor = .systemGreen
        } else {
            cell.amountLabel.textColor = .systemRed
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            accountBalance -= transactions[indexPath.row].amount
            numberFormatter.numberStyle = .currency
            
            accountBalanceTextField.text = numberFormatter.string(from: NSNumber(value: accountBalance))
            
            container.viewContext.delete(transactions[indexPath.row])
            transactions.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            saveContext()
        default:
            return
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "NewTransaction":
            os_log("Adding a new transaction.", log: .default, type: .debug)
            
            guard let destination = segue.destination as? TransactionDetailTableViewController else {
                fatalError("Unexpected Destination: \(segue.destination)")
            }
            
            destination.container = container
            destination.account = account
        case "ShowDetail":
            os_log("Editing existing transaction.", log: .default, type: .debug)
            
            guard let destination = segue.destination as? TransactionDetailTableViewController else {
                fatalError("Unexpected Destination: \(segue.destination)")
            }
            
            guard let selectedTransactionCell = sender as? TransactionTableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }

            guard let indexPath = tableView.indexPath(for: selectedTransactionCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            destination.container = container
            destination.account = account
            destination.transaction = transactions[indexPath.row]
            
        default:
            os_log("A segue was attempted with an unknown segue.", log: .default, type: .debug)
        }
    }
    
    @IBAction func unwindToTransactionList(sender: UIStoryboardSegue) {
        print("Unwinding with \(transactions.count) transaction(s)!")
        if sender.source is TransactionDetailTableViewController {
            saveContext()
            
            transactions = fetchTransactions(account: account)
            
            self.tableView.reloadData()
        }
    }
}

class TransactionTableViewCell: UITableViewCell {
    @IBOutlet weak var payeeLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
}
