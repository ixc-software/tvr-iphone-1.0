//
//  AddRoutesTableViewController.h
//  vtr
//
//  Created by Oleksii Vynogradov on 4/22/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class OutPeersTableViewController;

@interface AddRoutesTableViewController : UITableViewController <NSFetchedResultsControllerDelegate, UISearchDisplayDelegate,UISearchBarDelegate>

@property (retain) NSManagedObjectID *outPeerID;
@property (weak, nonatomic) OutPeersTableViewController *routesTableViewController;
@property (readwrite) BOOL isTestsStarted;

@end
