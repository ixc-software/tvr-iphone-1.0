//
//  TestingResultCell.h
//  vtr
//
//  Created by Oleksii Vynogradov on 4/23/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TestingResultsTableViewController.h"

@interface TestingResultCell : UITableViewCell

@property ( nonatomic) IBOutlet UILabel *numberA;
@property ( nonatomic) IBOutlet UILabel *number;
@property ( nonatomic) IBOutlet UIButton *playButton;
@property ( nonatomic) IBOutlet UISegmentedControl *responseTime;
@property ( nonatomic) IBOutlet UISegmentedControl *pddTime;
@property ( nonatomic) IBOutlet UISegmentedControl *callTime;
@property ( nonatomic) IBOutlet UILabel *fasReason;
@property (unsafe_unretained, nonatomic) TestingResultsTableViewController *delegate;
@property ( nonatomic) NSIndexPath *indexPath ;
@property (assign, nonatomic) BOOL isPlayingCall;
@property (assign, nonatomic) BOOL isPlayingRing;

@property ( nonatomic) IBOutlet UIImageView *bk;


@end
