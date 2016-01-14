//
//  GameBoardViewController.m
//  BoxedIn
//
//  Created by Robert Miller on 11/5/15.
//  Copyright © 2015 Robert Miller. All rights reserved.
//

#import "GameBoardViewController.h"
#import "BoxedInColors.h"
#import "GBButton.h"
#import <VBFPopFlatButton/VBFPopFlatButton.h>
#import <SSUIViewMiniMe.h>
#import "UIImageView+Letters.h"
#import "NewGameViewController.h"
#import <SVProgressHUD.h>
#import <iAd/iAd.h>
#import "MessagesViewController.h"
#import <DVITutorialView.h>

@interface GameBoardViewController () <MessagesViewControllerDelegate>

@property(nonatomic,retain) NSString *playerOneLetter;
@property(nonatomic,retain) NSString *playerTwoLetter;

@property(nonatomic,retain) VBFPopFlatButton *playBoxButton;
//@property(nonatomic,retain) VBFPopFlatButton *messageButton;
@property(nonatomic,retain) GBButton *currentButton;

@property(nonatomic,retain) UIView *containerView;
@property(nonatomic,retain) SSUIViewMiniMe *miniContainer;
@property(nonatomic) BOOL hideMini;

@property(nonatomic) int totalMovesRemaining;

@property(nonatomic,retain) NSMutableArray *coordinates;
@property(nonatomic,retain) NSMutableArray *playerOneBoxes;
@property(nonatomic,retain) NSMutableArray *playerTwoBoxes;

@property(nonatomic,retain) PFUser *oppUser;

@property(nonatomic) BOOL tutorialComplete;

-(void)centerScrollViewContents;

@end

#define DOTSPACE            90.0f
#define LINEHJUST           15.0f
#define LINEVJUST           0.0f
#define DOTSIZE             30.0f
#define LINELNGTH           90.0f
#define LINEWIDTH           30.0f

#define LINE_PICKED         true
#define LINE_NOT_PICKED     false

#define HORIZONTAL          0
#define VERTICAL            1

#define CLOSETAG            0
#define PLAYTAG             1

#define BUTTONTAG(i,j,HV,rows)   (2*(i*(rows+1))+2*j+HV)
#define DOTTAG              0x8000

#define LOCALTYPE   0
#define P2PTYPE     1
#define NETTYPE     2

