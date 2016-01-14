//
//  NewGameViewController.m
//  BoxedIn
//
//  Created by Robert Miller on 11/5/15.
//  Copyright © 2015 Robert Miller. All rights reserved.
//

#import "NewGameViewController.h"
#import "BoxedInColors.h"
#import "GameBoardViewController.h"
#import "FriendCell.h"
#import <GameKit/GameKit.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "UIImageView+Letters.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "PFObject+Coder.h"
#import <DVITutorialView.h>

@interface NewGameViewController () <MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate, MCSessionDelegate, UITableViewDataSource, UITableViewDelegate, GameBoardViewControllerDelegate>

@property(nonatomic,retain) NSMutableArray *dataSource;
@property(nonatomic,strong,readonly) MCSession *session;
@property(nonatomic,retain) MCNearbyServiceBrowser *serviceBrowser;
@property(nonatomic,retain) MCNearbyServiceAdvertiser *serviceAdvertiser;
@property(nonatomic) BOOL startedGame;
@property(nonatomic) int gameType;
@property(nonatomic,retain) MCPeerID *oppPeerID;
@property(nonatomic) BOOL receivedGame;
@property(nonatomic,retain) GameBoardViewController *gameBoard;
@property(nonatomic,retain) PFUser *oppUser;

@property(nonatomic,retain) UITapGestureRecognizer *tapGesture;
@property(nonatomic) BOOL tutorialComplete;
@property(nonatomic,retain) NSTimer *randomTimer;

@end

@implementation NewGameViewController

#define CANCELTAG   0
#define BACKTAG     1
#define OKTAG       2

#define P2PTAG      0
#define FNDTAG      1

#define LOCALTYPE   0
#define P2PTYPE     1
#define NETTYPE     2
#define FRIENDTYPE  3

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:@"UpdateUserInformation" object:nil];
    
    _cancelButton.tag = CANCELTAG;
    _cancelButton.titleLabel.text = @"";
    [_cancelButton setCurrentButtonStyle:buttonRoundedStyle];
    [_cancelButton setCurrentButtonType:buttonDefaultType];
    _cancelButton.roundBackgroundColor = BIGreen;
    _cancelButton.tintColor = BILightGrey;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_cancelButton animateToType:buttonCloseType];
    });
    
    _gameOptionsView = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width + 45, _p2pButtonYCoordinate, self.view.frame.size.width, self.view.frame.size.height - _p2pButtonYCoordinate)];
    [self.view addSubview:_gameOptionsView];
    [self.view sendSubviewToBack:_gameOptionsView];
    
    UILabel *columnLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, 0, 90, 30)];
    columnLabel.textColor = BIGreen;
    columnLabel.text = @"Columns: ";
    columnLabel.font = [UIFont fontWithName:@"Futura-Medium" size:17.0];
    [_gameOptionsView addSubview:columnLabel];
    
    _columnsTextField = [[FUITextField alloc] initWithFrame:CGRectMake(135, 0, 45, 30)];
    _columnsTextField.keyboardType = UIKeyboardTypeNumberPad;
    _columnsTextField.text = @"10";
    _columnsTextField.textColor = BIGreen;
    [_gameOptionsView addSubview:_columnsTextField];
    
    UIStepper *columnStepper = [[UIStepper alloc] initWithFrame:CGRectMake(90, 35, 45, 30)];
    columnStepper.value = 10;
    [columnStepper addTarget:self action:@selector(changeColumns:) forControlEvents:UIControlEventValueChanged];
    [columnStepper configureFlatStepperWithColor:BIGreen highlightedColor:BILightGrey disabledColor:BIDarkGrey iconColor:BILightGrey];
    [_gameOptionsView addSubview:columnStepper];
    
    UILabel *rowsLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, 70, 90, 30)];
    rowsLabel.textColor = BIGreen;
    rowsLabel.text = @"Rows: ";
    rowsLabel.font = [UIFont fontWithName:@"Futura-Medium" size:17.0];
    [_gameOptionsView addSubview:rowsLabel];
    
    _rowsTextField = [[FUITextField alloc] initWithFrame:CGRectMake(135, 70, 45, 30)];
    _rowsTextField.keyboardType = UIKeyboardTypeNumberPad;
    _rowsTextField.text = @"10";
    _rowsTextField.textColor = BIGreen;
    [_gameOptionsView addSubview:_rowsTextField];
    
    UIStepper *rowStepper = [[UIStepper alloc] initWithFrame:CGRectMake(90, 105, 45, 30)];
    rowStepper.value = 10;
    [rowStepper addTarget:self action:@selector(changeRows:) forControlEvents:UIControlEventValueChanged];
    [rowStepper configureFlatStepperWithColor:BIGreen highlightedColor:BILightGrey disabledColor:BIDarkGrey iconColor:BILightGrey];
    [_gameOptionsView addSubview:rowStepper];
    
    _randomSegment = [[FUISegmentedControl alloc] initWithItems:@[@"Friends", @"Random"]];
    [_randomSegment setFrame:CGRectMake(self.view.frame.size.width + self.view.frame.size.width/2, 30, self.view.frame.size.width * 0.75, 30)];
    [_randomSegment setSelectedColor:BIGreen];
    [_randomSegment setDeselectedColor:BIDarkGrey];
    [_randomSegment setSelectedFontColor:BILightGrey];
    [_randomSegment setDeselectedFontColor:BILightGrey];
    [_randomSegment setDividerColor:BILightGrey];
    [_randomSegment setSelectedSegmentIndex:0];
    [_randomSegment addTarget:self action:@selector(segmentChanged) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_randomSegment];
    
    [_cancelButton setNeedsLayout];
    [_cancelButton layoutIfNeeded];
    
    CGRect frame = _cancelButton.frame;
    frame.origin.x += 30 + self.view.frame.size.width;
    _saveButton = [[VBFPopFlatButton alloc] initWithFrame:frame buttonType:buttonDefaultType buttonStyle:buttonRoundedStyle animateToInitialState:YES];
    _saveButton.roundBackgroundColor = BIGreen;
    _saveButton.tintColor = BILightGrey;
    [_saveButton addTarget:self action:@selector(saveButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    _saveButton.tag = OKTAG;
    [self.view addSubview:_saveButton];
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"FirstTimeNewGame"] boolValue] == false) {
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(startTutorial)];
        [self.view addGestureRecognizer:_tapGesture];
    }
}

