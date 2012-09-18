//
//  RoutesTableViewController.m
//  vtr
//
//  Created by Oleksii Vynogradov on 4/22/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import "OutPeersTableViewController.h"
#import "AppDelegate.h"
#import "RoutesCell.h"
#import "DestinationsListWeBuy.h"
#import "CodesvsDestinationsList.h"
#import "Carrier.h"
#import "ClientController.h"
#import "TestingResultsTableViewController.h"
#import "AddNumbersViewController.h"
#import "AddRoutesTableViewController.h"
#import "AddRoutesTableViewControllerMain.h"

@interface OutPeersTableViewController ()
@property (nonatomic) NSArray* sectionsTitles;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *edit;
@property (nonatomic) NSMutableString *previousSearchString;
@property (nonatomic) NSMutableArray *selectedObjectsIDs;
@property (nonatomic) NSMutableArray *testedDestinationsID;
@property (nonatomic) UIActivityIndicatorView *activity;

@end

@implementation OutPeersTableViewController
@synthesize searchBar;
@synthesize testButton;
@synthesize sectionsTitles;
@synthesize edit;
@synthesize fetchedResultsController,previousSearchString;
@synthesize selectedObjectsIDs;
@synthesize selectedCarrier;
@synthesize testedSelector;
@synthesize bar;
@synthesize testedDestinationsID;
@synthesize numbers,destinationsForTest,outpeerIDForTest;
@synthesize startEditingButton;
@synthesize firstCell;
@synthesize activity;

static unsigned char base64EncodeLookup[65] =
"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";


