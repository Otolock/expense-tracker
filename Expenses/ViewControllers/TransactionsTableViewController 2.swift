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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // load managedCOntext
        let managedContext = container.viewContext
        
        // try to fetch data from CoreData. If successful, load into entries.
        do {
            entries = try managedContext.fetch(Entry.fetchRequest())
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as? NewTransactionViewController
        vc.container = self.container
    }
    
    // save a new entry to the data store
    func save(entryDescription: String, amount: Double) {
        let managedContext = container.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Entry", in: managedContext)!
        
        let entry = NSManagedObject(entity: entity, insertInto: managedContext)
        
        entry.setValue(entryDescription, forKey: "entryDescription")
        entry.setValue(amount, forKey: "amount")
        entry.setValue(UUID(), forKey: "id")
        entry.setValue(Date(), forKey: "date")
        
        do {
            try managedContext.save()
            entries.append(entry)
          } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
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
    
    // MARK: - IBActions
//    @IBAction func addEntry(sender: UIBarButtonItem) {
//        let alert = UIAlertController(title: "New Name", message: "Add a new name", preferredStyle: .alert)
//        
//        let saveAction = UIAlertAction(title: "Save", style: .default) {
//            [unowned self] action in
//            
//            // create optional binding for alert text fields
//            guard let descriptionTextField = alert.textFields?[0], let entryDescription = descriptionTextField.text else {
//                return
//            }
//            
//            // TODO: need to add validation for amountTextField otherwise app will crash
////            guard let amountTextField = alert.textFields?[1], let entryAmount = Double(amountTextField.text!) else {
////                return
////            }
//            
//            // data to send to Core Data
//            self.save(entryDescription: entryDescription, amount: 9.90)
//            self.saveContext()
//            
//            // reset the tableView to defaults if no data message was displayed before loading data.
//            if self.tableView.backgroundView != nil {
//                self.tableView.backgroundView = nil
//                self.tableView.separatorStyle = .singleLine
//            }
//            self.tableView.reloadData()
//        }
//        
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
//        
//        alert.addTextField()
////        alert.addTextField()
//        
//        alert.addAction(saveAction)
//        alert.addAction(cancelAction)
//        
//        present(alert, animated: true)
//    }
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "transactionCell", for: indexPath)
        
        
        let entry = entries[indexPath.row]
        let entryDescription = entry.value(forKey: "entryDescription") as? String
        let entryAmount = entry.value(forKey: "amount") as? Double
        
        cell.textLabel!.text = entryDescription
        cell.detailTextLabel!.text = String(format: "$%.2f", entryAmount ?? 0.00)
        
        return cell
    }
}
