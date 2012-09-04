//
//  RoutesTableViewController.h
//  vtr
//
//  Created by Oleksii Vynogradov on 4/22/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Carrier.h"
@class RoutesCell;

@interface OutPeersTableViewController : UITableViewController <NSFetchedResultsControllerDelegate,UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *testButton;
@property (retain) Carrier *selectedCarrier;
@property (weak, nonatomic) IBOutlet UISegmentedControl *testedSelector;
@property (weak, nonatomic) IBOutlet UISearchBar *bar;
@property (nonatomic) NSFetchedResultsController *fetchedResultsController;

@property (retain) NSArray *numbers;
@property (retain) NSArray *destinationsForTest;
@property (retain) NSManagedObjectID *outpeerIDForTest;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *startEditingButton;

@property (retain) RoutesCell *firstCell;


-(void)destinationChooseForIndexPath:(NSIndexPath *)indexPath;

-(void)testStartForDestinations:(NSArray *)destinations forOutPeerID:(NSManagedObjectID *)outpeerID;


@end