-(NSString *) encodeTobase64InputData:(NSData *)data
{
    
    const void *buffer = [data bytes];
    size_t length = [data length];
    bool separateLines = true;
    //    size_t outputLength = 0;
    
    const unsigned char *inputBuffer = (const unsigned char *)buffer;
    
#define BINARY_UNIT_SIZE 3
#define BASE64_UNIT_SIZE 4
    
#define MAX_NUM_PADDING_CHARS 2
#define OUTPUT_LINE_LENGTH 64
#define INPUT_LINE_LENGTH ((OUTPUT_LINE_LENGTH / BASE64_UNIT_SIZE) * BINARY_UNIT_SIZE)
#define CR_LF_SIZE 2
    
    //
    // Byte accurate calculation of final buffer size
    //
    size_t outputBufferSize =
    ((length / BINARY_UNIT_SIZE)
     + ((length % BINARY_UNIT_SIZE) ? 1 : 0))
    * BASE64_UNIT_SIZE;
    if (separateLines)
    {
        outputBufferSize +=
        (outputBufferSize / OUTPUT_LINE_LENGTH) * CR_LF_SIZE;
    }
    
    //
    // Include space for a terminating zero
    //
    outputBufferSize += 1;
    
    //
    // Allocate the output buffer
    //
    char *outputBuffer = (char *)malloc(outputBufferSize);
    if (!outputBuffer)
    {
        return NULL;
    }
    
    size_t i = 0;
    size_t j = 0;
    const size_t lineLength = separateLines ? INPUT_LINE_LENGTH : length;
    size_t lineEnd = lineLength;
    
    while (true)
    {
        if (lineEnd > length)
        {
            lineEnd = length;
        }
        
        for (; i + BINARY_UNIT_SIZE - 1 < lineEnd; i += BINARY_UNIT_SIZE)
        {
            //
            // Inner loop: turn 48 bytes into 64 base64 characters
            //
            outputBuffer[j++] = base64EncodeLookup[(inputBuffer[i] & 0xFC) >> 2];
            outputBuffer[j++] = base64EncodeLookup[((inputBuffer[i] & 0x03) << 4)
                                                   | ((inputBuffer[i + 1] & 0xF0) >> 4)];
            outputBuffer[j++] = base64EncodeLookup[((inputBuffer[i + 1] & 0x0F) << 2)
                                                   | ((inputBuffer[i + 2] & 0xC0) >> 6)];
            outputBuffer[j++] = base64EncodeLookup[inputBuffer[i + 2] & 0x3F];
        }
        
        if (lineEnd == length)
        {
            break;
        }
        
        //
        // Add the newline
        //
        outputBuffer[j++] = '\r';
        outputBuffer[j++] = '\n';
        lineEnd += lineLength;
    }
    
    if (i + 1 < length)
    {
        //
        // Handle the single '=' case
        //
        outputBuffer[j++] = base64EncodeLookup[(inputBuffer[i] & 0xFC) >> 2];
        outputBuffer[j++] = base64EncodeLookup[((inputBuffer[i] & 0x03) << 4)
                                               | ((inputBuffer[i + 1] & 0xF0) >> 4)];
        outputBuffer[j++] = base64EncodeLookup[(inputBuffer[i + 1] & 0x0F) << 2];
        outputBuffer[j++] =	'=';
    }
    else if (i < length)
    {
        //
        // Handle the double '=' case
        //
        outputBuffer[j++] = base64EncodeLookup[(inputBuffer[i] & 0xFC) >> 2];
        outputBuffer[j++] = base64EncodeLookup[(inputBuffer[i] & 0x03) << 4];
        outputBuffer[j++] = '=';
        outputBuffer[j++] = '=';
    }
    outputBuffer[j] = 0;
    
    //
    // Set the output length and return the buffer
    //
    //    if (outputLength)
    //    {
    //        outputLength = j;
    //    }
    
    //    return outputBuffer;
    
	NSString *result = [[NSString alloc] initWithBytes:outputBuffer length:j encoding:NSASCIIStringEncoding];
    
    return result;
}


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(NSArray *) indexForSectionIndexTitlesForEntity:(NSString *)entityName;
{
    
    __block NSString *entityNameBlock = entityName;
    
    __unsafe_unretained NSMutableArray *countForLetters = [NSMutableArray arrayWithCapacity:0];
    __unsafe_unretained NSMutableArray *letters = [NSMutableArray arrayWithCapacity:0];
    [letters addObject:UITableViewIndexSearch];
    
    __block NSUInteger total = 0;
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityNameBlock
                                              inManagedObjectContext:delegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setResultType:NSDictionaryResultType];
    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObject:@"country"]];
    [fetchRequest setReturnsDistinctResults:YES];
    
    
    
    NSError *error = nil;
    NSArray *fetchedObjects = [delegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    [fetchedObjects enumerateObjectsUsingBlock:^(NSDictionary *country, NSUInteger idx, BOOL *stop) {
        NSString *countryName = [country valueForKey:@"country"];
        NSString *letter = [countryName substringWithRange:NSMakeRange(0, 1)];
        [countForLetters addObject:[NSDictionary dictionaryWithObjectsAndKeys:letter,@"letter",[NSNumber numberWithInteger:total],@"index", nil]];
        [letters addObject:letter];
        
        total += 1;
        
    }];
    
    [countForLetters addObject:[NSDictionary dictionaryWithObjectsAndKeys:letters,@"letters", nil]];
    
    
    return [NSArray arrayWithArray:countForLetters];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    previousSearchString = [[NSMutableString alloc] initWithString:@""];
    selectedObjectsIDs = [[NSMutableArray alloc] initWithCapacity:0];
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bk_320x480.png"]];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.0 green:0.44 blue:0.80 alpha:1.0];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    sectionsTitles = [[NSArray alloc] initWithArray:[self indexForSectionIndexTitlesForEntity:@"CountrySpecificCodeList"]];
    fetchedResultsController = [self fetchedResultsController];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    testedDestinationsID = [[NSMutableArray alloc] initWithCapacity:0];
    self.bar.tintColor = [UIColor colorWithRed:0.0 green:0.44 blue:0.80 alpha:1.0];

//    activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
//    //set the initial property
//    [activity stopAnimating];
//    [activity hidesWhenStopped];
//    //Create an instance of Bar button item with custome view which is of activity indicator
//    UIBarButtonItem * barButton = [[UIBarButtonItem alloc] initWithCustomView:activity];
//    //Set the bar button the navigation bar
//    [self navigationItem].leftBarButtonItem = barButton;

}