@implementation GameBoardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:@"UpdateGameNotification" object:nil];
    
    [self setInterstitialPresentationPolicy:ADInterstitialPresentationPolicyManual];
    [UIViewController prepareInterstitialAds];
    
    [SVProgressHUD showWithStatus:@"Updating Game Board.."];
    //[_game fetchInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
    //    [self updateDataPoints];
    //}];
    //[_game fetchInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
    //    _game = object;
    //    [self updateDataPoints];
    //}];
    //PFQuery *query = [PFQuery queryWithClassName:@"GameBoard"];
    //[query whereKey:@"objectId" equalTo:_game.objectId];
    //[query getObjectInBackgroundWithId:_game.objectId block:^(PFObject * _Nullable object, NSError * _Nullable error) {
    //    _game = object;
    //    [self updateDataPoints];
    //}];
    //[_game unpin];
    //[_game fetchInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
    //    _game = object;
    //    [self updateDataPoints];
    //}];
    
    [self.navigationController.navigationBar configureFlatNavigationBarWithColor:BIGreen];
    BOOL goodArray = true;
    
    //_tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(screenTapped:)];
    //[_containerView addGestureRecognizer:_tapGesture];
    
    _playerOneBoxes = [[NSMutableArray alloc] init];
    _playerTwoBoxes = [[NSMutableArray alloc] init];
    _coordinates = [[NSMutableArray alloc] init];
    
    _playerOneTurn = true;
    _opponentScoreLabel.backgroundColor = BILightGrey;
    _opponentScoreLabel.textColor = BIGreen;
    _opponentUserLabel.backgroundColor = BILightGrey;
    _opponentUserLabel.textColor = BIGreen;
    _myScoreLabel.backgroundColor = BIPurple;
    _myScoreLabel.textColor = BIOrange;
    _myUserLabel.backgroundColor = BIPurple;
    _myUserLabel.textColor = BIOrange;
    
    
    if (_game != nil) {
        if (_gameType == nil) {
            _gameType = [_game[@"gameType"] intValue];
        }
        
        int rows = [_game[@"NumberRows"] intValue];
        int cols = [_game[@"NumberCols"] intValue];
        _totalMovesRemaining = 0;
        
        PFUser *userOne = _game[@"PlayerOne"];
        PFUser *userTwo = _game[@"PlayerTwo"];
        
        NSString *opponentLabel = @"@";
        opponentLabel = [opponentLabel stringByAppendingString:userOne.username];
        const unichar this = [opponentLabel characterAtIndex:1];
        _playerOneLetter = [NSString stringWithCharacters:&this length:1];
        _opponentUserLabel.text = opponentLabel;
        if (_game[@"PlayerTwo"] == nil) {
            _myUserLabel.text = @"@PlayerTwo";
            const unichar that = [_myUserLabel.text characterAtIndex:1];
            _playerTwoLetter = [NSString stringWithCharacters:&that length:1];
        }
        else {
            NSString *mylabel = @"@";
            _myUserLabel.text = [mylabel stringByAppendingString:userTwo.username];
            const unichar that = [_myUserLabel.text characterAtIndex:1];
            _playerTwoLetter = [NSString stringWithCharacters:&that length:1];
        }
        //NSString *oppScoreText = [_game[@"playerOneBoxes"] stringValue];
        //NSArray *pOneBoxes = _game[@"playerOneBoxes"];
        //if (oppScoreText == nil) {
        //    _opponentScoreLabel.text = @"0";
        //}
        //else {
        //    _opponentScoreLabel.text = oppScoreText;
        //}
        
        @try {
            PFFile *playerOneBoxesFile = _game[@"PlayerOneBoxes"];
            NSData *data = [playerOneBoxesFile getData];
            _playerOneBoxes = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        }
        @catch (NSException *exception) {
            //_playerOneBoxes = nil;
        }
        @finally {
            // up up
        }
        
        @try {
            PFFile *playerTwoBoxesFile = _game[@"PlayerTwoBoxes"];
            NSData *twoData = [playerTwoBoxesFile getData];
            _playerTwoBoxes = [NSKeyedUnarchiver unarchiveObjectWithData:twoData];
        }
        @catch (NSException *exception) {
            //_playerTwoBoxes = nil;
        }
        @finally {
            // up up
        }
        
        /*if (_game[@"PlayerOneBoxes"] != nil) {
            PFFile *playerOneBoxesFile = _game[@"PlayerOneBoxes"];
            NSData *data = [playerOneBoxesFile getData];
            _playerOneBoxes = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        }
        
        if (_game[@"PlayerTwoBoxes"] != nil) {
            PFFile *playerTwoBoxesFile = _game[@"PlayerTwoBoxes"];
            NSData *twoData = [playerTwoBoxesFile getData];
            _playerTwoBoxes = [NSKeyedUnarchiver unarchiveObjectWithData:twoData];
        }
        */
        if ((_playerOneBoxes.count == 0) || (_playerOneBoxes == nil)) {
            _opponentScoreLabel.text = @"0";
            _playerOneBoxes = [[NSMutableArray alloc] init];
        }
        else {
            NSNumber *num = [NSNumber numberWithUnsignedInteger:_playerOneBoxes.count];
            _opponentScoreLabel.text = [num stringValue];
        }
        if ((_playerTwoBoxes.count == 0) || (_playerTwoBoxes == nil)) {
            _myScoreLabel.text = @"0";
            _playerTwoBoxes = [[NSMutableArray alloc] init];
        }
        else {
            NSNumber *num = [NSNumber numberWithUnsignedInteger:_playerTwoBoxes.count];
            _myScoreLabel.text = [num stringValue];
        }
        
        [_gameBoardView setNeedsLayout];
        [_gameBoardView layoutIfNeeded];
        
        _containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, (rows + 2) * DOTSPACE, (cols + 2) * DOTSPACE)];
        _containerView.backgroundColor = BILightGrey;
        [_gameBoardView addSubview:_containerView];
        
        [_gameBoardView setContentSize:_containerView.frame.size];
        _gameBoardView.delegate = self;
        
        NSArray *savedArray = [[NSArray alloc] init];
        @try {
            PFFile *file = _game[@"coordinates"];
            NSData *cData = [file getData];
            savedArray = [NSKeyedUnarchiver unarchiveObjectWithData:cData];
        }
        @catch (NSException *exception) {
            // up up
        }
        @finally {
            // up up
        }
        
        if (savedArray.count == 0) {
            //we need to fix this
            goodArray = false;
        }
        
        for (int i = 0; i < rows + 1; i++) {
            for (int j = 0; j < cols + 1; j++) {
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((i * DOTSPACE) + DOTSPACE, (j * DOTSPACE) + DOTSPACE, DOTSIZE, DOTSIZE)];
                imageView.tag = DOTTAG;
                imageView.image = [UIImage imageNamed:@"dot.png"];
                imageView.contentMode = UIViewContentModeScaleAspectFill;
                [_containerView addSubview:imageView];
            }
        }
        
        NSMutableArray *verticalArray = [[NSMutableArray alloc] init];
        NSMutableArray *horizontalArray = [[NSMutableArray alloc] init];
        for (int i = 0; i < rows + 1; i++) {
            NSMutableArray *newHorizontalRow = [[NSMutableArray alloc] init];
            NSMutableArray *newVerticalRow = [[NSMutableArray alloc] init];
            for (int j = 0; j < cols + 1; j++) {
                
                if (i < rows) {
                    GBButton *horizontalButton = [[GBButton alloc] initWithFrame:CGRectMake((i * DOTSPACE) + DOTSPACE + LINEHJUST, (j * DOTSPACE) + DOTSPACE + LINEVJUST, LINELNGTH, LINEWIDTH)];
                    horizontalButton.tag = BUTTONTAG(i, j, HORIZONTAL, rows);
                    if (goodArray) {
                        //fill the coordinates with the array
                        GBCoordinate *hCoordinate = [[[savedArray objectAtIndex:HORIZONTAL] objectAtIndex:i] objectAtIndex:j];
                        [horizontalButton setCoordinate:hCoordinate];
                        if (hCoordinate.highlighted.boolValue == LINE_PICKED) {
                            [horizontalButton setImage:[UIImage imageNamed:@"line.png"] forState:UIControlStateDisabled];
                            [horizontalButton setEnabled:NO];
                            horizontalButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
                            [_containerView addSubview:horizontalButton];
                        }
                        else {
                            [horizontalButton setImage:[UIImage imageNamed:@"grey-line.png"] forState:UIControlStateNormal];
                            [horizontalButton addTarget:self action:@selector(lineButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
                            horizontalButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
                            [_containerView addSubview:horizontalButton];
                            _totalMovesRemaining++;
                        }
                        [newHorizontalRow addObject:hCoordinate];
                    }
                    else {
                        [horizontalButton setImage:[UIImage imageNamed:@"grey-line.png"] forState:UIControlStateNormal];
                        horizontalButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
                        GBCoordinate *hCoordinate = [[GBCoordinate alloc] init];
                        [hCoordinate setXCoordinate:[NSNumber numberWithInt:i]];
                        [hCoordinate setYCoordinate:[NSNumber numberWithInt:j]];
                        [hCoordinate setVertical:[NSNumber numberWithBool:HORIZONTAL]];
                        [hCoordinate setHighlighted:LINE_NOT_PICKED];
                        [horizontalButton setCoordinate:hCoordinate];
                        [horizontalButton addTarget:self action:@selector(lineButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
                        [_containerView addSubview:horizontalButton];
                        //[_coordinates addObject:hCoordinate];
                        [newHorizontalRow addObject:hCoordinate];
                        _totalMovesRemaining++;
                    }
                    
                }
                
                if (j < cols) {
                    GBButton *verticalButton = [[GBButton alloc] initWithFrame:CGRectMake((i * DOTSPACE) + DOTSPACE + LINEVJUST, (j * DOTSPACE) + DOTSPACE + LINEHJUST, LINEWIDTH, LINELNGTH)];
                    verticalButton.tag = BUTTONTAG(i, j, VERTICAL, rows);
                    if (goodArray) {
                        GBCoordinate *vCoordinate = [[[savedArray objectAtIndex:VERTICAL] objectAtIndex:i] objectAtIndex:j];
                        [verticalButton setCoordinate:vCoordinate];
                        if (vCoordinate.highlighted.boolValue == LINE_PICKED) {
                            [verticalButton setImage:[UIImage imageNamed:@"vertical-line.png"] forState:UIControlStateDisabled];
                            [verticalButton setEnabled:NO];
                            verticalButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
                            [_containerView addSubview:verticalButton];
                        }
                        else {
                            [verticalButton setImage:[UIImage imageNamed:@"vertical-grey-line.png"] forState:UIControlStateNormal];
                            [verticalButton addTarget:self action:@selector(lineButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
                            verticalButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
                            [_containerView addSubview:verticalButton];
                            _totalMovesRemaining++;
                        }
                        [newVerticalRow addObject:vCoordinate];
                        
                    }
                    else {
                        [verticalButton setImage:[UIImage imageNamed:@"vertical-grey-line.png"] forState:UIControlStateNormal];
                        verticalButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
                        GBCoordinate *vCoordinate = [[GBCoordinate alloc] init];
                        [vCoordinate setXCoordinate:[NSNumber numberWithInt:i]];
                        [vCoordinate setYCoordinate:[NSNumber numberWithInt:j]];
                        [vCoordinate setVertical:[NSNumber numberWithBool:VERTICAL]];
                        [vCoordinate setHighlighted:LINE_NOT_PICKED];
                        [verticalButton setCoordinate:vCoordinate];
                        [verticalButton addTarget:self action:@selector(lineButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
                        [_containerView addSubview:verticalButton];
                        //[_coordinates addObject:vCoordinate];
                        [newVerticalRow addObject:vCoordinate];
                        _totalMovesRemaining++;
                    }
                    
                }
                
            }
            [horizontalArray addObject:newHorizontalRow];
            [verticalArray addObject:newVerticalRow];
        }
        [_coordinates addObject:horizontalArray];
        [_coordinates addObject:verticalArray];
    }
    
    for (int i = 0; i < _playerOneBoxes.count; i++) {
        GBCoordinate *coordinate = [_playerOneBoxes objectAtIndex:i];
        [self makeBox:coordinate];
    }
    _playerOneTurn = false;
    for (int i = 0; i < _playerTwoBoxes.count; i++) {
        GBCoordinate *coordinate = [_playerTwoBoxes objectAtIndex:i];
        [self makeBox:coordinate];
    }
    
    if (_game[@"playerOneTurn"] == nil) {
        _playerOneTurn = true;
    }
    else {
        _playerOneTurn = [_game[@"playerOneTurn"] boolValue];
    }
    
    _playBoxButton = [[VBFPopFlatButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 15, self.view.frame.size.height - 45, 30, 30) buttonType:buttonCloseType buttonStyle:buttonRoundedStyle animateToInitialState:YES];
    _playBoxButton.alpha = 0.7;
    _playBoxButton.roundBackgroundColor = BIDarkGrey;
    _playBoxButton.tintColor = BILightGrey;
    _playBoxButton.tag = CLOSETAG;
    [_playBoxButton addTarget:self action:@selector(playButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_playBoxButton];
    
    _miniContainer = [[SSUIViewMiniMe alloc] initWithView:_containerView withRatio:10 withSize:_gameBoardView.frame.size];
    _miniContainer.backgroundColor = BIGreen;
    _hideMini = false;
    [_miniContainer setHidden:_hideMini];
    [_gameBoardView addSubview:_miniContainer];
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"FirstTimeGameBoard"] boolValue] == false) {
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(startTutorial)];
        [self.view addGestureRecognizer:_tapGesture];
    }
}

-(void)viewDidDisappear:(BOOL)animated {
    [SVProgressHUD dismiss];
}

-(void)startTutorial {
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"FirstTimeGameBoard"] boolValue] == false) {
        if (!_tutorialComplete) {
            DVITutorialView *tutorialView = [[DVITutorialView alloc] init];
            [tutorialView addToView:self.view];
            
            tutorialView.tutorialStrings = @[
                                             @"On the game board, select the line you want to pick..",
                                             @"Tap and Hold to remove the Mini View..",
                                             @"Pinch to zoom in and out of the game board..",
                                             @"When the button is a check mark, tap to make your move..",
                                             @"When the button is an X, you can exit the game board..",
                                             @"You can also message your opponent by tapping their score board..",
                                             @"Make your first move!",
                                             ];
            
            tutorialView.tutorialViews = @[
                                           _gameBoardView,
                                           _gameBoardView,
                                           _gameBoardView,
                                           _playBoxButton,
                                           _playBoxButton,
                                           _messageButton,
                                           [[UIView alloc] init],
                                           ];
            
            [tutorialView startWithCompletion:^{
                [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:@"FirstTimeGameBoard"];
                _tutorialComplete = true;
                [_tapGesture setEnabled:NO];
            }];
        }
        else {
            [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:@"FirstTimeGameBoard"];
            [_tapGesture setEnabled:NO];
        }
    }
    else {
        [_tapGesture setEnabled:NO];
    }
}

