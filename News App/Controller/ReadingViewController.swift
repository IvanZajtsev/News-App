//
//  ReadingViewController.swift
//  News App
//
//  Created by Иван Зайцев on 06.02.2022.
//

import Foundation
import UIKit
class ReadingViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    var pickedPosition = 0
    var url = ""
    
    
    
    @IBOutlet weak var textView: UITextView!
    @IBAction func goToSourceButton(_ sender: UIButton) {
            guard let urlToOpen = URL(string: url) else {
                 return
            }
            if UIApplication.shared.canOpenURL(urlToOpen) {
                 UIApplication.shared.open(urlToOpen, options: [:], completionHandler: nil)
            }
    }
    
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        titleLabel.text = "\(UserDefaults.standard.array(forKey: "Titles")![pickedPosition])"
        titleLabel.font = UIFont(name: "KohinoorTelugu-Medium", size: 30)
        textView.font = UIFont(name: "KohinoorTelugu-Light", size: 20)
        textView.text = "\(UserDefaults.standard.array(forKey: "Descriptions")![pickedPosition])"
        url = "\(UserDefaults.standard.array(forKey: "Urls")![pickedPosition])"
    }
    
}
