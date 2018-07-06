//
//  Leaderboard.swift
//  TriviaApp
//
//  Created by Gebruiker on 04-07-18.
//  Copyright © 2018 Gebruiker. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase

class Leaderboard: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var yourHighScore: UILabel!
    @IBOutlet weak var scoreTable: UITableView!
    
    var ref: DatabaseReference!
    var dataBaseHandle: DatabaseHandle?
    var name: String = ""
    var score: Int = 0
    var allScores: [String] = []
    var allNames: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        // retrives score board from firebase
        dataBaseHandle = ref?.child("highScores").observe(.value, with: { (snapshot) in
            print(snapshot)
            if snapshot.childrenCount > 0 {
                for placeInScore in snapshot.children.allObjects as! [DataSnapshot] {
                    
                    self.allScores.insert(placeInScore.key, at: 0)
                    self.allNames.insert(placeInScore.value as! String, at: 0)
                }
                
                self.scoreTable.reloadData()
            }
        })
        
        // displays your score if you just played a game
        if name != "" {
            yourHighScore.text = "Your score is \(score)"
        } else {
            yourHighScore.isHidden = true
        }
    }
    
    // gives number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allNames.count
    }
    
    // creates cells with information in them
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "scoreCell", for: indexPath) as! HighScoreTableCell
        
        cell.nameLabel.text = "\(indexPath.row + 1). \(allNames[indexPath.row])"
        cell.scoreLabel.text = "\(allScores[indexPath.row])"
        
        return cell
    }
}
