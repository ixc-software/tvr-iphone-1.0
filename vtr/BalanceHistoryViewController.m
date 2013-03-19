//
//  BalanceHistoryViewController.m
//  tvr
//
//  Created by Oleksii Vynogradov on 1/4/13.
//  Copyright (c) 2013 IXC-USA Corp. All rights reserved.
//

#import "BalanceHistoryViewController.h"
#import "AppDelegate.h"
#import "BanceHistoryCell.h"
#import "GrossBookRecord.h"

@interface BalanceHistoryViewController ()

@property (nonatomic) NSFetchedResultsController *fetchedResultsController;


@end

@implementation BalanceHistoryViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.fetchedResultsController = [self newFetchedResultsControllerWithSearch:@""];
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bk_320x480.png"]];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.0 green:0.44 blue:0.80 alpha:1.0];
    //[[self navigationController] setNavigationBarHidden:NO animated:NO];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
//    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    NSEntityDescription *entity = [NSEntityDescription entityForName:@"GrossBookRecord" inManagedObjectContext:delegate.managedObjectContext];
//    [fetchRequest setEntity:entity];
//    
//    NSError *error = nil;
//    NSArray *allRecords = [delegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
//    [allRecords enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        [delegate.managedObjectContext deleteObject:obj];
//        
//    }];
//    [delegate saveContext];
//    NSLog(@"history->%@",allRecords);
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:NO animated:NO];
    self.fetchedResultsController = [self newFetchedResultsControllerWithSearch:@""];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    id <NSFetchedResultsSectionInfo> sectionInfoCoreData = [[[self fetchedResultsController] sections] objectAtIndex:section];
    NSInteger numSpecificsInSection = [sectionInfoCoreData numberOfObjects];
    //NSLog(@"number of rows:%d in section:%d",numSpecificsInSection,section);
    return numSpecificsInSection;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"BanceHistoryCell";
    BanceHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    GrossBookRecord *record = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    NSDateFormatter *formatterDate = [[NSDateFormatter alloc] init];
    [formatterDate setDateFormat:@"dd.MM.yyyy"];

    NSNumberFormatter *newFormatter = [[NSNumberFormatter alloc] init];
    newFormatter.maximumFractionDigits = 2;
    
    cell.date.text = [formatterDate stringFromDate:record.creationDate];
    if ([record.tariffPlan isEqualToString:@"Advanced"]) cell.operationLabel.text = [NSString stringWithFormat:@"Refilled advanced plan"];
    if ([record.tariffPlan isEqualToString:@"AdvancedPlusFax"]) cell.operationLabel.text = [NSString stringWithFormat:@"Refilled advanced plus fax plan"];
    
    cell.paymentAmount.text = [NSString stringWithFormat:@"$%@",[newFormatter stringFromNumber:record.paymentAmount]];

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
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
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

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    // Navigation logic may go here. Create and push another view controller.
//    /*
//     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
//     // ...
//     // Pass the selected object to the new view controller.
//     [self.navigationController pushViewController:detailViewController animated:YES];
//     */
//}

- (NSFetchedResultsController *)newFetchedResultsControllerWithSearch:(NSString *)searchString
{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    NSPredicate *filterPredicate = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"GrossBookRecord" inManagedObjectContext:delegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    if (filterPredicate) [fetchRequest setPredicate:filterPredicate];
    [fetchRequest setFetchBatchSize:20];
    [fetchRequest setSortDescriptors:sortDescriptors];
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                                managedObjectContext:delegate.managedObjectContext
                                                                                                  sectionNameKeyPath:nil
                                                                                                           cacheName:nil];
    aFetchedResultsController.delegate = nil;
    NSError *error = nil;
    if (![aFetchedResultsController performFetch:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    return aFetchedResultsController;
}    


@end
