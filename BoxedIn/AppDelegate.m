//
//  AppDelegate.m
//  BoxedIn
//
//  Created by Robert Miller on 10/19/15.
//  Copyright (c) 2015 Robert Miller. All rights reserved.
//

#import "AppDelegate.h"
#import <MinimalTabBar/JDMinimalTabBarController.h>
#import "ViewController.h"
#import "FriendListViewController.h"
#import "FriendPageViewController.h"
#import "InfoPageViewController.h"
#import "GameBoardViewController.h"
#import "GameListViewController.h"
#import "SettingsViewController.h"
#import "NewGameViewController.h"
#import "BoxedInColors.h"
#import <PFFacebookUtils.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>


@interface AppDelegate ()

@property(nonatomic,retain) JDMinimalTabBarController *tabBarController;

@end

@implementation AppDelegate

+(id)sharedInstance
{
    return [[UIApplication sharedApplication] delegate];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    [Parse enableLocalDatastore];
    [Parse setApplicationId:@"aSJwZ9zYs5qmdb4KHc13UIbKvPB2bS0viHUGDKJW" clientKey:@"lPRPpHn5Vlglzd1vIYfGqwAsamhapHXJ6i8jGguW"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    [PFFacebookUtils initializeFacebook];
    
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes  categories:nil];
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];
    
    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserName"];
    NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:@"Password"];
    NSLog(@"password: %@", password);
    
    if (userName == nil) {
        _parseUser = nil;
    }
    else {
        NSError *error = nil;
        _parseUser = [PFUser logInWithUsername:userName password:password error:&error];
        
    }
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Override point for customization after application launch.
    //self.window.backgroundColor = [UIColor blackColor];
    [self.window makeKeyAndVisible];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    
    ViewController *frontPage = [storyboard instantiateViewControllerWithIdentifier:@"frontPageViewController"];
    NSLog(@"size in app delegate: %f x %f", frontPage.view.frame.size.width, frontPage.view.frame.size.height);
    UITabBarItem *frontPageTabBarItem = [[UITabBarItem alloc] initWithTitle:@"boxedIn" image:[UIImage imageNamed: @"boxedIn-toolbar-icon.png"] selectedImage:[UIImage imageNamed:@"boxedIn-toolbar-icon.png"]];
    frontPage.tabBarItem = frontPageTabBarItem;
    
    FriendListViewController *friendList = [storyboard instantiateViewControllerWithIdentifier:@"friendListViewController"];
    UITabBarItem *friendListTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Friends" image:[UIImage imageNamed:@"group-50.png"] selectedImage:[UIImage imageNamed:@"boxedIn-toolbar-icon.png"]];
    friendList.tabBarItem = friendListTabBarItem;
    
    InfoPageViewController *infoPage = [storyboard instantiateViewControllerWithIdentifier:@"infoPageViewController"];
    UITabBarItem *infoPageTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Info" image:[UIImage imageNamed:@"about-50.png"] selectedImage:[UIImage imageNamed:@"boxedIn-toolbar-icon.png"]];
    infoPage.tabBarItem = infoPageTabBarItem;
    
    GameListViewController *gameList = [storyboard instantiateViewControllerWithIdentifier:@"gameListViewController"];
    UITabBarItem *gameListTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Games" image:[UIImage imageNamed:@"play-toolbar-icon.png"] selectedImage:[UIImage imageNamed:@"boxedIn-toolbar-icon.png"]];
    gameList.tabBarItem = gameListTabBarItem;
    
    SettingsViewController *settingsPage = [storyboard instantiateViewControllerWithIdentifier:@"settingsViewController"];
    UITabBarItem *settingsPageTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Settings" image:[UIImage imageNamed:@"mind_map-50.png"] selectedImage:[UIImage imageNamed:@"boxedIn-toolbar-icon.png"]];
    settingsPage.tabBarItem = settingsPageTabBarItem;
    
    _tabBarController = [[JDMinimalTabBarController alloc] init];
    [_tabBarController.view setFrame:self.window.frame];
    
    [self.window setRootViewController:_tabBarController];
    
    _tabBarController.minimalBar.defaultTintColor = BIOrange;
    _tabBarController.minimalBar.selectedTintColor = BIDarkGrey;//[UIColor colorWithRed:222.0f/255.f green:157.0f/255.f blue:0.0f/255.f alpha:1.f];
    _tabBarController.minimalBar.showTitles = YES;
    _tabBarController.minimalBar.hidesTitlesWhenSelected = YES;
    _tabBarController.minimalBar.backgroundColor = [UIColor clearColor];
    
    NSArray *vcArray = [[NSArray alloc] initWithObjects:frontPage, gameList, friendList, settingsPage, infoPage, nil];
    [_tabBarController setViewControllers:vcArray];
    
    
    
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current Installation and save it to Parse
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
    [PFUser currentUser][@"installationId"] = currentInstallation.objectId;
    [[PFUser currentUser] saveInBackground];
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    //[PFPush handlePush:userInfo];
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation.badge != 0) {
        currentInstallation.badge = 0;
        [currentInstallation saveEventually];
    }
    
    if (application.applicationState == UIApplicationStateActive) {
        if ([self.window.rootViewController isKindOfClass:[GameBoardViewController class]]) {
            GameBoardViewController *this = (GameBoardViewController*)self.window.rootViewController;
            if ([this.game.objectId isEqualToString:[userInfo objectForKey:@"g"]]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateGameNotification" object:[userInfo objectForKey:@"g"]];
            }
        }
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"You're turn!" message:[userInfo valueForKey:@"message"] preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            // up up
        }]];
        [self.window.rootViewController presentViewController:alert animated:YES completion:^{
            // up up
        }];
    }
    else {
        //NSDictionary *notificationPayload = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
        NSString *objID = [userInfo objectForKey:@"g"];
        PFObject *game = [PFObject objectWithoutDataWithClassName:@"GameBoard" objectId:objID];
        
        [game fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
            if (!error) {
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                GameBoardViewController *gbvc = [storyboard instantiateViewControllerWithIdentifier:@"gameBoardViewController"];
                gbvc.game = object;
                [self.window.rootViewController presentViewController:gbvc animated:YES completion:^{
                    //up up
                }];
            }
        }];
    }
    
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    //return [[FBSDKApplicationDelegate sharedInstance] application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication withSession:[PFFacebookUtils session]];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBSDKAppEvents activateApp];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
