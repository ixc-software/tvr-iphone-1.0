//
//  TestingResultsTableViewController.h
//  vtr
//
//  Created by Oleksii Vynogradov on 4/23/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <AVFoundation/AVFoundation.h>
#import "DestinationsListWeBuy.h"
#import "OutPeer.h"

@interface TestingResultsTableViewController : UITableViewController  <NSFetchedResultsControllerDelegate, UISearchDisplayDelegate,UISearchBarDelegate,AVAudioPlayerDelegate>
@property (nonatomic, retain) AVAudioPlayer *player;
@property (nonatomic, retain) DestinationsListWeBuy *destination;
@property (nonatomic, retain) OutPeer *outPeer;
@property (weak, nonatomic) IBOutlet UISegmentedControl *selectDate;
- (IBAction)playCallForIndexPath:(NSIndexPath *)indexPath;
- (IBAction)playRingForIndexPath:(NSIndexPath *)indexPath;
- (IBAction)stopPlayRingForIndexPath:(NSIndexPath *)indexPath;
@property (weak, nonatomic) IBOutlet UISearchBar *bar;
- (IBAction)stopPlayCallForIndexPath:(NSIndexPath *)indexPath;

@end
