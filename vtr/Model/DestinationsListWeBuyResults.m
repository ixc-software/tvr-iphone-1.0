//
//  DestinationsListWeBuyResults.m
//  vtr
//
//  Created by Oleksii Vynogradov on 4/22/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import "DestinationsListWeBuyResults.h"
#import "DestinationsListWeBuyTesting.h"


@implementation DestinationsListWeBuyResults

@dynamic call_id;
@dynamic callMP3;
@dynamic creationDate;
@dynamic disconnect_cause;
@dynamic disconnect_code;
@dynamic dstnum;
@dynamic duration;
@dynamic fasReason;
@dynamic GUID;
@dynamic iD;
@dynamic inpack;
@dynamic inputPackets;
@dynamic isFAS;
@dynamic log;
@dynamic media_g729;
@dynamic media_g729_ring;
@dynamic media_ogg;
@dynamic media_ogg_ring;
@dynamic modificationDate;
@dynamic numberA;
@dynamic numberB;
@dynamic outpack;
@dynamic outputPackets;
@dynamic ringingOK;
@dynamic ringMP3;
@dynamic srcnum;
@dynamic timeInvite;
@dynamic timeOk;
@dynamic timeRelease;
@dynamic timeRinging;
@dynamic timeSetup;
@dynamic timeTrying;
@dynamic tryingRinging;
@dynamic ts_invite;
@dynamic ts_ok;
@dynamic ts_release;
@dynamic ts_ringing;
@dynamic ts_trying;
@dynamic destinationsListWeBuyTesting;
- (void)awakeFromInsert {
    NSDate *now = [NSDate date];
    
    [self willChangeValueForKey:@"GUID"];
    [self setPrimitiveValue:[[NSProcessInfo processInfo] globallyUniqueString] forKey:@"GUID"];
    [self didChangeValueForKey:@"GUID"];
    
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
