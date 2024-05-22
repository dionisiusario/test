//
//  QRReaderViewController.swift
//  Rawg.io
//
//  Created by MNC Insurance 1 on 22/05/24
//

import UIKit
import SwiftQRScanner
import CoreData

class QRReaderViewController: UIViewController {

  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var stackViewAddGame: UIStackView!
  @IBOutlet weak var qrCodeButtonMiddle: UIButton!
  @IBOutlet weak var qrCodeButtonTop: UIButton!
  
  @IBAction func scanQRCode(_ sender: Any) {
    
        //Simple QR Code Scanner
        let scanner = QRCodeScannerController()
        scanner.delegate = self
        self.present(scanner, animated: true, completion: nil)
    }
    
  
  var gameList : [Details] = []
  var details : Details?{
      didSet{
          DispatchQueue.main.async{
            self.create()
            self.tableView.reloadData()
            self.gameList = self.retrieve()
            self.tableView.reloadData()
            if self.gameList.count != 0 {
              self.stackViewAddGame.isHidden = true
            }else {
              self.stackViewAddGame.isHidden = false

            }
          }
      }
  }
  var id = 0
  
  override func viewDidLoad() {
      super.viewDidLoad()
      setupTableView()
    
   
  }
  
  override func viewDidAppear(_ animated: Bool) {
      gameList = retrieve()
      tableView.reloadData()
    
    if self.gameList.count != 0 {
      self.stackViewAddGame.isHidden = true
    }else {
      self.stackViewAddGame.isHidden = false

    }
  }
  
  
  func setupTableView(){
      tableView.register(UINib(nibName: "GameTableViewCell", bundle: nil), forCellReuseIdentifier: "gameTableCell")
      tableView.delegate = self
      tableView.dataSource = self
      tableView.rowHeight = 160
      tableView.reloadData()
  }
  
  func setupDate(date: String) -> String{
      
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "yyyy-MM-dd"
      let format = dateFormatter.date(from:date) ?? Date()
      dateFormatter.dateFormat = "dd MMMM yyyy"
      let dateString = dateFormatter.string(from: format)
      return dateString
  }
  
  func create(){
      
      guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
      let context = appDelegate.persistentContainer.viewContext
      let gameEntity = NSEntityDescription.entity(forEntityName: "GameModelQR", in: context)
      
      let detailDate = setupDate(date: details?.released ?? "")
    let insert = NSManagedObject(entity: gameEntity!, insertInto: context)
      insert.setValue(details?.id, forKey: "idQR")
      insert.setValue(details?.name, forKey: "nameQR")
      insert.setValue(details?.description, forKey: "descriptionsQR")
      insert.setValue(detailDate, forKey: "releasedQR")
      insert.setValue(details?.backgroundImage, forKey: "backgroundImageQR")
      insert.setValue(details?.website, forKey: "websiteQR")
      insert.setValue(details?.rating, forKey: "ratingQR")
      insert.setValue(details?.rating_top, forKey: "rating_topQR")
      
      do{
          try context.save()
      }catch let err{
          print(err)
      }
      
  }
  
  func retrieve() -> [Details]{

      var details = [Details]()
      
      let appDelegate = UIApplication.shared.delegate as! AppDelegate
      let context = appDelegate.persistentContainer.viewContext
      let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "GameModelQR")

      do{
          let result = try context.fetch(fetchRequest) as! [NSManagedObject]
          result.forEach{ detail in
              details.append(
                  Details(id: detail.value(forKey: "idQR") as? Int,
                          name: detail.value(forKey: "nameQR") as? String,
                          description: detail.value(forKey: "descriptionsQR") as? String,
                          released: detail.value(forKey: "releasedQR") as? String,
                          backgroundImage: detail.value(forKey: "backgroundImageQR") as? String,
                          website: detail.value(forKey: "websiteQR") as? String,
                          rating: detail.value(forKey: "ratingQR") as? Double,
                          rating_top: detail.value(forKey: "rating_topQR") as? Double)
              )
          }
      }catch let err{
          print(err)
      }

      return details

  }
  
  
  func fetchData(url: String){
      
      Network.sharedInstance.getGameFromQR(url: url) {[weak self] result in
          switch result {
          case .failure(let error):
              print(error)
          case .success(let detail):
              self?.details = detail
          }
          
      }
  }
  

}
extension QRReaderViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return gameList.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(withIdentifier: "gameTableCell", for: indexPath) as! GameTableViewCell
      cell.prepareForReuse()
      cell.nameLabel.text = gameList[indexPath.row].name
      cell.gameImageView.kf.setImage(with: URL(string: "\(gameList[indexPath.row].backgroundImage ?? "")"))
      cell.ratingLabel.text = "\(gameList[indexPath.row].rating ?? 0.0) / \(gameList[indexPath.row].rating_top ?? 5.0)"
      cell.releaseLabel.text = "Released: \(gameList[indexPath.row].released ?? ""))"
      cell.statusImage.isHidden = true
      cell.statusButton.isHidden = true
      cell.game = gameList[indexPath.row]
      return cell
      
  }
  
  
}

extension QRReaderViewController: QRScannerCodeDelegate {
  func qrScanner(_ controller: UIViewController, didFailWithError error: SwiftQRScanner.QRCodeError) {
    print("error:\(error.localizedDescription)")

  }
  
    func qrScanner(_ controller: UIViewController, didScanQRCodeWithResult result: String) {
        print("result:\(result)")
      fetchData(url: result)
    }
    
   
    
    func qrScannerDidCancel(_ controller: UIViewController) {
        print("SwiftQRScanner did cancel")
    }

}
