//
//  PFObject+Coder.h
//  BoxedIn
//
//  Created by Robert Miller on 12/1/15.
//  Copyright © 2015 Robert Miller. All rights reserved.
//

#import <Parse/Parse.h>

@interface PFObject (Coder)

-(void)encodeWithCoder:(NSCoder*)encoder;
-(id)initWithCoder:(NSCoder*)aDecoder;

@end

@interface PFACL (Coder)

-(void)encodeWithCoder:(NSCoder *)aCoder;
-(id)initWithCoder:(NSCoder *)aDecoder;

@end
