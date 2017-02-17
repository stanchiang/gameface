//
//  ConversationViewController.swift
//  Drift
//
//  Created by Brian McDonald on 28/07/2016.
//  Copyright © 2016 Drift. All rights reserved.
//

import UIKit
import SlackTextViewController
import QuickLook
import LayerKit
import ObjectMapper
import SVProgressHUD

class DriftPreviewItem: NSObject, QLPreviewItem{
    var previewItemURL: URL?
    var previewItemTitle: String?
    
    init(url: URL, title: String){
        self.previewItemURL = url
        self.previewItemTitle = title
    }
}

public protocol AttachementSelectedDelegate: class{
    func attachmentSelected(_ attachment: Attachment, sender: AnyObject)
}

class ConversationViewController: SLKTextViewController {
    
    enum ConversationType {
        case createConversation(authorId: Int?)
        case continueConversation(conversationId: Int)
    }
    
    let emptyState = ConversationEmptyStateView.fromNib() as! ConversationEmptyStateView
    var sections: [[Message]] = []
    var attachments: [Int: Attachment] = [:]
    var attachmentIds: Set<Int> = []
    var previewItem: DriftPreviewItem?
    var dateFormatter: DriftDateFormatter = DriftDateFormatter()
    
    lazy var qlController = QLPreviewController()
    lazy var imagePicker = UIImagePickerController()
    lazy var interactionController = UIDocumentInteractionController()
    
    var conversationType: ConversationType! {
        didSet{
            if case ConversationType.continueConversation(let conversationId) = conversationType!{
                self.conversationId = conversationId
                InboxManager.sharedInstance.addMessageSubscription(MessageSubscription(delegate: self, conversationId: conversationId))
            }
        }
    }

    var conversationId: Int?{
        didSet{
            leftButton.isEnabled = true
            leftButton.tintColor = DriftDataStore.sharedInstance.generateBackgroundColor()
            leftButton.setImage(UIImage.init(named: "plus-circle", in: Bundle(for: Drift.self), compatibleWith: nil), for: UIControlState())
            textView.placeholder = "Message"
        }
    }
    
    func setConversationType(_ conversationType: ConversationType){
        self.conversationType = conversationType
    }
    
    convenience init(conversationType: ConversationType) {
        self.init(tableViewStyle: UITableViewStyle.grouped)
        setConversationType(conversationType)
    }

    class func navigationController(_ conversationType: ConversationType) -> UINavigationController {
        let vc = ConversationViewController.init(conversationType: conversationType)
        let navVC = UINavigationController.init(rootViewController: vc)
        
        let leftButton = UIBarButtonItem.init(image: UIImage.init(named: "closeIcon", in: Bundle.init(for: ConversationViewController.classForCoder()), compatibleWith: nil), style: UIBarButtonItemStyle.plain, target:vc, action: #selector(ConversationViewController.dismissVC))
        leftButton.tintColor = DriftDataStore.sharedInstance.generateForegroundColor()
        vc.navigationItem.leftBarButtonItem  = leftButton

        return navVC
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSlackTextView()
        
        tableView?.register(UINib.init(nibName: "ConversationMessageTableViewCell", bundle: Bundle(for: ConversationMessageTableViewCell.classForCoder())), forCellReuseIdentifier: "ConversationMessageTableViewCell")
        tableView?.register(UINib.init(nibName: "ConversationAttachmentsTableViewCell", bundle: Bundle(for: ConversationAttachmentsTableViewCell.classForCoder())), forCellReuseIdentifier: "ConversationAttachmentsTableViewCell")
        
        if let navVC = navigationController {
            navVC.navigationBar.barTintColor = DriftDataStore.sharedInstance.generateBackgroundColor()
            navVC.navigationBar.tintColor = DriftDataStore.sharedInstance.generateForegroundColor()
            navVC.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: DriftDataStore.sharedInstance.generateForegroundColor(), NSFontAttributeName: UIFont.init(name: "AvenirNext-Medium", size: 16)!]
            navigationItem.title = "Conversation"
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(ConversationViewController.didOpen), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ConversationViewController.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)

