//
//  AddRoutesTableViewController.m
//  vtr
//
//  Created by Oleksii Vynogradov on 4/22/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import "AddRoutesTableViewController.h"
#import "AppDelegate.h"
#import "NormalizedCodesTransformer.h"
#import "NormalizedCountryTransformer.h"
#import "NormalizedSpecificTransformer.h"
#import "CountrySpecificCodeList.h"
#import "AddRoutesCell.h"
#import "OutPeersTableViewController.h"

#import "DestinationsListWeBuy.h"
#import "ClientController.h"
#import "NumbersForTestEditorMain.h"

@interface AddRoutesTableViewController ()
@property (nonatomic) IBOutlet UISearchBar *bar;
@property (nonatomic) UISegmentedControl *routesList;
@property (nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic) NSMutableString *previousSearchString;
@property (nonatomic) NSMutableArray *selectedObjectsIDs;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addRoutes;
@property (nonatomic) NSArray* sectionsTitles;

@end

@implementation AddRoutesTableViewController
@synthesize bar,routesList;
@synthesize fetchedResultsController,previousSearchString;
@synthesize selectedObjectsIDs;
@synthesize addRoutes;
@synthesize sectionsTitles;
@synthesize outPeerID,routesTableViewController;

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
    self.bar.tintColor = [UIColor colorWithRed:0.0 green:0.44 blue:0.80 alpha:1.0];
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if ([delegate isPad]) self.tableView.rowHeight = 82.0;
    else self.tableView.rowHeight = 109.0;
}

- (void)viewDidUnload
{
    [self setAddRoutes:nil];
    [self setBar:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void) viewWillDisappear:(BOOL)animated
{
    // here is adding selected routes
//    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;

}

-(void) viewWillAppear:(BOOL)animated
{
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[delegate.managedObjectContext persistentStoreCoordinator] withSender:self withMainMoc:delegate.managedObjectContext];
    CompanyStuff *admin = [clientController authorization];
    if (!admin) addRoutes.enabled = NO;
    else addRoutes.enabled = YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

#pragma mark Table view data source and delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
    NSInteger count = [[[self fetchedResultsController] sections] count];
    //NSLog(@"Sections:%@",[NSNumber numberWithUnsignedInteger:count]);
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AddRoutesCell";
    AddRoutesCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[AddRoutesCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    // Configure the cell...
    CountrySpecificCodeList *managedObject = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    cell.specific.text = managedObject.specific;
    cell.codes.text = managedObject.codes;
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
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
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    //NSLog(@"%@",sectionsTitles);
    
    return [[sectionsTitles lastObject] valueForKey:@"letters"]; 
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if ([title isEqualToString:UITableViewIndexSearch]) return 0;
    
    NSPredicate *letterPredicate = [NSPredicate predicateWithFormat:@"letter == %@",title];
    NSArray *sectionTitlesFiltered = [sectionsTitles filteredArrayUsingPredicate:letterPredicate];
    if ([sectionTitlesFiltered count] == 0) NSLog(@"COUNTRIES LIST: >>>> warning, for title %@ index not found",title);
    else return [[[sectionTitlesFiltered lastObject] valueForKey:@"index"] unsignedIntegerValue];
    //NSLog(@"sectionForSectionIndexTitle:%@ and index:%@ return value is:%@",title,[NSNumber numberWithUnsignedInteger:index],[NSNumber numberWithUnsignedInteger:index * 12]);
    //return [self.fetchedResultsController sectionForSectionIndexTitle:title atIndex:index - 1];
    return 0;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AddRoutesCell *selectedCell = (AddRoutesCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    CountrySpecificCodeList *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];

    if (selectedCell.accessoryType == UITableViewCellAccessoryNone) {
        selectedCell.accessoryType = UITableViewCellAccessoryCheckmark;
        [selectedObjectsIDs addObject:object.objectID];
    }
    else {
        selectedCell.accessoryType = UITableViewCellAccessoryNone;
        [selectedObjectsIDs removeObject:object.objectID];
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
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

    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"country" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    NSPredicate *filterPredicate = nil;
    
    /*
     Set up the fetched results controller.
     */
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CountrySpecificCodeList" inManagedObjectContext:delegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSMutableArray *predicateArray = [NSMutableArray array];
    
    if(searchString.length) {
        
        NormalizedCountryTransformer *transformerCountry = [[NormalizedCountryTransformer alloc] init];
        NSPredicate *predicateCountryUnModified = [NSPredicate predicateWithFormat:@"(country CONTAINS[cd] %@)",searchString];
        NSPredicate *predicateCountry = [transformerCountry reverseTransformedValue:predicateCountryUnModified];
        
        NormalizedSpecificTransformer *transformerSpecific = [[NormalizedSpecificTransformer alloc] init];
        NSPredicate *predicateSpecificUnModified = [NSPredicate predicateWithFormat:@"(specific CONTAINS[cd] %@)",searchString];
        NSPredicate *predicateSpecific = [transformerSpecific reverseTransformedValue:predicateSpecificUnModified];
        
        NormalizedCodesTransformer *transformerCodes = [[NormalizedCodesTransformer alloc] init];
        NSPredicate *predicateCodesUnModified = [NSPredicate predicateWithFormat:@"(codes CONTAINS[cd] %@)",searchString];
        NSPredicate *predicateCodes = [transformerCodes reverseTransformedValue:predicateCodesUnModified];
        
        [predicateArray addObject:predicateCountry];
        [predicateArray addObject:predicateSpecific];
        [predicateArray addObject:predicateCodes];
        
        
        if(filterPredicate)
        {
            filterPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:filterPredicate, [NSCompoundPredicate orPredicateWithSubpredicates:predicateArray], nil]];
        }
        else
        {
            filterPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:predicateArray];
        }
    }
    
    [fetchRequest setPredicate:filterPredicate];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    //[fetchRequest setFetchLimit:120];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
                                                                                                managedObjectContext:delegate.managedObjectContext 
                                                                                                  sectionNameKeyPath:@"country" 
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
    NSString *currentSearchString = self.bar.text;
    
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


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([searchText isEqualToString:@""]) { 
        [self performSelector:@selector(hideKeyboardWithSearchBar:) withObject:searchBar afterDelay:0];
    }
    
    [self.tableView reloadData];
    //NSLog(@"textDidChange predicate stop");
    
}
#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods


