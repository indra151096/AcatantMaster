//
//  ResultViewController.swift
//  AcatantMaster
//
//  Created by Indra Sumawi on 20/09/19.
//  Copyright © 2019 Indra Sumawi. All rights reserved.
//

import UIKit

class ResultViewController: UIViewController {
  
  @IBOutlet weak var image: UIImageView!
  var category = ""
  
  override func viewDidLoad() {
        super.viewDidLoad()

    switch category {
    case "food":
      talk(message: "Mungkin Anda tertarik untuk mencoba ini")
      image.image = UIImage(named: "capgome")
      break
    case "schedule":
      talk(message: "Berikut jadwal untuk besok")
      image.image = UIImage(named: "schedule")
      break
    case "find":
      talk(message: "Prayudi sedang berada di Academy, tepatnya di Lab 2")
      image.image = UIImage(named: "profile_sm")
      break
    default:
      break
    }
    
      let timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false) { timer in
        self.dismiss(animated: true, completion: nil)
      }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