- (void)viewDidUnload
{
    [self setSearchBar:nil];
    [self setTestButton:nil];
    [self setTestedSelector:nil];
    [self setBar:nil];
    [self setStartEditingButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger count = [[[self fetchedResultsController] sections] count];
    //NSLog(@"Sections:%@",[NSNumber numberWithUnsignedInteger:count]);
    if (tableView.isEditing) count = count + 1;

    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{ 
    NSUInteger numberOfObjects = 0;
    if (tableView.isEditing) { 
        
        if (section == 0) numberOfObjects = 1;
        else {
            id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section - 1];
            numberOfObjects = [sectionInfo numberOfObjects];

        }
    }
    else {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        numberOfObjects = [sectionInfo numberOfObjects];
    }
    return numberOfObjects;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"RouteCell";
    RoutesCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[RoutesCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
    }
    
    if (tableView.isEditing  && indexPath.section == 0) { 
        cell.ips.hidden = YES;
        cell.outPeerName.hidden = YES;
        cell.carrier.hidden = YES;
        cell.latestTestingResults.hidden = YES;
        cell.testButton.hidden = YES;
        cell.testButtonLabel.hidden = YES;
        cell.activity.hidden = YES;
        cell.prefix.hidden = YES;
        
        cell.ipsEdited.hidden = NO;
        cell.prefixEdited.hidden = NO;
        cell.nameEdited.hidden = NO;
        
    } else {
        cell.ips.hidden = NO;
        cell.outPeerName.hidden = NO;
        cell.carrier.hidden = NO;
        cell.latestTestingResults.hidden = NO;
        cell.testButton.hidden = NO;
        cell.testButtonLabel.hidden = NO;
        cell.prefix.hidden = NO;

        cell.ipsEdited.hidden = YES;
        cell.prefixEdited.hidden = YES;
        cell.nameEdited.hidden = YES;
        OutPeer *managedObject = nil;
        
        if (tableView.isEditing) managedObject = [[self fetchedResultsController] objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section - 1]];
        else {
            managedObject = [[self fetchedResultsController] objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section]];
        }
        cell.outPeerName.text = managedObject.outpeerName;
        
        
        //    NSSet *codes = managedObject.codesvsDestinationsList;
        //    NSMutableString *codesList = [NSMutableString string];
        //    NSSet *allUniqueCodes = [codes valueForKeyPath:@"@distinctUnionOfObjects.code"];
        //    __block NSUInteger idx = 0;
        //    [allUniqueCodes enumerateObjectsUsingBlock:^(NSNumber *code, BOOL *stop) {
        //
        //        [codesList appendString:code.stringValue];
        //        
        //        if (idx != allUniqueCodes.count - 1) [codesList appendString:@","];
        //        idx++;
        //
        //    }];
        NSString *outpeerPrefix = managedObject.outpeerPrefix;
        if (outpeerPrefix.length == 0) outpeerPrefix = @"no prefix";
        cell.prefix.text = outpeerPrefix;
        cell.carrier.text = managedObject.carrier.name;
        //    CodesvsDestinationsList *anyCode = codes.anyObject;
        
        cell.ips.text = managedObject.ips;
        
        if (managedObject.destinationsListWeBuyTesting.count > 0) cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        else cell.accessoryType = UITableViewCellAccessoryNone;
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"indexPath == %@",indexPath];
        NSArray *filteredTestedDestinationsID = [self.testedDestinationsID filteredArrayUsingPredicate:predicate];
        
        if (filteredTestedDestinationsID.count > 0) {
            //NSLog(@"for indexpath:%@ is testing:%@",indexPath,self.testedDestinationsID);
            // this index in testing now
            cell.activity.alpha = 1.0;
            [cell.activity startAnimating];
            cell.testButton.enabled = NO;
            [cell.testButton setImage:[UIImage imageNamed:@"test-button-pressed.png"] forState:UIControlStateNormal];
            cell.testButtonLabel.text = @"Testing";
            
        } else {
            // this index not tested
            //NSLog(@"for indexpath:%@ is normal",indexPath);
            
            cell.activity.alpha = 0.0;
            [cell.activity stopAnimating];
            cell.testButton.enabled = YES;
            [cell.testButton setImage:[UIImage imageNamed:@"test-button-md.png"] forState:UIControlStateNormal];
            cell.testButtonLabel.text = @"Test";
            
        }
        
        //cell.testButtonLabel.text = [NSString stringWithFormat:@"OutPeerID:%@",managedObject.outpeerID];

        //cell.accessoryType = UITableViewCellAccessoryNone;
        cell.delegate = self;
        cell.indexPath = indexPath;
    }
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (tableView.isEditing && section == 0) return @"";
    if (tableView.isEditing && section > 0) section = section - 1;
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    
    return [sectionInfo name];
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
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        NSFetchedResultsController *fetchController = [self fetchedResultsController];
        OutPeer *peer = [fetchController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section - 1]];
        NSLog(@"DELETE Outpeer:%@",peer.outpeerName);
        NSString *outPeerExternalID = peer.outpeerID.copy;
        
        [delegate.managedObjectContext deleteObject:peer];
        [delegate saveContext];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
            
            ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[delegate.managedObjectContext persistentStoreCoordinator]withSender:self withMainMoc:delegate.managedObjectContext];
            [clientController removeOutPeerWithID:outPeerExternalID];
        });
        
    }   
    if (editingStyle == UITableViewCellEditingStyleInsert) {
        [activity startAnimating];
        firstCell = (RoutesCell *)[tableView cellForRowAtIndexPath:indexPath];
        [firstCell.nameEdited resignFirstResponder];
        [firstCell.ipsEdited resignFirstResponder];
        [firstCell.prefixEdited resignFirstResponder];

        
        ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[delegate.managedObjectContext persistentStoreCoordinator]withSender:self withMainMoc:delegate.managedObjectContext];


        CompanyStuff *updated = (CompanyStuff *)[delegate.managedObjectContext objectWithID:[clientController authorization].objectID];
        
        NSSet *carriers = updated.carrier;
        
        __block UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Please choose carrier" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"Cancel" otherButtonTitles:nil];
        [carriers enumerateObjectsUsingBlock:^(Carrier *carrier, BOOL *stop) {
            [sheet addButtonWithTitle:carrier.name];
        }];

        
        sheet.tag = 1;
        
        sheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
        
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

        if ([delegate isPad]) {
            [sheet showFromRect:self.navigationController.navigationBar.frame inView:self.view animated:YES];
        } else [sheet showFromToolbar:self.navigationController.toolbar];//showFromRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width) inView:self.view animated:YES];

        
        
    }   
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return UITableViewCellEditingStyleInsert;
    } 
    return UITableViewCellEditingStyleDelete;
    
}

//- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (tableView.isEditing)  return nil;
//
//    OutPeer *managedObject = [[self fetchedResultsController] objectAtIndexPath:indexPath];
//    if (managedObject.destinationsListWeBuyTesting.count > 0) return indexPath;
//    else return nil;
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
//    RoutesCell *selectedCell = (RoutesCell *)[self.tableView cellForRowAtIndexPath:indexPath];
//    DestinationsListWeBuy *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
//    
//    if (selectedCell.accessoryType == UITableViewCellAccessoryNone) {
//        selectedCell.accessoryType = UITableViewCellAccessoryCheckmark;
//        [selectedObjectsIDs addObject:object.objectID];
//    }
//    else {
//        selectedCell.accessoryType = UITableViewCellAccessoryNone;
//        [selectedObjectsIDs removeObject:object.objectID];
//    }
//    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self destinationChooseForIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath;
{
    OutPeer *managedObject = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.testingResultsTableViewController.outPeer = managedObject;
    [self.tabBarController setSelectedIndex:3];
    
}
#pragma mark Delegate methods of NSFetchedResultsController


- (NSFetchedResultsController *)newFetchedResultsControllerWithSearch:(NSString *)searchString
{
    /*if ([searchString length] < 2 && fetchedResultsController != nil) {
     NSLog(@"fetch controller return standart controller:%@",[NSDate date]);
     
     return self.fetchedResultsController;
     }*/
    //NSLog(@"fetch controller start:%@",[NSDate date]);
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"carrier.name" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    NSPredicate *filterPredicate = nil;
    
    /*
     Set up the fetched results controller.
     */
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"OutPeer" inManagedObjectContext:delegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSMutableArray *predicateArray = [NSMutableArray array];
    
    if(searchString.length) {
        
        NSPredicate *predicateName = [NSPredicate predicateWithFormat:@"(outpeerName CONTAINS[cd] %@)",searchString];
        [predicateArray addObject:predicateName];
  
        
//        if(filterPredicate)
//        {
//            filterPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:filterPredicate, [NSCompoundPredicate orPredicateWithSubpredicates:predicateArray], nil]];
//        }
//        else
//        {
//            filterPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicateArray];
//        }
    }
    
    if (self.selectedCarrier) {
        NSPredicate *predicateName = [NSPredicate predicateWithFormat:@"carrier.GUID == %@",selectedCarrier.GUID];
        [predicateArray addObject:predicateName];
    }
    
    if (self.testedSelector.selectedSegmentIndex == 0) {
//        NSPredicate *predicateName = [NSPredicate predicateWithFormat:@"(destinationsListWeBuyTesting.@count > 0)"];
//        [predicateArray addObject:predicateName];
    } else {
        NSPredicate *predicateName = [NSPredicate predicateWithFormat:@"destinationsListWeBuyTesting.@count > 0"];
        [predicateArray addObject:predicateName];
//        [fetchRequest setPredicate:nil];


    }
    //NSLog(@"FINAL PREDICATE:%@",predicateArray);

    if (predicateArray.count > 0) { 
        filterPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicateArray];
        [fetchRequest setPredicate:filterPredicate];
    }
    
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    //[fetchRequest setFetchLimit:120];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
                                                                                                managedObjectContext:delegate.managedObjectContext 
                                                                                                  sectionNameKeyPath:@"carrier.name" 
                                                                                                           cacheName:nil];
    aFetchedResultsController.delegate = self;
    
    
    
    NSError *error = nil;
    if (![aFetchedResultsController performFetch:&error]) 
    {
        
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return aFetchedResultsController;
}    


