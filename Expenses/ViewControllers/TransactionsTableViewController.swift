//
//  TransactionsTableViewController.swift
//  expenses
//
//  Created by Antonio Santos on 7/24/19.
//  Copyright © 2019 Antonio Santos. All rights reserved.
//

import UIKit
import CoreData

class TransactionsTableViewController: UIViewController {
    // MARK: - Properties
    var entries: [NSManagedObject] = []
    var container: NSPersistentContainer!
    
    // MARK: - IBOutlets
    @IBOutlet var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup persistent container
        container = NSPersistentContainer(name: "expenses")
        // load store
        container.loadPersistentStores { storeDescription, error in
            if let error = error {
                print("Unresolved error \(error)")
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        // this passes a reference to a new Entry to the NewTransactionViewController
        case "NewTransactionSegue":
            let destination = segue.destination as! UINavigationController
            let targetController = destination.topViewController as! NewTransactionViewController
            let entity = NSEntityDescription.entity(forEntityName: "Entry", in: container.viewContext)!
            let entry = NSManagedObject(entity: entity, insertInto: container.viewContext)
            targetController.entry = entry as? Entry
        default:
            print("Unknown segue: \(segue.identifier!)")
        }
    }
    
    @IBAction func unwindToTransactionList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? NewTransactionViewController, let entry = sourceViewController.entry {
            // Receive the entry back from the NewTransactionViewController, save it to the persistent storage and append
            // it to the entries array for the tableView.
            do {
                try container.viewContext.save()
                entries.append(entry)
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // load managedCOntext
        let managedContext = container.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Entry")
        
        // try to fetch data from CoreData. If successful, load into entries.
        do {
            entries = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    // save the current container context
    func saveContext() {
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
        if (entries.count > 0) {
            return entries.count
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
        
        
        let entry = entries[indexPath.row]
        let entryDescription = entry.value(forKey: "entryDescription") as? String
        let entryAmount = entry.value(forKey: "amount") as? Double
        let entryDate = entry.value(forKey: "date") as? Date
        
        cell.transactionDescriptionLabel.text = entryDescription
        
        //format entryAmount to currency.
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency

        cell.transactionAmountLabel.text = numberFormatter.string(from: entryAmount! as NSNumber)

//        cell.transactionAmountLabel.text = String(format: "$%.2f", entryAmount ?? 0.00)
        
        // format entryDate to relatativeDateFormatting
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .medium
        dateFormatter.locale = Locale.current
        dateFormatter.doesRelativeDateFormatting = true
        
        cell.transactionDateLabel.text = (dateFormatter.string(from: entryDate!))
        
        
        return cell
    }
}

// MARK: - TransactionTableViewCell
class TransactionTableViewCell: UITableViewCell {
    @IBOutlet weak var transactionDescriptionLabel: UILabel!
    @IBOutlet weak var transactionDateLabel: UILabel!
    @IBOutlet weak var transactionAmountLabel: UILabel!
}
