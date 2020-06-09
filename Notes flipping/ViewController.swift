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
import AVKit
import Vision

protocol ViewControllerDelegate: class {
    func changeVertical()
    func changeHorizontal()
    func changeIcon()
    func changeAutomatic()
    func startRunning()
}

class ViewController: UIViewController, ViewControllerDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {

    weak var delegate: TableViewControllerDelegate?
    
    private var isTurning = false
    private var icon: Bool!
    private var document: PDFDocument!
    private var vertical: Bool!
    private var automatic: Bool!
    private var viewPdf: CGRect!
    private var row: Int!
    private var smile = false
    private var output = AVCaptureVideoDataOutput()
    
    @IBOutlet weak var pdfView: PDFView!
    @IBOutlet weak var verticalThumbnail: PDFThumbnailView!
    @IBOutlet weak var horizontalThumbnail: PDFThumbnailView!
    @IBOutlet weak var pageButton: UIBarButtonItem!
    @IBOutlet weak var space: UIBarButtonItem!
    @IBOutlet weak var statusButton: UIBarButtonItem!
    
    private lazy var currentSession: AVCaptureSession = {
        let session = AVCaptureSession()
        session.sessionPreset = .high
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            return session
        }
        guard let input = try? AVCaptureDeviceInput(device: camera)
            else {
                return session
            }
        session.addInput(input)
        return session
    }()
    
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
    
    func startRunning(){
        if automatic {
            currentSession.startRunning()
            statusButton.title = "Лицо не распознано"
        }
        else {statusButton.title = ""}
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "video"))
        currentSession.addOutput(output)
        
        startRunning()
        
        viewPdf = pdfView.frame
        
        changeThumbnail()
        
        toolbarItems = [pageButton, space, statusButton]
        
        self.navigationController?.setToolbarHidden(false, animated: true)
        PDFViewSetup()
        
        thumbnailViewSetup()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handlePageChange(notification:)), name: Notification.Name.PDFViewPageChanged, object: nil)
    }
    
    func setParameters (document: PDFDocument, row: Int, automatic: Bool, icon: Bool, vertical: Bool){
        self.document = document
        self.row = row
        self.automatic = automatic
        self.icon = icon
        self.vertical = vertical
    }
    
    private func changeThumbnail(){
        if icon {
            if vertical {
                pdfView.frame =  CGRect(x: verticalThumbnail.frame.width, y:viewPdf.minY , width: viewPdf.width-verticalThumbnail.frame.width, height:viewPdf.height)
            }
            else {
                pdfView.frame =  CGRect(x: viewPdf.minX, y:viewPdf.minY , width: viewPdf.width, height:viewPdf.height-horizontalThumbnail.frame.height)
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
    }
    
    private func thumbnailViewSetup(){
        verticalThumbnail.pdfView = pdfView
        verticalThumbnail.thumbnailSize = CGSize(width: 100, height: 90)
        verticalThumbnail.layoutMode = .vertical
        verticalThumbnail.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
       
        horizontalThumbnail.pdfView = pdfView
        horizontalThumbnail.thumbnailSize = CGSize(width: horizontalThumbnail.frame.height - 50, height: horizontalThumbnail.frame.height - 50)
        horizontalThumbnail.layoutMode = .horizontal
        horizontalThumbnail.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
    }
    
    private func changePage(){
        if (document!.index(for: pdfView.currentPage!)+1 != document!.pageCount) {
            pdfView.go(to: (document?.page(at:document!.index(for: pdfView.currentPage!)+1))!)
        }
    }
    
    @objc private func handlePageChange(notification: Notification) {
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
        destination.setParameters(automatic: automatic, icon: icon, vertical: vertical)
        currentSession.stopRunning()
    }
    
    func captureOutput(_ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let image = CIImage(cvPixelBuffer: pixelBuffer, options: nil)
        
        let detector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: [CIDetectorSmile : true as AnyObject, CIDetectorAccuracy: CIDetectorAccuracyHigh])!
        
        DispatchQueue.global(qos: .userInteractive).async {
            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
            do {
                try handler.perform([VNDetectFaceRectanglesRequest {(req, error) in
                        DispatchQueue.main.async {
                            if req.results!.count == 0 {
                                self.statusButton.title = "Лицо не распознано"
                            }
                    }
                }])
            } catch let err {
                print("Ошибка в выполнении запроса: ", err)
            }
        }
    
        for feature in detector.features(in: image, options: [CIDetectorSmile: true as AnyObject, CIDetectorAccuracy: CIDetectorAccuracyHigh]) as! [CIFaceFeature] {

            if (feature.hasSmile) {
                DispatchQueue.main.async {
                    if !self.smile {
                        self.statusButton.title = "Распознана улыбка"
                        self.smile = true
                        self.changePage()
                    }
                }
            }
            else {
                DispatchQueue.main.async {
                    self.smile = false
                    self.statusButton.title = "Лицо распознано"
                }
            }
        }
    }
}

