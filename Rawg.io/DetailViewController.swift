//
//  DetailViewController.swift
//  Rawg.io
//
//  Created by MNC Insurance 1 on 22/05/24
//

import UIKit
import NVActivityIndicatorView
import Kingfisher
import CoreData

class DetailViewController: UIViewController {
    
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var gameDetailImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var releasedLabel: UILabel!
    @IBOutlet weak var websiteButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    
    var activityIndicator : NVActivityIndicatorView!
    var id = 0
    var isFromFavorite = false
    var details : Details?{
        didSet{
            DispatchQueue.main.async{
                self.activityIndicator.stopAnimating()
                self.setup()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupActivity()
        fetchData()
    }
    
    func setup(){
        gameDetailImageView.kf.setImage(with: URL(string: details?.backgroundImage ?? ""))
        nameLabel.text = "\(details?.name ?? "")"
        let text = details?.description ?? ""
        let data = Data(text.utf8)
        if let attributedString = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
            descLabel.attributedText = attributedString
            let font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
            descLabel.font = font
        }
        websiteButton.setTitle("\(details?.website ?? "")", for: .normal)
        
        releasedLabel.text = "Released: \(setupDate(date: details?.released ?? ""))"
        ratingLabel.text = "\(details?.rating ?? 0) / \(details?.rating_top ?? 0)"
        
        if isFromFavorite {
            favoriteButton.isHidden = true
        }else{
            favoriteButton.isHidden = false

        }
        
        if retrieve().count != 0 {
            for i in 0 ... retrieve().count - 1 {
                if retrieve()[i].id == id {
                    favoriteButton.isSelected = true
                    favoriteButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                    return
                }else{
                    favoriteButton.isSelected = false
                    favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
                    
                }
            }
        }
        
        
    }
    
    func setupDate(date: String) -> String{
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let format = dateFormatter.date(from:date) ?? Date()
        dateFormatter.dateFormat = "dd MMMM yyyy"
        let dateString = dateFormatter.string(from: format)
        return dateString
    }
    
    func setupActivity(){
        let midY = self.view.frame.height / 2
        let midX = self.view.frame.width / 2
        let frame = CGRect(x: midX - 50, y: midY - 50, width: 100, height: 100)
        
        activityIndicator = NVActivityIndicatorView(frame: frame,
                                                    type: .pacman)
        activityIndicator.tintColor = .black
        activityIndicator.backgroundColor = .gray
        activityIndicator.layer.cornerRadius = 15
        view.addSubview(activityIndicator)
    }
    
    func fetchData(){
        activityIndicator.startAnimating()
        
        Network.sharedInstance.getDetailGame(id: id){[weak self] result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let detail):
                self?.details = detail
            }
            
        }
    }
    
    @IBAction func websiteButtonTapped(_ sender: Any) {
        guard let url = URL(string: "\(details?.website ?? "")") else { return }
        UIApplication.shared.open(url)
        
    }
    
    @IBAction func favoriteButtonTapped(_ sender: UIButton) {
        favoriteButton.isSelected = !favoriteButton.isSelected
        let id = details?.id ?? 0
        
        if favoriteButton.isSelected {
            favoriteButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            create()
            
        }else {
            favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
            deleteData(id: id)
        }
        
        print(retrieve())
        
        
    }
    
    func create(){
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        let gameEntity = NSEntityDescription.entity(forEntityName: "GameModel", in: context)
        
        let detailDate = setupDate(date: details?.released ?? "")
        let insert = NSManagedObject(entity: gameEntity!, insertInto: context)
        insert.setValue(details?.id, forKey: "id")
        insert.setValue(details?.name, forKey: "name")
        insert.setValue(details?.description, forKey: "descriptions")
        insert.setValue(detailDate, forKey: "released")
        insert.setValue(details?.backgroundImage, forKey: "backgroundImage")
        insert.setValue(details?.website, forKey: "website")
        insert.setValue(details?.rating, forKey: "rating")
        insert.setValue(details?.rating_top, forKey: "rating_top")
        
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
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "GameModel")
        
        do{
            let result = try context.fetch(fetchRequest) as! [NSManagedObject]
            result.forEach{ detail in
                details.append(
                    Details(id: detail.value(forKey: "id") as? Int,
                            name: detail.value(forKey: "name") as? String,
                            description: detail.value(forKey: "descriptions") as? String,
                            released: detail.value(forKey: "released") as? String,
                            backgroundImage: detail.value(forKey: "backgroundImage") as? String,
                            website: detail.value(forKey: "website") as? String,
                            rating: detail.value(forKey: "rating") as? Double,
                            rating_top: detail.value(forKey: "rating_top") as? Double)
                )
            }
        }catch let err{
            print(err)
        }
        
        return details
        
    }
    
    func deleteData(id:Int){
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "GameModel")
        fetchRequest.predicate = NSPredicate(format: "id = %i", id)
        
        do{
            let deletedData = try context.fetch(fetchRequest)[0] as! NSManagedObject
            context.delete(deletedData)
            
            try context.save()
        }catch let err{
            print(err)
        }
        
    }
    
    
    
}