- (void)hideKeyboardWithSearchBar:(UISearchBar *)searchBar
{   
    [self.bar resignFirstResponder];   
}

#pragma mark - own actions

- (IBAction)addRoutesStart:(id)sender {
    self.routesTableViewController.outpeerIDForTest = outPeerID;
    
    NSArray *selectedObjesID = self.selectedObjectsIDs;
    
    if (selectedObjesID) self.routesTableViewController.destinationsForTest = selectedObjesID.copy;

    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    delegate.countrySpecificIDsForTest = selectedObjectsIDs.copy;
    
    NSString *storyBoardName = nil;
    //NSString *addRoutesTableViewControllerName = nil;
    
    if ([delegate isPad]) {
        storyBoardName = @"MainStoryboard_iPad";
        //addRoutesTableViewControllerName = @"MainStoryboard_iPad";
        
    }
    else {
        storyBoardName = @"MainStoryboard_iPhone";
    }
    NumbersForTestEditorMain *viewController = [[UIStoryboard storyboardWithName:storyBoardName bundle:NULL] instantiateViewControllerWithIdentifier:@"NumbersForTestEditorMain"];
    viewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;

    [self presentModalViewController:viewController animated:YES];

//    [self.routesTableViewController testStartForDestinations:selectedObjectsIDs forOutPeerID:self.outPeerID];
    //[self dismissModalViewControllerAnimated:YES];
    
}
- (IBAction)cancelAdding:(id)sender {
    self.routesTableViewController.destinationsForTest = nil;
    self.routesTableViewController.outpeerIDForTest = nil;

    [self dismissModalViewControllerAnimated:YES];

}

#pragma mark - UISearchBarDelegate
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}



@end