-(void)startTutorial {
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"FirstTimeNewGame"] boolValue] == false) {
        if (!_tutorialComplete) {
            DVITutorialView *tutorialView = [[DVITutorialView alloc] init];
            [tutorialView addToView:self.view];
            
            tutorialView.tutorialStrings = @[
                                             @"Tap Here to Play a Game between you and your friend on your phone..",
                                             @"Tap Here to Play a Game between you and someone nearby..",
                                             @"Tap Here to Play a Game between you and any opponent anywhere or to play a random person..",
                                             @"Press this button to cancel your new game :,(",
                                             @"Make your first move!",
                                             ];
            
            tutorialView.tutorialViews = @[
                                           _localButton,
                                           _p2pButton,
                                           _playButton,
                                           _cancelButton,
                                           [[UIView alloc] init],
                                           ];
            
            [tutorialView startWithCompletion:^{
                [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:@"FirstTimeNewGame"];
                _tutorialComplete = true;
                [_tapGesture setEnabled:NO];
            }];
        }
        else {
            [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:@"FirstTimeNewGame"];
            [_tapGesture setEnabled:NO];
        }
    }
    else {
        [_tapGesture setEnabled:NO];
    }
}

-(void)viewDidLayoutSubviews {
    _dataSource = [[NSMutableArray alloc] init];
    //_tableView = [[UITableView alloc] initWithFrame:CGRectMake(self.view.frame.size.width, _p2pButtonYCoordinate, self.view.frame.size.width, self.view.frame.size.height - _p2pButtonYCoordinate)];
    CGRect tbFrame = _tableView.frame;
    tbFrame.origin.x = self.view.frame.size.width;
    tbFrame.size.width = self.view.frame.size.width;
    [_tableView setFrame:tbFrame];
    //[_tableView setHidden:YES];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //[_tableView registerClass:[FriendCell class] forCellReuseIdentifier:@"NewFriendCell"];
    [self.view addSubview:_tableView];
    [self.view sendSubviewToBack:_tableView];
    _tableView.backgroundColor = BILightGrey;
    _tableView.delegate = self;
    _tableView.dataSource = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)playButtonPresed:(id)sender {
    
    float moveHeight = self.view.frame.size.height;
    [_localButton setEnabled:NO];
    [_p2pButton setEnabled:NO];
    [_playButton setEnabled:NO];
    
    _gameType = NETTYPE;
    [UIView animateWithDuration:0.7 animations:^{
        CGRect localButtonRect = _localButton.frame;
        _localButtonYCoordinate = localButtonRect.origin.y;
        localButtonRect.origin.y -= moveHeight;
        [_localButton setFrame:localButtonRect];
        
        CGRect localLabelRect = _localLabel.frame;
        _localLabelYCoordinate = localLabelRect.origin.y;
        localLabelRect.origin.y -= moveHeight;
        [_localLabel setFrame:localLabelRect];
        
        CGRect p2pButtonRect = _p2pButton.frame;
        _p2pButtonYCoordinate = p2pButtonRect.origin.y;
        p2pButtonRect.origin.y -= moveHeight;
        [_p2pButton setFrame:p2pButtonRect];
        
        CGRect p2pLabelRect = _p2pLabel.frame;
        _p2pLabelYCoordinate = p2pLabelRect.origin.y;
        p2pLabelRect.origin.y -= moveHeight;
        [_p2pLabel setFrame:p2pLabelRect];
        
        CGRect playButtonRect = _playButton.frame;
        _playButtonYCoordinate = playButtonRect.origin.y;
        playButtonRect.origin.y = _localButtonYCoordinate;
        [_playButton setFrame:playButtonRect];
        
        CGRect playLabelRect = _playLabel.frame;
        _playLabelYCoordinate = playLabelRect.origin.y;
        playLabelRect.origin.y = _localLabelYCoordinate;
        [_playLabel setFrame:playLabelRect];
        
        CGRect randomSegmentRect = _randomSegment.frame;
        randomSegmentRect.origin.x = self.view.frame.size.width/2 - _randomSegment.frame.size.width/2;
        [_randomSegment setFrame:randomSegmentRect];
        
        _cancelButtonXCoordinate = _cancelButton.frame.origin.x;
        [_cancelButton animateToType:buttonBackType];
        _cancelButton.tag = BACKTAG;
    }];
    [self displayTableViewForFriendList];
}

