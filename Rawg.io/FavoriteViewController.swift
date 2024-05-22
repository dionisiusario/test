//
//  FavoriteViewController.swift
//  Rawg.io
//
//  Created by MNC Insurance 1 on 22/05/24
//

import UIKit
import CoreData
import Kingfisher
import CRNotifications

class FavoriteViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var gameList : [Details] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        gameList = retrieve()
        tableView.reloadData()
    }
    
    
    func setupTableView(){
        tableView.register(UINib(nibName: "GameTableViewCell", bundle: nil), forCellReuseIdentifier: "gameTableCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 160
        
        tableView.reloadData()
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "showFavorite") {
            guard let viewController = segue.destination as? DetailViewController else {return}
            guard let indexPath = sender as? IndexPath else {return}
            viewController.id = self.gameList[indexPath.row].id ?? 0
            viewController.isFromFavorite = true
        }
    }
    
    

}
extension FavoriteViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gameList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "gameTableCell", for: indexPath) as! GameTableViewCell
        cell.prepareForReuse()
        cell.statusImage.image = UIImage(systemName: "heart.fill")
        cell.nameLabel.text = gameList[indexPath.row].name
        cell.gameImageView.kf.setImage(with: URL(string: "\(gameList[indexPath.row].backgroundImage ?? "")"))
        cell.ratingLabel.text = "\(gameList[indexPath.row].rating ?? 0.0) / \(gameList[indexPath.row].rating_top ?? 5.0)"
        cell.releaseLabel.text = "Released: \(gameList[indexPath.row].released ?? ""))"
        cell.delegate = self
        cell.game = gameList[indexPath.row]
        return cell
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showFavorite", sender: indexPath)
        
    }
    
}

extension FavoriteViewController: ButtonTapped {
    func likeButtonTapped(game: Details) {
        let alert = UIAlertController(title: "Delete \(game.name ?? "")", message: "Are you sure?", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            switch action.style{
            case .default:
                print("default")
                self.deleteData(id: game.id ?? 0)
                self.tableView.reloadData()
                self.gameList = self.retrieve()
                self.tableView.reloadData()
              CRNotifications.showNotification(type: CRNotifications.success, title: "Sukses Menghapus!", message: "Berhasil Menghapus game yang dipilih", dismissDelay: 3)
            case .cancel:
                print("cancel")

            case .destructive:
                print("destructive")
            }
        }))
        
    }
}