- (NSFetchedResultsController *)fetchedResultsController 
{
    //NSLog(@"fetchedResultsController");
    NSString *currentSearchString = self.searchBar.text;
    
    if (!currentSearchString) currentSearchString = @"";
    
    if (fetchedResultsController != nil && [currentSearchString isEqualToString:self.previousSearchString]) 
    {
        return fetchedResultsController;
    }
    //NSLog(@"fetchedResultsController from nil");
    [self.previousSearchString setString:currentSearchString];
    fetchedResultsController = [self newFetchedResultsControllerWithSearch:currentSearchString];
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
            if (self.tableView.isEditing) [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex + 1] withRowAnimation:UITableViewRowAnimationFade];
                else [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            if (self.tableView.isEditing) [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex + 1] withRowAnimation:UITableViewRowAnimationFade];
            else [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
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
            NSLog(@"ROUTES: NSFetchedResultsChangeInsert");

            if (tableView.isEditing) {
                NSIndexPath *newIndexPathForInsert = [NSIndexPath indexPathForRow:newIndexPath.row inSection:newIndexPath.section + 1];
                [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPathForInsert] withRowAnimation:UITableViewRowAnimationFade];
            } else[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            NSLog(@"ROUTES: NSFetchedResultsChangeDelete");

            if (tableView.isEditing) {
                NSIndexPath *newIndexPathForDelete = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section + 1];
                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPathForDelete] withRowAnimation:UITableViewRowAnimationFade];
            } else [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            
            break;
            
        case NSFetchedResultsChangeUpdate:
            NSLog(@"ROUTES: NSFetchedResultsChangeUpdate");

            if (tableView.isEditing) {
                NSIndexPath *newIndexPathForUpdate = [NSIndexPath indexPathForRow:indexPath.row  inSection:indexPath.section];
                [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPathForUpdate] withRowAnimation:UITableViewRowAnimationFade];
            } else [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            //[self configureCell:[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
        {
            NSLog(@"ROUTES: NSFetchedResultsChangeMove");

            if (tableView.isEditing) {
                NSIndexPath *newIndexPathForDelete = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section + 1];
                NSIndexPath *newIndexPathForInsert = [NSIndexPath indexPathForRow:newIndexPath.row inSection:newIndexPath.section + 1];
                
                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPathForDelete] withRowAnimation:UITableViewRowAnimationFade];
                [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPathForInsert] withRowAnimation:UITableViewRowAnimationFade];
                
                
            } else {
                
                
                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                
            }
            break;
        }
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}


