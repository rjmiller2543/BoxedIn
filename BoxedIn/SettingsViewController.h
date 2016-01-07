//
//  SettingsViewController.h
//  BoxedIn
//
//  Created by Robert Miller on 11/5/15.
//  Copyright © 2015 Robert Miller. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController

@property(nonatomic,retain) IBOutlet UILabel *userLabel;
@property(nonatomic,retain) IBOutlet UILabel *gamesPlayedLabel;
@property(nonatomic,retain) IBOutlet UILabel *gamesWonLabel;
@property(nonatomic,retain) IBOutlet UILabel *totalBoxesLabel;
@property(nonatomic,retain) IBOutlet UIButton *connectFbButton;

-(IBAction)connectFBButtonPressed:(id)sender;
-(IBAction)editButtonPressed:(id)sender;
-(IBAction)deleteAccountButtonPressed:(id)sender;
-(IBAction)donateCash:(id)sender;

@end