-(void)localButtonPressed:(id)sender {
    float moveHeight = self.view.frame.size.height;
    
    _gameType = LOCALTYPE;
    [UIView animateWithDuration:0.7 animations:^{
        CGRect localButtonRect = _localButton.frame;
        _localButtonYCoordinate = localButtonRect.origin.y;
        //localButtonRect.origin.y -= moveHeight;
        //[_localButton setFrame:localButtonRect];
        
        CGRect localLabelRect = _localLabel.frame;
        _localLabelYCoordinate = localLabelRect.origin.y;
        //localLabelRect.origin.y -= moveHeight;
        //[_localLabel setFrame:localLabelRect];
        
        CGRect p2pButtonRect = _p2pButton.frame;
        _p2pButtonYCoordinate = p2pButtonRect.origin.y;
        p2pButtonRect.origin.y += moveHeight;
        [_p2pButton setFrame:p2pButtonRect];
        
        CGRect p2pLabelRect = _p2pLabel.frame;
        _p2pLabelYCoordinate = p2pLabelRect.origin.y;
        p2pLabelRect.origin.y += moveHeight;
        [_p2pLabel setFrame:p2pLabelRect];
        
        CGRect playButtonRect = _playButton.frame;
        _playButtonYCoordinate = playButtonRect.origin.y;
        playButtonRect.origin.y += moveHeight;
        [_playButton setFrame:playButtonRect];
        
        CGRect playLabelRect = _playLabel.frame;
        _playLabelYCoordinate = playLabelRect.origin.y;
        playLabelRect.origin.y += moveHeight;
        [_playLabel setFrame:playLabelRect];
        
    }];
    
    [self displayGameOptions];
}

-(void)p2pButtonPressed:(id)sender {
    float moveHeight = self.view.frame.size.height;
    _gameType = P2PTYPE;
    [UIView animateWithDuration:0.7 animations:^{
        CGRect localButtonRect = _localButton.frame;
        _localButtonYCoordinate = localButtonRect.origin.y;
        localButtonRect.origin.y -= moveHeight;
        [_localButton setFrame:localButtonRect];
        
        CGRect localLabelRect = _localLabel.frame;
        _localLabelYCoordinate = localLabelRect.origin.y;
        localLabelRect.origin.y -= moveHeight;
        [_localLabel setFrame:localLabelRect];
        
        CGRect p2pButtonRect = _p2pButton.frame;
        _p2pButtonYCoordinate = p2pButtonRect.origin.y;
        p2pButtonRect.origin.y = _localButtonYCoordinate;
        [_p2pButton setFrame:p2pButtonRect];
        
        CGRect p2pLabelRect = _p2pLabel.frame;
        _p2pLabelYCoordinate = p2pLabelRect.origin.y;
        p2pLabelRect.origin.y = _localLabelYCoordinate;
        [_p2pLabel setFrame:p2pLabelRect];
        
        CGRect playButtonRect = _playButton.frame;
        _playButtonYCoordinate = playButtonRect.origin.y;
        playButtonRect.origin.y += moveHeight;
        [_playButton setFrame:playButtonRect];
        
        CGRect playLabelRect = _playLabel.frame;
        _playLabelYCoordinate = playLabelRect.origin.y;
        playLabelRect.origin.y += moveHeight;
        [_playLabel setFrame:playLabelRect];
        
        _cancelButtonXCoordinate = _cancelButton.frame.origin.x;
        [_cancelButton animateToType:buttonBackType];
        _cancelButton.tag = BACKTAG;
        
    }];
    [self displayTableViewForGameKit];
    
}

