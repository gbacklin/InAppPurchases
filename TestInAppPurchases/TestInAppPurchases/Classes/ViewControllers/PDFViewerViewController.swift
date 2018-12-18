//
//  PDFViewerViewController.swift
//  TestInAppPurchases
//
//  Created by Gene Backlin on 12/12/18.
//  Copyright © 2018 Gene Backlin. All rights reserved.
//

import UIKit
import PDFKit
import MessageUI

class PDFViewerViewController: UIViewController {
    var pdfData: Data?
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        title = "Detail"
        if let pdf = pdfData {
            if #available(iOS 11.0, *) {
                display(pdf: pdf, in: view)
            } else {
                // Fallback on earlier versions
            }
            
            let sendButton = UIBarButtonItem(title: "Send", style: .plain, target: self, action: #selector(PDFViewerViewController.send(_:)))
            navigationItem.rightBarButtonItem = sendButton
        }
    }
    
    // MARK: - PDF creation
    
    @available(iOS 11.0, *)
    func display(pdf pdfData: Data, in parentView: UIView) {
        let pdfView = PDFView()
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        
        parentView.addSubview(pdfView)
        
        pdfView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        pdfView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        pdfView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        pdfView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        pdfView.document = PDFDocument(data: pdfData)
    }
    
    // MARK: - Mail methods
    
    func sendImageInMail(image: UIImage) {
        if (MFMailComposeViewController.canSendMail()) {
            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self
            
            mailComposer.setSubject("Series as of \(dateToString(now: Date()))")
            mailComposer.setMessageBody("My latest series.", isHTML: false)
            mailComposer.addAttachmentData(image.jpegData(compressionQuality: 1)!, mimeType: "image/jpeg", fileName: "image.jpeg")
            
            present(mailComposer, animated: true, completion: nil)
        } else {
            displayAction(message: "Cannot send email.")
        }
    }
    
    func sendImageInSMS(image: UIImage) {
        if (MFMessageComposeViewController.canSendAttachments()) {
            let controller = MFMessageComposeViewController()
            controller.messageComposeDelegate = self
            
            controller.body = "Series as of \(dateToString(now: Date()))"
            controller.addAttachmentData(image.pngData()!, typeIdentifier: "image/png", filename: "image.png")
            
            present(controller, animated: true, completion: nil)
        } else {
            displayAction(message: "Cannot send SMS.")
        }
    }
    
    // MARK: - Utility
    
    func dateToString(now: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy HH:mm:ss"
        
        return dateFormatter.string(from: now)
    }
    
    func displayAction(message: String) {
        let alertController: UIAlertController = UIAlertController(title: "Mail Action", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
}

// MARK: - Selector methods

extension PDFViewerViewController {
    @objc func send(_ sender: AnyObject) {
        //sendImageInMail(image: view.screenShot())
        sendImageInSMS(image: view.screenShot())
    }
}

// MARK: - UIView utility

extension UIView {
    func screenShot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, UIScreen.main.scale)
        let contextRef = UIGraphicsGetCurrentContext()
        contextRef!.translateBy(x: 2.0, y: 2.0)
        layer.render(in: contextRef!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}

// MARK: - MFMailComposeViewControllerDelegate

extension PDFViewerViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .cancelled:
            print("Email cancelled")
        case .saved:
            print("Email saved")
        case .sent:
            print("Email sent")
        case .failed:
            print("Email failed")
        default:
            print("default")
        }
        dismiss(animated: true, completion: nil)
    }
    
}

// MARK: - MFMessageComposeViewControllerDelegate

extension PDFViewerViewController: MFMessageComposeViewControllerDelegate {
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch result {
        case .cancelled:
            print("SMS cancelled")
        case .sent:
            print("SMS sent")
        case .failed:
            print("SMS failed")
        default:
            print("default")
        }
        dismiss(animated: true, completion: nil)
    }
    
}
