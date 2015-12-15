//
//  NewFriendGameViewController.h
//  BoxedIn
//
//  Created by Robert Miller on 11/20/15.
//  Copyright © 2015 Robert Miller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FlatUIKit.h>

@interface NewFriendGameViewController : UIViewController

@property(nonatomic,retain) IBOutlet UITextField *rowTextField;
@property(nonatomic,retain) IBOutlet UIStepper *rowStepper;
@property(nonatomic,retain) IBOutlet UITextField *colTextField;
@property(nonatomic,retain) IBOutlet UIStepper *colStepper;

-(IBAction)startButtonPressed:(id)sender;

@end
