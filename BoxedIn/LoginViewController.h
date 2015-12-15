//
//  LoginViewController.h
//  BoxedIn
//
//  Created by Robert Miller on 11/12/15.
//  Copyright © 2015 Robert Miller. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController

@property(nonatomic,retain) IBOutlet UITextField *userNameTextField;
@property(nonatomic,retain) IBOutlet UITextField *passwordTextField;

-(IBAction)facebookButtonPressed:(id)sender;
-(IBAction)passwordButtonPressed:(id)sender;

@end
