//
//  AccountTableViewController.swift
//  Manhattan
//
//  Created by Antonio Santos on 9/11/19.
//  Copyright © 2019 Antonio Santos. All rights reserved.
//

import UIKit
import CoreData
import os.log

class AccountTableViewController: UITableViewController, UITextFieldDelegate {
    var saveButton: UIBarButtonItem?
    
    @IBOutlet weak var accountNameTextField: UITextField!
    
    var managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func configureView() {
        
        saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
        navigationItem.rightBarButtonItem = saveButton
        
        if let _ = account {
            navigationItem.title = account?.name ?? "New Account"
            accountNameTextField?.text = account?.name
        } else {
            navigationItem.title = "New Account"
            saveButton?.isEnabled = false
        }
    }
    
    @objc func save() {
        if let _ = account {
            account?.name = accountNameTextField?.text
        } else {
            account = NSEntityDescription.insertNewObject(forEntityName: "Account", into: managedObjectContext) as? Account
            account?.name = accountNameTextField.text
            account?.id = UUID()
            account?.balance = 0.0
        }
        
        self.performSegue(withIdentifier: "unwindToAccounts", sender: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        
        accountNameTextField.delegate = self
    }
    
    weak var account: Account?
    
    // MARK: - Text field delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = (textField.text! as NSString).replacingCharacters(in: range, with: string)

        if text.isEmpty {
            saveButton?.isEnabled = false
        } else {
            saveButton?.isEnabled = true
        }
        
        return true
    }

    // MARK: - Table view data source
//
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 0
//    }

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
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }

}
