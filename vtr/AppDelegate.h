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

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (weak, nonatomic) IBOutlet OutPeersTableViewController *routesViewController;
@property (nonatomic, retain) NSData *deviceToken;
@property (retain) NSMutableString *firstServer;
@property (retain) NSMutableString *secondServer;
@property (retain) NSMutableString *urlChoosed;
@property (retain) NSMutableDictionary *allURLs;

@property (retain) NSMutableString *appleID;
@property (retain) NSMutableString *messageFull;

@property (readwrite) BOOL isMessageConfirmed;
@property (readwrite) BOOL downloadCompleted;
@property (retain, nonatomic) NSMutableData *receivedData;
-(BOOL)isPad;
- (NSURL *)applicationDocumentsDirectory;
- (void)saveContext;

@end
