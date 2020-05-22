//
//  TableViewController.swift
//  Notes flipping
//
//  Created by Анастасия Гладкова on 19.05.2020.
//  Copyright © 2020 Анастасия Гладкова. All rights reserved.
//

import UIKit
import RealmSwift
import MobileCoreServices

class TableViewController: UITableViewController {

    private var realm: Realm!
    private var notes: Results<Note>!
    private var sortedNotes: Results<Note>!
    private var favouriteNotes: Results<Note>!
    private var currentName: String!
    private var isChanging = false
    private var isFavourite = false
    private var documentPicker = UIDocumentPickerViewController(documentTypes: [kUTTypePDF as String], in: .import)
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private var isEmpty: Bool {
        guard let text = searchController.searchBar.text else {
            return false
        }
        return text.isEmpty
    }
    
    private var isSearching: Bool {
        return searchController.isActive && (!isEmpty || searchController.searchBar.selectedScopeButtonIndex != 0)
    }
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var favouriteButton: UIBarButtonItem!
    @IBOutlet weak var deleteAllButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        realm = try! Realm()
        notes = self.realm.objects(Note.self)
        
        toolbarItems = [deleteAllButton]
        editButton.isEnabled = notes.count > 0
        favouriteButton.isEnabled = notes.count > 0
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск нот"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        documentPicker.delegate = self
        if #available(iOS 11.0, *){
            documentPicker.allowsMultipleSelection = false
        }
    }
    
    @IBAction func addAction(_ sender: Any) {
        
        let controller = UIAlertController(title: "Добавить новые ноты", message: nil, preferredStyle: .alert)
            
            let addAction = UIAlertAction(title: "Выбрать файл", style: .default) { (alert) in
                self.currentName = controller.textFields![0].text!
                self.present(self.documentPicker, animated: true, completion: nil)
                self.editButton.isEnabled = true
                self.favouriteButton.isEnabled = true
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
        searchController.searchBar.isUserInteractionEnabled = true
    }
    
    @IBAction func editAction(_ sender: Any) {
        tableView.setEditing(!tableView.isEditing, animated: true)
        
        if tableView.isEditing {
            editButton.title = "Готово"
            navigationController?.setToolbarHidden(false, animated: true)
            addButton.isEnabled = false
            favouriteButton.isEnabled = false
            isChanging = true
            searchController.searchBar.isUserInteractionEnabled = false
        } else {
            notEditinStyle()
        }
    }
    
    @IBAction func favouriteAction(_ sender: Any) {
        isFavourite = !isFavourite
        if isFavourite {
            self.title = "Избранные ноты"
            favouriteNotes = notes.filter("favourite = true")
            editButton.isEnabled = false
            addButton.isEnabled = false
            favouriteButton.image = UIImage(systemName: "suit.heart.fill")
        }
        else {
            self.title = "Мои ноты"
            editButton.isEnabled = true
            addButton.isEnabled = true
            favouriteButton.image = UIImage(systemName: "suit.heart")
        }
        self.tableView.reloadData()
    }
    
    @IBAction func deleteAllAction(_ sender: Any) {
        let controller = UIAlertController(title: "", message: "Все ноты будут удалены. Данное действие необратимо.", preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "Удалить все ноты", style: .destructive) { (alert) in
            try! self.realm.write {
                self.realm.deleteAll()
            }
            self.tableView.setEditing(false, animated: true)
            self.notEditinStyle()
            self.tableView.reloadData()
            self.editButton.isEnabled = false
            self.favouriteButton.isEnabled = false
        }
    
        let cancelAction = UIAlertAction(title: "Отменить", style: .cancel) { (alert) in
        }
        
        controller.addAction(deleteAction)
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
        if isSearching {return sortedNotes.count}
        else if isFavourite {return favouriteNotes.count}
        return notes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath)
        var note: Note
        
        if (isFavourite && !isSearching) {
            note = favouriteNotes[indexPath.row]
        }
        else if (!isFavourite && !isSearching) {
            note = notes[indexPath.row]
        }
        else {note = sortedNotes[indexPath.row]}
        
        cell.textLabel?.text = note.name

        return cell
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration {
        let favourite = UIContextualAction(style: .normal, title: "Избранное") { (favourite, view, competion) in
            try! self.realm.write {
                self.notes[indexPath.row].favourite = !self.notes[indexPath.row].favourite
            }
            competion(true)
        }
        
        if (self.notes[indexPath.row].favourite == true) {
            favourite.image = UIImage(systemName: "suit.heart.fill")!.withTintColor(UIColor.systemPink, renderingMode: .alwaysOriginal)
        }
        else {favourite.image = UIImage(systemName: "suit.heart")!.withTintColor(UIColor.systemPink, renderingMode: .alwaysOriginal) }
        favourite.backgroundColor = .systemGray6
        if (self.isFavourite) {return UISwipeActionsConfiguration(actions: [])}
        else {return UISwipeActionsConfiguration(actions: [favourite])}
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration {
        let delete = UIContextualAction(style: .normal, title: "Удалить") { (delete, view, competion) in
            try! self.realm.write {
                self.realm.delete(self.notes[indexPath.row])
                }
            tableView.deleteRows(at: [indexPath], with: .fade)
            if !self.isChanging {
                self.editButton.isEnabled = self.notes.count > 0
                self.favouriteButton.isEnabled = self.notes.count > 0
            }
            else if self.notes.count == 0 {
                self.notEditinStyle()
                self.editButton.isEnabled = false
                self.favouriteButton.isEnabled = false
                tableView.setEditing(false, animated: true)
            }
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

    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as? ViewController
        destination!.title = notes[tableView.indexPathForSelectedRow!.row].name
       destination!.url = URL(string:notes[tableView.indexPathForSelectedRow!.row].url)!
        
    }
}

extension TableViewController: UISearchResultsUpdating {
func updateSearchResults(for searchController: UISearchController) {
    filterContentForSearchText(searchController.searchBar.text!)
}
    private func filterContentForSearchText(_ searchText:String){
        if isFavourite {
            sortedNotes = favouriteNotes.filter("name CONTAINS[c] '\(searchText.lowercased())'")}
            else {
                sortedNotes = notes.filter("name CONTAINS[c] '\(searchText.lowercased())'")}
            tableView.reloadData()
        }
}

extension TableViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        let note = Note()
        note.name = currentName
        note.favourite = false
        note.url = url.absoluteString
        print(url)
        try! realm.write {
                realm.add(note)
            }
        self.tableView.reloadData()
    }
}