-(void)cancelButtonPressed:(id)sender {
    
    UIButton *button = (UIButton*)sender;
    switch (button.tag) {
        case CANCELTAG:
            [self dismissViewControllerAnimated:YES completion:^{
                //up up
                [SVProgressHUD dismiss];
            }];
            break;
        case BACKTAG:
            [self moveBackToFrames];
            break;
        case OKTAG:
            [self createGameBoard];
            break;
            
        default:
            break;
    }
    
}

-(void)saveButtonPressed:(id)sender {
    [self createGameBoard];
}

-(void)createGameBoard {
    
    //create game
    PFObject *game = [PFObject objectWithClassName:@"GameBoard"];
    game[@"NumberRows"] = [NSNumber numberWithInt:[_rowsTextField.text intValue]];
    game[@"NumberCols"] = [NSNumber numberWithInt:[_columnsTextField.text intValue]];
    game[@"PlayerOne"] = [PFUser currentUser];
    
    switch (_gameType) {
        case LOCALTYPE: {
            //do nothing, we're ready to ship
            //create the game board
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            _gameBoard = [storyboard instantiateViewControllerWithIdentifier:@"gameBoardViewController"];
            _gameBoard.game = game;
            _gameBoard.prevViewController = self;
            
            //[gameBoard setupGameBoard];
            [self presentViewController:_gameBoard animated:YES completion:^{
                NSLog(@"game board presented");
            }];
            break;
        }
        case P2PTYPE: {
            _receivedGame = true;
            //setup the second player from the table cell index
            //send the game objectID over the peer network for the other user to d/l over parse
            [SVProgressHUD showInfoWithStatus:@"Setting up and sending.."];
            NSUInteger row = [_tableView indexPathForSelectedRow].row;
            _oppPeerID = [_dataSource objectAtIndex:row];
            NSString *userName = _oppPeerID.displayName;
            //PFQuery *query = [PFUser query];
            //[query whereKey:@"username" equalTo:userName];
            //[query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                //PFUser *otherUser = [objects objectAtIndex:0];
                //game[@"PlayerTwo"] = otherUser;
            //temp user
            PFUser *otherUser = [PFUser new];
            otherUser.username = _oppPeerID.displayName;
            game[@"PlayerTwo"] = otherUser;
            game[@"completed"] = @NO;
                game[@"playerOneTurn"] = @YES;
                //NSString *gameID = game.objectId;
                NSData *data = [NSKeyedArchiver archivedDataWithRootObject:game];
                PFObject *test = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            NSError *error = nil;
                [_session sendData:data toPeers:@[_oppPeerID] withMode:MCSessionSendDataReliable error:&error];
                
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                _gameBoard = [storyboard instantiateViewControllerWithIdentifier:@"gameBoardViewController"];
                _gameBoard.game = game;
                _gameBoard.prevViewController = self;
            _gameBoard.gameType = P2PTYPE;
                _gameBoard.delegate = self;
                
                //[gameBoard setupGameBoard];
                [self presentViewController:_gameBoard animated:YES completion:^{
                    [SVProgressHUD dismiss];
                    NSLog(@"game board presented");
                }];
            //}];
                        
            break;
        }
        case NETTYPE: {
            //setup the second player from the table cell index
            //create the game and send a notification over parse network for other user to d/l over parse
            NSInteger index = [_tableView indexPathForSelectedRow].row;
            PFUser *user = [_dataSource objectAtIndex:index];
            game[@"PlayerTwo"] = user;
            game[@"playerOneTurn"] = @YES;
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            _gameBoard = [storyboard instantiateViewControllerWithIdentifier:@"gameBoardViewController"];
            _gameBoard.game = game;
            _gameBoard.prevViewController = self;
            _gameBoard.gameType = NETTYPE;
            game[@"gameType"] = @NETTYPE;
            _gameBoard.delegate = self;
            
            //[gameBoard setupGameBoard];
            [self presentViewController:_gameBoard animated:YES completion:^{
                [SVProgressHUD dismiss];
                NSLog(@"game board presented");
            }];
            break;
        }
        case FRIENDTYPE: {
            game[@"PlayerTwo"] = _oppUser;
            game[@"playerOneTurn"] = @YES;
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            _gameBoard = [storyboard instantiateViewControllerWithIdentifier:@"gameBoardViewController"];
            _gameBoard.game = game;
            _gameBoard.prevViewController = self;
            _gameBoard.gameType = NETTYPE;
            game[@"gameType"] = @NETTYPE;
            _gameBoard.delegate = self;
            
            //[gameBoard setupGameBoard];
            [self presentViewController:_gameBoard animated:YES completion:^{
                [SVProgressHUD dismiss];
                NSLog(@"game board presented");
            }];
            break;
        }
            
            
        default:
            break;
    }
    
}


