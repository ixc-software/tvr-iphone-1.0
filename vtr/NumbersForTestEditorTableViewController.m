//
//  NumbersForTestEditorTableViewController.m
//  tvr
//
//  Created by Oleksii Vynogradov on 9/6/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import "NumbersForTestEditorTableViewController.h"
#import "AppDelegate.h"
#import "DCRoundSwitch.h"
#import "ClientController.h"
#import "NumbersForTestCell.h"

#import "CountrySpecificCodeList.h"

@interface NumbersForTestEditorTableViewController ()
@property (weak, nonatomic) IBOutlet DCRoundSwitch *protocolSwitch;
@property (strong) NSDictionary *data;
@property (strong) NSIndexPath *selected;

@end

@implementation NumbersForTestEditorTableViewController
@synthesize protocolSwitch;

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
    protocolSwitch.onText = @"SIP";
    protocolSwitch.offText = @"H323";
    protocolSwitch.onTintColor = [UIColor colorWithRed:0 green:0.37 blue:0.78 alpha:1.0];

    protocolSwitch.on = YES;
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bk_320x480.png"]];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.0 green:0.44 blue:0.80 alpha:1.0];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [self setProtocolSwitch:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSArray *countrySpecificObjecsIDs = delegate.countrySpecificIDsForTest;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
        

        ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[delegate.managedObjectContext persistentStoreCoordinator] withSender:self withMainMoc:delegate.managedObjectContext];
        clientController.sender = self;
        [clientController startGetPhoneNumbersForContrySpecific:countrySpecificObjecsIDs];
    });
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return self.data.allKeys.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    
    NSArray *allKeys = self.data.allKeys;
    NSString *key = [allKeys objectAtIndex:section];
    NSArray *allNumbers = [self.data valueForKey:key];
    if (tableView.isEditing) return allNumbers.count + 1;
    return allNumbers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"NumbersForTestCell";
    NumbersForTestCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    NSArray *allKeys = self.data.allKeys;
    NSString *key = [allKeys objectAtIndex:indexPath.section];
    NSArray *allNumbers = [self.data valueForKey:key];
    
    if (tableView.isEditing) {
        if (indexPath.row == 0) {
            cell.numberLabel.text = @"new number";

        } else {
            NSDictionary *row = [allNumbers objectAtIndex:indexPath.row - 1];
            NSString *number = [row valueForKey:@"number"];
            cell.numberLabel.text = number;
            NSString *description = [row valueForKey:@"description"];
            if (description.length > 0) cell.descriptionLabel.text = description;
            else cell.descriptionLabel.text = @"system number";
            
        }
        
    } else {
        NSDictionary *row = [allNumbers objectAtIndex:indexPath.row];
        NSString *number = [row valueForKey:@"number"];
        cell.numberLabel.text = number;
        NSString *description = [row valueForKey:@"description"];
        if (description.length > 0) cell.descriptionLabel.text = description;
        else cell.descriptionLabel.text = @"system number";
        
    }
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    
    NSArray *allKeys = self.data.allKeys;
    NSString *key = [allKeys objectAtIndex:section];
    return key;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!tableView.isEditing) return UITableViewCellEditingStyleNone;
    if (indexPath.row == 0) {
        return UITableViewCellEditingStyleInsert;
    }
    return UITableViewCellEditingStyleDelete;
    
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        
        NSArray *allKeys = self.data.allKeys;
        NSString *key = [allKeys objectAtIndex:self.selected.section];
        NSArray *allNumbers = [self.data valueForKey:key];
        NSMutableArray *allNumbersMutable = allNumbers.mutableCopy;
        [allNumbersMutable removeObjectAtIndex:self.selected.row - 1];
        NSMutableDictionary *dataMutable = self.data.mutableCopy;
        [dataMutable setValue:allNumbersMutable forKey:key];
        self.data = dataMutable;
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];

    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        NumbersForTestCell *cell = (NumbersForTestCell *)[tableView cellForRowAtIndexPath:indexPath];
        cell.numberLabel.text = cell.numberEditor.text;
        NSArray *allKeys = self.data.allKeys;
        NSString *key = [allKeys objectAtIndex:indexPath.section];
        NSArray *allNumbers = [self.data valueForKey:key];

        NSMutableDictionary *rowMutable = [NSMutableDictionary dictionary];
        [rowMutable setValue:cell.numberEditor.text forKey:@"number"];
        [rowMutable setValue:@"added" forKey:@"description"];

        NSMutableArray *allNumbersMutable = allNumbers.mutableCopy;
        [allNumbersMutable insertObject:rowMutable atIndex:indexPath.row];
        NSMutableDictionary *dataMutable = self.data.mutableCopy;
        [dataMutable setValue:allNumbersMutable forKey:key];
        self.data = dataMutable;
        [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationFade];
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NumbersForTestCell *cell = (NumbersForTestCell *)[tableView cellForRowAtIndexPath:indexPath];

    if ([tableView isEditing]) {
        cell.numberLabel.hidden = YES;
        cell.numberEditor.hidden = NO;
        [cell.numberEditor becomeFirstResponder];
        [tableView deselectRowAtIndexPath:indexPath animated:NO];

    } else {
        if (cell.accessoryType == UITableViewCellAccessoryCheckmark) cell.accessoryType = UITableViewCellAccessoryNone;
        else cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [tableView deselectRowAtIndexPath:indexPath animated:YES];

    }
    self.selected = indexPath;
}


