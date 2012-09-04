//
//  OutPeer.m
//  tvr
//
//  Created by Oleksii Vynogradov on 7/4/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import "OutPeer.h"
#import "Carrier.h"
#import "DestinationsListWeBuyTesting.h"


@implementation OutPeer

@dynamic outpeerID;
@dynamic outpeerName;
@dynamic isEnable;
@dynamic outpeerPrefix;
@dynamic outpeerSecondName;
@dynamic outpeerTag;
@dynamic guid;
@dynamic creationDate;
@dynamic modificationDate;
@dynamic ips;
@dynamic carrier;
@dynamic destinationsListWeBuyTesting;
- (void)awakeFromInsert {
    NSDate *now = [NSDate date];
    
    [self willChangeValueForKey:@"guid"];
    [self setPrimitiveValue:[[NSProcessInfo processInfo] globallyUniqueString] forKey:@"guid"];
    [self didChangeValueForKey:@"guid"];
    
    [self willChangeValueForKey:@"creationDate"];
    [self setPrimitiveValue:now forKey:@"creationDate"];
    [self didChangeValueForKey:@"creationDate"];
    
    [self willChangeValueForKey:@"modificationDate"];
    [self setPrimitiveValue:now forKey:@"modificationDate"];
    [self didChangeValueForKey:@"modificationDate"];
}

-(void)willSave {
    NSDate *now = [NSDate date];
    if ([self isUpdated]) {
        
        
        if (self.modificationDate == nil || [now timeIntervalSinceDate:self.modificationDate] > 1.0) {
            self.modificationDate = now;
        }
    }
}

@end
