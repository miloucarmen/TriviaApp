//
//  QuestionViewController.swift
//  TriviaApp
//
//  Created by Gebruiker on 04-07-18.
//  Copyright © 2018 Gebruiker. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase


class QuestionViewController: UIViewController {
    
    // all outlets en variables
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var questionNumber: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var answerLabel: UILabel!
    
    var ref: DatabaseReference!
    var nameTextField: UITextField?
    var score: Int = 0
    var currentQuestion: Int = 0
    var valueQuestion: Int = 0
    var answerQuestion: String = ""
    var name: String = ""
    
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        submitButton.setTitle("Submit", for: .normal)
        answerLabel.isHidden = true
        // assigns score and empties questionTextField
        scoreLabel.text = "\(score)"
        answerTextField.text = ""
        
        // keeps track of question
        currentQuestion += 1
        questionNumber.text = "\(currentQuestion)"
        
        // retrieves question
        QuestionController.shared.fetchQuestion { (question) in
            if let question = question {
                
                // voorgrond en achtergrond sync
                DispatchQueue.main.async {
                    
                    // makes label question and saves answer and value
                    self.questionLabel.text = question[0].question
                    self.answerQuestion = question[0].answer
                    self.valueQuestion = question[0].value
                }
            }
        }
    }
    
    // dismisses keypad
    @IBAction func returnIsPressed(_ sender: UITextField) {
        answerTextField.resignFirstResponder()
    }
    
    // when button is pressed adds score and loads viewdidload
    @IBAction func submitPressed(_ sender: UIButton) {
        
        if submitButton.titleLabel?.text == "Submit" {
            
            answerLabel.isHidden = false
            if answerTextField.text?.lowercased() == answerQuestion.lowercased() {

                // ads to score if answer correct
                score += valueQuestion
                
                // gives specifics to label
                answerLabel.textColor = .green
                answerLabel.text = "That is correct!"
            } else {
                
                // gives specifics to label
                answerLabel.textColor = .red
                answerLabel.text = answerQuestion
            }
            
            if currentQuestion == 10 {
                submitButton.setTitle("End Quiz", for: .normal)
            } else {
                submitButton.setTitle("Next Question", for: .normal)
            }
        } else {

            // goes through options
            if currentQuestion < 9 {
                viewDidLoad()
            } else if currentQuestion == 9 {
                
                // changes name of submit button
                viewDidLoad()
            } else {
                ref = Database.database().reference()
                
                // alert message to type name for leaderboard
                let alert = UIAlertController(title: "Congratulations!", message: "Please enter your name to enter leaderboard", preferredStyle: .alert)
                alert.addTextField { (nameTextField) in
                    nameTextField.text = "User"
                }
                
                // adds action to alert
                alert.addAction(UIAlertAction(title: "Submit", style: .default) { action in
                    
                    // goes to prepare for segue
                    self.name = alert.textFields![0].text!
                    if self.name == "" {
                        self.name = "User"
                    }
                    
                    // add score to firebass
                    let update = ["\(self.score)": self.name] as [String: Any]
                    self.ref?.child("highScores").updateChildValues(update)
                    self.performSegue(withIdentifier: "toLeaderboard", sender: nil)
                })
                present(alert, animated: true, completion: nil)
                
            }
        }
    }
    
    // prepares for segue sends information to leaderboard
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toLeaderboard" {
            let highScoreController = segue.destination as! Leaderboard
            highScoreController.score = score
            highScoreController.name = name
        }
    }
}
    

class QuestionController {
    
    static let shared = QuestionController()
    let baseURL = URL(string: "http://jservice.io/api/")!
    
    // fetches a random question from api
    func fetchQuestion(completion: @escaping ([QuestionStruct]?) -> Void) {
        
        // appends to the base URL
        let randomQuestionURL = baseURL.appendingPathComponent("random")
        
        // makes the data request to URL
        let task = URLSession.shared.dataTask(with: randomQuestionURL) { (data, response, error) in
            let jsonDecoder = JSONDecoder()
            
            if let data = data,
                let question = try? jsonDecoder.decode([QuestionStruct].self, from: data) {
                completion(question)
            } else {
                completion(nil)
            }
        }
        task.resume()
    }
}
