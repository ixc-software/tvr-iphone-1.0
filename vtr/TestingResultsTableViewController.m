//
//  TestingResultsTableViewController.m
//  vtr
//
//  Created by Oleksii Vynogradov on 4/23/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import "TestingResultsTableViewController.h"
#import "TestingResultCell.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>

#import "DestinationsListWeBuyResults.h"
#import "DestinationsListWeBuyTesting.h"
#import "OutPeer.h"

@interface TestingResultsTableViewController ()
@property (nonatomic) NSFetchedResultsController *fetchedResultsController;

@end

@implementation TestingResultsTableViewController
@synthesize bar;
@synthesize selectDate;
@synthesize fetchedResultsController,player,destination,outPeer;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        /// Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    CALayer *background = [CALayer layer];
//    background.zPosition = -1;
//    background.frame = self.view.frame;
//    background.contents = (id)[UIImage imageNamed:@"bk_320x480.png"].CGImage;
//    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
//    [backgroundView addSubview:[UIImage imageNamed:@"bk_320x480.png"]];
    
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bk_320x480.png"]];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.0 green:0.44 blue:0.80 alpha:1.0];
    self.bar.tintColor = [UIColor colorWithRed:0.0 green:0.44 blue:0.80 alpha:1.0];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [self setSelectDate:nil];
    [self setBar:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.outPeer = nil;
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger count = [[[self fetchedResultsController] sections] count];
    NSLog(@"Number of sections:%@",[NSNumber numberWithUnsignedInteger:count]);
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    NSArray *object = [sectionInfo objects];
    DestinationsListWeBuyResults *result = object.lastObject;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd' 'HH':'mm"];
    
	// create the parent view that will hold header Label
	UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(40.0, 0.0, 200.0, 44.0)];
	UIImageView *background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"form_header_44-3.png"]];
    [customView addSubview:background];
    
	// create the button object
	UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	headerLabel.backgroundColor = [UIColor clearColor];
	headerLabel.opaque = NO;
    [headerLabel setAlpha:0.5];
    
	headerLabel.textColor = [UIColor blackColor];
	headerLabel.highlightedTextColor = [UIColor blackColor];
	headerLabel.font = [UIFont boldSystemFontOfSize:20];
	headerLabel.frame = CGRectMake(10.0, 0.0, 300.0, 44.0);
    headerLabel.textAlignment = UITextAlignmentCenter;
    
	headerLabel.text = [NSString stringWithFormat:@"Date:%@",[dateFormatter stringFromDate:result.destinationsListWeBuyTesting.date]];
    headerLabel.shadowOffset = CGSizeMake(1, 1);
    headerLabel.shadowColor = [UIColor whiteColor];
    
	[customView addSubview:headerLabel];
    
	return customView;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 44.0;
}

- (void)configureCell:(TestingResultCell *)cell atIndexPath:(NSIndexPath *)indexPath forTableView:(UITableView *)tableView;

