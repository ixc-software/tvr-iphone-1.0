//
//  NumbersForTestEditorTableViewController.h
//  tvr
//
//  Created by Oleksii Vynogradov on 9/6/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class AddRoutesTableViewController;

@interface NumbersForTestEditorTableViewController : UITableViewController

-(void)refreshNumbers:(NSArray *)receivedNumbers withCodes:(NSString *)codes;
@property (retain) NSManagedObjectID *outPeerID;
@property (weak, nonatomic) AddRoutesTableViewController *addRoutesTableViewController;


@end
