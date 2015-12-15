//
//  FriendPageViewController.h
//  BoxedIn
//
//  Created by Robert Miller on 11/5/15.
//  Copyright © 2015 Robert Miller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse.h>

@interface FriendPageViewController : UIViewController

@property(nonatomic,retain) IBOutlet UILabel *userLabel;
@property(nonatomic,retain) IBOutlet UILabel *gamesPlayedLabel;
@property(nonatomic,retain) IBOutlet UILabel *gamesWonLabel;
@property(nonatomic,retain) IBOutlet UILabel *totalBoxesLabel;

@property(nonatomic,retain) IBOutlet UIButton *connectButton;

@property(nonatomic,retain) PFUser *friendUser;

-(IBAction)connectButtonPressed:(id)sender;
-(IBAction)messageButtonPressed:(id)sender;
-(IBAction)newGameButtonPressed:(id)sender;
-(IBAction)closePage:(id)sender;

@end
