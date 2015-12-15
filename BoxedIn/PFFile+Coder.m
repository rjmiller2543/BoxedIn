//
//  PFFile+Coder.m
//  BoxedIn
//
//  Created by Robert Miller on 12/3/15.
//  Copyright © 2015 Robert Miller. All rights reserved.
//

#import "PFFile+Coder.h"
#import <objc/runtime.h>

#define kPFFileName @"_name"
#define kPFFileURL @"_url"
#define kPFFileData @"data"

@implementation PFFile (Coder)

-(void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.name forKey:kPFFileName];
    [encoder encodeObject:self.url forKey:kPFFileURL];
    if (self.isDataAvailable) {
        [encoder encodeObject:[self getData] forKey:kPFFileData];
    }
}

-(id)initWithCoder:(NSCoder *)aDecoder  {
    NSString *name = [aDecoder decodeObjectForKey:kPFFileName];
    NSString *url = [aDecoder decodeObjectForKey:kPFFileURL];
    NSData *data = [aDecoder decodeObjectForKey:kPFFileData];
    
    self = [PFFile fileWithName:name data:data];
    if (self) {
        if (url) {
            [self setValue:url forKey:kPFFileURL];
        }
    }
    return self;
}

@end