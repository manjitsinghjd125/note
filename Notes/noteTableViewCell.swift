//
//  noteTableViewCell.swift
//  Notes
//
//  Created by Manjit Singh on 2018-04-04.
//  Copyright © 2018 Manjit Singh. All rights reserved.
//

import UIKit
import CoreData

class noteTableViewCell: UITableViewCell {

    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var noteNameLabel: UILabel!
    @IBOutlet weak var noteDescriptionLabel: UILabel!
    @IBOutlet weak var noteSubjectLabel: UILabel!
    @IBOutlet weak var noteImage: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
       shadowView.layer.shadowColor = UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1.0 ).cgColor
        shadowView.layer.shadowOffset = CGSize(width: 0.75, height: 0.75)
        shadowView.layer.shadowOpacity = 0.2
        shadowView.layer.shadowRadius = 1.5
        shadowView.layer.cornerRadius = 2
        noteImage.layer.cornerRadius = 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
   public func celldata (note: Note)
    {
        self.noteNameLabel.text = note.notename?.uppercased()
        self.noteSubjectLabel.text = note.notesubject?.capitalized
        self.noteDescriptionLabel.text = note.notedescription
        self.noteImage.image = UIImage(data: note.noteimage! as Data)
    }

}
