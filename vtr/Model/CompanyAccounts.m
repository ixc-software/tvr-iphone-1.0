//
//  CompanyAccounts.m
//  vtr
//
//  Created by Oleksii Vynogradov on 4/22/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import "CompanyAccounts.h"
#import "CurrentCompany.h"
#import "InvoicesAndPayments.h"


@implementation CompanyAccounts

@dynamic balance;
@dynamic bankABA;
@dynamic bankAccountNumber;
@dynamic bankAddress;
@dynamic bankIBAN;
@dynamic bankName;
@dynamic bankSwift;
@dynamic creationDate;
@dynamic externalID;
@dynamic GUID;
@dynamic modificationDate;
@dynamic name;
@dynamic currentCompany;
@dynamic invoicesAndPayments;
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