#pragma mark - moving frames and animations

-(void)moveBackToFrames {
    
    [self removeGameOptions];
    [self removeTableViewFromView];
    [_localButton setEnabled:YES];
    [_p2pButton setEnabled:YES];
    [_playButton setEnabled:YES];
    [SVProgressHUD dismiss];
    
    [[PFUser currentUser] setObject:@NO forKey:@"random"];
    [[PFUser currentUser] saveInBackground];
    
    [UIView animateWithDuration:0.7 animations:^{
        CGRect localButtonRect = _localButton.frame;
        //_localButtonYCoordinate = localButtonRect.origin.y;
        localButtonRect.origin.y = _localButtonYCoordinate;
        [_localButton setFrame:localButtonRect];
        
        CGRect localLabelRect = _localLabel.frame;
       // _localLabelYCoordinate = localLabelRect.origin.y;
        localLabelRect.origin.y = _localLabelYCoordinate;
        [_localLabel setFrame:localLabelRect];
        
        CGRect p2pButtonRect = _p2pButton.frame;
        //_p2pButtonYCoordinate = p2pButtonRect.origin.y;
        p2pButtonRect.origin.y = _p2pButtonYCoordinate;
        [_p2pButton setFrame:p2pButtonRect];
        
        CGRect p2pLabelRect = _p2pLabel.frame;
        //_p2pLabelYCoordinate = p2pLabelRect.origin.y;
        p2pLabelRect.origin.y = _p2pLabelYCoordinate;
        [_p2pLabel setFrame:p2pLabelRect];
        
        CGRect playButtonRect = _playButton.frame;
        //_playButtonYCoordinate = playButtonRect.origin.y;
        playButtonRect.origin.y = _playButtonYCoordinate;
        [_playButton setFrame:playButtonRect];
        
        CGRect playLabelRect = _playLabel.frame;
        //_playLabelYCoordinate = playLabelRect.origin.y;
        playLabelRect.origin.y = _playLabelYCoordinate;
        [_playLabel setFrame:playLabelRect];
        
        CGRect cancelButtonRect = _cancelButton.frame;
        cancelButtonRect.origin.x = _cancelButtonXCoordinate;
        [_cancelButton setFrame:cancelButtonRect];
        [_cancelButton animateToType:buttonCloseType];
        _cancelButton.tag = CANCELTAG;
        
        CGRect randomSegmentRect = _randomSegment.frame;
        randomSegmentRect.origin.x = self.view.frame.size.width + self.view.frame.size.width/2;
        [_randomSegment setFrame:randomSegmentRect];
        
        if (_saveButton.frame.origin.x < self.view.frame.size.width) {
            CGRect saveButtonRect = _saveButton.frame;
            saveButtonRect.origin.x += self.view.frame.size.width;
            [_saveButton setFrame:saveButtonRect];
        }
        
    }];
}


#pragma mark - Game Options

-(void)removeGameOptions {
    
    [UIView animateWithDuration:0.7 animations:^{
        CGRect frame = _gameOptionsView.frame;
        frame.origin.x = self.view.frame.size.width + 45;
        [_gameOptionsView setFrame:frame];
    } completion:^(BOOL finished) {
        //for (__strong UIView *subview in _gameOptionsView.subviews) {
        //    subview = nil;
        //}
        //_gameOptionsView = nil;
    }];
    
}

