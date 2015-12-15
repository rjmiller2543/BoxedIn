//
//  PFObject+Coder.m
//  BoxedIn
//
//  Created by Robert Miller on 12/1/15.
//  Copyright © 2015 Robert Miller. All rights reserved.
//

#import "PFObject+Coder.h"

@interface PFObject (CoderPrivate)


@end

@implementation PFObject (Coder)

#pragma mark - NSCoding compliance
#define kPFObjectAllKeys @"___PFObjectAllKeys"
#define kPFObjectClassName @"___PFObjectClassName"
#define kPFObjectObjectID @"___PFObjectID"
#define kPFACLPermissions @"permissionsById"

-(void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:[self parseClassName] forKey:kPFObjectClassName];
    [encoder encodeObject:[self objectId] forKey:kPFObjectObjectID];
    [encoder encodeObject:[self allKeys] forKey:kPFObjectAllKeys];
    for (NSString * key in [self allKeys]) {
        [encoder encodeObject:[self objectForKey:key] forKey:key];
    }
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    NSString *aClassName = [aDecoder decodeObjectForKey:kPFObjectClassName];
    NSString *anObjectId = [aDecoder decodeObjectForKey:kPFObjectObjectID];
    
    self = [PFObject objectWithoutDataWithClassName:aClassName objectId:anObjectId];
    
    if (self) {
        NSArray *allKeys = [aDecoder decodeObjectForKey:kPFObjectAllKeys];
        for (NSString * key in allKeys) {
            id obj = [aDecoder decodeObjectForKey:key];
            if (obj) {
                [self setObject:[aDecoder decodeObjectForKey:key] forKey:key];
            }
        }
    }
    return self;
}

@end

@implementation PFACL (Coder)

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[self valueForKey:kPFACLPermissions] forKey:kPFACLPermissions];
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        [self setValue:[aDecoder decodeObjectForKey:kPFACLPermissions] forKey:kPFACLPermissions];
    }
    return self;
}

@end