-(void)viewWillAppear:(BOOL)animated {
    // Set up the minimum & maximum zoom scales
    CGRect scrollViewFrame = _gameBoardView.frame;
    CGFloat scaleWidth = scrollViewFrame.size.width / _gameBoardView.contentSize.width;
    CGFloat scaleHeight = scrollViewFrame.size.height / _gameBoardView.contentSize.height;
    CGFloat minScale = MIN(scaleWidth, scaleHeight);
    
    _gameBoardView.minimumZoomScale = 0.333;
    _gameBoardView.maximumZoomScale = 1.0f;
    _gameBoardView.zoomScale = minScale;
    
    [self centerScrollViewContents];
}

-(void)setupGameBoard {
    [self.navigationController.navigationBar configureFlatNavigationBarWithColor:BIGreen];
    BOOL goodArray = true;
    
    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(screenTapped:)];
    [_containerView addGestureRecognizer:_tapGesture];
    
    _playerOneBoxes = [[NSMutableArray alloc] init];
    _playerTwoBoxes = [[NSMutableArray alloc] init];
    _coordinates = [[NSMutableArray alloc] init];
    
    _playerOneTurn = true;
    _opponentScoreLabel.backgroundColor = BILightGrey;
    _opponentScoreLabel.textColor = BIGreen;
    _opponentUserLabel.backgroundColor = BILightGrey;
    _opponentUserLabel.textColor = BIGreen;
    _myScoreLabel.backgroundColor = BIPurple;
    _myScoreLabel.textColor = BIOrange;
    _myUserLabel.backgroundColor = BIPurple;
    _myUserLabel.textColor = BIOrange;
    
    
    if (_game != nil) {
        int rows = [_game[@"NumberRows"] intValue];
        int cols = [_game[@"NumberCols"] intValue];
        _totalMovesRemaining = 0;
        
        PFUser *userOne = _game[@"PlayerOne"];
        PFUser *userTwo = _game[@"PlayerTwo"];
        
        NSString *opponentLabel = @"@";
        opponentLabel = [opponentLabel stringByAppendingString:userOne.username];
        const unichar this = [opponentLabel characterAtIndex:1];
        _playerOneLetter = [NSString stringWithCharacters:&this length:1];
        _opponentUserLabel.text = opponentLabel;
        if (_game[@"PlayerTwo"] == nil) {
            _myUserLabel.text = @"@PlayerTwo";
            const unichar that = [_myUserLabel.text characterAtIndex:1];
            _playerTwoLetter = [NSString stringWithCharacters:&that length:1];
        }
        else {
            NSString *mylabel = @"@";
            _myUserLabel.text = [mylabel stringByAppendingString:userTwo.username];
            const unichar that = [_myUserLabel.text characterAtIndex:1];
            _playerTwoLetter = [NSString stringWithCharacters:&that length:1];
        }
        NSString *oppScoreText = [_game[@"PlayerOneBoxes"] stringValue];
        if (oppScoreText == nil) {
            _opponentScoreLabel.text = @"0";
        }
        else {
            _opponentScoreLabel.text = oppScoreText;
        }
        
        PFFile *playerOneBoxesFile = _game[@"PlayerOneBoxes"];
        NSData *data = [playerOneBoxesFile getData];
        _playerOneBoxes = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        
        PFFile *playerTwoBoxesFile = _game[@"PlayerTwoBoxes"];
        NSData *twoData = [playerTwoBoxesFile getData];
        _playerTwoBoxes = [NSKeyedUnarchiver unarchiveObjectWithData:twoData];
        
        if ((_playerOneBoxes.count == 0) || (_playerOneBoxes == nil)) {
            _opponentScoreLabel.text = @"0";
            _playerOneBoxes = [[NSMutableArray alloc] init];
        }
        else {
            NSNumber *num = [NSNumber numberWithUnsignedInteger:_playerOneBoxes.count];
            _opponentScoreLabel.text = [num stringValue];
        }
        if ((_playerTwoBoxes.count == 0) || (_playerTwoBoxes == nil)) {
            _myScoreLabel.text = @"0";
            _playerTwoBoxes = [[NSMutableArray alloc] init];
        }
        else {
            NSNumber *num = [NSNumber numberWithUnsignedInteger:_playerTwoBoxes.count];
            _myScoreLabel.text = [num stringValue];
        }
        
        [_gameBoardView setNeedsLayout];
        [_gameBoardView layoutIfNeeded];
        
        _containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, (rows + 2) * DOTSPACE, (cols + 2) * DOTSPACE)];
        _containerView.backgroundColor = BILightGrey;
        [_gameBoardView addSubview:_containerView];
        
        [_gameBoardView setContentSize:_containerView.frame.size];
        _gameBoardView.delegate = self;
        
        PFFile *file = _game[@"coordinates"];
        NSData *cData = [file getData];
        NSArray *savedArray = [NSKeyedUnarchiver unarchiveObjectWithData:cData];
        if (savedArray.count == 0) {
            //we need to fix this
            goodArray = false;
        }
        
        for (int i = 0; i < rows + 1; i++) {
            for (int j = 0; j < cols + 1; j++) {
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((i * DOTSPACE) + DOTSPACE, (j * DOTSPACE) + DOTSPACE, DOTSIZE, DOTSIZE)];
                imageView.image = [UIImage imageNamed:@"dot.png"];
                imageView.contentMode = UIViewContentModeScaleAspectFill;
                [_containerView addSubview:imageView];
            }
        }
        
        NSMutableArray *verticalArray = [[NSMutableArray alloc] init];
        NSMutableArray *horizontalArray = [[NSMutableArray alloc] init];
        for (int i = 0; i < rows + 1; i++) {
            NSMutableArray *newHorizontalRow = [[NSMutableArray alloc] init];
            NSMutableArray *newVerticalRow = [[NSMutableArray alloc] init];
            for (int j = 0; j < cols + 1; j++) {
                
                if (i < rows) {
                    GBButton *horizontalButton = [[GBButton alloc] initWithFrame:CGRectMake((i * DOTSPACE) + DOTSPACE + LINEHJUST, (j * DOTSPACE) + DOTSPACE + LINEVJUST, LINELNGTH, LINEWIDTH)];
                    horizontalButton.tag = BUTTONTAG(i, j, HORIZONTAL, rows);
                    if (goodArray) {
                        //fill the coordinates with the array
                        GBCoordinate *hCoordinate = [[[savedArray objectAtIndex:HORIZONTAL] objectAtIndex:i] objectAtIndex:j];
                        if (hCoordinate.highlighted.boolValue == LINE_PICKED) {
                            [horizontalButton setImage:[UIImage imageNamed:@"line.png"] forState:UIControlStateDisabled];
                            [horizontalButton setEnabled:NO];
                            horizontalButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
                            [_containerView addSubview:horizontalButton];
                        }
                        else {
                            [horizontalButton setImage:[UIImage imageNamed:@"grey-line.png"] forState:UIControlStateNormal];
                            [horizontalButton addTarget:self action:@selector(lineButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
                            horizontalButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
                            [_containerView addSubview:horizontalButton];
                            _totalMovesRemaining++;
                        }
                        [newHorizontalRow addObject:hCoordinate];
                    }
                    else {
                        [horizontalButton setImage:[UIImage imageNamed:@"grey-line.png"] forState:UIControlStateNormal];
                        horizontalButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
                        GBCoordinate *hCoordinate = [[GBCoordinate alloc] init];
                        [hCoordinate setXCoordinate:[NSNumber numberWithInt:i]];
                        [hCoordinate setYCoordinate:[NSNumber numberWithInt:j]];
                        [hCoordinate setVertical:[NSNumber numberWithBool:HORIZONTAL]];
                        [hCoordinate setHighlighted:LINE_NOT_PICKED];
                        [horizontalButton setCoordinate:hCoordinate];
                        [horizontalButton addTarget:self action:@selector(lineButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
                        [_containerView addSubview:horizontalButton];
                        //[_coordinates addObject:hCoordinate];
                        [newHorizontalRow addObject:hCoordinate];
                        _totalMovesRemaining++;
                    }
                    
                }
                
                if (j < cols) {
                    GBButton *verticalButton = [[GBButton alloc] initWithFrame:CGRectMake((i * DOTSPACE) + DOTSPACE + LINEVJUST, (j * DOTSPACE) + DOTSPACE + LINEHJUST, LINEWIDTH, LINELNGTH)];
                    verticalButton.tag = BUTTONTAG(i, j, VERTICAL, rows);
                    if (goodArray) {
                        GBCoordinate *vCoordinate = [[[savedArray objectAtIndex:VERTICAL] objectAtIndex:i] objectAtIndex:j];
                        if (vCoordinate.highlighted.boolValue == LINE_PICKED) {
                            [verticalButton setImage:[UIImage imageNamed:@"vertical-line.png"] forState:UIControlStateDisabled];
                            [verticalButton setEnabled:NO];
                            verticalButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
                            [_containerView addSubview:verticalButton];
                        }
                        else {
                            [verticalButton setImage:[UIImage imageNamed:@"vertical-grey-line.png"] forState:UIControlStateNormal];
                            [verticalButton addTarget:self action:@selector(lineButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
                            verticalButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
                            [_containerView addSubview:verticalButton];
                            _totalMovesRemaining++;
                        }
                        [newVerticalRow addObject:vCoordinate];
                        
                    }
                    else {
                        [verticalButton setImage:[UIImage imageNamed:@"vertical-grey-line.png"] forState:UIControlStateNormal];
                        verticalButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
                        GBCoordinate *vCoordinate = [[GBCoordinate alloc] init];
                        [vCoordinate setXCoordinate:[NSNumber numberWithInt:i]];
                        [vCoordinate setYCoordinate:[NSNumber numberWithInt:j]];
                        [vCoordinate setVertical:[NSNumber numberWithBool:VERTICAL]];
                        [vCoordinate setHighlighted:LINE_NOT_PICKED];
                        [verticalButton setCoordinate:vCoordinate];
                        [verticalButton addTarget:self action:@selector(lineButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
                        [_containerView addSubview:verticalButton];
                        //[_coordinates addObject:vCoordinate];
                        [newVerticalRow addObject:vCoordinate];
                        _totalMovesRemaining++;
                    }
                    
                }
                
            }
            [horizontalArray addObject:newHorizontalRow];
            [verticalArray addObject:newVerticalRow];
        }
        [_coordinates addObject:horizontalArray];
        [_coordinates addObject:verticalArray];
    }
    
    for (int i = 0; i < _playerOneBoxes.count; i++) {
        GBCoordinate *coordinate = [_playerOneBoxes objectAtIndex:i];
        [self makeBox:coordinate];
    }
    _playerOneTurn = false;
    for (int i = 0; i < _playerTwoBoxes.count; i++) {
        GBCoordinate *coordinate = [_playerTwoBoxes objectAtIndex:i];
        [self makeBox:coordinate];
    }
    
    if (_game[@"playerOneTurn"] == nil) {
        _playerOneTurn = true;
    }
    else {
        _playerOneTurn = [_game[@"playerOneTurn"] boolValue];
    }
    
    _playBoxButton = [[VBFPopFlatButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 15, self.view.frame.size.height - 45, 30, 30) buttonType:buttonCloseType buttonStyle:buttonRoundedStyle animateToInitialState:YES];
    _playBoxButton.roundBackgroundColor = BIDarkGrey;
    _playBoxButton.tintColor = BILightGrey;
    _playBoxButton.tag = CLOSETAG;
    [_playBoxButton addTarget:self action:@selector(playButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_playBoxButton];
    
    _miniContainer = [[SSUIViewMiniMe alloc] initWithView:_containerView withRatio:10 withSize:_gameBoardView.frame.size];
    _miniContainer.backgroundColor = BIGreen;
    _hideMini = false;
    [_miniContainer setHidden:_hideMini];
    [_gameBoardView addSubview:_miniContainer];
}

-(void)updateDataPoints {
    
    [SVProgressHUD showWithStatus:@"Updating Game Board.."];
    
    int rows = [_game[@"NumberRows"] intValue];
    int cols = [_game[@"NumberCols"] intValue];
    
    //[_game[@"coordinates"] fetch];
    PFFile *file = _game[@"coordinates"];
    NSData *cData = [file getData];
    _coordinates = [NSKeyedUnarchiver unarchiveObjectWithData:cData];
    
    for (int i = 0; i < rows + 1; i++) {
        for (int j = 0; j < cols + 1; j++) {
            
            if (i < rows) {
                //GBButton *horizontalButton = [[GBButton alloc] initWithFrame:CGRectMake((i * DOTSPACE) + DOTSPACE + LINEHJUST, (j * DOTSPACE) + DOTSPACE + LINEVJUST, LINELNGTH, LINEWIDTH)];
                GBButton *horizontalButton = (GBButton*)[_containerView viewWithTag:BUTTONTAG(i, j, HORIZONTAL, rows)];
                    //fill the coordinates with the array
                if ([horizontalButton class] != [GBButton class]) {
                    NSLog(@"subview is not button");
                    break;
                }
                    GBCoordinate *hCoordinate = [[[_coordinates objectAtIndex:HORIZONTAL] objectAtIndex:i] objectAtIndex:j];
                    if (hCoordinate.highlighted.boolValue == LINE_PICKED) {
                        [horizontalButton setImage:[UIImage imageNamed:@"line.png"] forState:UIControlStateDisabled];
                        [horizontalButton setEnabled:NO];
                        horizontalButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
                        //[_containerView addSubview:horizontalButton];
                    }
                    else {
                        [horizontalButton setImage:[UIImage imageNamed:@"grey-line.png"] forState:UIControlStateNormal];
                        [horizontalButton addTarget:self action:@selector(lineButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
                        horizontalButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
                        //[_containerView addSubview:horizontalButton];
                        _totalMovesRemaining++;
                    }
                    //[newHorizontalRow addObject:hCoordinate];
                
            }
            
            if (j < cols) {
                //GBButton *verticalButton = [[GBButton alloc] initWithFrame:CGRectMake((i * DOTSPACE) + DOTSPACE + LINEVJUST, (j * DOTSPACE) + DOTSPACE + LINEHJUST, LINEWIDTH, LINELNGTH)];
                GBButton *verticalButton = (GBButton*)[_containerView viewWithTag:BUTTONTAG(i, j, VERTICAL, rows)];
                if ([verticalButton class] != [GBButton class]) {
                    NSLog(@"subview is not button");
                    break;
                }
                    GBCoordinate *vCoordinate = [[[_coordinates objectAtIndex:VERTICAL] objectAtIndex:i] objectAtIndex:j];
                    if (vCoordinate.highlighted.boolValue == LINE_PICKED) {
                        [verticalButton setImage:[UIImage imageNamed:@"vertical-line.png"] forState:UIControlStateDisabled];
                        [verticalButton setEnabled:NO];
                        verticalButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
                        //[_containerView addSubview:verticalButton];
                    }
                    else {
                        [verticalButton setImage:[UIImage imageNamed:@"vertical-grey-line.png"] forState:UIControlStateNormal];
                        [verticalButton addTarget:self action:@selector(lineButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
                        verticalButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
                        //[_containerView addSubview:verticalButton];
                        _totalMovesRemaining++;
                    }
                    //[newVerticalRow addObject:vCoordinate];

            
            }
        //[horizontalArray addObject:newHorizontalRow];
        //[verticalArray addObject:newVerticalRow];
        }
    }
    
    @try {
        //[_game[@"PlayerOneBoxes"] fetch];
        PFFile *file = _game[@"PlayerOneBoxes"];
        NSData *p1Data = [file getData];
        _playerOneBoxes = [NSKeyedUnarchiver unarchiveObjectWithData:p1Data];
    }
    @catch (NSException *exception) {
        // up up
    }
    @finally {
        // up up
    }
    
    @try {
        //[_game[@"PlayerTwoBoxes"] fetch];
        PFFile *file = _game[@"PlayerTwoBoxes"];
        NSData *p2Data = [file getData];
        _playerTwoBoxes = [NSKeyedUnarchiver unarchiveObjectWithData:p2Data];
    }
    @catch (NSException *exception) {
        // up up
    }
    @finally {
        // up up
    }

    _playerOneTurn = true;
    for (int i = 0; i < _playerOneBoxes.count; i++) {
        GBCoordinate *coordinate = [_playerOneBoxes objectAtIndex:i];
        [self makeBox:coordinate];
    }
    _playerOneTurn = false;
    for (int i = 0; i < _playerTwoBoxes.count; i++) {
        GBCoordinate *coordinate = [_playerTwoBoxes objectAtIndex:i];
        [self makeBox:coordinate];
    }

    if (_game[@"playerOneTurn"] == nil) {
        _playerOneTurn = true;
    }
    else {
        _playerOneTurn = [_game[@"playerOneTurn"] boolValue];
    }
    [self updatePlayerTurnViews];
    [SVProgressHUD dismiss];
    [SVProgressHUD dismiss];
}

- (void)centerScrollViewContents {
    
    //_containerView.center = CGPointMake(_gameBoardView.frame.size.width / 2.0f, _gameBoardView.frame.size.height / 2.0f);
    
    
    CGSize boundsSize = _gameBoardView.bounds.size;
    CGRect contentsFrame = _containerView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    _containerView.frame = contentsFrame;
    
}

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    // Return the view that we want to zoom
    return self.containerView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    // The scroll view has zoomed, so we need to re-center the contents
    [self centerScrollViewContents];
}

-(void)updatePlayerTurnViews {
    if (_playerOneTurn) {
        //_playerOneTurn = true;
        _opponentScoreLabel.backgroundColor = BILightGrey;
        _opponentScoreLabel.textColor = BIGreen;
        _opponentUserLabel.backgroundColor = BILightGrey;
        _opponentUserLabel.textColor = BIGreen;
        _myScoreLabel.backgroundColor = BIPurple;
        _myScoreLabel.textColor = BIOrange;
        _myUserLabel.backgroundColor = BIPurple;
        _myUserLabel.textColor = BIOrange;
    }
    else {
        //_playerOneTurn = false;
        _opponentScoreLabel.backgroundColor = BIPurple;
        _opponentScoreLabel.textColor = BIOrange;
        _opponentUserLabel.backgroundColor = BIPurple;
        _opponentUserLabel.textColor = BIOrange;
        _myScoreLabel.backgroundColor = BILightGrey;
        _myScoreLabel.textColor = BIGreen;
        _myUserLabel.backgroundColor = BILightGrey;
        _myUserLabel.textColor = BIGreen;
    }
}

-(void)lineButtonPressed:(id)sender {
    GBButton *button = (GBButton*)sender;
    
    if (_currentButton.coordinate.highlighted == LINE_NOT_PICKED) {
        if (_currentButton.coordinate.vertical.boolValue == VERTICAL) {
            [_currentButton setImage:[UIImage imageNamed:@"vertical-grey-line.png"] forState:UIControlStateNormal];
        }
        else
            [_currentButton setImage:[UIImage imageNamed:@"grey-line.png"] forState:UIControlStateNormal];
    }
    
    _currentButton = button;
    
    //GBCoordinate *coordinate = button.coordinate;
    if ( _currentButton.coordinate.vertical.boolValue == VERTICAL) {
        [_currentButton setImage:[UIImage imageNamed:@"vertical-line.png"] forState:UIControlStateNormal];
        [_currentButton setImage:[UIImage imageNamed:@"vertical-line.png"] forState:UIControlStateDisabled];
    }
    else {
        [_currentButton setImage:[UIImage imageNamed:@"line.png"] forState:UIControlStateNormal];
        [_currentButton setImage:[UIImage imageNamed:@"line.png"] forState:UIControlStateDisabled];
    }
    
    [_playBoxButton animateToType:buttonOkType];
    _playBoxButton.tag = PLAYTAG;
    
}

-(void)playButtonPressed {
    
    int box = 0;
    
    BOOL myTurn;
    PFUser *user = [PFUser currentUser];
    if ((_playerOneTurn == true) && [user.objectId isEqualToString:[_game[@"PlayerOne"] objectId]]) {
        myTurn = YES;
    }
    else if ((_playerOneTurn == false) && [user.objectId isEqualToString:[_game[@"PlayerTwo"] objectId]]) {
        myTurn = YES;
    }
    else
        myTurn = NO;
    
    if ( ((_gameType == P2PTYPE) || (_gameType == NETTYPE)) && !myTurn && (_playBoxButton.tag != CLOSETAG)) {
        _playBoxButton.tag = CLOSETAG;
        [_playBoxButton animateToType:buttonCloseType];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Wait your turn.." message:@"It's the other player's turn.. Tell them to hurry up!!" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            // up up
        }]];
        [self presentViewController:alert animated:YES completion:^{
            // up up
        }];
        
        return;
    }
    
    switch (_playBoxButton.tag) {
        case CLOSETAG: {
            NSData *cData = [NSKeyedArchiver archivedDataWithRootObject:_coordinates];
            PFFile *coordinateFile = [PFFile fileWithData:cData];
            _game[@"coordinates"] = coordinateFile;
            
            NSData *oneData = [NSKeyedArchiver archivedDataWithRootObject:_playerOneBoxes];
            PFFile *oneFile = [PFFile fileWithData:oneData];
            _game[@"PlayerOneBoxes"] = oneFile;
            
            NSData *twoData = [NSKeyedArchiver archivedDataWithRootObject:_playerTwoBoxes];
            PFFile *twoFile = [PFFile fileWithData:twoData];
            _game[@"PlayerTwoBoxes"] = twoFile;
            
            if (_playerOneTurn) {
                _game[@"playerOneTurn"] = @YES;
            }
            else
                _game[@"playerOneTurn"] = @NO;
            
            if (_totalMovesRemaining != 0) {
                _game[@"completed"] = @NO;
            }
            
            if (_gameType != NETTYPE) {
                //only save the game if it's a local or p2p game otherwise we stand to overwrite data
                [_game saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    if (succeeded) {
                        NSLog(@"succeeded in saving the game..");
                    }
                }];
            }
            
            [self dismissViewControllerAnimated:YES completion:^{
                //up up
                if (_prevViewController != nil) {
                    [self.prevViewController dismissViewControllerAnimated:YES completion:^{
                        //up up
                        //return ;
                    }];
                }
            }];
            return;
            break;
        }
        case PLAYTAG: {
            _playBoxButton.tag = CLOSETAG;
            [_playBoxButton animateToType:buttonCloseType];
            
            [_currentButton setEnabled:NO];
            _currentButton.alpha = 1.0;
            [_playBoxButton animateToType:buttonCloseType];
            _playBoxButton.tag = CLOSETAG;
            
            GBCoordinate *coordinate = _currentButton.coordinate;
            GBCoordinate *arrayCoordinate = [[[_coordinates objectAtIndex:coordinate.vertical.intValue] objectAtIndex:coordinate.xCoordinate.intValue] objectAtIndex:coordinate.yCoordinate.intValue];
            arrayCoordinate.highlighted = [NSNumber numberWithBool:LINE_PICKED];
            
            box = [self checkForBox:coordinate];
            
            switch (box) {
                case 0x0:
                    [self finishTurn];
                    if (_gameType == NETTYPE) {
                        if (([[PFUser currentUser][@"paidUser"] boolValue] == true) || [[[NSUserDefaults standardUserDefaults] objectForKey:@"paidUser"] boolValue] == true) {
                            //do not show the ad
                            NSLog(@"paid user.. do not show the ad");
                        }
                        else
                            [self requestInterstitialAdPresentation];
                    }
                    break;
                case 0x1: {
                    NSLog(@"box completed");
                    if (_playerOneTurn) {
                        //int score = [_opponentScoreLabel.text intValue];
                        //score++;
                        PFUser *user = _game[@"PlayerOne"];
                        int totalBoxes = [user[@"totalBoxes"] intValue];
                        totalBoxes++;
                        user[@"totalBoxes"] = [NSNumber numberWithInt:totalBoxes];
                        [_playerOneBoxes addObject:coordinate];
                        [self makeBox:coordinate];
                    }
                    else {
                        PFUser *user = _game[@"PlayerTwo"];
                        int totalBoxes = [user[@"totalBoxes"] intValue];
                        totalBoxes++;
                        user[@"totalBoxes"] = [NSNumber numberWithInt:totalBoxes];
                        [_playerTwoBoxes addObject:coordinate];
                        [self makeBox:coordinate];
                    }
                    break;
                }
                case 0x2: {
                    NSLog(@"box completed");
                    if (_playerOneTurn) {
                        PFUser *user = _game[@"PlayerOne"];
                        int totalBoxes = [user[@"totalBoxes"] intValue];
                        totalBoxes++;
                        user[@"totalBoxes"] = [NSNumber numberWithInt:totalBoxes];
                        
                        GBCoordinate *newCoordinate = [GBCoordinate new];
                        newCoordinate.xCoordinate = [NSNumber numberWithInt:coordinate.xCoordinate.intValue - 1];
                        newCoordinate.yCoordinate = coordinate.yCoordinate;
                        newCoordinate.vertical = coordinate.vertical;
                        newCoordinate.highlighted = coordinate.highlighted;
                        [_playerOneBoxes addObject:newCoordinate];
                        [self makeBox:newCoordinate];
                    }
                    else {
                        PFUser *user = _game[@"PlayerTwo"];
                        int totalBoxes = [user[@"totalBoxes"] intValue];
                        totalBoxes++;
                        user[@"totalBoxes"] = [NSNumber numberWithInt:totalBoxes];
                        
                        GBCoordinate *newCoordinate = [GBCoordinate new];
                        newCoordinate.xCoordinate = [NSNumber numberWithInt:coordinate.xCoordinate.intValue - 1];
                        newCoordinate.yCoordinate = coordinate.yCoordinate;
                        newCoordinate.vertical = coordinate.vertical;
                        newCoordinate.highlighted = coordinate.highlighted;
                        [_playerTwoBoxes addObject:newCoordinate];
                        [self makeBox:newCoordinate];
                    }
                    break;
                }
                case 0x3: {
                    NSLog(@"box completed");
                    if (_playerOneTurn) {
                        //int score = [_opponentScoreLabel.text intValue];
                        //score++;
                        PFUser *user = _game[@"PlayerOne"];
                        int totalBoxes = [user[@"totalBoxes"] intValue];
                        totalBoxes+=2;
                        user[@"totalBoxes"] = [NSNumber numberWithInt:totalBoxes];
                        [user saveInBackground];
                        
                        [_playerOneBoxes addObject:coordinate];
                        [self makeBox:coordinate];
                        
                        GBCoordinate *newCoordinate = [GBCoordinate new];
                        newCoordinate.xCoordinate = [NSNumber numberWithInt:coordinate.xCoordinate.intValue - 1];
                        newCoordinate.yCoordinate = coordinate.yCoordinate;
                        newCoordinate.vertical = coordinate.vertical;
                        newCoordinate.highlighted = coordinate.highlighted;
                        [_playerOneBoxes addObject:newCoordinate];
                        [self makeBox:newCoordinate];
                    }
                    else {
                        PFUser *user = _game[@"PlayerTwo"];
                        int totalBoxes = [user[@"totalBoxes"] intValue];
                        totalBoxes+=2;
                        user[@"totalBoxes"] = [NSNumber numberWithInt:totalBoxes];
                        [user saveInBackground];
                        
                        [_playerTwoBoxes addObject:coordinate];
                        [self makeBox:coordinate];
                        
                        GBCoordinate *newCoordinate = [GBCoordinate new];
                        newCoordinate.xCoordinate = [NSNumber numberWithInt:coordinate.xCoordinate.intValue - 1];
                        newCoordinate.yCoordinate = coordinate.yCoordinate;
                        newCoordinate.vertical = coordinate.vertical;
                        newCoordinate.highlighted = coordinate.highlighted;
                        [_playerTwoBoxes addObject:newCoordinate];
                        [self makeBox:newCoordinate];
                    }
                    break;
                }
                case 0x4: {
                    NSLog(@"box completed");
                    if (_playerOneTurn) {
                        PFUser *user = _game[@"PlayerOne"];
                        int totalBoxes = [user[@"totalBoxes"] intValue];
                        totalBoxes++;
                        user[@"totalBoxes"] = [NSNumber numberWithInt:totalBoxes];
                        [user saveInBackground];
                        
                        [_playerOneBoxes addObject:coordinate];
                        [self makeBox:coordinate];
                    }
                    else {
                        PFUser *user = _game[@"PlayerTwo"];
                        int totalBoxes = [user[@"totalBoxes"] intValue];
                        totalBoxes++;
                        user[@"totalBoxes"] = [NSNumber numberWithInt:totalBoxes];
                        [user saveInBackground];
                        
                        [_playerTwoBoxes addObject:coordinate];
                        [self makeBox:coordinate];
                    }
                    break;
                }
                case 0x8: {
                    NSLog(@"box completed");
                    if (_playerOneTurn) {
                        PFUser *user = _game[@"PlayerOne"];
                        int totalBoxes = [user[@"totalBoxes"] intValue];
                        totalBoxes++;
                        user[@"totalBoxes"] = [NSNumber numberWithInt:totalBoxes];
                        [user saveInBackground];
                        
                        GBCoordinate *newCoordinate = [GBCoordinate new];
                        newCoordinate.xCoordinate = coordinate.xCoordinate;
                        newCoordinate.yCoordinate = [NSNumber numberWithInt:coordinate.yCoordinate.intValue - 1];
                        newCoordinate.vertical = coordinate.vertical;
                        newCoordinate.highlighted = coordinate.highlighted;
                        [_playerOneBoxes addObject:newCoordinate];
                        [self makeBox:newCoordinate];
                    }
                    else {
                        PFUser *user = _game[@"PlayerTwo"];
                        int totalBoxes = [user[@"totalBoxes"] intValue];
                        totalBoxes++;
                        user[@"totalBoxes"] = [NSNumber numberWithInt:totalBoxes];
                        [user saveInBackground];
                        
                        GBCoordinate *newCoordinate = [GBCoordinate new];
                        newCoordinate.xCoordinate = coordinate.xCoordinate;
                        newCoordinate.yCoordinate = [NSNumber numberWithInt:coordinate.yCoordinate.intValue - 1];
                        newCoordinate.vertical = coordinate.vertical;
                        newCoordinate.highlighted = coordinate.highlighted;
                        [_playerTwoBoxes addObject:newCoordinate];
                        [self makeBox:newCoordinate];
                    }
                    break;
                }
                case 0xc: {
                    NSLog(@"box completed");
                    if (_playerOneTurn) {
                        PFUser *user = _game[@"PlayerOne"];
                        int totalBoxes = [user[@"totalBoxes"] intValue];
                        totalBoxes+=2;
                        user[@"totalBoxes"] = [NSNumber numberWithInt:totalBoxes];
                        [user saveInBackground];
                        
                        [_playerOneBoxes addObject:coordinate];
                        [self makeBox:coordinate];
                        
                        GBCoordinate *newCoordinate = [GBCoordinate new];
                        newCoordinate.xCoordinate = coordinate.xCoordinate;
                        newCoordinate.yCoordinate = [NSNumber numberWithInt:coordinate.yCoordinate.intValue - 1];
                        newCoordinate.vertical = coordinate.vertical;
                        newCoordinate.highlighted = coordinate.highlighted;
                        [_playerOneBoxes addObject:newCoordinate];
                        [self makeBox:newCoordinate];
                    }
                    else {
                        PFUser *user = _game[@"PlayerTwo"];
                        int totalBoxes = [user[@"totalBoxes"] intValue];
                        totalBoxes+=2;
                        user[@"totalBoxes"] = [NSNumber numberWithInt:totalBoxes];
                        [user saveInBackground];
                        
                        [_playerTwoBoxes addObject:coordinate];
                        [self makeBox:coordinate];
                        
                        GBCoordinate *newCoordinate = [GBCoordinate new];
                        newCoordinate.xCoordinate = coordinate.xCoordinate;
                        newCoordinate.yCoordinate = [NSNumber numberWithInt:coordinate.yCoordinate.intValue - 1];
                        newCoordinate.vertical = coordinate.vertical;
                        newCoordinate.highlighted = coordinate.highlighted;
                        [_playerTwoBoxes addObject:newCoordinate];
                        [self makeBox:newCoordinate];
                    }
                    break;
                }
                    
                default:
                    break;
            }
            _totalMovesRemaining--;
            if (_totalMovesRemaining == 0) {
                [self checkForWinner];
            }
            break;
        }
        default:
            break;
    }
    
}

-(void)finishTurn {
    if (_playerOneTurn) {
        _playerOneTurn = false;
    }
    else {
        _playerOneTurn = true;
    }
    
    [self updatePlayerTurnViews];
    
    if (_gameType == LOCALTYPE) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Other Player's Turn!" message:@"Pass the phone or wait for them to make their move.." preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //up up
        }]];
        [self presentViewController:alert animated:YES completion:^{
            //up up
        }];
    }
    if (_gameType == P2PTYPE) {
        NSData *cData = [NSKeyedArchiver archivedDataWithRootObject:_coordinates];
        PFFile *coordinateFile = [PFFile fileWithData:cData];
        _game[@"coordinates"] = coordinateFile;
        
        NSData *oneData = [NSKeyedArchiver archivedDataWithRootObject:_playerOneBoxes];
        PFFile *oneFile = [PFFile fileWithData:oneData];
        _game[@"PlayerOneBoxes"] = oneFile;
        
        NSData *twoData = [NSKeyedArchiver archivedDataWithRootObject:_playerTwoBoxes];
        PFFile *twoFile = [PFFile fileWithData:twoData];
        _game[@"PlayerTwoBoxes"] = twoFile;
        
        _game[@"gameType"] = @P2PTYPE;
        
        if (_playerOneTurn) {
            _game[@"playerOneTurn"] = @YES;
        }
        else
            _game[@"playerOneTurn"] = @NO;
        NewGameViewController *controller = (NewGameViewController*)_prevViewController;
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_game];
        [controller sendGameData:data];
    }
    if (_gameType == NETTYPE) {
        _game[@"completed"] = @NO;
        
        NSData *cData = [NSKeyedArchiver archivedDataWithRootObject:_coordinates];
        PFFile *coordinateFile = [PFFile fileWithData:cData];
        _game[@"coordinates"] = coordinateFile;
        
        NSData *oneData = [NSKeyedArchiver archivedDataWithRootObject:_playerOneBoxes];
        PFFile *oneFile = [PFFile fileWithData:oneData];
        _game[@"PlayerOneBoxes"] = oneFile;
        
        NSData *twoData = [NSKeyedArchiver archivedDataWithRootObject:_playerTwoBoxes];
        PFFile *twoFile = [PFFile fileWithData:twoData];
        _game[@"PlayerTwoBoxes"] = twoFile;
        
        _game[@"gameType"] = @NETTYPE;
        
        PFUser *sendingUser;
        PFUser *senderUser;
        if (_playerOneTurn) {
            _game[@"playerOneTurn"] = @YES;
            sendingUser = _game[@"PlayerOne"];
            senderUser = _game[@"PlayerTwo"];
        }
        else {
            _game[@"playerOneTurn"] = @NO;
            sendingUser = _game[@"PlayerTwo"];
            senderUser = _game[@"PlayerOne"];
        }
        
        [SVProgressHUD showWithStatus:@"Saving.."];
        [_game saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded) {
                // Find users near a given location
                //PFQuery *userQuery = [PFUser query];
                //[userQuery whereKey:@"objectId" equalTo:sendingUser.objectId];
                
                // Find devices associated with these users
                PFQuery *pushQuery = [PFInstallation query];
                [pushQuery whereKey:@"objectId" equalTo:sendingUser[@"installationId"]];
                
                // Send push notification to query
                PFPush *push = [[PFPush alloc] init];
                [push setQuery:pushQuery]; // Set our Installation query
                
                NSString *message = @"It's your turn to play against ";
                message = [message stringByAppendingString:senderUser.username];
                message = [message stringByAppendingString:@"!"];
                NSDictionary *data = @{
                                       @"alert" : message,
                                       @"pushType" : @"GameNotification",
                                       @"g" : _game.objectId,
                                       @"badge" : @"Increment",
                                       @"sounds" : @"default",
                                       @"fromUserName" : senderUser.username
                                       };
                
                [push setData:data];
                [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    if (succeeded) {
                        NSLog(@"push sent..");
                        [SVProgressHUD showSuccessWithStatus:@"Saved!"];
                    }
                    else if (error) {
                        NSLog(@"push not sent with error: %@", error);
                    }
                }];
            }
        }];
        
    }
}

