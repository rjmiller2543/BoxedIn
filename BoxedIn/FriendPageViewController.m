//
//  FriendPageViewController.m
//  BoxedIn
//
//  Created by Robert Miller on 11/5/15.
//  Copyright © 2015 Robert Miller. All rights reserved.
//

#import "FriendPageViewController.h"
#import <FlatUIKit.h>
#import "NewGameViewController.h"
#import <MZFormSheetController.h>
#import "MessagesViewController.h"

@interface FriendPageViewController () <MessagesViewControllerDelegate>

@property(nonatomic) BOOL connectedToUser;

@end

@implementation FriendPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString *userlabelstring = @"@";
    if (_friendUser != nil) {
        _userLabel.text = [userlabelstring stringByAppendingString:_friendUser.username];
        _gamesPlayedLabel.text = [_friendUser[@"gamesPlayed"] stringValue];
        _gamesWonLabel.text = [_friendUser[@"totalWins"] stringValue];
        _totalBoxesLabel.text = [_friendUser[@"totalBoxes"] stringValue];
    }
}

-(void)viewDidLayoutSubviews {
    NSArray *friendArray = [PFUser currentUser][@"friendsList"];
    [_connectButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    if ([friendArray containsObject:_friendUser.objectId]) {
        _connectedToUser = true;
        _connectButton.titleLabel.text = @"Unfriend";
    }
    else if (friendArray == nil) {
        _connectedToUser = false;
        _connectButton.titleLabel.text = @"Friend";
    }
    else {
        _connectedToUser = false;
        _connectButton.titleLabel.text = @"Friend";
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)connectButtonPressed:(id)sender {
    if (_connectedToUser == false) {
        [[PFUser currentUser] addObject:_friendUser.objectId forKey:@"friendsList"];
        [[PFUser currentUser] saveInBackground];
    }
}

-(void)messageButtonPressed:(id)sender {
    MessagesViewController *messageViewController = [[MessagesViewController alloc] init];
    [messageViewController setOppUser:_friendUser];
    
    messageViewController.delegateModal = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:messageViewController];
    [self presentViewController:nav animated:YES completion:^{
        //up up
    }];
}

-(void)newGameButtonPressed:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    NewGameViewController *newGame = [storyboard instantiateViewControllerWithIdentifier:@"newGameViewController"];
    [self presentViewController:newGame animated:YES completion:^{
        [newGame setupFriendGame:_friendUser];
    }];
}

-(void)didDismissJSQDemoViewController:(MessagesViewController *)vc {
    [self dismissViewControllerAnimated:YES completion:^{
        //up up
    }];
}

-(void)closePage:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        // up up
    }];
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
