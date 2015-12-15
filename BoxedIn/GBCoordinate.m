//
//  GBCoordinate.m
//  BoxedIn
//
//  Created by Robert Miller on 11/11/15.
//  Copyright © 2015 Robert Miller. All rights reserved.
//

#import "GBCoordinate.h"

@implementation GBCoordinate

-(id)initWithCoder:(NSCoder*)aDecoder {
    if (self = [super init]) {
        [self setXCoordinate:[aDecoder decodeObjectForKey:@"xCoordinate"]];
        [self setYCoordinate:[aDecoder decodeObjectForKey:@"yCoordinate"]];
        [self setVertical:[aDecoder decodeObjectForKey:@"vertical"]];
        [self setHighlighted:[aDecoder decodeObjectForKey:@"highlighted"]];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder*)aCoder {
    [aCoder encodeObject:_xCoordinate forKey:@"xCoordinate"];
    [aCoder encodeObject:_yCoordinate forKey:@"yCoordinate"];
    [aCoder encodeObject:_vertical forKey:@"vertical"];
    [aCoder encodeObject:_highlighted forKey:@"highlighted"];
}

@end
