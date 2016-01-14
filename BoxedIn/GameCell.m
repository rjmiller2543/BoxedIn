//
//  GameCell.m
//  BoxedIn
//
//  Created by Robert Miller on 11/6/15.
//  Copyright © 2015 Robert Miller. All rights reserved.
//

#import "GameCell.h"
#import "UIImageView+Letters.h"
#import "BoxedInColors.h"

@implementation GameCell

- (void)awakeFromNib {
    // Initialization code
}

-(void)setupView {
    PFUser *user = [PFUser currentUser];
    _youLetterView.image = nil;
    
    PFUser *playerOne = _game[@"PlayerOne"];
    PFUser *playerTwo = _game[@"PlayerTwo"];
    
    //[playerOne fetch];
    //[playerTwo fetch];
    
    //[_game fetch];
    
    if ([playerOne isEqual:user]) {
        if ([_game[@"playerOneTurn"] boolValue]) {
            _meLabel.textColor = BIPurple;
            _meScore.textColor = BIPurple;
            _youLabel.textColor = BILightGrey;
            _youScore.textColor = BILightGrey;
            //const unichar firstLetterChar = [playerTwo.username characterAtIndex:1];
            //NSString *firstLetterString = [NSString stringWithCharacters:&firstLetterChar length:1];
            //[_youLetterView setImageWithString:firstLetterString color:BIPurple circular:NO];
        }
        else {
            _meLabel.textColor = BILightGrey;
            _meScore.textColor = BILightGrey;
            _youLabel.textColor = BIPurple;
            _youScore.textColor = BIPurple;
            //const unichar firstLetterChar = [playerOne.username characterAtIndex:1];
            //NSString *firstLetterString = [NSString stringWithCharacters:&firstLetterChar length:1];
            //[_youLetterView setImageWithString:firstLetterString color:BILightGrey circular:NO];
        }
        NSString *meLabelText = @"@";
        if (playerOne == nil) {
            _meLabel.text = [meLabelText stringByAppendingString:@"PlayerOne"];
        }
        else {
            if ([playerOne isDataAvailable]) {
                _meLabel.text = [meLabelText stringByAppendingString:playerOne.username];
            }
            else {
                [playerOne fetchInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
                    _meLabel.text = [meLabelText stringByAppendingString:playerOne.username];
                }];
            }
        }
        
        PFFile *playerOneBoxesFile = _game[@"PlayerOneBoxes"];
        NSData *data = [playerOneBoxesFile getData];
        NSArray *playerOneBoxes = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        _meScore.text = [[NSNumber numberWithUnsignedInteger:playerOneBoxes.count] stringValue];
        
        NSString *youLabelText = @"@";
        if (playerTwo == nil) {
            _youLabel.text = [youLabelText stringByAppendingString:@"PlayerTwo"];
        }
        else {
            if ([playerTwo isDataAvailable]) {
                _youLabel.text = [youLabelText stringByAppendingString:playerTwo.username];
            }
            else {
                [playerTwo fetchInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
                    _youLabel.text = [youLabelText stringByAppendingString:playerTwo.username];
                }];
            }
        }
        
        PFFile *playerTwoBoxesFile = _game[@"PlayerTwoBoxes"];
        NSData *twoData = [playerTwoBoxesFile getData];
        NSArray *playerTwoBoxes = [NSKeyedUnarchiver unarchiveObjectWithData:twoData];
        _youScore.text = [[NSNumber numberWithUnsignedInteger:playerTwoBoxes.count] stringValue];
        
        const unichar firstLetterChar = [_youLabel.text characterAtIndex:1];
        NSString *firstLetterString = [NSString stringWithCharacters:&firstLetterChar length:1];
        [_youLetterView setImageWithString:firstLetterString color:BILightGrey circular:NO];
    }
    else {
        if ([_game[@"playerOneTurn"] boolValue]) {
            _meLabel.textColor = BILightGrey;
            _meScore.textColor = BILightGrey;
            _youLabel.textColor = BIPurple;
            _youScore.textColor = BIPurple;
            //const unichar firstLetterChar = [playerTwo.username characterAtIndex:1];
            //NSString *firstLetterString = [NSString stringWithCharacters:&firstLetterChar length:1];
            //[_youLetterView setImageWithString:firstLetterString color:BILightGrey circular:NO];
        }
        else {
            _meLabel.textColor = BIPurple;
            _meScore.textColor = BIPurple;
            _youLabel.textColor = BILightGrey;
            _youScore.textColor = BILightGrey;
            //const unichar firstLetterChar = [playerOne.username characterAtIndex:1];
            //NSString *firstLetterString = [NSString stringWithCharacters:&firstLetterChar length:1];
            //[_youLetterView setImageWithString:firstLetterString color:BIPurple circular:NO];
        }
        NSString *meLabelText = @"@";
        if (playerTwo == nil) {
            _meLabel.text = [meLabelText stringByAppendingString:@"PlayerTwo"];
        }
        else {
            if ([playerTwo isDataAvailable]) {
                _meLabel.text = [meLabelText stringByAppendingString:playerTwo.username];
            }
            else {
                [playerTwo fetchInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
                    _meLabel.text = [meLabelText stringByAppendingString:playerTwo.username];
                }];
            }
        }
        
        PFFile *playerTwoBoxesFile = _game[@"PlayerTwoBoxes"];
        NSData *data = [playerTwoBoxesFile getData];
        NSArray *playerTwoBoxes = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        _meScore.text = [[NSNumber numberWithUnsignedInteger:playerTwoBoxes.count] stringValue];
        
        NSString *youLabelText = @"@";
        if (playerOne == nil) {
            _youLabel.text = [youLabelText stringByAppendingString:@"PlayerOne"];
        }
        else {
            if ([playerOne isDataAvailable]) {
                _youLabel.text = [youLabelText stringByAppendingString:playerOne.username];
            }
            else {
                [playerOne fetchInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
                    _youLabel.text = [youLabelText stringByAppendingString:playerOne.username];
                }];
            }
        }
        
        PFFile *playerOneBoxesFile = _game[@"PlayerOneBoxes"];
        NSData *twoData = [playerOneBoxesFile getData];
        NSArray *playerOneBoxes = [NSKeyedUnarchiver unarchiveObjectWithData:twoData];
        _youScore.text = [[NSNumber numberWithUnsignedInteger:playerOneBoxes.count] stringValue];
        
        const unichar firstLetterChar = [_youLabel.text characterAtIndex:1];
        NSString *firstLetterString = [NSString stringWithCharacters:&firstLetterChar length:1];
        [_youLetterView setImageWithString:firstLetterString color:BILightGrey circular:NO];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
