//
//  GrossBookRecord.m
//  tvr
//
//  Created by Oleksii Vynogradov on 1/4/13.
//  Copyright (c) 2013 IXC-USA Corp. All rights reserved.
//

#import "GrossBookRecord.h"
#import "CompanyStuff.h"


@implementation GrossBookRecord

@dynamic tariffPlan;
@dynamic paymentAmount;
@dynamic userID;
@dynamic receiptFromItunes;
@dynamic transactionIdentifier;
@dynamic creationDate;
@dynamic companyStuff;

- (void)awakeFromInsert {
    NSDate *now = [NSDate date];
    
    [self willChangeValueForKey:@"creationDate"];
    [self setPrimitiveValue:now forKey:@"creationDate"];
    [self didChangeValueForKey:@"creationDate"];
}


@end
