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
    var transactions = [NSManagedObject]()
    var account: NSManagedObject!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updatePersistentStorage()
        
        // Create Default Account on first launch
        if Helper.isFirstLaunch() {
            os_log("Creating Default account.", log: .default, type: .debug )
            account = NSEntityDescription.insertNewObject(forEntityName: "Account", into: container.viewContext) as! Account
            account.setValue(UUID(), forKey: "id")
            account.setValue("Default", forKey: "name")
            account.setValue(0.00, forKey: "balance")
            saveContext()
        } else {
            os_log("Loading Default account.", log: .default, type: .debug )
            
            let accountsFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Account")
            accountsFetch.predicate = NSPredicate(format: "name == %@", "Default")
             
            do {
                let fetchedAccounts = try container.viewContext.fetch(accountsFetch) as! [Account]
                account = fetchedAccounts.first
            } catch {
                fatalError("Failed to fetch employees: \(error)")
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard container != nil else {
            fatalError("This view needs a persistent container.")
        }
        
        loadSavedData()
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 55
    }
    
    // MARK: - CoreData Related Functions
    func loadSavedData() {
        let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        let sort = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [sort]

        do {
            transactions = try container.viewContext.fetch(request)
            print("Got \(transactions.count) transactions")
            tableView.reloadData()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }
//
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
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
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        
        guard let transactionAmount = transaction.value(forKey: "amount") as? Double else {
            print("Transaction: \(transaction)")
            fatalError("No Amount object referenced by Transaction")
        }
        
        cell.amountLabel.text = numberFormatter.string(from: transactionAmount as NSNumber? ?? 0.00)

        return cell
    }

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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "NewTransaction":
            os_log("Adding a new transaction.", log: .default, type: .debug)
            
            guard let destination = segue.destination as? TransactionDetailTableViewController else {
                fatalError("Unexpected Destination: \(segue.destination)")
            }
            
            destination.container = container
            destination.account = account
        default:
            os_log("A segue was attempted with an unknown segue.", log: .default, type: .debug)
        }
    }
    
    @IBAction func unwindToTransactionList(sender: UIStoryboardSegue) {
        if sender.source is TransactionDetailTableViewController {
            // Receive the transaction back from the TransactionDetailViewController, save it to the persistent storage and
            // update Persistent Storage.
            do {
                try container.viewContext.save()
                updatePersistentStorage()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }

            // reset the tableView to defaults if no data message was displayed before loading data.
            if self.tableView.backgroundView != nil {
                self.tableView.backgroundView = nil
                self.tableView.separatorStyle = .singleLine
            }
            self.tableView.reloadData()
        }
    }

    // MARK: - Private Methods
    // Update transactions and reload table data.
    private func updatePersistentStorage() {
        // load managedCOntext
        let managedContext = container.viewContext
        
        let fetchTransactionsRequest = NSFetchRequest<NSManagedObject>(entityName: "Transaction")
        let sortByDate = NSSortDescriptor(key: "date", ascending: false)
        fetchTransactionsRequest.sortDescriptors = [sortByDate]
        
        // try to fetch data from CoreData. If successful, load into transactions.
        do {
            transactions = try managedContext.fetch(fetchTransactionsRequest)
            tableView.reloadData()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
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

}

class TransactionTableViewCell: UITableViewCell {
    @IBOutlet weak var payeeLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
}
