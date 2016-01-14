//
//  MessagesViewController.m
//  BoxedIn
//
//  Created by Robert Miller on 1/4/16.
//  Copyright © 2016 Robert Miller. All rights reserved.
//

#import "MessagesViewController.h"
#import <JSQMessages.h>
#import <JSQSystemSoundPlayer+JSQMessages.h>
#import "BoxedInColors.h"

@interface MessagesViewController ()

@property(nonatomic,retain) NSTimer *timer;
@property(nonatomic,retain) NSDate *lastQuery;

@end

@implementation MessagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMessages) name:@"UpdateMessageNotification" object:nil];
    
    [self setAutomaticallyScrollsToMostRecentMessage:YES];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(closePressed:)];
    
    PFUser *me = [PFUser currentUser];
    self.senderId = [me username];
    self.senderDisplayName = [me username];
    
    _messageData = [[NSMutableArray alloc] init];
    _messages = [[NSMutableArray alloc] init];
    //NSPredicate *currpredicate = [NSPredicate predicateWithFormat:@"(FromUser = %@ OR ToUser = %@) AND (FromUser = %@ OR ToUser = %@", [PFUser currentUser], [PFUser currentUser], _oppUser, _oppUser];
    NSPredicate *mePredicate = [NSPredicate predicateWithFormat:@"FromUser = %@ OR ToUser = %@", me, me];
    NSPredicate *youPredicate = [NSPredicate predicateWithFormat:@"FromUser = %@ OR ToUser = %@", _oppUser, _oppUser];
    NSPredicate *currpredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[youPredicate, mePredicate]];
    PFQuery *query = [PFQuery queryWithClassName:@"Message" predicate:currpredicate];
    [query orderByAscending:@"createdAt"];
    [query setLimit:30];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        [_messageData addObjectsFromArray:objects];
        for (PFObject *message in _messageData) {
            NSDate *date = message.createdAt;
            JSQMessage *newMessage = [[JSQMessage alloc] initWithSenderId:[message[@"FromUser"] username] senderDisplayName:[message[@"FromUser"] username] date:date text:message[@"message"]];
            [_messages addObject:newMessage];
        }
        [self.collectionView reloadData];
        
        [self scrollToBottomAnimated:YES];
    }];
    
    //_timer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(timerFired) userInfo:NULL repeats:YES];
    _lastQuery = [NSDate date];
    //[_timer ];
}

-(void)updateMessages {
    PFUser *me = [PFUser currentUser];
    NSPredicate *mePredicate = [NSPredicate predicateWithFormat:@"FromUser = %@ OR ToUser = %@", me, me];
    NSPredicate *youPredicate = [NSPredicate predicateWithFormat:@"FromUser = %@ OR ToUser = %@", _oppUser, _oppUser];
    NSPredicate *currpredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[youPredicate, mePredicate]];
    PFQuery *query = [PFQuery queryWithClassName:@"Message" predicate:currpredicate];
    [query orderByDescending:@"createdAt"];
    [query setLimit:30];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        [_messageData addObjectsFromArray:objects];
        for (PFObject *message in objects) {
            NSDate *date = message.createdAt;
            JSQMessage *newMessage = [[JSQMessage alloc] initWithSenderId:[message[@"FromUser"] username] senderDisplayName:[message[@"FromUser"] username] date:date text:message[@"message"]];
            [_messages addObject:newMessage];
        }
        [self.collectionView reloadData];
        
        [self scrollToBottomAnimated:YES];
        //NSInteger item = [self collectionView:self.collectionView numberOfItemsInSection:0];
        //NSIndexPath *lastIndexPath = [NSIndexPath indexPathForItem:item inSection:0];
        //[self.collectionView scrollToItemAtIndexPath:lastIndexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:YES];
    }];
    _lastQuery = [NSDate date];
}

-(void)updateData {
    PFUser *me = [PFUser currentUser];
    NSPredicate *mePredicate = [NSPredicate predicateWithFormat:@"FromUser = %@ OR ToUser = %@", me, me];
    NSPredicate *youPredicate = [NSPredicate predicateWithFormat:@"FromUser = %@ OR ToUser = %@", _oppUser, _oppUser];
    NSPredicate *currpredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[youPredicate, mePredicate]];
    PFQuery *query = [PFQuery queryWithClassName:@"Message" predicate:currpredicate];
    [query orderByAscending:@"createdAt"];
    [query setLimit:30];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        [_messageData addObjectsFromArray:objects];
        for (PFObject *message in _messageData) {
            NSDate *date = message.createdAt;
            PFUser *from = message[@"FromUser"];
            [from fetch];
            NSString *messageString = message[@"message"];
            JSQMessage *newMessage = [[JSQMessage alloc] initWithSenderId:[from username] senderDisplayName:[from username] date:date text:messageString];
            [_messages addObject:newMessage];
        }
        [self.collectionView reloadData];
        
        [self scrollToBottomAnimated:YES];
    }];
}

- (void)closePressed:(UIBarButtonItem *)sender
{
    [_delegateModal didDismissJSQDemoViewController:self];
}