-(void)displayGameOptions {
    
    [[PFUser currentUser] setObject:@NO forKey:@"random"];
    [[PFUser currentUser] saveInBackground];
    
    [_randomTimer invalidate];
    
    CGRect yCorrectFrame = _gameOptionsView.frame;
    yCorrectFrame.origin.y = _p2pButtonYCoordinate;
    [_gameOptionsView setFrame:yCorrectFrame];
    [UIView animateWithDuration:0.7 animations:^{
        CGRect frame = _gameOptionsView.frame;
        frame.origin.x = 0;
        [_gameOptionsView setFrame:frame];
        
        CGRect cancelButtonRect = _cancelButton.frame;
        _cancelButtonXCoordinate = _cancelButton.frame.origin.x;
        cancelButtonRect.origin.x -= 30;
        [_cancelButton setFrame:cancelButtonRect];
        [_cancelButton animateToType:buttonBackType];
        _cancelButton.tag = BACKTAG;
        
        CGRect saveButtonRect = _saveButton.frame;
        saveButtonRect.origin.x -= self.view.frame.size.width;
        [_saveButton setFrame:saveButtonRect];
        [_saveButton animateToType:buttonOkType];
        
        [SVProgressHUD dismiss];
    }];
    
}

-(void)changeColumns:(id)sender {
    UIStepper *stepper = (UIStepper*)sender;
    if (stepper.value < 5) {
        stepper.value = 5;
    }
    else if (stepper.value > 25) {
        stepper.value = 25;
    }
    _columnsTextField.text = [[NSNumber numberWithInt:stepper.value] stringValue];
}

-(void)changeRows:(id)sender {
    UIStepper *stepper = (UIStepper*)sender;
    if (stepper.value < 5) {
        stepper.value = 5;
    }
    else if (stepper.value > 25) {
        stepper.value = 25;
    }
    _rowsTextField.text = [[NSNumber numberWithInt:stepper.value] stringValue];
}


#pragma mark - Friend List Handlers

-(void)displayTableViewForFriendList {
    CGRect yCorrectFrame = _tableView.frame;
    yCorrectFrame.origin.y = _p2pButtonYCoordinate;
    yCorrectFrame.size.height = self.view.frame.size.height - _p2pButtonYCoordinate;
    [_tableView setFrame:yCorrectFrame];
    _tableView.tag = NETTYPE;
    [_tableView setHidden:NO];
    //get the data for friend list
#warning SETUP FRIEND DATA SOURCE
    [UIView animateWithDuration:0.7 animations:^{
        CGRect frame = _tableView.frame;
        frame.origin.x = 0;
        [_tableView setFrame:frame];
    }];
    
    PFUser *currUser = [PFUser currentUser];
    NSArray *array = [[NSArray alloc] initWithArray:currUser[@"friendsList"]];
    
    PFQuery *query = [PFUser query];
    [query whereKey:@"objectId" containedIn:array];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        [_dataSource addObjectsFromArray:objects];
        [_tableView reloadData];
    }];
}

-(void)segmentChanged {
    if ([_randomSegment selectedSegmentIndex] == 0) {
        [[PFUser currentUser] setObject:@NO forKey:@"random"];
        [[PFUser currentUser] saveInBackground];
        
        PFUser *currUser = [PFUser currentUser];
        NSArray *array = [[NSArray alloc] initWithArray:currUser[@"friendsList"]];
        
        PFQuery *query = [PFUser query];
        [query whereKey:@"objectId" containedIn:array];
        [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            [_dataSource removeAllObjects];
            [_dataSource addObjectsFromArray:objects];
            [_tableView reloadData];
        }];
        [_randomTimer invalidate];
    }
    else if ([_randomSegment selectedSegmentIndex] == 1) {
        PFQuery *query = [PFUser query];
        [query whereKey:@"random" equalTo:@YES];
        [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            [_dataSource removeAllObjects];
            [_dataSource addObjectsFromArray:objects];
            [_tableView reloadData];
            
            [[PFUser currentUser] setObject:@YES forKey:@"random"];
            [[PFUser currentUser] saveInBackground];
            _randomTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(updateRandom) userInfo:NULL repeats:YES];
        }];
    }
}

-(void)updateRandom {
    PFQuery *query = [PFUser query];
    [query whereKey:@"random" equalTo:@YES];
    [query whereKey:@"objectId" notEqualTo:[PFUser currentUser].objectId];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        [_dataSource removeAllObjects];
        [_dataSource addObjectsFromArray:objects];
        [_tableView reloadData];
    }];
}

