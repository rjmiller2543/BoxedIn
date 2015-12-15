//
//  NewGameViewController.h
//  BoxedIn
//
//  Created by Robert Miller on 11/5/15.
//  Copyright © 2015 Robert Miller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FlatUIKit.h>
#import <VBFPopFlatButton.h>
#import <Parse.h>

@interface NewGameViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property(nonatomic,retain) IBOutlet UIButton *localButton;
@property(nonatomic,retain) IBOutlet UILabel *localLabel;
@property(nonatomic,retain) IBOutlet UIButton *p2pButton;
@property(nonatomic,retain) IBOutlet UILabel *p2pLabel;
@property(nonatomic,retain) IBOutlet UIButton *playButton;
@property(nonatomic,retain) IBOutlet UILabel *playLabel;
@property(nonatomic,retain) IBOutlet VBFPopFlatButton *cancelButton;

@property(nonatomic,retain) UIView *gameOptionsView;
@property(nonatomic,retain) FUITextField *columnsTextField;
@property(nonatomic,retain) FUITextField *rowsTextField;
@property(nonatomic,retain) VBFPopFlatButton *saveButton;

@property(nonatomic,retain) IBOutlet UITableView *tableView;
@property(nonatomic,retain) NSArray *dataSourceArray;

@property(nonatomic) float localButtonYCoordinate;
@property(nonatomic) float localLabelYCoordinate;
@property(nonatomic) float p2pButtonYCoordinate;
@property(nonatomic) float p2pLabelYCoordinate;
@property(nonatomic) float playButtonYCoordinate;
@property(nonatomic) float playLabelYCoordinate;
@property(nonatomic) float cancelButtonXCoordinate;

-(IBAction)localButtonPressed:(id)sender;
-(IBAction)p2pButtonPressed:(id)sender;
-(IBAction)playButtonPresed:(id)sender;
-(IBAction)cancelButtonPressed:(id)sender;

-(void)sendGameData:(NSData*)data;

-(void)setupFriendGame:(PFUser*)user;

@end
