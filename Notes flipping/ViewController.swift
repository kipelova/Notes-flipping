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

    var url: URL!
    private var isTurning = false
    private var document: PDFDocument?
    private var outline: PDFOutline?
    
    @IBOutlet weak var pdfView: PDFView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        PDFViewSetup()
    }
    
    func PDFViewSetup(){
        document = PDFDocument(url: url)
        outline = document!.outlineRoot
        pdfView.document = document
        view.addSubview(pdfView)
        pdfView.displayDirection = .vertical
        pdfView.usePageViewController(true, withViewOptions: nil)
        pdfView.displayMode = .singlePage
        pdfView.pageBreakMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        pdfView.autoScales = true
    }
}

