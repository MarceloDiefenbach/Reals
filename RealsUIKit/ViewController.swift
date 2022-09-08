//
//  ViewController.swift
//  reals
//
//  Created by Marcelo Diefenbach on 04/09/22.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var buttonStart: UIButton!
    
    @IBAction func buttonStartAction(_ sender: Any) {
        performSegue(withIdentifier: "goToFeed", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
          if (segue.identifier == "goToFeed"){
            let displayVC = segue.destination as! UIViewController

//            displayVC.posts = posts

          }
      }
}

