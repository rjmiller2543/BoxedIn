//
//  GameListViewController.m
//  BoxedIn
//
//  Created by Robert Miller on 11/5/15.
//  Copyright © 2015 Robert Miller. All rights reserved.
//

#import "GameListViewController.h"
#import "GameCell.h"
#import <Parse.h>
#import "BoxedInColors.h"
#import "GameBoardViewController.h"
#import <SVPullToRefresh.h>

@interface GameListViewController ()

@property(nonatomic,retain) NSMutableArray *currentGamesArray;
@property(nonatomic,retain) NSMutableArray *previousGamesArray;

@end

@implementation GameListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:@"UpdateUserInformation" object:nil];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    __weak typeof(self) weakSelf = self;
    [_tableView addPullToRefreshWithActionHandler:^{
        [weakSelf refreshData];
    }];
    
    _currentGamesArray = [[NSMutableArray alloc] init];
    _previousGamesArray = [[NSMutableArray alloc] init];
    
    //[_tableView registerClass:[GameCell class] forCellReuseIdentifier:@"GameCell"];
    PFUser *user = [PFUser currentUser];
    if (user != nil) {
        NSPredicate *currpredicate = [NSPredicate predicateWithFormat:@"(PlayerOne = %@ OR PlayerTwo = %@) AND completed = 0", user, user];
        PFQuery *currquery = [PFQuery queryWithClassName:@"GameBoard" predicate:currpredicate];
        [currquery orderByDescending:@"updatedAt"];
        [currquery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            [_currentGamesArray removeAllObjects];
            [_currentGamesArray addObjectsFromArray:objects];
        }];
        
        NSPredicate *prevpredicate = [NSPredicate predicateWithFormat:@"(PlayerOne = %@ OR PlayerTwo = %@) AND completed = 1", user, user];
        PFQuery *prevquery = [PFQuery queryWithClassName:@"GameBoard" predicate:prevpredicate];
        [prevquery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            [_previousGamesArray removeAllObjects];
            [_previousGamesArray addObjectsFromArray:objects];
        }];
    }
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:180.0 target:self selector:@selector(refreshData) userInfo:nil repeats:YES];
    [timer fire];
    
    /*
    PFQuery *query = [PFQuery queryWithClassName:@"GameBoard"];
    [query whereKey:@"PlayerOne" equalTo:user];
    [query whereKey:@"PlayerTwo" equalTo:user];
    [query whereKey:@"completed" equalTo:[NSNumber numberWithBool:false]];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        [_currentGamesArray addObjectsFromArray:objects];
    }];
    
    PFQuery *prevQuery = [PFQuery queryWithClassName:@"GameBoard"];
    [prevQuery whereKey:@"PlayerOne" equalTo:user];
    [prevQuery whereKey:@"PlayerTwo" equalTo:user];
    [prevQuery whereKey:@"completed" equalTo:[NSNumber numberWithBool:true]];
    [prevQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        [_previousGamesArray addObjectsFromArray:objects];
    }];
     */
}

/*
-(void)viewDidAppear:(BOOL)animated {
    PFUser *user = [PFUser currentUser];
    if (user != nil) {
        NSPredicate *currpredicate = [NSPredicate predicateWithFormat:@"(PlayerOne = %@ OR PlayerTwo = %@) AND completed = NO", user, user];
        PFQuery *currquery = [PFQuery queryWithClassName:@"GameBoard" predicate:currpredicate];
        [currquery orderByDescending:@"updatedAt"];
        [currquery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            NSLog(@"finished finding curr games");
            if (error) {
                NSLog(@"Error finding curr games with error: %@", error);
            }
            [_currentGamesArray removeAllObjects];
            [_currentGamesArray addObjectsFromArray:objects];
            [_tableView reloadData];
        }];
        
        NSPredicate *prevpredicate = [NSPredicate predicateWithFormat:@"(PlayerOne = %@ OR PlayerTwo = %@) AND completed = YES", user, user];
        PFQuery *prevquery = [PFQuery queryWithClassName:@"GameBoard" predicate:prevpredicate];
        [prevquery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            [_previousGamesArray removeAllObjects];
            [_previousGamesArray addObjectsFromArray:objects];
            [_tableView reloadData];
        }];
    }
    
    NSTimer *timer = [NSTimer timerWithTimeInterval:90.0 target:self selector:@selector(refreshData) userInfo:nil repeats:YES];
    [timer fire];
    //[_tableView reloadData];
}
 */

