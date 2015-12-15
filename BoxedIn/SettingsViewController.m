//
//  SettingsViewController.m
//  BoxedIn
//
//  Created by Robert Miller on 11/5/15.
//  Copyright © 2015 Robert Miller. All rights reserved.
//

#import "SettingsViewController.h"
#import <Parse/Parse.h>
#import <PFFacebookUtils.h>
#import <FacebookSDK/FacebookSDK.h>
#import <Facebook-iOS-SDK/FacebookSDK/FacebookSDK.h>
#import "LoginViewController.h"
#import <FBSDKCoreKit.h>
//#import <FBSDKLoginKit.h>

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:@"UpdateUserInformation" object:nil];
    
    PFUser *user = [PFUser currentUser];
    
    _userLabel.text = user.username;
    _gamesPlayedLabel.text = user[@"gamesPlayed"];
    _gamesWonLabel.text = user[@"gamesWon"];
    _totalBoxesLabel.text = user[@"totalBoxes"];
    
}

-(void)viewDidLayoutSubviews {
    PFUser *user = [PFUser currentUser];
    [user fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if (![PFFacebookUtils isLinkedWithUser:user]) {
            _connectFbButton.titleLabel.text = @"Link FB";
        }
        else {
            _connectFbButton.titleLabel.text = @"Unlink FB";
        }
    }];
}

-(void)updateUserPage {
    PFUser *user = [PFUser currentUser];
    
    _userLabel.text = user.username;
    _gamesPlayedLabel.text = user[@"gamesPlayed"];
    _gamesWonLabel.text = user[@"gamesWon"];
    _totalBoxesLabel.text = user[@"totalBoxes"];
    
    [user fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if (![PFFacebookUtils isLinkedWithUser:user]) {
            _connectFbButton.titleLabel.text = @"Link FB";
        }
        else {
            _connectFbButton.titleLabel.text = @"Unlink FB";
        }
    }];
}

-(void)editButtonPressed:(id)sender {
    // get rid of the edit button
}

-(void)connectFBButtonPressed:(id)sender {
    
    PFUser *user = [PFUser currentUser];
    
    if ([PFFacebookUtils isLinkedWithUser:user]) {
        [PFFacebookUtils unlinkUserInBackground:user block:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded) {
                [[PFUser currentUser] setObject:@"" forKey:@"fbID"];
                [[PFUser currentUser] saveInBackground];
                _connectFbButton.titleLabel.text = @"Connect With Facebook";
            }
        }];
    }
    else {
        /*FBSDKLoginButton *login = [[FBSDKLoginButton alloc] init];
        
        [PFFacebookUtils logInWithPermissions:@[@"public_profile", @"user_friends"] block:^(PFUser * _Nullable user, NSError * _Nullable error) {
            if (!error) {
                NSLog(@"logged in");
            }
        }];
         */
       
        [PFFacebookUtils linkUser:user permissions:@[@"public_profile", @"user_friends"] block:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded) {
                if (user) {
                    _connectFbButton.titleLabel.text = @"Unlink FB";
                    FBRequest *request = [FBRequest requestForMe];
                    [request setSession:[PFFacebookUtils session]];
                    
                    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                        if (!error) {
                            [[PFUser currentUser] setObject:[result objectForKey:@"id"] forKey:@"fbID"];
                            [[PFUser currentUser] saveInBackground];
                        }
                    }];
                }
            }
        }];
    }
    
}

-(void)deleteAccountButtonPressed:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Delete Account?" message:@"Are you sure you want to delete?" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        //[alert dismissViewControllerAnimated:YES completion:^{
            [self deleteAccount];
        //}];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Nevermind.." style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //do nothing
    }]];
    [self presentViewController:alert animated:YES completion:^{
        //up up
    }];
}

-(void)deleteAccount {
    if ([PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        [[PFUser currentUser] deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded) {
                [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"UserName"];
                [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"Password"];
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                LoginViewController *login = [storyboard instantiateViewControllerWithIdentifier:@"loginViewController"];
                [self presentViewController:login animated:YES completion:^{
                    //up up
                }];
            }
        }];
    }
    else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Let's get your credentials.." message:@"Before we delete it, let's make sure it's you who wants it delted.." preferredStyle:UIAlertControllerStyleAlert];
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            
        }];
        [alert addAction:[UIAlertAction actionWithTitle:@"DELETE" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            UITextField *textField = [[alert textFields] objectAtIndex:0];
            if ([textField.text isEqualToString:[[NSUserDefaults standardUserDefaults] valueForKey:@"Password"]]) {
                [[PFUser currentUser] deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    if (succeeded) {
                        [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"UserName"];
                        [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"Password"];
                        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                        LoginViewController *login = [storyboard instantiateViewControllerWithIdentifier:@"loginViewController"];
                        [self presentViewController:login animated:YES completion:^{
                            //up up
                        }];
                    }
                }];
            }
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //up up
        }]];
        [self presentViewController:alert animated:YES completion:^{
            //up up
        }];
    }
}

-(void)receiveNotification:(NSNotification*)notification {
    if ([[notification name] isEqualToString:@"UpdateUserInformation"]) {
        [[PFUser currentUser] fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
            //up up
            [self updateUserPage];
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
