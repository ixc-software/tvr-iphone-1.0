//
//  CompanyStuff.h
//  tvr
//
//  Created by Oleksii Vynogradov on 1/4/13.
//  Copyright (c) 2013 IXC-USA Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Carrier, CurrentCompany, InvoicesAndPayments;

@interface CompanyStuff : NSManagedObject

@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSData * deviceToken;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * fromIP;
@property (nonatomic, retain) NSString * GUID;
@property (nonatomic, retain) NSNumber * isCompanyAdmin;
@property (nonatomic, retain) NSNumber * isRegistrationDone;
@property (nonatomic, retain) NSNumber * isRegistrationProcessed;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * login;
@property (nonatomic, retain) NSDate * modificationDate;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSData * photo;
@property (nonatomic, retain) NSString * toIP;
@property (nonatomic, retain) NSData * transactionReceipt;
@property (nonatomic, retain) NSString * userID;
@property (nonatomic, retain) NSSet *carrier;
@property (nonatomic, retain) CurrentCompany *currentCompany;
@property (nonatomic, retain) NSSet *invoicesAndPayments;
@property (nonatomic, retain) NSOrderedSet *grossBookRecord;
@end

@interface CompanyStuff (CoreDataGeneratedAccessors)

- (void)addCarrierObject:(Carrier *)value;
- (void)removeCarrierObject:(Carrier *)value;
- (void)addCarrier:(NSSet *)values;
- (void)removeCarrier:(NSSet *)values;

- (void)addInvoicesAndPaymentsObject:(InvoicesAndPayments *)value;
- (void)removeInvoicesAndPaymentsObject:(InvoicesAndPayments *)value;
- (void)addInvoicesAndPayments:(NSSet *)values;
- (void)removeInvoicesAndPayments:(NSSet *)values;

- (void)insertObject:(NSManagedObject *)value inGrossBookRecordAtIndex:(NSUInteger)idx;
- (void)removeObjectFromGrossBookRecordAtIndex:(NSUInteger)idx;
- (void)insertGrossBookRecord:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeGrossBookRecordAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInGrossBookRecordAtIndex:(NSUInteger)idx withObject:(NSManagedObject *)value;
- (void)replaceGrossBookRecordAtIndexes:(NSIndexSet *)indexes withGrossBookRecord:(NSArray *)values;
- (void)addGrossBookRecordObject:(NSManagedObject *)value;
- (void)removeGrossBookRecordObject:(NSManagedObject *)value;
- (void)addGrossBookRecord:(NSOrderedSet *)values;
- (void)removeGrossBookRecord:(NSOrderedSet *)values;
@end
