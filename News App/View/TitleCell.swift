//
//  TitleCell.swift
//  News App
//
//  Created by Иван Зайцев on 05.02.2022.
//

import UIKit

class TitleCell: UITableViewCell {

    
    @IBOutlet weak var visitsPicture: UIImageView!
    @IBOutlet weak var countLable: UILabel!
    @IBOutlet weak var titleText: UITextView!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        countLable.textColor = .lightGray
        countLable.text = ""
        titleText.font = UIFont(name: "KohinoorTelugu-Light", size: 20)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        titleText.isUserInteractionEnabled = false
    }
    
}
