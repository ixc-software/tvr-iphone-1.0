//
//  CarriersTableViewController.m
//  vtr
//
//  Created by Oleksii Vynogradov on 4/22/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import "CarriersTableViewController.h"
#import "AppDelegate.h"
#import "ClientController.h"
#import "CarrierCell.h"

#import "Carrier.h"
#import "CompanyStuff.h"
#import "OutPeer.h"

@interface CarriersTableViewController ()
@property (nonatomic) NSArray* sectionsTitles;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *edit;
@property (nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic) NSMutableString *previousSearchString;
@property (nonatomic) NSMutableString *adminFirstAndLastName;
@property (readwrite) BOOL isCarriersEditing;
@property (nonatomic) UIActivityIndicatorView *activity;

@end

@implementation CarriersTableViewController
@synthesize searchBar;
@synthesize editButton;
@synthesize sectionsTitles;
@synthesize edit;
@synthesize fetchedResultsController,previousSearchString;
@synthesize isCarriersEditing,adminFirstAndLastName;
@synthesize activity;

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
    
    __block NSUInteger total = 0;
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityNameBlock
                                              inManagedObjectContext:delegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setResultType:NSDictionaryResultType];
    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObject:@"name"]];
    [fetchRequest setReturnsDistinctResults:YES];

    NSError *error = nil;
    NSArray *fetchedObjects = [delegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    [fetchedObjects enumerateObjectsUsingBlock:^(NSDictionary *country, NSUInteger idx, BOOL *stop) {
        NSString *countryName = [country valueForKey:@"name"];
        if (countryName && countryName.length > 0) {
            NSString *letter = [countryName substringWithRange:NSMakeRange(0, 1)];
            NSPredicate *filterForLetters = [NSPredicate predicateWithFormat:@"SELF == %@",letter];
            NSArray *filteredLetters = [letters filteredArrayUsingPredicate:filterForLetters];
            if (filteredLetters.count == 0) {
                [countForLetters addObject:[NSDictionary dictionaryWithObjectsAndKeys:letter,@"letter",[NSNumber numberWithInteger:total],@"index", nil]];
                [letters addObject:letter];
            }
            total += 1;
        }
    }];
    
    if (letters.count > 3) {
        [letters insertObject:UITableViewIndexSearch atIndex:0];
        [countForLetters addObject:[NSDictionary dictionaryWithObjectsAndKeys:letters,@"letters", nil]];
    }
    
    return [NSArray arrayWithArray:countForLetters];
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    previousSearchString = [[NSMutableString alloc] initWithString:@""];
    adminFirstAndLastName = [[NSMutableString alloc] initWithString:@""];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bk_320x480.png"]];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.0 green:0.44 blue:0.80 alpha:1.0];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    sectionsTitles = [[NSArray alloc] initWithArray:[self indexForSectionIndexTitlesForEntity:@"Carrier"]];
    fetchedResultsController = [self fetchedResultsControllerWithSearchString:@""];
    self.searchBar.tintColor = [UIColor colorWithRed:0.0 green:0.44 blue:0.80 alpha:1.0];
 
    activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    //set the initial property
    [activity stopAnimating];
    [activity hidesWhenStopped];
    //Create an instance of Bar button item with custome view which is of activity indicator
    UIBarButtonItem * barButton = [[UIBarButtonItem alloc] initWithCustomView:activity];
    //Set the bar button the navigation bar
    [self navigationItem].leftBarButtonItem = barButton;
    
}

