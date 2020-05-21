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
    private var isChanging = false
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var favouriteButton: UIBarButtonItem!
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
    
    func notEditinStyle() {
        editButton.title = "Изменить"
        navigationController?.setToolbarHidden(true, animated: true)
        addButton.isEnabled = true
        favouriteButton.isEnabled = true
        isChanging = false
    }
    
    @IBAction func editAction(_ sender: Any) {
        tableView.setEditing(!tableView.isEditing, animated: true)
        
        if tableView.isEditing {
            editButton.title = "Готово"
            navigationController?.setToolbarHidden(false, animated: true)
            addButton.isEnabled = false
            favouriteButton.isEnabled = false
            isChanging = true
        } else {
            notEditinStyle()
        }
    }
    
    @IBAction func deleteAllAction(_ sender: Any) {
        try! self.realm.write {
            self.realm.deleteAll()
        }
        tableView.setEditing(false, animated: true)
        notEditinStyle()
        tableView.reloadData()
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
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration {
        let delete = UIContextualAction(style: .normal, title: "Удалить") { (delete, view, competion) in
            try! self.realm.write {
                self.realm.delete(self.notes[indexPath.row])
                }
            tableView.deleteRows(at: [indexPath], with: .fade)
            competion(true)
        }
        delete.backgroundColor = .red
        let edit = UIContextualAction(style: .normal, title: "Изменить") { (edit, view, competion) in
            
            let controller = UIAlertController(title: "Изменить название нот", message: nil, preferredStyle: .alert)
            
            let editAction = UIAlertAction(title: "Изменить", style: .default) { (alert) in
                try! self.realm.write {
                    self.notes[indexPath.row].name = controller.textFields![0].text!
                }
                self.tableView.reloadData()
            }
            
            editAction.isEnabled = false
            
            let cancelAction = UIAlertAction(title: "Отменить", style: .cancel) { (alert) in
                }
              
            controller.addTextField { (textField) in
                      textField.placeholder = "Введите новое название нот"
                
                NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: OperationQueue.main, using:
                               {_ in
                                    editAction.isEnabled = textField.text != ""
                           })
                  }
                  
                controller.addAction(editAction)
                controller.addAction(cancelAction)
                
            self.present(controller, animated: true, completion: nil)
        
            competion(true)

        }

        if (self.isChanging) { return UISwipeActionsConfiguration(actions: [delete]) }
        else { return UISwipeActionsConfiguration(actions: [delete, edit]) }
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
