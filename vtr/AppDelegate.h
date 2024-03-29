//
//  AppDelegate.h
//  vtr
//
//  Created by Oleksii Vynogradov on 4/22/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "OutPeersTableViewController.h"
#import "TestingResultsTableViewController.h"
#import <StoreKit/StoreKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate,SKProductsRequestDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong) IBOutlet OutPeersTableViewController *routesViewController;
@property (weak, nonatomic) IBOutlet TestingResultsTableViewController *testingResultsTableViewController;

@property (nonatomic, retain) NSData *deviceToken;
@property (retain) NSMutableString *firstServer;
@property (retain) NSMutableString *secondServer;
@property (retain) NSMutableString *urlChoosed;
@property (retain) NSMutableDictionary *allURLs;

@property (retain) NSMutableString *appleID;
@property (retain) NSMutableString *messageFull;

@property (strong) NSArray *countrySpecificIDsForTest;
@property (strong) NSManagedObjectID *outPeerID;
@property (readwrite) BOOL isTestsStarted;

@property (readwrite) BOOL isMessageConfirmed;
@property (readwrite) BOOL downloadCompleted;
@property (retain, nonatomic) NSMutableData *receivedData;

@property (nonatomic, retain) SKProduct *productAdvanced;
@property (nonatomic, retain) SKProduct *productAdvancedPlusFax;

@property (retain, nonatomic) NSString *deviceUDID;

-(BOOL)isPad;
- (NSURL *)applicationDocumentsDirectory;
- (void)saveContext;




@property (retain) IBOutlet UITabBarController *tapBarController;

@end
