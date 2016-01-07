//
//  FriendListViewController.m
//  BoxedIn
//
//  Created by Robert Miller on 11/5/15.
//  Copyright © 2015 Robert Miller. All rights reserved.
//

#import "FriendListViewController.h"
#import "FriendCell.h"
#import <Parse.h>
#import "BoxedInColors.h"
#import "UIImageView+Letters.h"
#import "FriendPageViewController.h"
#import <PFFacebookUtils.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <DVITutorialView.h>

@interface FriendListViewController ()

@property(nonatomic,retain) NSMutableArray *dataSource;
@property(nonatomic) BOOL tutorialComplete;
@property(nonatomic,retain) UITapGestureRecognizer *tapGesture;

@end

@implementation FriendListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:@"UpdateUserInformation" object:nil];
    _searchBar.tag = 1001;
    _tutorialComplete = false;
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    _dataSource = [[NSMutableArray alloc] init];
    _searchBar.delegate = self;
    _searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
    PFUser *currUser = [PFUser currentUser];
    NSArray *array = [[NSArray alloc] initWithArray:currUser[@"friendsList"]];
    
    PFQuery *query = [PFUser query];
    [query whereKey:@"objectId" containedIn:array];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        [_dataSource addObjectsFromArray:objects];
        [_tableView reloadData];
    }];
    
    if ([PFFacebookUtils isLinkedWithUser:currUser]) {
        // Issue a Facebook Graph API request to get your user's friend list
        [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                // result will contain an array with your user's friends in the "data" key
                NSArray *friendObjects = [result objectForKey:@"data"];
                NSMutableArray *friendIds = [NSMutableArray arrayWithCapacity:friendObjects.count];
                // Create a list of friends' Facebook IDs
                for (NSDictionary *friendObject in friendObjects) {
                    [friendIds addObject:[friendObject objectForKey:@"id"]];
                }
                
                // Construct a PFUser query that will find friends whose facebook ids
                // are contained in the current user's friend list.
                PFQuery *friendQuery = [PFUser query];
                [friendQuery whereKey:@"fbID" containedIn:friendIds];
                
                // findObjects will return a list of PFUsers that are friends
                // with the current user
                NSArray *friendUsers = [friendQuery findObjects];
                [_dataSource addObjectsFromArray:friendUsers];
            }
        }];
    }
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"FirstTimeFriendList"] boolValue] == false) {
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(startTutorial)];
        [self.view addGestureRecognizer:_tapGesture];
    }
    
}

-(void)viewDidLayoutSubviews {
    //_tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(startTutorial)];
    //[self.view addGestureRecognizer:_tapGesture];
    
    
}

-(void)startTutorial {
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"FirstTimeFriendList"] boolValue] == false) {
        if (!_tutorialComplete) {
            DVITutorialView *tutorialView = [[DVITutorialView alloc] init];
            [tutorialView addToView:self.view];
            
            tutorialView.tutorialStrings = @[
                                             @"Tap the Search Bar to Filter, Find, and Add Friends..",
                                             @"Get Started!",
                                             ];
            
            tutorialView.tutorialViews = @[
                                           _searchBar,
                                           [[UIView alloc] init],
                                           ];
            
            [tutorialView startWithCompletion:^{
                [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:@"FirstTimeFriendList"];
                _tutorialComplete = true;
                [_tapGesture setEnabled:NO];
            }];
        }
        else {
            [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:@"FirstTimeFriendList"];
            [_tapGesture setEnabled:NO];
        }
    }
    else {
        [_tapGesture setEnabled:NO];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FriendCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"FriendCell"];
    
    PFUser *user = [_dataSource objectAtIndex:indexPath.row];
    cell.friendLabel.text = [user username];
    cell.friendScore.text = [user[@"totalWins"] stringValue];
    [cell.imageView setImageWithString:@"P" color:BIDarkGrey];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    FriendPageViewController *friendPage = [storyboard instantiateViewControllerWithIdentifier:@"friendPageViewController"];
    friendPage.friendUser = [_dataSource objectAtIndex:indexPath.row];
    
    [self presentViewController:friendPage animated:YES completion:^{
        //up up
    }];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 94;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataSource.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_searchBar resignFirstResponder];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [PFQuery cancelPreviousPerformRequestsWithTarget:self];
    PFQuery *query = [PFUser query];
    [query whereKey:@"username" containsString:searchText];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        [_dataSource removeAllObjects];
        [_dataSource addObjectsFromArray:objects];
        [_tableView reloadData];
    }];
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
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
