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
    func changeIcon()
    func changeAutomatic()
}

class ViewController: UIViewController, ViewControllerDelegate {

    weak var delegate: TableViewControllerDelegate?
    
    private var isTurning = false
    var icon: Bool!
    var document: PDFDocument?
    var vertical: Bool!
    var automatic: Bool!
    private var viewPdf: CGRect!
    private var viewVertical: CGRect!
    private var viewHorizontal: CGRect!
    var row: Int!
    
    @IBOutlet weak var pdfView: PDFView!
    @IBOutlet weak var verticalThumbnail: PDFThumbnailView!
    @IBOutlet weak var horizontalThumbnail: PDFThumbnailView!
    @IBOutlet weak var pageButton: UIBarButtonItem!
    
    func changeVertical() {
        vertical = true
        pdfView.go(to: (document?.page(at:1))!)
        pdfView.displayDirection = .vertical
        changeThumbnail()
    }
    
    func changeHorizontal() {
        vertical = false
        pdfView.go(to: (document?.page(at:1))!)
        pdfView.displayDirection = .horizontal
        changeThumbnail()
    }
    
    func changeIcon(){
        icon = !icon
        changeThumbnail()
    }
    
    func changeAutomatic(){
        automatic = !automatic
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewPdf = pdfView.frame
        viewVertical = verticalThumbnail.frame
        viewHorizontal = horizontalThumbnail.frame
        
        pdfView.frame =  CGRect(x:110, y: 0, width:668, height:864)
        changeThumbnail()
        
        toolbarItems = [pageButton]
        pageButton.isEnabled = false
        self.navigationController?.setToolbarHidden(false, animated: true)
        PDFViewSetup()
        thumbnailViewSetup()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handlePageChange(notification:)), name: Notification.Name.PDFViewPageChanged, object: nil)
    }
    
    private func changeThumbnail(){
        if icon {
            if vertical {
                pdfView.frame =  CGRect(x: viewVertical.width, y:viewPdf.minY , width: viewPdf.width-viewVertical.width, height:viewPdf.height)
            }
            else {
                pdfView.frame =  CGRect(x: viewPdf.minX, y:viewPdf.minY , width: viewPdf.width, height:viewPdf.height-viewHorizontal.height)
            }
            horizontalThumbnail.isHidden = vertical
            verticalThumbnail.isHidden = !vertical
        }
        else {
            pdfView.frame = viewPdf
            horizontalThumbnail.isHidden = true
            verticalThumbnail.isHidden = true
        }
    }
    
    private func PDFViewSetup(){
        pdfView.document = document
        pageButton.title = "1/\(document!.pageCount)"
        view.addSubview(pdfView)
        if vertical {pdfView.displayDirection = .vertical}
        else {pdfView.displayDirection = .horizontal}
        pdfView.displayMode = .singlePageContinuous
        pdfView.pageBreakMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        pdfView.autoScales = true
        //pdfView.usePageViewController(true, withViewOptions: [:])
    }
    
    private func thumbnailViewSetup(){
        verticalThumbnail.pdfView = pdfView
        verticalThumbnail.thumbnailSize = CGSize(width: 100, height: 100)
        verticalThumbnail.layoutMode = .vertical
        verticalThumbnail.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        
        horizontalThumbnail.pdfView = pdfView
        horizontalThumbnail.thumbnailSize = CGSize(width: 100, height: 100)
        horizontalThumbnail.layoutMode = .horizontal
        horizontalThumbnail.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
    }
    
    @objc private func handlePageChange(notification: Notification)
      {
          pageButton.title = "\(document!.index(for: pdfView.currentPage!)+1)/\(document!.pageCount)"
      }
    override func willMove(toParent parent: UIViewController?) {
        if (!(parent?.isEqual(self.parent) ?? false)) {
            self.navigationController?.setToolbarHidden(true, animated: true)
            
            delegate!.changeParameters(automatic: automatic, vertical: vertical, icon: icon, row: row)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destination = segue.destination as? SettingsTableViewController else { return }
        destination.delegate = self
        destination.vertical = vertical
        destination.icon = icon
        destination.automatic = automatic
    }
}

