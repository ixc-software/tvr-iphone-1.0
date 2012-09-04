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

@property  NSURL *mainServer;
@property NSString *deviceToken64;

-(id)initWithPersistentStoreCoordinator:(NSPersistentStoreCoordinator *)coordinator withSender:(id)senderForThisClass withMainMoc:(NSManagedObjectContext *)itMainMoc;


-(CompanyStuff *)authorization;
-(BOOL) createOnServerNewUserAndCompany;

//-(BOOL)checkIfCurrentAdminCanLogin;

-(MainSystem *) firstSetup;

-(MainSystem *)getMainSystem;


-(void)getCompaniesListWithImmediatelyStart:(BOOL)isImmediatelyStart;
-(NSString *)getAllObjectsForEntity:(NSString *)entityName immediatelyStart:(BOOL)isImmediatelyStart isUserAuthorized:(BOOL)isUserAuthorized;
-(void)putObjectWithTimeoutWithIDs:(NSArray *)objectIDs mustBeApproved:(BOOL)isMustBeApproved;
-(void)removeObjectWithID:(NSManagedObjectID *)objectID;

-(void) setUserDefaultsObject:(id)object forKey:(NSString *)key;
-(NSString *)localStatusForObjectsWithRootGuid:(NSString *)rootObjectGUID;
-(void) finalSave:(NSManagedObjectContext *)mocForSave; 
//-(BOOL) checkIfCurrentAdminCanLogin;
-(void) updateLocalGraphFromSnowEnterpriseServerWithDateFrom:(NSDate *)dateFrom 
                                                  withDateTo:(NSDate *)dateTo
                               withIncludeCarrierSubentities:(BOOL)isIncludeCarrierSubentities;

-(NSArray *)getAllObjectsListWithEntityForList:(NSString *)entityForList 
                            withMainObjectGUID:(NSString *)mainObjectGUID 
                          withMainObjectEntity:(NSString *)mainObjectEntity 
                                     withAdmin:(CompanyStuff *)admin  
                                  withDateFrom:(NSDate *)dateFrom 
                                    withDateTo:(NSDate *)dateTo;
-(NSArray *)getAllObjectsWithGUIDs:(NSArray *)guids 
                            withEntity:(NSString *)entity 
                             withAdmin:(CompanyStuff *)admin;
-(NSArray *) updateGraphForObjects:(NSArray *)allObjects 
                        withEntity:(NSString *)entityFor 
                         withAdmin:(CompanyStuff *)admin 
                    withRootObject:(NSManagedObject *)rootObject
             isEveryTenPercentSave:(BOOL)isEveryTenPercentSave
        isNecessaryToLocalRegister:(BOOL)isNecessaryToLocalRegister;

-(void) updateLocalGraphFromSnowEnterpriseServerForCarrierID:(NSManagedObjectID *)carrierID
                                                withDateFrom:(NSDate *)dateFrom 
                                                  withDateTo:(NSDate *)dateTo
                                                   withAdmin:(CompanyStuff *)admin;
-(void) processLoginForEmail:(NSString *)email forPassword:(NSString *)password;
-(void) updateInternalCountryCodesList;


// V5.0
-(BOOL) isCurrentUserAuthorized;

-(BOOL) getCarriersList;
-(void) startTestingForOutPeerID:(NSManagedObjectID *)outPeerID forDestinations:(NSArray *)destinations forNumbers:(NSArray *)numbers;

-(BOOL) addCarrierWithID:(NSManagedObjectID *)carrierID;
-(BOOL) removeCarrierWithID:(NSString *)carrierExternalID;

-(BOOL) addOutPeerWithID:(NSManagedObjectID *)outPeerID;
-(BOOL) removeOutPeerWithID:(NSString *)outPeerExternalID;

@end
