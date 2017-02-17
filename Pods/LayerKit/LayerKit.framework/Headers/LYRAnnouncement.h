//
//  LYRAnnouncement.h
//  LayerKit
//
//  Created by Kabir Mahal on 5/31/15.
//  Copyright (c) 2015 Layer Inc. All rights reserved.
//

#import "LYRMessage.h"

/**
 @abstract The `LYRAnnouncement` class models a special type of message that was sent directly by the application
 rather than a user of the application. Announcements can be used to implement functionality such as announcing
 product news to the userbase, informing a user of particular activity related to their account, or inviting the
 user to take a particular action. Announcements are never part of a Conversation.  Announcements have all the queryable
 properties of messages except for `conversation`.
 */
@interface LYRAnnouncement : LYRMessage

@end