        didOpen()
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    func didOpen() {
        switch conversationType! {
        case .continueConversation(let conversationId):
            self.conversationId = conversationId
            getMessages(conversationId)
        case .createConversation(_):

            if let welcomeMessage = DriftDataStore.sharedInstance.embed?.welcomeMessage {
                emptyState.messageLabel.text = welcomeMessage
            }
            
            if let tableView = tableView{
                emptyState.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview(emptyState)
                edgesForExtendedLayout = []
                let leadingConstraint = NSLayoutConstraint(item: emptyState, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0)
                let trailingConstraint = NSLayoutConstraint(item: emptyState, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0)
                let topConstraint = NSLayoutConstraint(item: emptyState, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0)
                view.addConstraints([leadingConstraint, trailingConstraint, topConstraint])
                
                let label = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 30))
                label.textAlignment = .center
                label.text = "We're ⚡️ by Drift"
                label.font = UIFont(name: "Avenir-Book", size: 14)
                label.textColor = ColorPalette.grayColor
                label.transform = tableView.transform
                tableView.tableHeaderView = label
            }
            
        }
    }
    
    func rotated() {
        if UIDeviceOrientationIsLandscape(UIDevice.current.orientation) {
            if emptyState.isHidden == false && emptyState.alpha == 1.0 && UIDevice.current.userInterfaceIdiom == .phone && max(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height) <= 568.0{
                emptyState.isHidden = true
            }
        }
        
        if UIDeviceOrientationIsPortrait(UIDevice.current.orientation) {
            if emptyState.isHidden == true && emptyState.alpha == 1.0 && UIDevice.current.userInterfaceIdiom == .phone && max(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height) <= 568.0{
                emptyState.isHidden = false
            }
        }
    }
    
    func setupSlackTextView() {
        tableView?.backgroundColor = UIColor.white
        tableView?.contentInset = UIEdgeInsets.init()
        tableView?.separatorStyle = .none

        textInputbar.barTintColor = UIColor.white
       
        leftButton.tintColor = UIColor.lightGray
        leftButton.isEnabled = false
        leftButton.setImage(UIImage.init(named: "plus-circle", in: Bundle(for: Drift.self), compatibleWith: nil), for: UIControlState())
        textView.font = UIFont(name: "AvenirNext-Regular", size: 18)
        isInverted = true
        shouldScrollToBottomAfterKeyboardShows = false
        bounces = true
        
        if let organizationName = DriftDataStore.sharedInstance.embed?.organizationName {
            textView.placeholder = "Message \(organizationName)"
        }else{
            textView.placeholder = "Message"
        }
    }
    
    
    func dismissVC() {
        dismissKeyboard(true)
        dismiss(animated: true, completion: nil)
    }
    
    
    override func didPressLeftButton(_ sender: Any?) {
        dismissKeyboard(true)
        let uploadController = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
       
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
            uploadController.modalPresentationStyle = .popover
            let popover = uploadController.popoverPresentationController
            popover?.sourceView = self.leftButton
            popover?.sourceRect = self.leftButton.bounds
        }
        
        imagePicker.delegate = self
        
        uploadController.addAction(UIAlertAction(title: "Take a Photo", style: .default, handler: { (UIAlertAction) in
            self.imagePicker.sourceType = .camera
            self.present(self.imagePicker, animated: true, completion: nil)
        }))
        
        uploadController.addAction(UIAlertAction(title: "Choose From Library", style: .default, handler: { (UIAlertAction) in
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        }))

        uploadController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(uploadController, animated: true, completion: nil)
    }
    
    override func didPressRightButton(_ sender: Any?) {
        let message = Message()
        message.body = textView.text
        message.authorId = Int(DriftDataStore.sharedInstance.auth!.enduser!.externalId!)
        message.sendStatus = .Pending
        textView.slk_clearText(true)
        postMessage(message)
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = sections[indexPath.section][indexPath.row]
        
        var cell: UITableViewCell

        switch message.attachments.count{
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: "ConversationMessageTableViewCell", for: indexPath) as! ConversationMessageTableViewCell
            if let cell = cell as? ConversationMessageTableViewCell{
                cell.message = message
            }
        default:
            cell = tableView.dequeueReusableCell(withIdentifier: "ConversationAttachmentsTableViewCell", for: indexPath) as! ConversationAttachmentsTableViewCell
        }
        
        cell.transform = tableView.transform
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? ConversationAttachmentsTableViewCell{
            cell.attachmentImageView.image = UIImage(named: "imageEmptyState", in: Bundle(for: Drift.self), compatibleWith: nil)
            let message = sections[indexPath.section][indexPath.row]
            
            let messageAttachmentIds = Set(message.attachments)
            if messageAttachmentIds.isSubset(of: attachmentIds){
                var messageAttachments: [Attachment] = []
                for id in messageAttachmentIds{
                    if let attachment = attachments[id]{
                        messageAttachments.append(attachment)
                    }
                }
                
                cell.delegate = self
                cell.attachments = messageAttachments
                cell.message = message
                
            }else{
                APIManager.getAttachmentsMetaData(message.attachments, authToken: (DriftDataStore.sharedInstance.auth?.accessToken)!, completion: { (result) in
                    switch result{
                    case .success(let attachments):
                        for attachment in attachments{
                            self.attachments[attachment.id] = attachment
                            self.attachmentIds.insert(attachment.id)
                        }
                            cell.delegate = self
                            cell.attachments = attachments
                            cell.message = message
                    case .failure:
                        LoggerManager.log("Failed to get attachment metadata for id: \(message.attachments.first)")
                    }
                })
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if sections[section].count > 0 && !emptyState.isHidden{
            UIView.animate(withDuration: 0.4, animations: {
                self.emptyState.alpha = 0.0
            }, completion: { (_) in
                self.emptyState.isHidden = true
            })
        }
        return sections[section].count
    }

    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = self.sections[indexPath.section][indexPath.row]
        if message.sendStatus == .Failed{
            let alert = UIAlertController(title:nil, message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title:"Retry Send", style: .default, handler: { (_) -> Void in
                let messageRequest = Message()
                messageRequest.body = message.body!
                messageRequest.requestId = message.requestId
                messageRequest.sendStatus = .Pending
                messageRequest.type = message.type
                self.tableView!.reloadRows(at: [indexPath as IndexPath], with: .none)
                self.postMessage(messageRequest)
            }))
            alert.addAction(UIAlertAction(title:"Delete Message", style: .destructive, handler: { (_) -> Void in
                self.sections[indexPath.section].remove(at: self.sections[0].count-indexPath.row-1)
                self.tableView!.deleteRows(at: [indexPath as IndexPath], with: .none)
            }))
            
            present(alert, animated: true, completion: nil)
        }
    }
    
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView: MessageTableHeaderView =  MessageTableHeaderView.fromNib("MessageTableHeaderView") as! MessageTableHeaderView
        
        //This handles the fact we need to have a header on the last (top when inverted) section.
        if section == 0{
            
            return nil
        }else if sections[section-1].count == 0 {
            headerView.headerLabel.text = "Today"
        }else {
            let message = sections[section-1][0]
            headerView.headerLabel.text = dateFormatter.headerStringFromDate(message.createdAt)
        }
        
        headerView.transform = tableView.transform
        return headerView
    }
    
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let message = sections[indexPath.section][indexPath.row]
        
        if message.attachments.count > 0 {
            return 150
        }else{
            return 70
        }
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{
            return CGFloat.leastNormalMagnitude
        }else{
            return 42
        }
    }
    
    
    func addMessageToConversation(_ message: Message){
        if sections.count > 0, let _ = self.sections[0].index(where: { (message1) -> Bool in
            if message1.requestId == message.requestId{
                return true
            }
            return false
        }){
            //We've already added this message, it may have failed to send
        }else{
            if sections.count > 0 && (Calendar.current as NSCalendar).component(.day, from: (sections[0].first?.createdAt)! as Date) ==  (Calendar.current as NSCalendar).component(.day, from: Date()){
                sections[0].insert(message, at: 0)
                tableView!.insertRows(at: [IndexPath(row: 0, section: 0)], with: .bottom)
            }else{
                sections.insert([message], at: 0)
                tableView?.insertSections(IndexSet.init(integer: 0), with: .bottom)
            }
        }
    }
    
    
    func getSections(_ messages: [Message]) -> [[Message]]{
        let messagesReverse = messages.sorted(by: { $0.createdAt.compare($1.createdAt as Date) == .orderedDescending})
        
        var sections: [[Message]] = []
        var section: [Message] = []
        
        for message in messagesReverse{
            if section.count == 0{
                section.append(message)
            }else{
                let anchorMessage = section[0]
                if Calendar.current.component(.day, from: message.createdAt) !=  Calendar.current.component(.day, from: anchorMessage.createdAt) ||  Calendar.current.component(.month, from: message.createdAt) !=  Calendar.current.component(.month, from: anchorMessage.createdAt) ||  Calendar.current.component(.year, from: message.createdAt) !=  Calendar.current.component(.year, from: anchorMessage.createdAt){
                    sections.append(section)
                    section = []
                }
                section.append(message)
                
                if messages.count-1 == messagesReverse.index(of: message){
                    sections.append(section)
                }
            }
        }
        
        if sections.count == 0 && section.count > 0{
            sections.append(section)
        }
        
        //Append an empty section to ensure we have a header on the top section
        sections.append([])
        
        return sections
    }

    
    func getMessages(_ conversationId: Int){
        SVProgressHUD.show()
        APIManager.getMessages(conversationId, authToken: DriftDataStore.sharedInstance.auth!.accessToken) { (result) in
            SVProgressHUD.dismiss()
            switch result{
            case .success(let messages):
                let sorted = messages.sorted(by: { $0.createdAt.compare($1.createdAt as Date) == .orderedAscending})
                    self.sections = self.getSections(sorted)
                    self.tableView?.reloadData()
            case .failure:
                LoggerManager.log("Unable to get messages for conversationId: \(conversationId)")
            }
        }
    }
    
    func getContext() -> Context {
        let context = Context()
        context.userAgent = "Mobile App / \(UIDevice.current.modelName) / \(UIDevice.current.systemName) \(UIDevice.current.systemVersion)"
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] {
            context.userAgent?.append(" / App Version: \(version)")
        }
        return context
    }
    
    func postMessage(_ messageRequest: Message){
        if messageRequest.requestId == 0{
            messageRequest.requestId = Date().timeIntervalSince1970
        }
        messageRequest.type = Type.Chat
        messageRequest.context = getContext()
        addMessageToConversation(messageRequest)
        
        switch conversationType! {
        case .createConversation(let authodId):
            createConversationWithMessage(messageRequest, authorId: authodId)
        case .continueConversation(let conversationId):
            postMessageToConversation(conversationId, messageRequest: messageRequest)
        }
    }
    
    
    func postMessageToConversation(_ conversationId: Int, messageRequest: Message) {
        InboxManager.sharedInstance.postMessage(messageRequest, conversationId: conversationId) { (message, requestId) in
            if let index = self.sections[0].index(where: { (message1) -> Bool in
                if message1.requestId == messageRequest.requestId{
                    return true
                }
                return false
            }){
                if let message = message{
                    message.sendStatus = .Sent
                    self.sections[0][index] = message
                    
                }else{
                    let message = Message()
                    message.authorId = DriftDataStore.sharedInstance.auth?.enduser?.userId
                    message.body = messageRequest.body
                    message.requestId = messageRequest.requestId
                    message.sendStatus = .Failed
                    self.sections[0][index] = message
                }
                
                self.tableView!.reloadRows(at: [IndexPath(row:index, section: 0)], with: .none)
                self.tableView?.scrollToRow(at: IndexPath(row:0, section: 0), at: .bottom, animated: true)
            }
        }
    }
    
    
    func createConversationWithMessage(_ messageRequest: Message, authorId: Int?) {
        InboxManager.sharedInstance.createConversation(messageRequest, authorId: authorId) { (message, requestId) in
            if let index = self.sections[0].index(where: { (message1) -> Bool in
                if message1.requestId == messageRequest.requestId{
                    return true
                }
                return false
            }){
                if let message = message{
                    self.conversationType = ConversationType.continueConversation(conversationId: message.conversationId)
                    message.sendStatus = .Sent
                    self.sections[0][index] = message
                    self.conversationId = message.conversationId
                }else{
                    let message = Message()
                    message.authorId = DriftDataStore.sharedInstance.auth?.enduser?.userId
                    message.body = messageRequest.body
                    message.requestId = messageRequest.requestId
                    message.sendStatus = .Failed
                    self.sections[0][index] = message
                }
                
                self.tableView!.reloadRows(at: [IndexPath(row:0, section: 0)], with: .none)
                self.tableView?.scrollToRow(at: IndexPath(row:0, section: 0), at: .bottom, animated: true)
            }
        }
    }
}

