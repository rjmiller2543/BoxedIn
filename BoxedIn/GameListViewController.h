//
//  GameListViewController.h
//  BoxedIn
//
//  Created by Robert Miller on 11/5/15.
//  Copyright © 2015 Robert Miller. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GameListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property(nonatomic,retain) IBOutlet UITableView *tableView;

@end