- (void)viewDidUnload
{
    [self setEdit:nil];
    [self setSearchBar:nil];
    [self setEditButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void) viewWillDisappear:(BOOL)animated
{
    // here is adding selected routes
    //AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
}

-(void) viewWillAppear:(BOOL)animated
{
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[delegate.managedObjectContext persistentStoreCoordinator] withSender:self withMainMoc:delegate.managedObjectContext];
    CompanyStuff *admin = [clientController authorization];
    adminFirstAndLastName.string = [NSString stringWithFormat:@"%@ %@",admin.firstName,admin.lastName];
    if (!admin) edit.enabled = NO;
    else edit.enabled = YES;
    sectionsTitles = [[NSArray alloc] initWithArray:[self indexForSectionIndexTitlesForEntity:@"Carrier"]];
    [self.tableView reloadData];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    NSUInteger numberOfObjects = [sectionInfo numberOfObjects];
    if (tableView.isEditing) numberOfObjects = numberOfObjects + 1;
    NSLog(@"numberOfRowsInSection:1 is:%i",numberOfObjects);
    
    return numberOfObjects;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CarrierCell";
    CarrierCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[CarrierCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    if (tableView.isEditing && indexPath.row == 0) {
        // custom design for first editing row
        //NSArray *allObjects = [[self fetchedResultsController] fetchedObjects];
        //NSString *newCarrierName = [NSString stringWithFormat:@"new carrier%@",[NSNumber numberWithUnsignedInteger:[allObjects count]]];
        cell.name.hidden = YES;
        cell.responsibleFirstAndLastName.hidden = YES;
        cell.destinations.hidden = YES;
        cell.responsibleLabel.hidden = YES;
        
        cell.nameEdited.hidden = NO;
        cell.ipsEdited.hidden = NO;
        cell.prefixEdited.hidden = NO;
        
        
        //NSLog(@"display cell at index:%@ with carrier:NULL",indexPath);
        
    } else {
        cell.name.hidden = NO;
        cell.responsibleFirstAndLastName.hidden = NO;
        cell.destinations.hidden = NO;
        
        cell.nameEdited.hidden = YES;
        cell.ipsEdited.hidden = YES;
        cell.prefixEdited.hidden = YES;

        Carrier *carrier = nil;
        if (tableView.isEditing) carrier = [[self fetchedResultsController] objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row - 1 inSection:0]];
        else carrier = [[self fetchedResultsController] objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
        //cell.responsibleLabel.text = [NSString stringWithFormat:@"CarrierID:%@",carrier.externalID];
        
        //Carrier *managedObject = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        cell.name.text = carrier.name;
        CompanyStuff *stuff = carrier.companyStuff;
        cell.responsibleFirstAndLastName.text = [NSString stringWithFormat:@"%@ %@",stuff.firstName,stuff.lastName];
        
        if (tableView.isEditing && indexPath.row == 0) {
            // do nothing for first row in editing mode
            cell.destinations.hidden = YES;
            
        } else {
            cell.destinations.text = [NSString stringWithFormat:@"OutPeers:%@",[NSNumber numberWithUnsignedInteger:carrier.outPeer.count]];
            
        }
        
    }
    // Configure the cell...
    
    return cell;
}

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

-(void) startInsertForIndexPath:(NSIndexPath *)indexPath
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    [activity startAnimating];
    activity.hidden = NO;
    //[tableView beginUpdates];
    //isCarriersEditing = NO;
    
    CarrierCell *cell = (CarrierCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    NSString *name = cell.nameEdited.text.copy;
    NSString *ips = cell.ipsEdited.text.copy;
    NSString *prefix = cell.prefixEdited.text.copy;
    
    cell.nameEdited.text = @"";
    cell.ipsEdited.text = @"";
    cell.prefixEdited.text = @"";
    
    [cell.nameEdited resignFirstResponder];
    [cell.ipsEdited resignFirstResponder];
    [cell.prefixEdited resignFirstResponder];
    
    //[tableView endUpdates];
    
    
    //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
    //            dispatch_async(dispatch_get_main_queue(), ^(void) {
    //                sleep(1);
    //
    //                [tableView setEditing:NO animated:YES];
    //                //[tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    //            });
    //            sleep(4);
    
    
    Carrier *carrier = (Carrier *)[NSEntityDescription
                                   insertNewObjectForEntityForName:@"Carrier"
                                   inManagedObjectContext:delegate.managedObjectContext];
    
    carrier.name = name;
    
    OutPeer *outPeer = (OutPeer *)[NSEntityDescription
                                   insertNewObjectForEntityForName:@"OutPeer"
                                   inManagedObjectContext:delegate.managedObjectContext];
    
    outPeer.outpeerName = [NSString stringWithFormat:@"%@_out",name];
    outPeer.outpeerTag = name;
    
    outPeer.outpeerPrefix = prefix;
    outPeer.ips = ips;
    outPeer.carrier = carrier;
    
    ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[delegate.managedObjectContext persistentStoreCoordinator]withSender:self withMainMoc:delegate.managedObjectContext];
    
    CompanyStuff *updated = (CompanyStuff *)[delegate.managedObjectContext objectWithID:[clientController authorization].objectID];
    
    carrier.companyStuff = updated;
    [delegate saveContext];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
        ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[delegate.managedObjectContext persistentStoreCoordinator]withSender:self withMainMoc:delegate.managedObjectContext];
        
        [clientController addCarrierWithID:carrier.objectID];
    });

}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        NSFetchedResultsController *fetchController = [self fetchedResultsController];
        Carrier *carrier = [fetchController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row - 1 inSection:0]];
        NSLog(@"DELETE carrier:%@ with ID:%@",carrier.name,carrier.externalID);
        NSString *carrierExternalID = carrier.externalID.copy;
        
        [delegate.managedObjectContext deleteObject:carrier];
        [delegate saveContext];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
            
            ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[delegate.managedObjectContext persistentStoreCoordinator]withSender:self withMainMoc:delegate.managedObjectContext];
            [clientController removeCarrierWithID:carrierExternalID];
        });
        
    }   
    if (editingStyle == UITableViewCellEditingStyleInsert) {
        [self startInsertForIndexPath:indexPath];
        
//        [activity startAnimating];
//        activity.hidden = NO; 
//        //[tableView beginUpdates];
//        //isCarriersEditing = NO;
//        
//        CarrierCell *cell = (CarrierCell *)[tableView cellForRowAtIndexPath:indexPath];
//        NSString *name = cell.nameEdited.text.copy;
//        NSString *ips = cell.ipsEdited.text.copy;
//        NSString *prefix = cell.prefixEdited.text.copy;
//        
//        cell.nameEdited.text = @"";
//        cell.ipsEdited.text = @"";
//        cell.prefixEdited.text = @"";
//        
//        [cell.nameEdited resignFirstResponder];
//        [cell.ipsEdited resignFirstResponder];
//        [cell.prefixEdited resignFirstResponder];
//        
//        //[tableView endUpdates];
//        
//        
//        //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
//        //            dispatch_async(dispatch_get_main_queue(), ^(void) {
//        //                sleep(1);
//        //
//        //                [tableView setEditing:NO animated:YES];
//        //                //[tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
//        //            });
//        //            sleep(4);
//        
//        
//        Carrier *carrier = (Carrier *)[NSEntityDescription 
//                                       insertNewObjectForEntityForName:@"Carrier" 
//                                       inManagedObjectContext:delegate.managedObjectContext];
//        
//        carrier.name = name;
//        
//        OutPeer *outPeer = (OutPeer *)[NSEntityDescription 
//                                       insertNewObjectForEntityForName:@"OutPeer" 
//                                       inManagedObjectContext:delegate.managedObjectContext];
//        
//        outPeer.outpeerName = [NSString stringWithFormat:@"%@_out",name];
//        outPeer.outpeerTag = name;            
//        
//        outPeer.outpeerPrefix = prefix;
//        outPeer.ips = ips;
//        outPeer.carrier = carrier;
//        
//        ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[delegate.managedObjectContext persistentStoreCoordinator]withSender:self withMainMoc:delegate.managedObjectContext];
//        
//        CompanyStuff *updated = (CompanyStuff *)[delegate.managedObjectContext objectWithID:[clientController authorization].objectID];
//        
//        carrier.companyStuff = updated;
//        [delegate saveContext];
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
//            ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[delegate.managedObjectContext persistentStoreCoordinator]withSender:self withMainMoc:delegate.managedObjectContext];
//
//            [clientController addCarrierWithID:carrier.objectID];
//        });
        
//        [self.tableView setEditing:NO animated:YES];

        
        //[tableView isEditing
        
    }
    //[tableView setEditing:NO animated:YES];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!tableView.isEditing) return UITableViewCellEditingStyleNone;
    if (indexPath.row == 0) {
        return UITableViewCellEditingStyleInsert;
    } 
    return UITableViewCellEditingStyleDelete;
    
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"for indexPath:%@ isCarrierEditing:%@",indexPath,[NSNumber numberWithBool:isCarriersEditing]);
    
    if (tableView.isEditing)  return nil;
    else {
        return indexPath;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
//    self.tabBarController.selectedIndex = 2;
//    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//delegate.routesViewController.
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - FetchedResultsController methods


- (NSFetchedResultsController *)fetchedResultsControllerWithSearchString:(NSString *)searchString;
{
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;

    NSString *currentSearchString = searchString;
    
    if (!currentSearchString) currentSearchString = @"";
    
//    if (fetchedResultsController != nil && [currentSearchString isEqualToString:self.previousSearchString]) 
//    {
//        //NSLog(@"FETCH is same");
//        
//        return fetchedResultsController;
//    }
    
    //NSLog(@"FETCH is updated");
    
    [self.previousSearchString setString:currentSearchString];
    
    //isEdited = NO;
    NSMutableArray *predicateArray = [NSMutableArray array];
    
    
//    NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"(companyStuff.currentCompany.GUID == %@)",admin.currentCompany.GUID];;
    NSPredicate *filterPredicate = nil;
    
    if(currentSearchString.length) {
        NSPredicate *predicateName = [NSPredicate predicateWithFormat:@"(name CONTAINS[cd] %@)",currentSearchString];
        [predicateArray addObject:predicateName];
        
        if(filterPredicate)
        {
            filterPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:filterPredicate, [NSCompoundPredicate orPredicateWithSubpredicates:predicateArray], nil]];
        }
        else
        {
            filterPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:predicateArray];
        }
        
    }
    
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Carrier" inManagedObjectContext:delegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setPredicate:filterPredicate];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    
    //}
    
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
                                                                                                managedObjectContext:delegate.managedObjectContext 
                                                                                                  sectionNameKeyPath:nil 
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
    
    fetchedResultsController =  aFetchedResultsController;
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
    //NSLog(@"tableView isEditing:%@",[NSNumber numberWithBool:tableView.isEditing]);
    switch(type)
    {
            
        case NSFetchedResultsChangeInsert:
            NSLog(@"NSFetchedResultsChangeInsert tableView isEditing:%@",[NSNumber numberWithBool:tableView.isEditing]);

            if (tableView.isEditing) {
                NSIndexPath *newIndexPathForInsert = [NSIndexPath indexPathForRow:newIndexPath.row + 1 inSection:newIndexPath.section];
                [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPathForInsert] withRowAnimation:UITableViewRowAnimationFade];
            } else [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            NSLog(@"NSFetchedResultsChangeDelete tableView isEditing:%@",[NSNumber numberWithBool:tableView.isEditing]);

            if (tableView.isEditing) {
                NSIndexPath *newIndexPathForDelete = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section];
                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPathForDelete] withRowAnimation:UITableViewRowAnimationFade];
            } else [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            
            break;
            
        case NSFetchedResultsChangeUpdate:
            NSLog(@"NSFetchedResultsChangeUpdate tableView isEditing:%@",[NSNumber numberWithBool:tableView.isEditing]);

            if (tableView.isEditing) {
                NSIndexPath *newIndexPathForUpdate = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section];
                [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPathForUpdate] withRowAnimation:UITableViewRowAnimationFade];
            } else [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            //[self configureCell:[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
        {
            NSLog(@"NSFetchedResultsChangeMove tableView isEditing:%@",[NSNumber numberWithBool:tableView.isEditing]);

            if (tableView.isEditing) {
                NSIndexPath *newIndexPathForDelete = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section];
                NSIndexPath *newIndexPathForInsert = [NSIndexPath indexPathForRow:newIndexPath.row + 1 inSection:newIndexPath.section];
                
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

#pragma mark - searchBar delegate

- (void)searchBar:(UISearchBar *)searchBarr textDidChange:(NSString *)searchText
{
    if ([searchText isEqualToString:@""]) { 
        [self performSelector:@selector(hideKeyboardWithSearchBar:) withObject:searchBarr afterDelay:0];
        
    } else {
        
        if (![searchText isEqualToString:previousSearchString]) {
            NSFetchedResultsController *fetchController = [self fetchedResultsController];
            NSArray *allObjects = [fetchController fetchedObjects];
            if ([allObjects count] > 0) {
//                NSManagedObject *firstObject = [allObjects objectAtIndex:0];
                //NSLog(@"scroll to company:%@",[firstObject valueForKey:@"name"]);
//                [updatedCarriersIDs removeAllObjects];
//                [updatedCarriersIDs addObject:firstObject.objectID];
            }
            
        }
    }
    fetchedResultsController = [self fetchedResultsControllerWithSearchString:searchText];
    
    [self.tableView reloadData];
}
- (void)hideKeyboardWithSearchBar:(UISearchBar *)searchBar
{   
    
//    NSFetchedResultsController *fetchController = [self fetchedResultsController];
//    NSManagedObjectID *lastSelectedIDs = [updatedCarriersIDs lastObject];
//    if (lastSelectedIDs) {
//        NSManagedObject *obj = [fetchController.managedObjectContext objectWithID:lastSelectedIDs];
//        NSIndexPath *pathToScroll = [fetchController indexPathForObject:obj];
//        //NSLog(@"path to scroll:%@",pathToScroll);
//        [self.tableView scrollToRowAtIndexPath:pathToScroll atScrollPosition:UITableViewScrollPositionNone animated:YES];
//    }
    
    [self.searchBar resignFirstResponder];   
}


-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"prepare");
    Carrier *selectedCarrier = [self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForSelectedRow]];
    OutPeersTableViewController *destination = [segue destinationViewController];
    destination.selectedCarrier = selectedCarrier;
    
}
#pragma mark - UITextField delegate


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0 || buttonIndex == -1) {
        //cancel
        
    } else {
        if (buttonIndex == 1) {
            // insert
            NSLog(@"1");
            [self startInsertForIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            editButton.title = @"Edit";
            
            NSIndexPath *index = [NSIndexPath indexPathForRow:0 inSection:0];
            
            [self.tableView beginUpdates];
            //isCarriersEditing = NO;
            
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:index] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView setEditing:NO animated:YES];
            [self.tableView endUpdates];

        }
        if (buttonIndex == 2) {
            // save and not insert
            NSLog(@"2");
            CarrierCell *cell = (CarrierCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            
            cell.nameEdited.text = @"";
            cell.ipsEdited.text = @"";
            cell.prefixEdited.text = @"";
            
            [cell.nameEdited resignFirstResponder];
            [cell.ipsEdited resignFirstResponder];
            [cell.prefixEdited resignFirstResponder];

            editButton.title = @"Edit";
            
            NSIndexPath *index = [NSIndexPath indexPathForRow:0 inSection:0];
            
            [self.tableView beginUpdates];
            //isCarriersEditing = NO;
            
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:index] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView setEditing:NO animated:YES];
            [self.tableView endUpdates];

        }

    }
}
#pragma mark - actions

