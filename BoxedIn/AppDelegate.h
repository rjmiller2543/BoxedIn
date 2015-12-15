//
//  AppDelegate.h
//  BoxedIn
//
//  Created by Robert Miller on 10/19/15.
//  Copyright (c) 2015 Robert Miller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property(nonatomic,retain) PFUser *parseUser;

+(id)sharedInstance;

@end