{
    cell.bk.layer.cornerRadius = 7;
    cell.bk.layer.borderWidth = 2;
    
    cell.bk.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    NSFetchedResultsController *fetchController = [self fetchedResultsController];
    DestinationsListWeBuyResults *result = [fetchController objectAtIndexPath:indexPath];
    
    cell.number.text = [NSString stringWithFormat:@"To: +%@",result.numberB];
    cell.numberA.text = [NSString stringWithFormat:@"From +%@",result.numberA];
    
    NSDate *timeInvite = result.timeInvite;
    NSDate *timeOk = result.timeOk;
    NSDate *timeRinging = result.timeRinging;
    NSDate *timeRelease = result.timeRelease;
    
    NSTimeInterval inviteToRingingInterval = [timeRinging timeIntervalSinceDate:timeInvite];
    [cell.pddTime removeAllSegments];
    [cell.pddTime insertSegmentWithTitle:[NSString stringWithFormat:@"%@ sec",[NSNumber numberWithInt:inviteToRingingInterval]] atIndex:0 animated:NO];
    
    NSTimeInterval inviteOkInterval = [timeOk timeIntervalSinceDate:timeInvite];
    
    [cell.responseTime removeAllSegments];
    [cell.responseTime insertSegmentWithTitle:[NSString stringWithFormat:@"%@ sec",[NSNumber numberWithInt:inviteOkInterval]] atIndex:0 animated:NO];
    
    
    NSTimeInterval okReleaseInterval = [timeRelease timeIntervalSinceDate:timeOk];
    [cell.callTime removeAllSegments];
    [cell.callTime insertSegmentWithTitle:[NSString stringWithFormat:@"%@ sec",[NSNumber numberWithInt:okReleaseInterval]] atIndex:0 animated:NO];
    
    NSString *protocol = result.destinationsListWeBuyTesting.protocol;
    
    if (protocol) cell.protocolLabel.text = protocol;
    else cell.protocolLabel.text = @"";
    
    cell.outPeerLabel.text = result.destinationsListWeBuyTesting.outPeer.outpeerName;
    cell.carrierLabel.text = result.destinationsListWeBuyTesting.outPeer.carrier.name;
    
//    if (okReleaseInterval > 0) {
//        
//        if (result.isFAS.boolValue) {
//            //cell.number.textColor = [UIColor redColor];
//            cell.fasReason.hidden = NO;
//            cell.fasReason.text = result.fasReason;
////            [cell.markFasButton setImage:[UIImage imageNamed:@"unmarkAsFas.png"] forState:UIControlStateNormal];
////            [cell.markFasButton addTarget:cell action:@selector(unmarkAsFas:) forControlEvents:UIControlEventTouchUpInside];
//            
//        } else {
//            //cell.number.textColor = [UIColor greenColor];
//            cell.fasReason.hidden = YES;
////            cell.isFas = NO;
////            [cell.markFasButton setImage:[UIImage imageNamed:@"markAsFas.png"] forState:UIControlStateNormal];
////            [cell.markFasButton addTarget:cell action:@selector(markAsFas:) forControlEvents:UIControlEventTouchUpInside];
//        }
//    }  else {
//        cell.fasReason.hidden = YES;
////        cell.markFasButton.hidden = YES;
////        cell.playButton.hidden = YES;
//    }
    
    cell.playButton.enabled = NO;
    cell.playButton.hidden = YES;

    if (result.ringMP3 && result.ringMP3.length > 0) {
        cell.playButton.enabled = YES;
        cell.playButton.hidden = NO;

        [cell.playButton addTarget:cell action:@selector(playRing:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (result.callMP3 && result.callMP3.length > 0) {
        if (cell.isPlayingCall) [cell.playButton setImage:[UIImage imageNamed:@"btn_pause.png"] forState:UIControlStateNormal]; 
        else [cell.playButton setImage:[UIImage imageNamed:@"btn_play.png"] forState:UIControlStateNormal];
        [cell.playButton setNeedsDisplay];
        
        cell.playButton.enabled = YES;
        cell.playButton.hidden = NO;

        [cell.playButton addTarget:cell action:@selector(playCall:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    /*@dynamic numberB;
     @dynamic inputPackets;
     @dynamic outputPackets;
     @dynamic timeSetup;
     @dynamic timeInvite;
     @dynamic timeOk;
     @dynamic timeRelease;
     @dynamic timeRinging;
     @dynamic timeTrying;
     @dynamic numberA;
     @dynamic ringMP3;
     @dynamic callMP3;
     @dynamic isFAS;
     @dynamic log;
     @dynamic fasReason;
     */
    
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TestingResultCell";
    TestingResultCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[TestingResultCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    [self configureCell:cell atIndexPath:indexPath forTableView:tableView];
    cell.delegate = self;
    cell.indexPath = indexPath;

    // Configure the cell...
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    
}

#pragma mark - action methods
- (IBAction)playRingForIndexPath:(NSIndexPath *)indexPath;
{
    NSLog(@"playRingForIndexPath:%@",indexPath);
}

- (IBAction)stopPlayRingForIndexPath:(NSIndexPath *)indexPath;
{
    NSLog(@"stopPlayRingForIndexPath:%@",indexPath);
}
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    NSLog(@"error:%@",[error localizedDescription]);
}
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSLog(@"error:%c",flag);

}

- (IBAction)playCallForIndexPath:(NSIndexPath *)indexPath;
{
    NSLog(@"playCallForIndexPath:%@",indexPath);
    DestinationsListWeBuyResults *selectedObject = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    NSData *callMP3 = selectedObject.callMP3;
    NSError *error = nil;
    if (!player) player = [[AVAudioPlayer alloc] initWithData:callMP3 error:&error];
    else { 
        [player stop];
        player = nil;
        player = [[AVAudioPlayer alloc] initWithData:callMP3 error:&error];
    }
    player.numberOfLoops= -1;
    
    if (error) NSLog(@"TEST RESULTS: error play:%@",[error localizedDescription]);
    player.delegate = self;
    [player play];
    
    
}
- (IBAction)stopPlayCallForIndexPath:(NSIndexPath *)indexPath;
{
    NSLog(@"stopPlayCallForIndexPath:%@",indexPath);
    if (player) [player stop];
}

- (IBAction)unmarkAsFasForIndexPath:(NSIndexPath *)indexPath;
{
    NSLog(@"unmarkAsFasForIndexPath:%@",indexPath);
    
}
- (IBAction)markAsFasForIndexPath:(NSIndexPath *)indexPath;
{
    NSLog(@"markAsFasForIndexPath:%@",indexPath);
    
}

- (IBAction)selecDateStart:(id)sender {
    fetchedResultsController = nil;
    fetchedResultsController = [self fetchedResultsController];
    [self.tableView reloadData];

}

#pragma mark - NSFetchedResultsController methods
- (NSFetchedResultsController *)newFetchedResultsControllerWithSearch:(NSString *)searchString
{
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;

    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"destinationsListWeBuyTesting.date" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    
    NSPredicate *filterPredicate = nil;
    NSMutableArray *predicateArray = [NSMutableArray array];

    if (self.outPeer) {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(destinationsListWeBuyTesting.outPeer == %@)",self.outPeer];
        [predicateArray addObject:predicate];
    }

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

    
    if (self.selectDate.selectedSegmentIndex == 0) {
        // latest
        [fetchRequest setFetchLimit:5];
        
    }
    
    if (self.selectDate.selectedSegmentIndex == 1) {
        // todays
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit ) fromDate:[NSDate date]];
        //create a date with these components
        NSDate *startDate = [calendar dateFromComponents:components];
        [components setMonth:1];
        [components setDay:0]; //reset the other components
        [components setYear:0]; //reset the other components
        NSDate *endDate = [calendar dateByAddingComponents:components toDate:startDate options:0];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"((modificationDate > %@) AND (modificationDate <= %@))",startDate,endDate];
        [predicateArray addObject:predicate];
        
    }

    //NSLog(@"FINAL PREDICATE:%@",predicateArray);
    
    if (predicateArray.count > 0) { 
        filterPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicateArray];
        [fetchRequest setPredicate:filterPredicate];
    }

    
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DestinationsListWeBuyResults" inManagedObjectContext:delegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setPredicate:filterPredicate];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
                                                                                                managedObjectContext:delegate.managedObjectContext 
                                                                                                  sectionNameKeyPath:@"destinationsListWeBuyTesting.objectID" 
                                                                                                           cacheName:nil];
    aFetchedResultsController.delegate = self;
    
    
    NSError *error = nil;
    if (![aFetchedResultsController performFetch:&error]) 
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return aFetchedResultsController;
}    



- (NSFetchedResultsController *)fetchedResultsController 
{
    if (fetchedResultsController != nil) 
    {
        return fetchedResultsController;
    }
    fetchedResultsController = [self newFetchedResultsControllerWithSearch:nil];
    return fetchedResultsController;
}   

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
    
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type)
    {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            //[self configureCell:[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
        {
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView reloadSections:[NSIndexSet indexSetWithIndex:newIndexPath.section] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

#pragma mark - UISearchBarDelegate
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

@end
