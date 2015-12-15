//
//  PFFile+Coder.h
//  BoxedIn
//
//  Created by Robert Miller on 12/3/15.
//  Copyright © 2015 Robert Miller. All rights reserved.
//

#import <Parse/Parse.h>

@interface PFFile (Coder)

-(void)encodeWithCoder:(NSCoder*)encoder;
-(id)initWithCoder:(NSCoder*)aDecoder;

@end