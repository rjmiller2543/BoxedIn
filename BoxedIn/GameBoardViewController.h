//
//  GameBoardViewController.h
//  BoxedIn
//
//  Created by Robert Miller on 11/5/15.
//  Copyright © 2015 Robert Miller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FlatUIKit.h>
#import <Parse.h>

@protocol GameBoardViewControllerDelegate;

@interface GameBoardViewController : UIViewController <UIScrollViewDelegate>

@property(nonatomic,assign) id<GameBoardViewControllerDelegate> delegate;

@property(nonatomic,retain) IBOutlet UILabel *opponentUserLabel;
@property(nonatomic,retain) IBOutlet UILabel *opponentScoreLabel;
@property(nonatomic,retain) IBOutlet UILabel *myUserLabel;
@property(nonatomic,retain) IBOutlet UILabel *myScoreLabel;
@property(nonatomic,retain) IBOutlet UIScrollView *gameBoardView;
@property(nonatomic,retain) IBOutlet UIButton *messageButton;

@property(nonatomic,retain) UITapGestureRecognizer *tapGesture;

@property(nonatomic,retain) PFObject *game;
@property(nonatomic) int gameType;

@property(nonatomic) bool playerOneTurn;

@property(nonatomic,retain) id prevViewController;

-(void)setupGameBoard;
-(void)updateDataPoints;
-(IBAction)openMessenger:(id)sender;

@end

@protocol GameBoardViewControllerDelegate <NSObject>

@optional
-(void)updateGameBoard:(GameBoardViewController*)gameBoard WithData:(NSData*)data;

@end
