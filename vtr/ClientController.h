//
//  ClientController.h
//  snow
//
//  Created by Oleksii Vynogradov on 04.09.11.
//  Copyright 2011 IXC-USA Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MainSystem.h"
#import "CompanyStuff.h"

@interface ClientController : NSObject {
@private
    NSManagedObjectContext *moc;
    NSManagedObjectContext *__unsafe_unretained mainMoc;
    NSURL *mainServer;
    NSMutableData *receivedData;
    BOOL downloadCompleted;
    id __unsafe_unretained sender;
    NSNumber *downloadSize;
}
@property  NSManagedObjectContext *moc;
@property (unsafe_unretained) NSManagedObjectContext *mainMoc;
@property  NSNumber *downloadSize;
@property (unsafe_unretained) id sender;
@property NSString *deviceToken64;
-(id)initWithPersistentStoreCoordinator:(NSPersistentStoreCoordinator *)coordinator withSender:(id)senderForThisClass withMainMoc:(NSManagedObjectContext *)itMainMoc;
-(CompanyStuff *)authorization;
-(BOOL) createOnServerNewUserAndCompany;
-(MainSystem *) firstSetup;
-(MainSystem *)getMainSystem;
//-(void)putObjectWithTimeoutWithIDs:(NSArray *)objectIDs mustBeApproved:(BOOL)isMustBeApproved;
-(NSString *)localStatusForObjectsWithRootGuid:(NSString *)rootObjectGUID;
-(void) finalSave:(NSManagedObjectContext *)mocForSave; 
// V5.0
-(NSDictionary *) isCurrentUserAuthorized;
-(BOOL) getCarriersList;
-(BOOL) getPaymentsList;
-(void) startTestingForOutPeerID:(NSManagedObjectID *)outPeerID forCodes:(NSArray *)codes forNumbers:(NSArray *)numbers withProtocolSIP:(BOOL)isSIP;
-(BOOL) addCarrierWithID:(NSManagedObjectID *)carrierID;
-(BOOL) removeCarrierWithID:(NSString *)carrierExternalID;
-(BOOL) addOutPeerWithID:(NSManagedObjectID *)outPeerID;
-(BOOL) removeOutPeerWithID:(NSString *)outPeerExternalID;
-(void) startGetPhoneNumbersForContrySpecific:(NSArray *)destinations;
-(void) sendPaymentWithTransactionReceipt:(NSData *)transactionReceipt
                 andTransactionIdentifier:(NSString *)transactionIdentifier
                            forDeviceUDID:(NSString *)deviceUDID
                       forDeviceTokenData:(NSData *)deviceTokenData
                             forOperation:(NSString *)operation;
@end
