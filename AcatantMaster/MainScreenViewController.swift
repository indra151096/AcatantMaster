//
//  MainScreenViewController.swift
//  AcatantMaster
//
//  Created by Indra Sumawi on 19/09/19.
//  Copyright © 2019 Indra Sumawi. All rights reserved.
//

import UIKit
import CloudKit

class MainScreenViewController: UIViewController, eventDelegate {
  func happen(status: String) {
    if status == "enter" {
      performSegue(withIdentifier: "toAssistant", sender: self)
    }
    else if status == "reminder" {
      talk(message: "Indra, Jangan lupa minum air!")
    }
  }
  
  let listStatus = ["exit", "enter", "reminder"]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    subscribe()
    // Do any additional setup after loading the view.
  }
  
  override func viewWillAppear(_ animated: Bool) {
    let app = UIApplication.shared.delegate as! AppDelegate
    app.delegate = self
  }
  
  func subscribe() {
    //let database2 = CKContainer.default().publicCloudDatabase
    let database = CKContainer.init(identifier: "iCloud.com.indratechid.EstimoteBeacon").publicCloudDatabase
    database.fetchAllSubscriptions { [unowned self] (subscriptions, error) in
      if error == nil {
        if let subscriptions = subscriptions {
          for subscription in subscriptions {
            database.delete(withSubscriptionID: subscription.subscriptionID, completionHandler: { (str, error) in
              if error != nil {
                print(error!.localizedDescription)
              }
            })
          }
          
          //more
          for status in self.listStatus {
            print("subs")
            let predicate = NSPredicate(format: "status = %@", status)
            let subscription =  CKQuerySubscription(recordType: "Request", predicate: predicate, options: .firesOnRecordCreation)
            let notification = CKSubscription.NotificationInfo()
            notification.alertBody = "There's  a new event in the \(status)."
            //notification.soundName = "default"
            subscription.notificationInfo = notification
            
            database.save(subscription, completionHandler: { (result, error) in
              if let error = error {
                print(error.localizedDescription)
                print(error)
                print("NA")
              }
            })
          }
        }
      }
      else {
        print(error!.localizedDescription)
        print("NI")
      }
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