-(int)checkForBox:(GBCoordinate*)coordinate {
    int box = 0;
    
    int rows = [_game[@"NumberRows"] intValue];
    int cols = [_game[@"NumberCols"] intValue];
    if ((coordinate.vertical.boolValue == VERTICAL) && (coordinate.xCoordinate.intValue < rows)) {
        GBCoordinate *firstCheck = [[[_coordinates objectAtIndex:HORIZONTAL] objectAtIndex:[coordinate.xCoordinate intValue]] objectAtIndex:[coordinate.yCoordinate intValue]];
        if ( [firstCheck.highlighted boolValue] == LINE_PICKED ) {
            GBCoordinate *secondCheck = [[[_coordinates objectAtIndex:VERTICAL] objectAtIndex:[coordinate.xCoordinate intValue] + 1] objectAtIndex:[coordinate.yCoordinate intValue]];
            if ( [secondCheck.highlighted boolValue] == LINE_PICKED ) {
                GBCoordinate *thirdCheck = [[[_coordinates objectAtIndex:HORIZONTAL] objectAtIndex:[coordinate.xCoordinate intValue]] objectAtIndex:[coordinate.yCoordinate intValue] + 1];
                if ( [thirdCheck.highlighted boolValue] == LINE_PICKED ) {
                    box |= 0x1;
                }
            }
        }
        //firstCheck = [[[_coordinates objectAtIndex:HORIZONTAL] objectAtIndex:[coordinate]]]
    }
    if ((coordinate.vertical.boolValue == VERTICAL) && (coordinate.xCoordinate.intValue > 0)) {
        GBCoordinate *firstCheck = [[[_coordinates objectAtIndex:HORIZONTAL] objectAtIndex:coordinate.xCoordinate.intValue - 1] objectAtIndex:coordinate.yCoordinate.intValue];
        if ( firstCheck.highlighted.boolValue == LINE_PICKED ) {
            GBCoordinate *secondCheck = [[[_coordinates objectAtIndex:VERTICAL] objectAtIndex:coordinate.xCoordinate.intValue - 1] objectAtIndex:coordinate.yCoordinate.intValue];
            if (secondCheck.highlighted.boolValue == LINE_PICKED) {
                GBCoordinate *finalCheck = [[[_coordinates objectAtIndex:HORIZONTAL] objectAtIndex:coordinate.xCoordinate.intValue - 1] objectAtIndex:coordinate.yCoordinate.intValue + 1];
                if (finalCheck.highlighted.boolValue == LINE_PICKED) {
                    box |= 0x2;
                }
            }
        }
    }
    if ((coordinate.vertical.boolValue == HORIZONTAL) && (coordinate.yCoordinate.intValue < cols)) {
        GBCoordinate *firstCheck = [[[_coordinates objectAtIndex:VERTICAL] objectAtIndex:coordinate.xCoordinate.intValue] objectAtIndex:coordinate.yCoordinate.intValue];
        if (firstCheck.highlighted.boolValue == LINE_PICKED) {
            GBCoordinate *secondCheck = [[[_coordinates objectAtIndex:HORIZONTAL] objectAtIndex:coordinate.xCoordinate.intValue] objectAtIndex:coordinate.yCoordinate.intValue + 1];
            if (secondCheck.highlighted.boolValue == LINE_PICKED) {
                GBCoordinate *finalCheck = [[[_coordinates objectAtIndex:VERTICAL] objectAtIndex:coordinate.xCoordinate.intValue + 1] objectAtIndex:coordinate.yCoordinate.intValue];
                if (finalCheck.highlighted.boolValue == LINE_PICKED) {
                    box |= 0x4;
                }
            }
        }
    }
    if ((coordinate.vertical.boolValue == HORIZONTAL) && (coordinate.yCoordinate.intValue > 0)) {
        GBCoordinate *firstCheck = [[[_coordinates objectAtIndex:VERTICAL] objectAtIndex:coordinate.xCoordinate.intValue] objectAtIndex:coordinate.yCoordinate.intValue - 1];
        if (firstCheck.highlighted.boolValue == LINE_PICKED) {
            GBCoordinate *secondCheck = [[[_coordinates objectAtIndex:HORIZONTAL] objectAtIndex:coordinate.xCoordinate.intValue] objectAtIndex:coordinate.yCoordinate.intValue - 1];
            if (secondCheck.highlighted.boolValue == LINE_PICKED) {
                GBCoordinate *finalCheck = [[[_coordinates objectAtIndex:VERTICAL] objectAtIndex:coordinate.xCoordinate.intValue + 1] objectAtIndex:coordinate.yCoordinate.intValue - 1];
                if (finalCheck.highlighted.boolValue == LINE_PICKED) {
                    box |= 0x8;
                }
            }
        }
    }
    
    return box;
}

