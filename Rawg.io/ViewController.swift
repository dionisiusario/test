//
//  ViewController.swift
//  Rawg.io
//
//  Created by MNC Insurance 1 on 22/05/24
//

import UIKit
import Kingfisher
import NVActivityIndicatorView

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var gameList : [Results] = []
    {
        didSet{
            DispatchQueue.main.async{
                self.tableView.reloadData()
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    var loadMore = false
    var page = 1
    
    var activityIndicator : NVActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupActivity()
        fetchData(page: page)
        setupTableView()
        
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
    
    func fetchData(page: Int){
        activityIndicator.startAnimating()
        
        Network.sharedInstance.getListGame(page: page){[weak self] result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let gameResult):
                
                for gameResulta in gameResult.results {
                    self?.gameList.append(gameResulta)
                    
                }
            }
            
        }
    }
    
    func setupTableView(){
        tableView.register(UINib(nibName: "GameTableViewCell", bundle: nil), forCellReuseIdentifier: "gameTableCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 160
        
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "showDetail") {
            guard let viewController = segue.destination as? DetailViewController else {return}
            guard let indexPath = sender as? IndexPath else {return}
            viewController.id = self.gameList[indexPath.row].id ?? 0

        }
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gameList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "gameTableCell", for: indexPath) as! GameTableViewCell
        cell.prepareForReuse()
        cell.nameLabel.text = gameList[indexPath.row].name
        cell.gameImageView.kf.setImage(with: URL(string: "\(gameList[indexPath.row].backgroundImage ?? "")"))
        cell.ratingLabel.text = "\(gameList[indexPath.row].rating ?? 0.0) / \(gameList[indexPath.row].rating_top ?? 5.0)"
        cell.releaseLabel.text = "Released: \(setupDate(date: gameList[indexPath.row].released ?? ""))"
        return cell
        
    }
    
    func setupDate(date: String) -> String{
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let format = dateFormatter.date(from:date) ?? Date()
        dateFormatter.dateFormat = "dd MMMM yyyy"
        let dateString = dateFormatter.string(from: format)
        return dateString
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showDetail", sender: indexPath)
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > contentHeight - scrollView.frame.height {
            if !loadMore {
                loadMoreGame()
            }
        }
    }
    
    func loadMoreGame(){
        loadMore = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            self.page = self.page + 1
            self.fetchData(page: self.page)
            self.loadMore = false
            self.tableView.reloadData()
        })
    }
    
    
    
}