- (IBAction)cancelEditing:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
    
}

- (IBAction)editNumbers:(id)sender {
    if (self.tableView.isEditing) {
        //NSLog(@"stop editing");

        [sender setTitle:@"Edit"];
        //[self.tableView beginUpdates];
        [self.tableView setEditing:NO animated:YES];
        //[self.tableView endUpdates];
        [self.tableView reloadData];

        //[self.tableView reloadData];
    } else {
       // NSLog(@"start editing");
        [sender setTitle:@"Save"];
        
        //[self.tableView beginUpdates];
        [self.tableView setEditing:YES animated:YES];
        [self.tableView reloadData];

//        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
//        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];

        //[self.tableView endUpdates];

        //[self.tableView reloadData];

    }
}

- (IBAction)beginTests:(id)sender {
}

#pragma mark - ClientController delegate

-(void)refreshNumbers:(NSArray *)receivedNumbers withCodes:(NSString *)codes;
{
    //NSLog(@"refresh for:%@ codes;%@",receivedNumbers,codes);
    //[self.tableView beginUpdates];
    // row inside, {number=2323,description="sd"}
    NSMutableDictionary *currentData = self.data.mutableCopy;
    if (!currentData) currentData = [NSMutableDictionary dictionary];
    [currentData setValue:receivedNumbers forKey:codes];
    self.data = currentData;
    //[self.tableView endUpdates];
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        
        [self.tableView reloadData];
    });
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NumbersForTestCell *cell = (NumbersForTestCell *)[self.tableView cellForRowAtIndexPath:self.selected];
    cell.numberLabel.text = textField.text;
    NSArray *allKeys = self.data.allKeys;
    NSString *key = [allKeys objectAtIndex:self.selected.section];
    NSArray *allNumbers = [self.data valueForKey:key];
    NSDictionary *row = [allNumbers objectAtIndex:self.selected.row - 1];
    NSMutableDictionary *rowMutable = row.mutableCopy;
    [rowMutable setValue:textField.text forKey:@"number"];
    NSMutableArray *allNumbersMutable = allNumbers.mutableCopy;
    [allNumbersMutable replaceObjectAtIndex:self.selected.row - 1 withObject:rowMutable];
    NSMutableDictionary *dataMutable = self.data.mutableCopy;
    [dataMutable setValue:allNumbersMutable forKey:key];
    self.data = dataMutable;
    
    cell.numberEditor.hidden = YES;
    cell.numberLabel.hidden = NO;
    [textField resignFirstResponder];
    return YES;
}
@end
