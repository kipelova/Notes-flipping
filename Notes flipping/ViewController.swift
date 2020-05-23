//
//  ViewController.swift
//  Notes flipping
//
//  Created by Анастасия Гладкова on 19.05.2020.
//  Copyright © 2020 Анастасия Гладкова. All rights reserved.
//

import UIKit
import RealmSwift
import PDFKit

protocol ViewControllerDelegate: class {
    func changeVertical()
    func changeHorizontal()
}

class ViewController: UIViewController, ViewControllerDelegate {

    private var isTurning = false
    var document: PDFDocument?
    private var vertical = true
    private var outline: PDFOutline?
    
    @IBOutlet weak var pdfView: PDFView!
    @IBOutlet weak var pageButton: UIBarButtonItem!
    
    func changeVertical() {
        vertical = true
        pdfView.go(to: (document?.page(at:1))!)
        pdfView.displayDirection = .vertical
    }
    
    func changeHorizontal() {
        vertical = false
        pdfView.go(to: (document?.page(at:1))!)
        pdfView.displayDirection = .horizontal
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        toolbarItems = [pageButton]
        pageButton.isEnabled = false
        self.navigationController?.setToolbarHidden(false, animated: true)
        PDFViewSetup()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handlePageChange(notification:)), name: Notification.Name.PDFViewPageChanged, object: nil)
    }
    
    func PDFViewSetup(){
        pdfView.document = document
        pageButton.title = "1/\(document!.pageCount)"
        view.addSubview(pdfView)
        pdfView.displayDirection = .vertical
        pdfView.displayMode = .singlePageContinuous
        pdfView.pageBreakMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        pdfView.autoScales = true
        //pdfView.usePageViewController(true, withViewOptions: [:])

    }
    @objc private func handlePageChange(notification: Notification)
      {
          pageButton.title = "\(document!.index(for: pdfView.currentPage!)+1)/\(document!.pageCount)"
      }
    override func willMove(toParent parent: UIViewController?) {
        if (!(parent?.isEqual(self.parent) ?? false)) {
            self.navigationController?.setToolbarHidden(true, animated: true)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destination = segue.destination as? SettingsTableViewController else { return }
        destination.delegate = self
        if vertical {destination.vertical = true}
        else {destination.vertical = false}
    }
}