-(void)setupFriendGame:(PFUser*)user {
    
    _oppUser = user;
    
    float moveHeight = self.view.frame.size.height;
    
    _gameType = FRIENDTYPE;
    [UIView animateWithDuration:0.7 animations:^{
        CGRect localButtonRect = _localButton.frame;
        _localButtonYCoordinate = localButtonRect.origin.y;
        //localButtonRect.origin.y -= moveHeight;
        //[_localButton setFrame:localButtonRect];
        
        CGRect localLabelRect = _localLabel.frame;
        _localLabelYCoordinate = localLabelRect.origin.y;
        //localLabelRect.origin.y -= moveHeight;
        //[_localLabel setFrame:localLabelRect];
        
        CGRect p2pButtonRect = _p2pButton.frame;
        _p2pButtonYCoordinate = p2pButtonRect.origin.y;
        p2pButtonRect.origin.y += moveHeight;
        [_p2pButton setFrame:p2pButtonRect];
        
        CGRect p2pLabelRect = _p2pLabel.frame;
        _p2pLabelYCoordinate = p2pLabelRect.origin.y;
        p2pLabelRect.origin.y += moveHeight;
        [_p2pLabel setFrame:p2pLabelRect];
        
        CGRect playButtonRect = _playButton.frame;
        _playButtonYCoordinate = playButtonRect.origin.y;
        playButtonRect.origin.y += moveHeight;
        [_playButton setFrame:playButtonRect];
        
        CGRect playLabelRect = _playLabel.frame;
        _playLabelYCoordinate = playLabelRect.origin.y;
        playLabelRect.origin.y += moveHeight;
        [_playLabel setFrame:playLabelRect];
        
    }];
    
    [self displayGameOptions];
}

#pragma mark - Peer to Peer Handlers

-(void)displayTableViewForGameKit {
    
    CGRect yCorrectFrame = _tableView.frame;
    yCorrectFrame.origin.y = _p2pButtonYCoordinate;
    yCorrectFrame.size.height = self.view.frame.size.height - _p2pButtonYCoordinate;
    [_tableView setFrame:yCorrectFrame];
    _tableView.tag = P2PTAG;
    [_tableView setHidden:NO];
    //get the data for game kit
#warning SETUP GAME KIT DATA SOURCE
    NSString *serviceType = @"Boxed-In-Game";
    
    MCPeerID *peerId = [[MCPeerID alloc] initWithDisplayName:[PFUser currentUser].username];
    _session = [[MCSession alloc] initWithPeer:peerId];
    _session.delegate = self;
    
    _serviceAdvertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:peerId discoveryInfo:nil serviceType:serviceType];
    _serviceAdvertiser.delegate = self;
    [_serviceAdvertiser startAdvertisingPeer];
    
    _serviceBrowser = [[MCNearbyServiceBrowser alloc] initWithPeer:peerId serviceType:serviceType];
    _serviceBrowser.delegate = self;
    [_serviceBrowser startBrowsingForPeers];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD showWithStatus:@"Looking for nearby friends to play.."];
    });
    
    [UIView animateWithDuration:0.7 animations:^{
        CGRect frame = _tableView.frame;
        frame.origin.x = 0;
        [_tableView setFrame:frame];
    }];
}

-(void)updateGameBoard:(GameBoardViewController *)gameBoard WithData:(NSData *)data {
    PFObject *game = gameBoard.game;
    PFObject *sentData = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    game[@"coordinates"] = sentData[@"coordinates"];
    game[@"PlayerOneBoxes"] = sentData[@"PlayerOneBoxes"];
    game[@"PlayerTwoBoxes"] = sentData[@"PlayerTwoBoxes"];
    game[@"playerOneTurn"] = sentData[@"playerOneTurn"];
    game[@"completed"] = sentData[@"completed"];
    gameBoard.game = game;
}

-(void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void (^)(BOOL, MCSession * _Nonnull))invitationHandler {
    //give a popup with option to accept or decline the invite
    NSString *invitation = [NSString stringWithFormat:@"%@ invited you to play a game with them", peerID.displayName];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Game Invitation!" message:invitation preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Accept" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //wait to get the game from the other user
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showWithStatus:@"Waiting for game to start.."];
        });
        //[_serviceBrowser stopBrowsingForPeers];
        //[_serviceAdvertiser stopAdvertisingPeer];
        _startedGame = false;
        _receivedGame = false;
        invitationHandler(YES, _session);
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Decline" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //do nothing i guess
    }]];
    [self presentViewController:alert animated:YES completion:^{
        // up up
    }];
}

-(void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary<NSString *,NSString *> *)info {
    [SVProgressHUD dismiss];
    [_dataSource addObject:peerID];
    [_tableView reloadData];
}

