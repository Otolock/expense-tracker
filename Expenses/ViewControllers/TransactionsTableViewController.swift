//
//  TransactionsTableViewController.swift
//  expenses
//
//  Created by Antonio Santos on 7/24/19.
//  Copyright © 2019 Antonio Santos. All rights reserved.
//

import UIKit
import CoreData
import os.log

class TransactionsTableViewController: UIViewController {
    // MARK: - Properties
    var transactions: [NSManagedObject] = []
    var container: NSPersistentContainer!
    
    // MARK: - IBOutlets
    @IBOutlet var tableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updatePersistentStorage()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup persistent container
        container = NSPersistentContainer(name: "Benjamin")
        // load store
        container.loadPersistentStores { storeDescription, error in
            if let error = error {
                print("Unresolved error \(error)")
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        // this passes a reference to a new Entry to the TransactionDetailViewController
        case "NewTransactionSegue":
            os_log("Adding a new transaction.", log: OSLog.default, type: .debug)
            let destination = segue.destination as! UINavigationController
            let targetController = destination.topViewController as! TransactionDetailViewController
            targetController.managedContext = container.viewContext
        case "ShowDetail":
            guard let transactionDetailViewController = segue.destination as? TransactionDetailViewController else {
                fatalError("Unexpected Destination: \(segue.destination)")
            }
            
            guard let selectedTransactionCell = sender as? TransactionTableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
             
            guard let indexPath = tableView.indexPath(for: selectedTransactionCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
             
            let selectedTransaction = transactions[indexPath.row]
            transactionDetailViewController.managedContext = container.viewContext
            transactionDetailViewController.transaction = selectedTransaction as? Transaction
        default:
            print("Unknown segue: \(segue.identifier!)")
        }
    }
    
    @IBAction func unwindToTransactionList(sender: UIStoryboardSegue) {
        if sender.source is TransactionDetailViewController {
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
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Transaction")
        let sortByDate = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sortByDate]
        
        // try to fetch data from CoreData. If successful, load into transactions.
        do {
            transactions = try managedContext.fetch(fetchRequest)
            tableView.reloadData()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    // save the current container context
    private func saveContext() {
        if container.viewContext.hasChanges {
            do {
                try container.viewContext.save()
            } catch {
                print("An error occurred while saving: \(error)")
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension TransactionsTableViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (transactions.count > 0) {
            return transactions.count
        } else {
            // if there is no data yet, display a friendly message.
            let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text = "Tap + to add your first transaction."
            noDataLabel.textAlignment = .center
            noDataLabel.lineBreakMode = .byWordWrapping
            noDataLabel.numberOfLines = 0
            tableView.backgroundView = noDataLabel
            tableView.separatorStyle = .none
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "transactionCell", for: indexPath) as! TransactionTableViewCell
        
        
        let transaction = transactions[indexPath.row]
        let transactionName = transaction.value(forKey: "name") as? String
        let transactionAmount = transaction.value(forKey: "amount") as? Double
        let transactionDate = transaction.value(forKey: "date") as? Date
        
        cell.transactionDescriptionLabel.text = transactionName
        
        //format transactionAmount to currency.
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency

        cell.transactionAmountLabel.text = numberFormatter.string(from: transactionAmount as NSNumber? ?? 0.00)
        
        // format transactionDate to relatativeDateFormatting
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .medium
        dateFormatter.locale = Locale.current
        dateFormatter.doesRelativeDateFormatting = true
        
        cell.transactionDateLabel.text = (dateFormatter.string(from: transactionDate!))
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let commit = transactions[indexPath.row]
            container.viewContext.delete(commit)
            transactions.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            saveContext()
        }
    }
}

// MARK: - TransactionTableViewCell
class TransactionTableViewCell: UITableViewCell {
    @IBOutlet weak var transactionDescriptionLabel: UILabel!
    @IBOutlet weak var transactionDateLabel: UILabel!
    @IBOutlet weak var transactionAmountLabel: UILabel!
}
