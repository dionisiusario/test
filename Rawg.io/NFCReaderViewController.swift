//
//  NFCReaderViewController.swift
//  Rawg.io
//
//  Created by MNC Insurance 1 on 22/05/24
//

import UIKit
import NFCReaderWriter

class NFCReaderViewController: UIViewController, NFCReaderDelegate {

  
  var readerWriter = NFCReaderWriter()
  
    override func viewDidLoad() {
        super.viewDidLoad()
     
    }

  @IBAction func scanButtonTapped(_ sender: UIButton) {
    readerWriter.newReaderSession(with: self, invalidateAfterFirstRead: true, alertMessage: "Nearby NFC Card for read")
    readerWriter.begin()

  }
  
  func reader(_ session: NFCReader, didInvalidateWithError error: any Error) {
    print("error\(error.localizedDescription)")
  }
  
  func reader(_ session: NFCReader, didDetectNDEFs messages: [NFCNDEFMessage]) {
    for message in messages {
      for (i, record) in message.records.enumerated() {
        print("Record \(i+1): \(String(data: record.payload, encoding: .ascii) ?? "format not supported")")
      }
    }
    
    readerWriter.alertMessage = "NFC Tag Info detected"
    readerWriter.end()
  }

}
