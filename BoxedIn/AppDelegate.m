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

@interface AppDelegate ()

@property(nonatomic,retain) JDMinimalTabBarController *tabBarController;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Override point for customization after application launch.
    //self.window.backgroundColor = [UIColor blackColor];
    [self.window makeKeyAndVisible];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    
    ViewController *frontPage = [storyboard instantiateViewControllerWithIdentifier:@"frontPageViewController"];
    //ViewController *frontPage = [[ViewController alloc] init];
    //[frontPage.view setFrame:self.window.frame];
    //frontPage.view.backgroundColor = BILightGrey;
    NSLog(@"size in app delegate: %f x %f", frontPage.view.frame.size.width, frontPage.view.frame.size.height);
    UITabBarItem *frontPageTabBarItem = [[UITabBarItem alloc] initWithTitle:@"boxedIn" image:[UIImage imageNamed: @"boxedIn-app-icon-50-with-alpha.png"] selectedImage:[UIImage imageNamed:@"boxedIn-app-icon-50-with-alpha.png"]];
    frontPage.tabBarItem = frontPageTabBarItem;
    
    FriendListViewController *friendList = [storyboard instantiateViewControllerWithIdentifier:@"friendListViewController"];
    //FriendListViewController *friendList = [[FriendListViewController alloc] init];
    //[friendList.view setFrame:self.window.frame];
    //friendList.view.backgroundColor = BILightGrey;
    UITabBarItem *friendListTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Friends" image:[UIImage imageNamed:@"group-50.png"] selectedImage:[UIImage imageNamed:@"boxedIn-app-icon-50-with-alpha.png"]];
    friendList.tabBarItem = friendListTabBarItem;
    
    InfoPageViewController *infoPage = [storyboard instantiateViewControllerWithIdentifier:@"infoPageViewController"];
    //InfoPageViewController *infoPage = [[InfoPageViewController alloc] init];
    //[infoPage.view setFrame:self.window.frame];
    //infoPage.view.backgroundColor = BIDarkGrey;
    UITabBarItem *infoPageTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Info" image:[UIImage imageNamed:@"about-50.png"] selectedImage:[UIImage imageNamed:@"boxedIn-app-icon-50-with-alpha.png"]];
    infoPage.tabBarItem = infoPageTabBarItem;
    
    GameListViewController *gameList = [storyboard instantiateViewControllerWithIdentifier:@"gameListViewController"];
    //GameListViewController *gameList = [[GameListViewController alloc] init];
    //[gameList.view setFrame:self.window.frame];
    //gameList.view.backgroundColor = BIGreen;
    UITabBarItem *gameListTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Games" image:[UIImage imageNamed:@"play-button-icon-50.png"] selectedImage:[UIImage imageNamed:@"boxedIn-app-icon-50-with-alpha.png"]];
    gameList.tabBarItem = gameListTabBarItem;
    
    SettingsViewController *settingsPage = [storyboard instantiateViewControllerWithIdentifier:@"settingsViewController"];
    //SettingsViewController *settingsPage = [[SettingsViewController alloc] init];
    //[settingsPage.view setFrame:self.window.frame];
    //settingsPage.view.backgroundColor = BIOrange;
    UITabBarItem *settingsPageTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Settings" image:[UIImage imageNamed:@"mind_map-50.png"] selectedImage:[UIImage imageNamed:@"boxedIn-app-icon-50-with-alpha.png"]];
    settingsPage.tabBarItem = settingsPageTabBarItem;
    
    _tabBarController = [[JDMinimalTabBarController alloc] init];
    
    [self.window addSubview:frontPage.view];
    [self.window addSubview:infoPage.view];
    [self.window addSubview:settingsPage.view];
    [self.window addSubview:friendList.view];
    [self.window addSubview:gameList.view];
    [self.window setRootViewController:_tabBarController];
    
    _tabBarController.minimalBar.defaultTintColor = BIGreen;
    _tabBarController.minimalBar.selectedTintColor = BIDarkGrey;//[UIColor colorWithRed:222.0f/255.f green:157.0f/255.f blue:0.0f/255.f alpha:1.f];
    _tabBarController.minimalBar.showTitles = YES;
    _tabBarController.minimalBar.hidesTitlesWhenSelected = YES;
    _tabBarController.minimalBar.backgroundColor = [UIColor clearColor];
    [_tabBarController setViewControllers:@[infoPage, frontPage, settingsPage, friendList, gameList]];
    
    return YES;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
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
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