extension ConversationViewController: MessageDelegate {
    
    func messagesDidUpdate(_ messages: [Message]) {
        let sorted = messages.sorted(by: { $0.createdAt.compare($1.createdAt as Date) == .orderedAscending})
        self.sections = self.getSections(sorted)
        self.tableView?.reloadData()
    }
    
    
    func newMessage(_ message: Message) {
        if let uuid = message.uuid{
            CampaignsManager.markConversationAsRead(uuid)
        }
        if message.authorId != DriftDataStore.sharedInstance.auth?.enduser?.userId{
            if let index = checkSectionsForMessages(message){
                    sections[(index as NSIndexPath).section][(index as NSIndexPath).row] = message
                    tableView!.reloadRows(at: [index], with: .bottom)
            }else{
                if let createdAt = sections.first?.first?.createdAt, (Calendar.current as NSCalendar).component(.day, from: createdAt as Date) ==  (Calendar.current as NSCalendar).component(.day, from: Date()){
                    self.sections[0].insert(message, at: 0)
                    tableView!.insertRows(at: [IndexPath(row: 0, section: 0)], with: .bottom)
                }else{
                    self.sections.insert([message], at: 0)
                    tableView?.insertSections(IndexSet.init(integer: 0), with: .bottom)
                }
            }
        }
    }
    
    
    func checkSectionsForMessages(_ message: Message) -> IndexPath? {
        if let section = sections.index(where: { $0.contains(message) }) {
            if let row = sections[section].index(of: message) {
                return IndexPath(row: row, section: section)
            }
        }
        return nil
    }
    
}

