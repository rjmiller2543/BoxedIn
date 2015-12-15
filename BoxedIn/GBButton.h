//
//  GBButton.h
//  BoxedIn
//
//  Created by Robert Miller on 11/11/15.
//  Copyright © 2015 Robert Miller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GBCoordinate.h"

@interface GBButton : UIButton

@property(nonatomic,retain) GBCoordinate *coordinate;

@end
