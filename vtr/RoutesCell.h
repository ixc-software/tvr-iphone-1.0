//
//  RoutesCell.h
//  vtr
//
//  Created by Oleksii Vynogradov on 4/23/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import <UIKit/UIKit.h>
@class OutPeersTableViewController;

@interface RoutesCell : UITableViewCell
@property (nonatomic) IBOutlet UILabel *ips;

@property (nonatomic) IBOutlet UILabel *outPeerName;
@property (nonatomic) IBOutlet UILabel *carrier;
@property (nonatomic) IBOutlet UILabel *prefix;
@property (nonatomic) IBOutlet UILabel *latestTestingResults;
@property (unsafe_unretained, nonatomic) OutPeersTableViewController *delegate;
@property ( nonatomic) NSIndexPath *indexPath ;
@property ( nonatomic) IBOutlet UIButton *testButton;
@property (nonatomic) IBOutlet UILabel *testButtonLabel;
@property ( nonatomic) IBOutlet UITextField *ipsEdited;
@property ( nonatomic) IBOutlet UITextField *prefixEdited;
@property ( nonatomic) IBOutlet UITextField *nameEdited;

@property (nonatomic) IBOutlet UIActivityIndicatorView *activity;

-(IBAction)test:(id)sender;


@end
