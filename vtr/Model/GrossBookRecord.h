//
//  GrossBookRecord.h
//  tvr
//
//  Created by Oleksii Vynogradov on 1/4/13.
//  Copyright (c) 2013 IXC-USA Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CompanyStuff;

@interface GrossBookRecord : NSManagedObject

@property (nonatomic, retain) NSString * tariffPlan;
@property (nonatomic, retain) NSNumber * paymentAmount;
@property (nonatomic, retain) NSString * userID;
@property (nonatomic, retain) NSData * receiptFromItunes;
@property (nonatomic, retain) NSString * transactionIdentifier;
@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) CompanyStuff *companyStuff;

@end
