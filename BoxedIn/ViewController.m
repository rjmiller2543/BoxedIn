//
//  ViewController.m
//  BoxedIn
//
//  Created by Robert Miller on 11/5/15.
//  Copyright © 2015 Robert Miller. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import <Parse.h>
#import "LoginViewController.h"
#import <iAd/iAd.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //ADInterstitialAd *ad = [[ADInterstitialAd alloc] init];
    //[self setInterstitialPresentationPolicy:ADInterstitialPresentationPolicyManual];
    //[UIViewController prepareInterstitialAds];
    //dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
    //    [self requestInterstitialAdPresentation];
    //});
    //[self requestInterstitialAdPresentation];
}

-(void)viewDidAppear:(BOOL)animated {
    PFUser *user = [PFUser currentUser];
    if (user == nil) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LoginViewController *login = [storyboard instantiateViewControllerWithIdentifier:@"loginViewController"];
        
        [self presentViewController:login animated:YES completion:^{
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
