//
//  CompanyStuff.m
//  tvr
//
//  Created by Oleksii Vynogradov on 1/4/13.
//  Copyright (c) 2013 IXC-USA Corp. All rights reserved.
//

#import "CompanyStuff.h"
#import "Carrier.h"
#import "CurrentCompany.h"
#import "InvoicesAndPayments.h"


@implementation CompanyStuff

@dynamic creationDate;
@dynamic deviceToken;
@dynamic email;
@dynamic firstName;
@dynamic fromIP;
@dynamic GUID;
@dynamic isCompanyAdmin;
@dynamic isRegistrationDone;
@dynamic isRegistrationProcessed;
@dynamic lastName;
@dynamic login;
@dynamic modificationDate;
@dynamic password;
@dynamic phone;
@dynamic photo;
@dynamic toIP;
@dynamic transactionReceipt;
@dynamic userID;
@dynamic carrier;
@dynamic currentCompany;
@dynamic invoicesAndPayments;
@dynamic grossBookRecord;

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
