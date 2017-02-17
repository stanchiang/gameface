//
//  ConversationAttachmentsTableViewCell.swift
//  Drift
//
//  Created by Brian McDonald on 01/08/2016.
//  Copyright © 2016 Drift. All rights reserved.
//

import UIKit

class ConversationAttachmentsTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var attachmentsCollectionView: UICollectionView!
    @IBOutlet weak var attachmentImageView: UIImageView!
    
    var dateFormatter: DriftDateFormatter = DriftDateFormatter()
    var attachments: [Attachment] = []
    var message: Message? {
        didSet{
            displayMessage()
            displayAttachments()
        }
    }
    weak var delegate: AttachementSelectedDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        attachmentsCollectionView.register(UINib.init(nibName: "AttachmentCollectionViewCell", bundle: Bundle(for: AttachmentCollectionViewCell.classForCoder())), forCellWithReuseIdentifier: "AttachmentCollectionViewCell")
        attachmentsCollectionView.dataSource = self
        attachmentsCollectionView.delegate = self
        attachmentsCollectionView.backgroundColor = UIColor.white
    }
    
    
    func displayMessage() {
  
        avatarImageView.image = UIImage.init(named: "placeholderAvatar", in: Bundle.init(for: ConversationListTableViewCell.classForCoder()), compatibleWith: nil)
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.layer.masksToBounds = true
        avatarImageView.layer.cornerRadius = 3
  
        messageTextView.textContainer.lineFragmentPadding = 0
        messageTextView.textContainerInset = UIEdgeInsets.zero
        
        attachmentImageView.layer.masksToBounds = true
        attachmentImageView.contentMode = .scaleAspectFill
        attachmentImageView.layer.cornerRadius = 3
        
        if let authorId = message?.authorId{
            getUser(authorId)
        }
        
        if let formattedBody = message?.formattedBody{
            messageTextView.attributedText = formattedBody
        }else{
            messageTextView.text = self.message?.body
        }
        
        nameLabel.textColor = ColorPalette.darkPrimaryColor
        
        timeLabel.textColor = ColorPalette.navyDark
        timeLabel.text = self.dateFormatter.createdAtStringFromDate(self.message!.createdAt)
 
    }
    
    
    func getUser(_ userId: Int){
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
    
    func displayAttachments() {
        if attachments.count == 1{
            attachmentImageView.image = UIImage(named: "imageEmptyState", in: Bundle(for: Drift.self), compatibleWith: nil)
            let fileName: NSString = attachments.first!.fileName as NSString
            let fileExtension = fileName.pathExtension
            if fileExtension == "jpg" || fileExtension == "png" || fileExtension == "gif"{
                let gestureRecognizer = UITapGestureRecognizer.init(target:self, action: #selector(ConversationAttachmentsTableViewCell.imagePressed))
                attachmentImageView.addGestureRecognizer(gestureRecognizer)
                if let previewString = attachments.first?.publicPreviewURL{
                    self.attachmentsCollectionView.isHidden = true
                    DispatchQueue.main.async {
                        ImageManager.sharedManager.getImage(urlString: previewString, completion: { (image) in
                            if let image = image{
                                self.attachmentImageView.image = image
                            }
                        })
                    }
                }
            }else{
                showCollectionView()
            }
        }else{
            showCollectionView()
        }

    }
    
    func showCollectionView() {
        self.attachmentImageView.isHidden = true
        self.attachmentsCollectionView.isHidden = false
        self.attachmentsCollectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? AttachmentCollectionViewCell {
            let attachment = self.attachments[(indexPath as NSIndexPath).row]
            let fileName: NSString = attachment.fileName as NSString
            let fileExtension = fileName.pathExtension
            cell.fileNameLabel.text = "\(fileName)"
            cell.fileExtensionLabel.text = "\(fileExtension.uppercased())"
            
            let formatter = ByteCountFormatter()
            formatter.string(fromByteCount: Int64(attachment.size))
            formatter.allowsNonnumericFormatting = false
            cell.sizeLabel.text = formatter.string(fromByteCount: Int64(attachment.size))
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AttachmentCollectionViewCell", for: indexPath) as! AttachmentCollectionViewCell
        cell.layer.cornerRadius = 3.0
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return attachments.count
    }
    
    
    func imagePressed(){
        if let attachment = attachments.first{
            delegate?.attachmentSelected(attachment, sender: self)
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if delegate != nil{
            delegate?.attachmentSelected(attachments[(indexPath as NSIndexPath).row], sender: self)
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 200, height: 55)
    }
    

}