- (void)searchBar:(UISearchBar *)searchBarReceived textDidChange:(NSString *)searchText
{
    if ([searchText isEqualToString:@""]) { 
        [self performSelector:@selector(hideKeyboardWithSearchBar:) withObject:searchBarReceived afterDelay:0];
    }
    
    [self.tableView reloadData];
    //NSLog(@"textDidChange predicate stop");
    
}
#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods


- (void)hideKeyboardWithSearchBar:(UISearchBar *)searchBar
{   
    [self.searchBar resignFirstResponder];   
}

#pragma mark - UITextField delegate


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
    
}


#pragma mark -
#pragma mark Action Methods

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"prepare");
//    DestinationsListWeBuy *selectedDestination = [self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForSelectedRow]];
//    TestingResultsTableViewController *destination = [segue destinationViewController];
//    destination.destination = selectedDestination;

    OutPeer *selectedOutPeer = [self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForSelectedRow]];
    TestingResultsTableViewController *destination = [segue destinationViewController];
    destination.outPeer = selectedOutPeer;

}

-(void)testStartForDestinations:(NSArray *)destinations forOutPeerID:(NSManagedObjectID *)outpeerID;
{
    NSLog(@"TEST STARTED FOR destinations:%@",destinations);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
        
        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        
        ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[delegate.managedObjectContext persistentStoreCoordinator] withSender:self withMainMoc:delegate.managedObjectContext];
        if (delegate.deviceToken) {
            NSString *deviceToken64 = [self encodeTobase64InputData:delegate.deviceToken];
            clientController.deviceToken64 = deviceToken64;
        }
        clientController.sender = self;
        //[clientController startTestingForOutPeerID:outpeerID  forDestinations:destinations forNumbers:numbers];
        numbers = nil;
    });
    

}


-(void)destinationChooseForIndexPath:(NSIndexPath *)indexPath;
{
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;

    NSString *storyBoardName = nil;
    //NSString *addRoutesTableViewControllerName = nil;

    if ([delegate isPad]) {
        storyBoardName = @"MainStoryboard_iPad";
        //addRoutesTableViewControllerName = @"MainStoryboard_iPad";
        
    }
    else {
        storyBoardName = @"MainStoryboard_iPhone";
    }
    AddRoutesTableViewControllerMain *viewController = [[UIStoryboard storyboardWithName:storyBoardName bundle:NULL] instantiateViewControllerWithIdentifier:@"AddRoutesTableViewControllerMain"];
    viewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    OutPeer *outPeerToTest = [self.fetchedResultsController objectAtIndexPath:indexPath];
    AddRoutesTableViewController *finalController = viewController.viewControllers.lastObject; 
    finalController.outPeerID = outPeerToTest.objectID;
    finalController.routesTableViewController = self;

    
    [self presentModalViewController:viewController animated:YES];
    
    NSDictionary *row = [NSDictionary dictionaryWithObjectsAndKeys:outPeerToTest.objectID,@"objectID",indexPath,@"indexPath", nil];
    [self.testedDestinationsID addObject:row];

}

