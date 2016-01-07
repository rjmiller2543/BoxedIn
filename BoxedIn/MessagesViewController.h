//
//  MessagesViewController.h
//  BoxedIn
//
//  Created by Robert Miller on 1/4/16.
//  Copyright © 2016 Robert Miller. All rights reserved.
//

#import <JSQMessagesViewController/JSQMessagesViewController.h>
#import <Parse.h>

@class MessagesViewController;

@protocol MessagesViewControllerDelegate <NSObject>

- (void)didDismissJSQDemoViewController:(MessagesViewController *)vc;

@end

@interface MessagesViewController : JSQMessagesViewController

@property (weak, nonatomic) id delegateModal;

@property(nonatomic,retain) NSMutableArray *messageData;
@property(nonatomic,retain) NSMutableArray *messages;

@property(nonatomic,retain) PFUser *oppUser;

@end
