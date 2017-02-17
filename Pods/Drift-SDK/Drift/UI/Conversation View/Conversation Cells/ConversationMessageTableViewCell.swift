//
//  ConversationMessageTableViewCell.swift
//  Drift
//
//  Created by Brian McDonald on 01/08/2016.
//  Copyright © 2016 Drift. All rights reserved.
//

import UIKit
import AlamofireImage

class ConversationMessageTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var messageTextView: UITextView!
    
    var dateFormatter: DriftDateFormatter = DriftDateFormatter()
    var message: Message? {
        didSet{
            displayMessage()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    func displayMessage() {

        avatarImageView.image = UIImage.init(named: "placeholderAvatar", in: Bundle.init(for: ConversationListTableViewCell.classForCoder()), compatibleWith: nil)
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.layer.masksToBounds = true
        avatarImageView.layer.cornerRadius = 3
        
        messageTextView.textContainer.lineFragmentPadding = 0
        messageTextView.textContainerInset = UIEdgeInsets.zero
        
        if let authorId = message?.authorId{
            getUser(authorId)
        }
        
        if let formattedBody = message?.formattedBody{
            messageTextView.attributedText = formattedBody
        }else{
            messageTextView.text = self.message?.body
        }
        
        if let sendStatus = message?.sendStatus, let createdAt = message?.createdAt {
            switch sendStatus{
            case .Sent:
                avatarImageView.alpha = 1.0
                nameLabel.textColor = UIColor.black
                timeLabel.textColor = ColorPalette.navyDark
                timeLabel.text = self.dateFormatter.createdAtStringFromDate(createdAt)
            case .Pending:
                timeLabel.text = "Sending..."
                timeLabel.textColor = ColorPalette.navyDark
                avatarImageView.alpha = 0.7
                nameLabel.textColor = ColorPalette.navyDark
                messageTextView.textColor = ColorPalette.navyDark
            case .Failed:
                nameLabel.textColor = ColorPalette.navyMedium
                timeLabel.text = "Failed to send"
                timeLabel.textColor = ColorPalette.navyMedium
                avatarImageView.alpha = 0.7
                nameLabel.textColor = ColorPalette.navyDark
                messageTextView.textColor = ColorPalette.navyDark
            }
        }
    }
    
    func getUser(_ userId: Int) {
        
        if let authorType = message?.authorType , authorType == .User {
            UserManager.sharedInstance.userMetaDataForUserId(userId, completion: { (user) in
                
                if let user = user {
                    if let avatar = user.avatarURL {
                        DispatchQueue.main.async {
                            ImageManager.sharedManager.getImage(urlString: avatar, completion: { (image) in
                                if let image = image{
                                    self.avatarImageView.image = image

                                }
                            })
                        }
                    }
                    
                    if let creatorName =  user.name {
                        self.nameLabel.text = creatorName
                    }
                }
            })
            
        }else {
            if let endUser = DriftDataStore.sharedInstance.auth?.enduser {
                if let avatar = endUser.avatarURL {
                    DispatchQueue.main.async {
                        ImageManager.sharedManager.getImage(urlString: avatar, completion: { (image) in
                            if let image = image{
                                self.avatarImageView.image = image
                                
                            }
                        })
                    }
                }
                
                if let creatorName = endUser.name {
                    self.nameLabel.text = creatorName
                }else if let email = endUser.email {
                    self.nameLabel.text = email
                }else{
                    self.nameLabel.text = "You"
                }
            }
        }
    }
}