-(void)refreshData {
    PFUser *user = [PFUser currentUser];
    if (user != nil) {
        NSPredicate *currpredicate = [NSPredicate predicateWithFormat:@"(PlayerOne = %@ OR PlayerTwo = %@) AND completed = NO", user, user];
        PFQuery *currquery = [PFQuery queryWithClassName:@"GameBoard" predicate:currpredicate];
        [currquery orderByDescending:@"updatedAt"];
        [currquery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            NSLog(@"finished finding curr games");
            if (error) {
                NSLog(@"Error finding curr games with error: %@", error);
            }
            [_currentGamesArray removeAllObjects];
            [_currentGamesArray addObjectsFromArray:objects];
            [_tableView reloadData];
        }];
        
        NSPredicate *prevpredicate = [NSPredicate predicateWithFormat:@"(PlayerOne = %@ OR PlayerTwo = %@) AND completed = YES", user, user];
        PFQuery *prevquery = [PFQuery queryWithClassName:@"GameBoard" predicate:prevpredicate];
        [prevquery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            [_previousGamesArray removeAllObjects];
            [_previousGamesArray addObjectsFromArray:objects];
            [_tableView reloadData];
            [_tableView.pullToRefreshView stopAnimating];
        }];
    }
}

-(void)refreshTableView {
    [_tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GameCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"GameCell"];
    
    if (indexPath.section == 0) {
        if (_currentGamesArray.count == 0) {
            cell.textLabel.text = @"You don't have any current games.. Go and start one with a friend!";
            cell.textLabel.backgroundColor = BIGreen;
            cell.textLabel.textColor = BILightGrey;
            cell.textLabel.numberOfLines = 2;
            cell.textLabel.font = [UIFont fontWithName:@"Futura-Medium" size:14.0f];
            CGRect rect = cell.textLabel.frame;
            rect.size.height = 10;
            [cell setFrame:rect];
            //cell.textLabel.sizeToFit;
        }
        else {
            cell.textLabel.text = @"";
            cell.textLabel.backgroundColor = [UIColor clearColor];
            cell.game = [_currentGamesArray objectAtIndex:indexPath.row];
            [cell setupView];
        }
    }
    else if (indexPath.section == 1) {
        if (_previousGamesArray.count == 0) {
            cell.textLabel.text = @"You don't have any previous games..";
            cell.textLabel.backgroundColor = BIGreen;
            cell.textLabel.textColor = BILightGrey;
            cell.textLabel.font = [UIFont fontWithName:@"Futura-Medium" size:14.0f];
            CGRect rect = cell.textLabel.frame;
            rect.size.height = 70;
            [cell setFrame:rect];
        }
        else {
            cell.game = [_previousGamesArray objectAtIndex:indexPath.row];
            [cell setupView];
        }
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    GameBoardViewController *gameBoard = [storyboard instantiateViewControllerWithIdentifier:@"gameBoardViewController"];
    if (indexPath.section == 0) {
        gameBoard.game = [_currentGamesArray objectAtIndex:indexPath.row];
    }
    else {
        gameBoard.game = [_previousGamesArray objectAtIndex:indexPath.row];
    }
    //UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:self];
//    self.navigationController
    //[gameBoard setupGameBoard];
    //[self.navigationController pushViewController:gameBoard animated:YES];
    [self presentViewController:gameBoard animated:YES completion:^{
        // up up
    }];
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 5;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 15;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 104;
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return @"";
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *sectionString = @"";
    
    switch (section) {
        case 0:
            sectionString = @"Current Games";
            break;
        case 1:
            sectionString = @"Previous Games";
            
        default:
            break;
    }
    
    return sectionString;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSUInteger numGames = 0;
    switch (section) {
        case 0:
            numGames = _currentGamesArray.count;
            break;
        case 1:
            numGames = _previousGamesArray.count;
            
        default:
            break;
    }
    if (numGames == 0) {
        numGames = 1;
    }
    return numGames;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

-(void)receiveNotification:(NSNotification*)notification {
    if ([[notification name] isEqualToString:@"UpdateUserInformation"]) {
        [[PFUser currentUser] fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
            //up up
            [self refreshData];
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