-(void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID {
    for (MCPeerID *peer in _dataSource) {
        [peer isEqual:peerID];
        [_dataSource removeObject:peer];
    }
    [_tableView reloadData];
}

-(void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID {
    if (_receivedGame == false) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _receivedGame = true;
            PFObject *game = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            _gameBoard = [storyboard instantiateViewControllerWithIdentifier:@"gameBoardViewController"];
            _gameBoard.game = game;
            _gameBoard.game[@"PlayerTwo"] = [PFUser currentUser];
            _gameBoard.delegate = self;
            _gameBoard.gameType = P2PTYPE;
            _gameBoard.prevViewController = self;
            
            [self presentViewController:_gameBoard animated:YES completion:^{
                // up up
            }];
        });
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateGameBoard:_gameBoard WithData:data];
            [_gameBoard updateDataPoints];
        });
    }
    
}

-(void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state {
    switch (state) {
        case MCSessionStateConnecting: {
            //[_serviceBrowser stopBrowsingForPeers];
            //[_serviceAdvertiser stopAdvertisingPeer];
            //NSData *data = [NSKeyedArchiver archivedDataWithRootObject:@"Connect"];
            //[session connectPeer:peerID withNearbyConnectionData:data];
            //[self moveTableView];
            //[self displayGameOptions];
            //if (_startedGame == true) {
            //    [SVProgressHUD dismiss];
            //    NSLog(@"peer %@ is connect", peerID.displayName);
            //    [self moveTableView];
            //    [self displayGameOptions];
            //}
            break;
        }
        case MCSessionStateConnected: {
            [_serviceAdvertiser stopAdvertisingPeer];
            [_serviceBrowser stopBrowsingForPeers];
            if (_startedGame == true) {
                [SVProgressHUD showSuccessWithStatus:@"Connected!"];
                [SVProgressHUD showWithStatus:@"Starting Game..."];
                NSLog(@"peer %@ is connect", peerID.displayName);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self moveTableView];
                    [self displayGameOptions];
                });
                
            }
            
            break;
        }
            
        default:
            break;
    }
}

-(void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress {
    
}

-(void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error {
    
}

-(void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID {
    
}

-(void)session:(MCSession *)session didReceiveCertificate:(NSArray *)certificate fromPeer:(MCPeerID *)peerID certificateHandler:(void (^)(BOOL))certificateHandler {
    _oppPeerID = peerID;
    certificateHandler(YES);
}

-(void)sendGameData:(NSData*)data {
    NSError *error = nil;
    [_session sendData:data toPeers:@[_oppPeerID] withMode:MCSessionSendDataReliable error:&error];
}


#pragma mark - Table View Delegate

-(void)removeTableViewFromView {
    
    [UIView animateWithDuration:0.7 animations:^{
        CGRect frame = _tableView.frame;
        frame.origin.x = self.view.frame.size.width;
        [_tableView setFrame:frame];
    }];
    
}

-(void)moveTableView {
    
    [UIView animateWithDuration:0.7 animations:^{
        CGRect frame = _tableView.frame;
        frame.origin.x = -1 * self.view.frame.size.width;
        [_tableView setFrame:frame];
    }];
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (_tableView.tag) {
        case P2PTAG: {
            //PFObject *game = [PFObject objectWithClassName:@"GameBoard"];
            [SVProgressHUD showInfoWithStatus:@"Connecting..."];
            [_serviceBrowser invitePeer:[_dataSource objectAtIndex:indexPath.row] toSession:_session withContext:nil timeout:30.0f];
            _startedGame = true;
            break;
        }
        case NETTYPE: {
#warning ADD HANDLER FOR SELECTING NEW FRIEND
            _startedGame = true;
            [self moveTableView];
            [self displayGameOptions];
            break;
        }
            
        default:
            break;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 94;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FriendCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"FriendCell"];
    
    if (_tableView.tag == P2PTAG) {
        MCPeerID *peerID = [_dataSource objectAtIndex:indexPath.row];
        cell.friendLabel.text = peerID.displayName;
        [cell.imageView setImageWithString:@"P" color:BIDarkGrey];
    }
    if (_tableView.tag == NETTYPE) {
        PFUser *user = [_dataSource objectAtIndex:indexPath.row];
        cell.friendLabel.text = user.username;
        [cell.imageView setImageWithString:@"P" color:BIDarkGrey];
    }
    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataSource.count;
}

-(void)receiveNotification:(NSNotification*)notification {
    if ([[notification name] isEqualToString:@"UpdateUserInformation"]) {
        [[PFUser currentUser] fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
            //up up
        }];
    }
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
