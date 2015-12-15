//
//  NewFriendGameViewController.m
//  BoxedIn
//
//  Created by Robert Miller on 11/20/15.
//  Copyright © 2015 Robert Miller. All rights reserved.
//

#import "NewFriendGameViewController.h"
#import "BoxedInColors.h"
#import <Parse.h>

@interface NewFriendGameViewController ()

@end

@implementation NewFriendGameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [_rowStepper configureFlatStepperWithColor:BIGreen highlightedColor:BILightGrey disabledColor:BIDarkGrey iconColor:BILightGrey];
    [_rowStepper addTarget:self action:@selector(rowChanged) forControlEvents:UIControlEventValueChanged];
    _rowStepper.value = 10;
    
    [_colStepper configureFlatStepperWithColor:BIGreen highlightedColor:BILightGrey disabledColor:BIDarkGrey iconColor:BILightGrey];
    [_colStepper addTarget:self action:@selector(colChanged) forControlEvents:UIControlEventValueChanged];
    _colStepper.value = 10;
}

-(void)rowChanged {
    _rowTextField.text = [[NSNumber numberWithDouble:_rowStepper.value] stringValue];
}

-(void)colChanged {
    _colTextField.text = [[NSNumber numberWithDouble:_colStepper.value] stringValue];
}

-(void)startButtonPressed:(id)sender {
    
}

-(void)receiveNotification:(NSNotification*)notification {
    if ([[notification name] isEqualToString:@"UpdateUserInformation"]) {
        [[PFUser currentUser] fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
            //up up
        }];
    }
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
