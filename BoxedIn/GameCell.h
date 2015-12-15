//
//  GameCell.h
//  BoxedIn
//
//  Created by Robert Miller on 11/6/15.
//  Copyright © 2015 Robert Miller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse.h>

@interface GameCell : UITableViewCell

@property(nonatomic,retain) IBOutlet UIView *containerView;
@property(nonatomic,retain) IBOutlet UILabel *meLabel;
@property(nonatomic,retain) IBOutlet UILabel *youLabel;
@property(nonatomic,retain) IBOutlet UILabel *meScore;
@property(nonatomic,retain) IBOutlet UILabel *youScore;
@property(nonatomic,retain) IBOutlet UIImageView *youLetterView;

@property(nonatomic,retain) PFObject *game;

-(void)setupView;
-(void)setupNoGamesView:(NSString*)message;

@end
