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

class ViewController: UIViewController {

    private var isTurning = false
    var document: PDFDocument?
    private var outline: PDFOutline?
    
    @IBOutlet weak var pdfView: PDFView!
    @IBOutlet weak var pageButton: UIBarButtonItem!
    
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
        //pdfView.usePageViewController(true, withViewOptions: nil)
        pdfView.displayMode = .singlePageContinuous
        pdfView.pageBreakMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        pdfView.autoScales = true
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
}

