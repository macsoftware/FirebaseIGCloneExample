//
//  FeedCell.swift
//  FirebaseIGCloneExample
//
//  Created by Ian MacKinnon on 19/01/2023.
//

import UIKit
import Firebase

class FeedCell: UITableViewCell {

    @IBOutlet weak var userEmailLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var docIDLabel: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func likeButtonClicked(_ sender: Any) {
        
        let fireStoreDB = Firestore.firestore()
        
        if let likeCount = Int(likeCountLabel.text!){
            
            let likeStore = ["likes" : likeCount + 1] as [String : Any]
            
            fireStoreDB.collection("Posts").document(docIDLabel.text!).setData(likeStore, merge: true)
            
            
        }
        
    }
    
}