-(void)setOppUser:(PFUser *)oppUser {
    _oppUser = oppUser;
    self.title = _oppUser.username;
    [self updateData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - JSQMessagesViewController method overrides

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date
{
    /**
     *  Sending a message. Your implementation of this method should do *at least* the following:
     *
     *  1. Play sound (optional)
     *  2. Add new id<JSQMessageData> object to your data source
     *  3. Call `finishSendingMessage`
     */
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    
    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:senderId
                                             senderDisplayName:senderDisplayName
                                                          date:date
                                                          text:text];
    
    [_messages addObject:message];
    
    [self finishSendingMessageAnimated:YES];
    
    PFUser *me = [PFUser currentUser];
    PFObject *pfMessage = [PFObject objectWithClassName:@"Message"];
    //pfMessage[@"FromUser"] = [PFUser currentUser];
    [pfMessage setObject:me forKey:@"FromUser"];
    //pfMessage[@"ToUser"] = _oppUser;
    [pfMessage setObject:_oppUser forKey:@"ToUser"];
    //pfMessage[@"message"] = text;
    [pfMessage setObject:text forKey:@"message"];
    //pfMessage.ACL = [PFACL ACLWithUser:[PFUser currentUser]];
    //[pfMessage setObject:[PFACL ACLWithUser:[PFUser currentUser]] forKey:@"ACL"];
    [pfMessage saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        //up up
    }];
    
    PFQuery *pushQuery = [PFInstallation query];
    [pushQuery whereKey:@"objectId" equalTo:_oppUser[@"installationId"]];
    
    // Send push notification to query
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:pushQuery]; // Set our Installation query
    
    NSString *pushMessage = me.username;
    pushMessage = [pushMessage stringByAppendingString:@": "];
    pushMessage = [pushMessage stringByAppendingString:text];
    NSDictionary *data = @{
                           @"alert" : pushMessage,
                           @"pushType" : @"MessageNotification",
                           //@"g" : _game.objectId,
                           @"badge" : @"Increment",
                           @"sounds" : @"default",
                           @"fromUserName" : me.username,
                           @"fromUserId" : me.objectId
                           };
    
    [push setData:data];
    [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            NSLog(@"push sent..");
            //[SVProgressHUD showSuccessWithStatus:@"Saved!"];
        }
        else if (error) {
            NSLog(@"push not sent with error: %@", error);
        }
    }];
}

#pragma mark - JSQMessages CollectionView DataSource

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [_messages objectAtIndex:indexPath.item];
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didDeleteMessageAtIndexPath:(NSIndexPath *)indexPath
{
    [_messages removeObjectAtIndex:indexPath.item];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  You may return nil here if you do not want bubbles.
     *  In this case, you should set the background color of your collection view cell's textView.
     *
     *  Otherwise, return your previously created bubble image data objects.
     */
    
    JSQMessage *message = [_messages objectAtIndex:indexPath.item];
    
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    if ([message.senderId isEqualToString:self.senderId]) {
        return [bubbleFactory outgoingMessagesBubbleImageWithColor:BIGreen];
    }
    
    return [bubbleFactory outgoingMessagesBubbleImageWithColor:BIOrange];
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Return `nil` here if you do not want avatars.
     *  If you do return `nil`, be sure to do the following in `viewDidLoad`:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
     *
     *  It is possible to have only outgoing avatars or only incoming avatars, too.
     */
    
    /**
     *  Return your previously created avatar image data objects.
     *
     *  Note: these the avatars will be sized according to these values:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize
     *
     *  Override the defaults in `viewDidLoad`
     */
    /*
    JSQMessage *message = [_messages objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        if (![NSUserDefaults outgoingAvatarSetting]) {
            return nil;
        }
    }
    else {
        if (![NSUserDefaults incomingAvatarSetting]) {
            return nil;
        }
    }
    
    
    return [self.demoData.avatars objectForKey:message.senderId];
     */
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
     *  The other label text delegate methods should follow a similar pattern.
     *
     *  Show a timestamp for every 3rd message
     */
    if (indexPath.item % 3 == 0) {
        JSQMessage *message = [_messages objectAtIndex:indexPath.item];
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [_messages objectAtIndex:indexPath.item];
    
    /**
     *  iOS7-style sender name labels
     */
    if ([message.senderId isEqualToString:self.senderId]) {
        return nil;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [_messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:message.senderId]) {
            return nil;
        }
    }
    
    /**
     *  Don't specify attributes to use the defaults.
     */
    return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_messages count];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Override point for customizing cells
     */
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    /**
     *  Configure almost *anything* on the cell
     *
     *  Text colors, label text, label colors, etc.
     *
     *
     *  DO NOT set `cell.textView.font` !
     *  Instead, you need to set `self.collectionView.collectionViewLayout.messageBubbleFont` to the font you want in `viewDidLoad`
     *
     *
     *  DO NOT manipulate cell layout information!
     *  Instead, override the properties you want on `self.collectionView.collectionViewLayout` from `viewDidLoad`
     */
    
    JSQMessage *msg = [_messages objectAtIndex:indexPath.item];
    
    if (!msg.isMediaMessage) {
        
        if ([msg.senderId isEqualToString:self.senderId]) {
            cell.textView.textColor = [UIColor blackColor];
        }
        else {
            cell.textView.textColor = [UIColor whiteColor];
        }
        
        cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                              NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    }
    
    return cell;
}

#pragma mark - JSQMessages collection view flow layout delegate

#pragma mark - Adjusting cell label heights

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Each label in a cell has a `height` delegate method that corresponds to its text dataSource method
     */
    
    /**
     *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
     *  The other label height delegate methods should follow similarly
     *
     *  Show a timestamp for every 3rd message
     */
    if (indexPath.item % 3 == 0) {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    
    return 0.0f;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  iOS7-style sender name labels
     */
    JSQMessage *currentMessage = [_messages objectAtIndex:indexPath.item];
    if ([[currentMessage senderId] isEqualToString:self.senderId]) {
        return 0.0f;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [_messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:[currentMessage senderId]]) {
            return 0.0f;
        }
    }
    
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return 0.0f;
}

#pragma mark - Responding to collection view tap events

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
                header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender
{
    NSLog(@"Load earlier messages!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView atIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped avatar!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped message bubble!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation
{
    NSLog(@"Tapped cell at %@!", NSStringFromCGPoint(touchLocation));
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
