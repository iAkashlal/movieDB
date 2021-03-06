//
//  Utility.swift
//  TMDb-Client
//
//  Created by Akashlal on 14/03/20.
//  Copyright © 2020 AkOS. All rights reserved.
//

import UIKit

extension UIViewController{
    func presentAlert(title: String, description: String){
        let alert = UIAlertController(title: title, message: description, preferredStyle: .alert)
        let action = UIAlertAction(title: "Okay!", style: .default, handler: nil)
        alert.addAction(action)
        alert.view.tintColor = UIColor.init(named: "TintColor")
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
}

enum Context{
    case discover, search
}

enum Sort: String{
    case popularity = "popularity.desc"
    case rating = "vote_average.desc"
}
