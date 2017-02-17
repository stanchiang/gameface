//
//  PresentationManager.swift
//  Drift
//
//  Created by Eoin O'Connell on 26/01/2016.
//  Copyright © 2016 Drift. All rights reserved.
//

import UIKit

protocol PresentationManagerDelegate:class {
    
    func campaignDidFinishWithResponse(_ view: CampaignView, campaign: Campaign, response: CampaignResponse)
    func messageViewDidFinish(_ view: CampaignView)
}


///Responsible for showing a campaign
class PresentationManager: PresentationManagerDelegate {
    
    static var sharedInstance: PresentationManager = PresentationManager()
    weak var currentShownView: CampaignView?
    
    init () {}
    
    func didRecieveCampaigns(_ campaigns: [Campaign]) {
        
        ///Show latest first
        let sortedCampaigns = campaigns.sorted {
            
            if let d1 = $0.createdAt, let d2 = $1.createdAt {
                return d1.compare(d2) == .orderedAscending
            }else{
                return false
            }
        }
        
        var nextCampaigns = [Campaign]()
        
        if campaigns.count > 1 {
            nextCampaigns = Array(sortedCampaigns.dropFirst())
        }
        

        DispatchQueue.main.async { () -> Void in
         
            if let firstCampaign = sortedCampaigns.first, let type = firstCampaign.messageType  {
                
                switch type {
                    
                case .Announcement:
                    self.showAnnouncementCampaign(firstCampaign, otherCampaigns: nextCampaigns)
                case .NPS:
                    self.showNPSCampaign(firstCampaign, otherCampaigns: nextCampaigns)
                case .NPSResponse:
                    ()
                }
            }
        }
    }
    
    func didRecieveNewMessages(_ messages: [(conversationId: Int, messages: [Message])]) {
        
        if let newMessageView = NewMessageView.fromNib() as? NewMessageView , currentShownView == nil && !conversationIsPresenting() {
            
            if let window = UIApplication.shared.keyWindow {
                currentShownView = newMessageView
                
                let currentConversation = messages.first!
                let otherConversations = messages.filter({ $0.conversationId != currentConversation.conversationId })
                newMessageView.otherConversations = otherConversations                
                newMessageView.conversation = currentConversation
                newMessageView.delegate = self
                newMessageView.showOnWindow(window)
                
            }
        }

        
        
    }
    
    func showAnnouncementCampaign(_ campaign: Campaign, otherCampaigns:[Campaign]) {
        if let announcementView = AnnouncementView.fromNib() as? AnnouncementView , currentShownView == nil && !conversationIsPresenting() {
            
            if let window = UIApplication.shared.keyWindow {
                currentShownView = announcementView
                announcementView.otherCampaigns = otherCampaigns
                announcementView.campaign = campaign
                announcementView.delegate = self
                announcementView.showOnWindow(window)
                                
            }
        }
    }
    
    func showExpandedAnnouncement(_ campaign: Campaign) {
    
        if let announcementView = AnnouncementExpandedView.fromNib() as? AnnouncementExpandedView, let window = UIApplication.shared.keyWindow , !conversationIsPresenting() {
            
            currentShownView = announcementView
            announcementView.campaign = campaign
            announcementView.delegate = self
            announcementView.showOnWindow(window)
            
        }
    }
    
    
    func showNPSCampaign(_ campaign: Campaign, otherCampaigns: [Campaign]) {
     
     
        if let npsContainer = NPSContainerView.fromNib() as? NPSContainerView, let npsView = NPSView.fromNib() as? NPSView , currentShownView == nil && !conversationIsPresenting(){
            
            if let window = UIApplication.shared.keyWindow {
                currentShownView = npsContainer
                npsContainer.delegate = self
                npsContainer.campaign = campaign
                npsView.campaign = campaign
                npsView.otherCampaigns = otherCampaigns
                npsContainer.showOnWindow(window)
                npsContainer.popUpContainer(initialView: npsView)
            }
        }else{
            LoggerManager.log("Error Loading Nib")
        }
    }
    
    func conversationIsPresenting() -> Bool{
        if let topVC = TopController.viewController() , topVC.classForCoder == ConversationListViewController.classForCoder() || topVC.classForCoder == ConversationViewController.classForCoder(){
            return true
        }
        return false
    }
    
    func showConversationList(){

        let conversationListController = ConversationListViewController.navigationController()
        TopController.viewController()?.present(conversationListController, animated: true, completion: nil)
        
    }
    
    func showConversationVC(_ conversationId: Int) {
        if let topVC = TopController.viewController()  {
            let navVC = ConversationViewController.navigationController(ConversationViewController.ConversationType.continueConversation(conversationId: conversationId))
            topVC.present(navVC, animated: true, completion: nil)
        }
    }
    
    func showNewConversationVC(_ authorId: Int?) {
        if let topVC = TopController.viewController()  {
            let navVC = ConversationViewController.navigationController(ConversationViewController.ConversationType.createConversation(authorId: authorId))
            topVC.present(navVC, animated: true, completion: nil)
        }
    }
    
    ///Presentation Delegate
    
    func campaignDidFinishWithResponse(_ view: CampaignView, campaign: Campaign, response: CampaignResponse) {
        view.hideFromWindow()
        currentShownView = nil
        switch response {
        case .announcement(let announcementResponse):
            if announcementResponse == .Opened {
                self.showExpandedAnnouncement(campaign)
            }
            CampaignResponseManager.recordAnnouncementResponse(campaign, response: announcementResponse)
        case .nps(let npsResponse):
            CampaignResponseManager.recordNPSResponse(campaign, response: npsResponse)
        }
    }
    
    func messageViewDidFinish(_ view: CampaignView) {
        view.hideFromWindow()
        currentShownView = nil
    }
}







