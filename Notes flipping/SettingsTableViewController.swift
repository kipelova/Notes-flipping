//
//  SettingsTableViewController.swift
//  Notes flipping
//
//  Created by Анастасия Гладкова on 23.05.2020.
//  Copyright © 2020 Анастасия Гладкова. All rights reserved.
//

import UIKit
import AVKit

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

        automaticSwitch.isEnabled = (AVCaptureDevice.authorizationStatus(for: AVMediaType.video) ==  AVAuthorizationStatus.authorized)
        
        navigationController?.setToolbarHidden(true, animated: true)
        
        iconSwitch.setOn(icon, animated: false)
        automaticSwitch.setOn(automatic, animated: false)
        
        if vertical {
            verticalChoice.accessoryType = UITableViewCell.AccessoryType.checkmark
        }
        else {
            horizontalChoice.accessoryType = UITableViewCell.AccessoryType.checkmark
        }
        
        if (AVCaptureDevice.authorizationStatus(for: AVMediaType.video) ==  AVAuthorizationStatus.denied) {
            
            let controller = UIAlertController(title: "Доступ к камере запрещен", message: "Чтобы включить функцию автоматического перелистывания, необходимо разрешить доступ к камере в настройках приложения.", preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "ОК", style: .default) { (alert) in
                }
                      
                    controller.addAction(okAction)
            
            present(controller, animated: true, completion: nil)
        }
    }
    
    func setParameters(automatic: Bool, icon: Bool, vertical: Bool){
        self.automatic = automatic
        self.icon = icon
        self.vertical = vertical
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
    
    override func willMove(toParent parent: UIViewController?) {
        if (!(parent?.isEqual(self.parent) ?? false)) {
            self.navigationController?.setToolbarHidden(false, animated: true)
            delegate?.startRunning()
        }
    }

}