-(void)makeBox:(GBCoordinate*)coordinate {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(coordinate.xCoordinate.intValue * DOTSPACE + DOTSPACE + LINEHJUST + 5, coordinate.yCoordinate.intValue * DOTSPACE + DOTSPACE + 20, DOTSPACE - 10, DOTSPACE - 10)];
    imageView.layer.cornerRadius = 5.0;
    if (_playerOneTurn) {
        [imageView setImageWithString:_playerOneLetter color:BIOrange circular:NO fontName:@"Futura-Medium"];
        imageView.tintColor = BILightGrey;
        
        _opponentScoreLabel.text = [[NSNumber numberWithInteger:_playerOneBoxes.count] stringValue];
    }
    else {
        [imageView setImageWithString:_playerTwoLetter color:BIDarkGrey circular:NO fontName:@"Futura-Medium"];
        imageView.tintColor = BILightGrey;
        //int score = [_myScoreLabel.text intValue];
        //score++;
        _myScoreLabel.text = [[NSNumber numberWithInteger:_playerTwoBoxes.count] stringValue];
    }
    [_containerView addSubview:imageView];
    
}

-(void)checkForWinner {
    if (_playerOneBoxes.count > _playerTwoBoxes.count) {
        NSString *title = _opponentUserLabel.text;
        title = [title stringByAppendingString:@" Wins!!"];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:@"WooHoo!" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //up up
        }]];
        [self presentViewController:alert animated:YES completion:^{
            //up up
        }];
        [_game setObject:@YES forKey:@"winner"];
        [_game setObject:@YES forKey:@"completed"];
    }
    else {
        NSString *title = _myUserLabel.text;
        title = [title stringByAppendingString:@" Wins!!"];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:@"WooHoo!" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //up up
        }]];
        [self presentViewController:alert animated:YES completion:^{
            //up up
        }];
        [_game setObject:@NO forKey:@"winner"];
        [_game setObject:@YES forKey:@"completed"];
    }
    [_game setObject:@YES forKey:@"completed"];
    [_game saveInBackground];
}