- (IBAction)testSelected:(id)sender {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
        
        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        
        ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[delegate.managedObjectContext persistentStoreCoordinator] withSender:self withMainMoc:delegate.managedObjectContext];
        if (delegate.deviceToken) {
            NSString *deviceToken64 = [self encodeTobase64InputData:delegate.deviceToken];
            clientController.deviceToken64 = deviceToken64;
        }
        [selectedObjectsIDs enumerateObjectsUsingBlock:^(NSManagedObjectID *selected, NSUInteger idx, BOOL *stop) {
            //NSManagedObject *selectedObj = [delegate.managedObjectContext objectWithID:selected];
            
            //[clientController startTestingForDestinationsWeBuyID:selected forNumbers:nil];
            
        }];
        dispatch_async(dispatch_get_main_queue(), ^(void) { 
            testButton.enabled = YES;
            
        });
    });
}
- (IBAction)testedNotTestedSelection:(id)sender {
//    NSString *previous = self.previousSearchString;
//    self.previousSearchString = nil;
    fetchedResultsController = nil;
    fetchedResultsController = [self fetchedResultsController];
//    self.previousSearchString.string = previous;
    [self.tableView reloadData];
}

#pragma mark - actions
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0 || buttonIndex == -1) {
        //cancel
        
    } else {
        NSInteger number = actionSheet.numberOfButtons;
        
        if (number > buttonIndex) {
            AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            
            //NSLog(@"actionSheet: %u number:%u not found:%u",buttonIndex,number,NSNotFound);
            
            NSString *carrierName = [actionSheet buttonTitleAtIndex:buttonIndex];
            
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"Carrier" inManagedObjectContext:delegate.managedObjectContext];
            [fetchRequest setEntity:entity];
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", carrierName];
            [fetchRequest setPredicate:predicate];
            
            NSError *error = nil;
            NSArray *fetchedObjects = [delegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
            
            Carrier *findedCarrer = fetchedObjects.lastObject;
            NSString *prefix = firstCell.prefixEdited.text;
            
            
            NSString *name = firstCell.nameEdited.text;
            NSString *ips = firstCell.ipsEdited.text;
            
            firstCell.nameEdited.text = @"";
            firstCell.ipsEdited.text = @"";
            firstCell.prefixEdited.text = @"";
            

            OutPeer *peer = (OutPeer *)[NSEntityDescription 
                                        insertNewObjectForEntityForName:@"OutPeer" 
                                        inManagedObjectContext:delegate.managedObjectContext];
            
            peer.outpeerName = name;            
            peer.outpeerTag = name;            
            peer.outpeerPrefix = prefix;
            peer.ips = ips;

            peer.carrier = findedCarrer;
            
            [delegate saveContext];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
                ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[delegate.managedObjectContext persistentStoreCoordinator]withSender:self withMainMoc:delegate.managedObjectContext];
                [clientController addOutPeerWithID:peer.objectID];
            });
        }
        
    }
}
- (IBAction)startEditing:(id)sender {
    if (self.tableView.isEditing) {
        dispatch_async(dispatch_get_main_queue(), ^(void) { 
            NSIndexPath *index = [NSIndexPath indexPathForRow:0 inSection:0];
            startEditingButton.title = @"Edit";

            [self.tableView beginUpdates];

            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:index] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView setEditing:NO animated:YES];
            [self.tableView endUpdates];
        });
        
        
    } else {
        //            NSInteger count = [[[self fetchedResultsController] fetchedObjects] count];
        dispatch_async(dispatch_get_main_queue(), ^(void) { 
            startEditingButton.title = @"Save";

            NSIndexPath *index = [NSIndexPath indexPathForRow:0 inSection:0];
            [self.tableView beginUpdates];
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:index] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView setEditing:YES animated:YES];
            [self.tableView endUpdates];
            [self.searchBar resignFirstResponder];
        });
        
        //            NSInteger count = [[[self fetchedResultsController] fetchedObjects] count];
    }
}


#pragma mark - external reload methods

