//
//  FeedViewController.swift
//  FirebaseIGCloneExample
//
//  Created by Ian MacKinnon on 18/01/2023.
//

import UIKit
import Firebase
import SDWebImage
import OneSignal

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var docIDArray = [String]()
    var userEmailArray = [String]()
    var userCommentArray = [String]()
    var likeArray = [Int]()
    var userImageArray = [String]()
    let fireStoreDB = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        // Do any additional setup after loading the view.
        getDataFromFirestore()
        
        // Push Notification
        //OneSignal.postNotification(["contents": ["en": "Test Message"], "include_player_ids" : [""]])
        
        // Player IDs
        if let status = OneSignal.getDeviceState(){
            let playerId = status.userId
            
            fireStoreDB.collection("OneSignalPlayerIds").whereField("email", isEqualTo: Auth.auth().currentUser!.email!).getDocuments { snapshot, error in
                if error == nil {
                    if snapshot?.isEmpty == false && snapshot != nil {
                        for document in snapshot!.documents {
                            if let existingPlayerId = document.get("player_id") as? String {
                                let documentId = document.documentID
                                if playerId != existingPlayerId {
                                    let playerIdDic = ["email": Auth.auth().currentUser!.email!, "player_id": playerId] as! [String : Any]
                                    
                                    self.fireStoreDB.collection("OneSignalPlayerIds").addDocument(data: playerIdDic){ (error) in
                                        if error != nil{
                                            print(error?.localizedDescription)
                                        }
                                    }
                                }
                            }
                        }
                    }else{
                        let playerIdDic = ["email": Auth.auth().currentUser!.email!, "player_id": playerId] as! [String : Any]
                        
                        self.fireStoreDB.collection("OneSignalPlayerIds").addDocument(data: playerIdDic){ (error) in
                            if error != nil{
                                print(error?.localizedDescription)
                            }
                        }
                    }
                }
            }
            
            
            
        }
    }
    
    func getDataFromFirestore(){
        
        fireStoreDB.collection("Posts")
            .order(by: "date", descending: true)
            .addSnapshotListener { snapshot, error in
            
            if(error != nil){
                print(error?.localizedDescription)
            }else{
                
                if snapshot?.isEmpty != true && snapshot != nil {
                    
                    self.docIDArray.removeAll()
                    self.userImageArray.removeAll()
                    self.userEmailArray.removeAll()
                    self.likeArray.removeAll()
                    self.userCommentArray.removeAll()
                    
                    for document in snapshot!.documents {
                                               
                        let docID = document.documentID
                        self.docIDArray.append(docID)
                        
                        if let postedBy = document.get("postedBy") as? String {
                            self.userEmailArray.append(postedBy)
                        }
                        if let userComment = document.get("postComment") as? String {
                            self.userCommentArray.append(userComment)
                        }
                        if let likes = document.get("likes") as? Int {
                            self.likeArray.append(likes)
                        }
                        if let imageURL = document.get("imageUrl") as? String {
                            self.userImageArray.append(imageURL)
                        }
                    }
                    self.tableView.reloadData()
                    
                }
                
                
            }
            
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userEmailArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FeedCell
        cell.userEmailLabel.text = userEmailArray[indexPath.row]
        cell.likeCountLabel.text = String(likeArray[indexPath.row])
        cell.commentLabel.text = userCommentArray[indexPath.row]
        cell.userImageView.sd_setImage(with: URL(string: userImageArray[indexPath.row]))
        cell.docIDLabel.text = docIDArray[indexPath.row]
        return cell
    }
    

}