-(void)receiveNotification:(NSNotification*)notification {
    if ([[notification name] isEqualToString:@"UpdateGameNotification"]) {
        NSLog(@"game received notification");
        if ([[notification object] isEqualToString:_game.objectId]) {
            //PFQuery *query = [PFQuery queryWithClassName:@"GameBoard"];
            //[query whereKey:@"objectId" equalTo:[notification object]];
            [_game unpin];
            [_game fetchInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
                _game = object;
                [self updateDataPoints];
            }];
        }
    }
    if ([[notification name] isEqualToString:@"UpdateUserInformation"]) {
        [[PFUser currentUser] fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
            //up up
        }];
    }
}

-(void)screenTapped:(id)sender {
    [_miniContainer setHidden:!_hideMini];
}

-(void)openMessenger:(id)sender {
    
    if (_gameType != LOCALTYPE) {
        MessagesViewController *messageViewController = [[MessagesViewController alloc] init];
        if ([[_game[@"PlayerOne"] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
            [messageViewController setOppUser:_game[@"PlayerTwo"]];
        }
        else {
            [messageViewController setOppUser:_game[@"PlayerOne"]];
        }
        
        messageViewController.delegateModal = self;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:messageViewController];
        [self presentViewController:nav animated:YES completion:^{
            //up up
        }];
    }
    
}

-(void)didDismissJSQDemoViewController:(MessagesViewController *)vc {
    [self dismissViewControllerAnimated:YES completion:^{
        //up up
    }];
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