-(void)updateUIWithData:(NSArray *)data;
{
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;

    //sleep(5);
    NSLog(@"ROUTES: data:%@",data);
    NSString *status = [data objectAtIndex:0];
    //NSNumber *progress = [data objectAtIndex:1];
    //NSNumber *isItLatestMessage = [data objectAtIndex:2];
    NSManagedObjectID *objectID = nil;
    NSNumber *isError = [data objectAtIndex:3];
    if ([isError boolValue]) {             
        BOOL isStatusNoNumbersFound = ([status rangeOfString:@"processing tests:no numbers found"].location != NSNotFound);
        if (isStatusNoNumbersFound) {
            if ([data count] > 4) objectID = [data objectAtIndex:4];
            if (objectID) {
                NSManagedObject *finalObject = [delegate.managedObjectContext objectWithID:objectID];
                NSIndexPath *indexPath = [self.fetchedResultsController indexPathForObject:finalObject];

                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    [self.tableView beginUpdates];

                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"indexPath != %@",indexPath];
                    [self.testedDestinationsID filterUsingPredicate:predicate];
                    NSLog(@"testedDestinationsID object removed");
                    
                    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                    [self.tableView endUpdates];
                    /*
                    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                    
                    NSManagedObject *finalObject = [delegate.managedObjectContext objectWithID:objectID];
                    NSIndexPath *indexPath = [self.fetchedResultsController indexPathForObject:finalObject];
                    
                    if (indexPath) {
                        if (![NSThread isMainThread]) {
                            //[self performSelectorOnMainThread:@selector(release) withObject:nil waitUntilDone:NO];
                            NSLog(@"NOT MAIN THREAD");
                        } 
                        
                        [self.tableView beginUpdates];
                        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"indexPath != %@",indexPath];
                        [self.testedDestinationsID filterUsingPredicate:predicate];
                        
                        //[self.testedDestinationsID removeObject:filteredTestedDestinationsID.lastObject];
                        NSLog(@">>>>>>>>>>> testedDestinationsID object removed:%@",testedDestinationsID);
                        
                        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                        [self.tableView endUpdates];
                        
                        UIStoryboard *mainStoryboard = nil;
                        
                        if (delegate.isPad) {
                            
                            mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad"
                                                                       bundle: nil];
                        } else {
                            mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone"
                                                                       bundle: nil];
                            
                        }
                        NSArray *errorComponent = [status componentsSeparatedByString:@":"];
                        NSString *country = [errorComponent objectAtIndex:2];
                        
                        AddNumbersViewController *addNumbers = [mainStoryboard instantiateViewControllerWithIdentifier:@"AddNumbersViewController"];
                        addNumbers.countryName = country;
                        addNumbers.selectedIndexPath = indexPath;
                        addNumbers.routesTableViewController = self;
                        addNumbers.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
                        [self presentModalViewController:addNumbers animated:YES];
                        
                        
                    }*/
                });
                
            } else NSLog(@"=============> no objectID found");
            
        }
        return;
    }
    BOOL isStatusStartTesting = ([status rangeOfString:@"processing tests:start testing"].location != NSNotFound);
    if (isStatusStartTesting) {
        if ([data count] > 4) objectID = [data objectAtIndex:4];
        if (objectID) {
            
            NSManagedObject *finalObject = [delegate.managedObjectContext objectWithID:objectID];
            NSIndexPath *indexPath = [self.fetchedResultsController indexPathForObject:finalObject];
            if (indexPath) {
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                        
                        [self.tableView beginUpdates];
                        
                        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                        [self.tableView endUpdates];
                        
                    
                });
                
            }
        }
    }


    BOOL isStatusUpdateGraph = ([status rangeOfString:@"processing tests:finish testing"].location != NSNotFound);
    if (isStatusUpdateGraph) {
        if ([data count] > 4) objectID = [data objectAtIndex:4];
        if (objectID) {
            AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;

            NSManagedObject *finalObject = [delegate.managedObjectContext objectWithID:objectID];
            NSIndexPath *indexPath = [self.fetchedResultsController indexPathForObject:finalObject];
            if (indexPath) {
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                        
                        [self.tableView beginUpdates];
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"indexPath != %@",indexPath];
                    [self.testedDestinationsID filterUsingPredicate:predicate];
                        NSLog(@"testedDestinationsID object removed from finish");
                        
                        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                        [self.tableView endUpdates];
                    
                });

            }
        }
    }
    
    BOOL isOutPeerAdded = ([status rangeOfString:@"addOutPeerWithID:OutPeer added"].location != NSNotFound);
    if (isOutPeerAdded) {
        [activity stopAnimating];
    }

}

#pragma mark - UISearchBarDelegate
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBarLocal
{
    [searchBarLocal resignFirstResponder];
}

@end
