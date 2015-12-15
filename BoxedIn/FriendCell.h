//
//  FriendCell.h
//  BoxedIn
//
//  Created by Robert Miller on 11/6/15.
//  Copyright © 2015 Robert Miller. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendCell : UITableViewCell

@property(nonatomic,retain) IBOutlet UIImageView *imageView;
@property(nonatomic,retain) IBOutlet UILabel *friendLabel;
@property(nonatomic,retain) IBOutlet UILabel *friendScore;

@end
