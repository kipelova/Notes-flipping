//
//  TableViewController.swift
//  Notes flipping
//
//  Created by Анастасия Гладкова on 19.05.2020.
//  Copyright © 2020 Анастасия Гладкова. All rights reserved.
//

import UIKit
import RealmSwift

class TableViewController: UITableViewController {

    private var realm: Realm!
    private var notes: Results<Note>!
    private var currentName: String!
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var deleteAllButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        realm = try! Realm()
        notes = self.realm.objects(Note.self)
        
        toolbarItems = [deleteAllButton]
    }
    
    @IBAction func addAction(_ sender: Any) {
        let controller = UIAlertController(title: "Добавить новые ноты", message: nil, preferredStyle: .alert)
            
            let addAction = UIAlertAction(title: "Выбрать файл", style: .default) { (alert) in
                self.currentName = controller.textFields![0].text!
                let note = Note()
                note.name = self.currentName
                try! self.realm.write {
                        self.realm.add(note)
                    }
                self.tableView.reloadData()
            }
            
            addAction.isEnabled = false
            
            let cancelAction = UIAlertAction(title: "Отменить", style: .cancel) { (alert) in
                }
              
            controller.addTextField { (textField) in
                      textField.placeholder = "Введите название нот"
                NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: OperationQueue.main, using:
                               {_ in
                                    addAction.isEnabled = textField.text != ""
                           })
                  }
                  
                controller.addAction(addAction)
                controller.addAction(cancelAction)
        
                present(controller, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return notes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath)

        var note: Note
        
        note = notes[indexPath.row]
        cell.textLabel?.text = note.name

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
