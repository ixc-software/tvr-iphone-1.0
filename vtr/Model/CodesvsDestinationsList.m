//
//  CodesvsDestinationsList.m
//  vtr
//
//  Created by Oleksii Vynogradov on 4/22/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import "CodesvsDestinationsList.h"
#import "DestinationsListForSale.h"
#import "DestinationsListPushList.h"
#import "DestinationsListTargets.h"
#import "DestinationsListWeBuy.h"


@implementation CodesvsDestinationsList

@dynamic code;
@dynamic country;
@dynamic creationDate;
@dynamic enabled;
@dynamic externalChangedDate;
@dynamic GUID;
@dynamic internalChangedDate;
@dynamic modificationDate;
@dynamic originalCode;
@dynamic peerID;
@dynamic prefix;
@dynamic rate;
@dynamic rateSheetID;
@dynamic rateSheetName;
@dynamic specific;
@dynamic destinationsListForSale;
@dynamic destinationsListPushList;
@dynamic destinationsListTargets;
@dynamic destinationsListWeBuy;
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
