//
//  GameTableViewCell.swift
//  Rawg.io
//
//  Created by MNC Insurance 1 on 22/05/24
//

import UIKit

protocol ButtonTapped{
    func likeButtonTapped(game: Details)
}

class GameTableViewCell: UITableViewCell {
    
    @IBOutlet weak var releaseLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var gameView: UIView!
    @IBOutlet weak var gameImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var statusImage: UIImageView!
    @IBOutlet weak var statusButton: UIButton!
    
    var game: Details?
    var delegate: ButtonTapped?

    
    override func awakeFromNib() {
        super.awakeFromNib()
        gameImageView.image = nil
        gameView.layer.cornerRadius = 20
        gameImageView.layer.cornerRadius = 20
    }
    
    override func prepareForReuse(){
        gameImageView.image = nil
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    @IBAction func statusButtonTapped(_ sender: Any) {
        
        statusButton.isSelected = false
        statusButton.setImage(UIImage(systemName: "heart"), for: .normal)
        delegate?.likeButtonTapped(game: game!)
        
    }
    
}