- (IBAction)startEditing:(id)sender {
    if (self.tableView.isEditing) {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            CarrierCell *cell = (CarrierCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            NSString *name = cell.nameEdited.text.copy;
            NSString *ips = cell.ipsEdited.text.copy;
            NSString *prefix = cell.prefixEdited.text.copy;
            
            if (name.length > 0 || ips.length >0 || prefix.length >0) {
                NSMutableString *title = [NSMutableString string];
                [title appendString:@"Do you like to insert new carrier with name:"];
                if (name.length >0) [title appendString:name];
                else [title appendString:@"(empty)"];
                [title appendString:@" and IP adresses:"];

                if (ips.length >0) [title appendString:ips];
                else [title appendString:@"(empty)"];

                [title appendString:@" and prefix:"];

                if (prefix.length >0) [title appendString:prefix];
                else [title appendString:@"(empty)"];

                
                UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"Return to editing" otherButtonTitles:@"Insert",@"Save without insert",nil];
                sheet.tag = 1;
                sheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
                AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                
                if ([delegate isPad]) {
                    [sheet showFromRect:self.navigationController.navigationBar.frame inView:self.view animated:YES];
                } else [sheet showFromToolbar:self.navigationController.toolbar];//showFromRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width)
                
            } else {
                
                editButton.title = @"Edit";
                
                NSIndexPath *index = [NSIndexPath indexPathForRow:0 inSection:0];
                
                [self.tableView beginUpdates];
                //isCarriersEditing = NO;
                
                [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:index] withRowAnimation:UITableViewRowAnimationFade];
                [self.tableView setEditing:NO animated:YES];
                [self.tableView endUpdates];
            }
        });

        
    } else {
        //            NSInteger count = [[[self fetchedResultsController] fetchedObjects] count];
        dispatch_async(dispatch_get_main_queue(), ^(void) { 
            editButton.title = @"Save";

            NSIndexPath *index = [NSIndexPath indexPathForRow:0 inSection:0];
            [self.tableView beginUpdates];
            //isCarriersEditing = YES;
            
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
    //sleep(5);
    //NSLog(@"CERRIERS: data:%@",data);
    NSString *status = [data objectAtIndex:0];
    //NSNumber *progress = [data objectAtIndex:1];
    //NSNumber *isItLatestMessage = [data objectAtIndex:2];
    
    //    NSNumber *isError = [data objectAtIndex:3];
    //    if ([isError boolValue]) {             
    BOOL isCarrierAdded = ([status rangeOfString:@"addCarrierWithID:carrier added"].location != NSNotFound);
    if (isCarrierAdded) {
//        sleep(3);
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [activity stopAnimating];
//            [self.tableView beginUpdates];
//            [self.tableView setEditing:NO animated:YES];
//            
//            isCarriersEditing = NO;
//            [self.tableView endUpdates];
//            
        });
        
    }
    return;
    //    }
}



@end