extension ConversationViewController: AttachementSelectedDelegate {
    
    func attachmentSelected(_ attachment: Attachment, sender: AnyObject) {
        SVProgressHUD.show()
        APIManager.downloadAttachmentFile(attachment, authToken: (DriftDataStore.sharedInstance.auth?.accessToken)!) { (result) in
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
            switch result{
            case .success(let tempFileURL):
                let fileName: NSString = attachment.fileName as NSString
                let fileExtension = fileName.pathExtension
                if fileExtension == "jpg" || fileExtension == "png" || fileExtension == "gif"{
                    DispatchQueue.main.async {
                        self.previewItem = DriftPreviewItem(url: tempFileURL, title: attachment.fileName)
                        self.qlController.dataSource = self
                        self.qlController.reloadData()
                        self.present(self.qlController, animated: true, completion:nil)
                    }
                }else{
                    DispatchQueue.main.async {
                        self.interactionController.url = tempFileURL
                        self.interactionController.name = attachment.fileName
                        self.interactionController.presentOptionsMenu(from: CGRect.zero, in: self.view, animated: true)
                    }
                }
            case .failure:
                let alert = UIAlertController.init(title: "Unable to preview file", message: "This file cannot be previewed", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction.init(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                LoggerManager.log("Unable to preview file with mimeType: \(attachment.mimeType)")
            }
        }
    }
}

extension ConversationViewController: QLPreviewControllerDataSource {
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        if let previewItem = previewItem{
            return previewItem
        }
        return DriftPreviewItem.init(url: URLComponents().url!, title: "")
    }
}

extension ConversationViewController: UIDocumentInteractionControllerDelegate{
    
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
    
    func documentInteractionControllerViewForPreview(_ controller: UIDocumentInteractionController) -> UIView? {
        return self.view
    }
    
    func documentInteractionControllerRectForPreview(_ controller: UIDocumentInteractionController) -> CGRect {
        return self.view.frame
    }
}


extension ConversationViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [AnyHashable: Any]!) {
        picker.dismiss(animated: true, completion: nil)
        if let imageRep = UIImageJPEGRepresentation(image, 0.2){
            let newAttachment = Attachment()
            newAttachment.data = imageRep
            newAttachment.conversationId = conversationId!
            newAttachment.mimeType = "image/jpeg"
            newAttachment.fileName = "image.jpg"
            
            APIManager.postAttachment(newAttachment,authToken: DriftDataStore.sharedInstance.auth!.accessToken) { (result) in
                switch result{
                case .success(let attachment):
                    let messageRequest = Message()
                    messageRequest.attachments.append(attachment.id)
                    self.postMessage(messageRequest)
                case .failure:
                    let alert = UIAlertController.init(title: "Unable to upload file", message: nil, preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction.init(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    LoggerManager.log("Unable to upload file with mimeType: \(newAttachment.mimeType)")

                }
            }
        }
    }
    
}
