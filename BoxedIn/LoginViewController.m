//
//  LoginViewController.m
//  BoxedIn
//
//  Created by Robert Miller on 11/12/15.
//  Copyright © 2015 Robert Miller. All rights reserved.
//

#import "LoginViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import <FlatUIKit.h>
#import <Parse.h>
#import "BoxedInColors.h"
#import "AppDelegate.h"

@interface LoginViewController () <FUIAlertViewDelegate, UITextFieldDelegate>

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _userNameTextField.delegate = self;
    _passwordTextField.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

-(void)facebookButtonPressed:(id)sender {
    // Set permissions required from the facebook user account
    
    NSString *userName = [_userNameTextField text];
    if ([userName characterAtIndex:0] ) {
        NSRange textfieldfirstText = [userName rangeOfComposedCharacterSequenceAtIndex:0];
        NSRange textfieldmatchText = [userName rangeOfCharacterFromSet:[NSCharacterSet letterCharacterSet] options:0 range:textfieldfirstText];
        
        if (textfieldmatchText.location != NSNotFound)
        {
            NSArray *permissionsArray = @[ @"public_profile", @"user_friends"];
            
            // Login PFUser using Facebook
            [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser * _Nullable user, NSError * _Nullable error) {
                if (!user) {
                    NSLog(@"Uh oh. The user cancelled the Facebook login.");
                    
                } else if (user.isNew) {
                    NSLog(@"User signed up and logged in through Facebook!");
                    
                    FBRequest *request = [FBRequest requestForMe];
                    [request setSession:[PFFacebookUtils session]];
                    
                    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                        if (!error) {
                            PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                            user[@"installationId"] = currentInstallation.objectId;
                            user.username = _userNameTextField.text;
                            [user setObject:[result objectForKey:@"id"] forKey:@"fbID"];
                            [user saveInBackground];
                            [self dismissViewControllerAnimated:YES completion:^{
                                //up up
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateUserInformation" object:nil];
                            }];
                        }
                    }];
                } else {
                    NSLog(@"User logged in through Facebook!");
                }
            }];
        }
        else
        {
            NSLog(@"not checking...");
            NSLog(@"checking...");
            FUIAlertView *alert = [[FUIAlertView alloc] initWithTitle:@"Invalid User Name" message:@"Your username must begin with a letter..  Use a different username and try again.." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            return;
            
        }
    }
    
}

-(void)passwordButtonPressed:(id)sender {
    
    NSString *userName = [_userNameTextField text];
    if ([userName characterAtIndex:0] ) {
        NSRange textfieldfirstText = [userName rangeOfComposedCharacterSequenceAtIndex:0];
        NSRange textfieldmatchText = [userName rangeOfCharacterFromSet:[NSCharacterSet letterCharacterSet] options:0 range:textfieldfirstText];
        
        if (textfieldmatchText.location != NSNotFound)
        {
            NSLog(@"checking...");
            
        }
        else
        {
            NSLog(@"not checking...");
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Invalid User Name" message:@"Your username must begin with a letter..  Try another username" preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                //up up
            }]];
            [self presentViewController:alert animated:YES completion:^{
                // up up
            }];
            return;
            
        }
    }
    
    PFQuery *query = [PFQuery queryWithClassName:@"User"];
    [query whereKey:@"username" equalTo:userName];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (objects.count > 0) {
            //PFUser *user = [PFUser user];
            //user.username = userName;
            //user.password = _passwordTextField.text;
            [PFUser logInWithUsernameInBackground:userName password:_passwordTextField.text block:^(PFUser * _Nullable user, NSError * _Nullable error) {
                if (error) {
                    FUIAlertView *alert = [[FUIAlertView alloc] initWithTitle:@"User Name used" message:@"The username you chose has already been taken or the password is wrong..  Try another" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                    [alert show];
                }
                else {
                    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                    [PFUser currentUser][@"installationId"] = currentInstallation.objectId;
                    [[PFUser currentUser] saveInBackground];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateUserInformation" object:nil];
                }
            }];
            
        }
        else {
            PFUser *user = [PFUser user];
            user.username = userName;
            user.password = _passwordTextField.text;
            [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if (succeeded) {
                    NSLog(@"signed up!");
                    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                    user[@"installationId"] = currentInstallation.objectId;
                    [user saveInBackground];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateUserInformation" object:nil];
                    [[NSUserDefaults standardUserDefaults] setValue:userName forKey:@"UserName"];
                    [[NSUserDefaults standardUserDefaults] setValue:_passwordTextField.text forKey:@"Password"];
                    [[AppDelegate sharedInstance] setParseUser:user];
                    [self dismissViewControllerAnimated:YES completion:^{
                        // up up
                    }];
                    
                }
            }];
        }
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
