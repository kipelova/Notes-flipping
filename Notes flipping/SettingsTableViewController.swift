//
//  SettingsTableViewController.swift
//  Notes flipping
//
//  Created by Анастасия Гладкова on 23.05.2020.
//  Copyright © 2020 Анастасия Гладкова. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    weak var delegate: ViewControllerDelegate?
    
    var vertical: Bool!
    var icon: Bool!
    var automatic: Bool!
   
    @IBOutlet weak var horizontalChoice: UITableViewCell!
    @IBOutlet weak var verticalChoice: UITableViewCell!
    @IBOutlet weak var iconSwitch: UISwitch!
    @IBOutlet weak var automaticSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.setToolbarHidden(true, animated: true)
        
        iconSwitch.setOn(icon, animated: false)
        automaticSwitch.setOn(automatic, animated: false)
        
        if vertical {
            verticalChoice.accessoryType = UITableViewCell.AccessoryType.checkmark
        }
        else {
            horizontalChoice.accessoryType = UITableViewCell.AccessoryType.checkmark
        }
    }
        
    @IBAction func iconAction(_ sender: Any) {
        delegate?.changeIcon()
    }
    
    @IBAction func automaticAction(_ sender: Any) {
        delegate?.changeAutomatic()
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        if indexPath.section == 1 {
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCell.AccessoryType.checkmark
            tableView.deselectRow(at: indexPath, animated: true)
            if indexPath.row == 0 {
                horizontalChoice.accessoryType = UITableViewCell.AccessoryType.none
                delegate?.changeVertical()
            }
            else {
                verticalChoice.accessoryType = UITableViewCell.AccessoryType.none
                delegate?.changeHorizontal()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 0 {return nil}
        return indexPath
    }
    
    /*override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    } */

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func willMove(toParent parent: UIViewController?) {
        if (!(parent?.isEqual(self.parent) ?? false)) {
            self.navigationController?.setToolbarHidden(false, animated: true)
        }
    }

}
