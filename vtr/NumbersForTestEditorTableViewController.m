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
#import "AddRoutesTableViewController.h"

#import "CountrySpecificCodeList.h"

@interface NumbersForTestEditorTableViewController ()
@property (weak, nonatomic) IBOutlet DCRoundSwitch *protocolSwitch;
@property (strong) NSDictionary *data;
@property (strong) NSIndexPath *selected;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *error;
@property (nonatomic) UIActivityIndicatorView *activity;
@property (weak, nonatomic) IBOutlet UIProgressView *progress;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *beginTestsButton;

@end

@implementation NumbersForTestEditorTableViewController
@synthesize progress = _progress;
@synthesize beginTestsButton = _beginTestsButton;
@synthesize error = _error;
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
    NSLog(@"viewDidLoad1");

    [super viewDidLoad];
    protocolSwitch.onText = @"SIP";
    protocolSwitch.offText = @"H323";
    protocolSwitch.onTintColor = [UIColor colorWithRed:0 green:0.37 blue:0.78 alpha:1.0];

    protocolSwitch.on = YES;
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bk_320x480.png"]];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.0 green:0.44 blue:0.80 alpha:1.0];
    self.navigationController.toolbar.tintColor = [UIColor colorWithRed:0.0 green:0.44 blue:0.80 alpha:1.0];
    //self.navigationItem.prompt = @"This is the title";
    //[self.navigationItem]
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    //set the initial property
    [self.activity stopAnimating];
    [self.activity hidesWhenStopped];
    //Create an instance of Bar button item with custome view which is of activity indicator
    UIBarButtonItem * barButton = [[UIBarButtonItem alloc] initWithCustomView:self.activity];
    //Set the bar button the navigation bar
    [self navigationItem].leftBarButtonItem = barButton;

}

- (void)viewDidUnload
{
    [self setProtocolSwitch:nil];
    [self setError:nil];
    [self setProgress:nil];
    [self setBeginTestsButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void) viewDidAppear:(BOOL)animated
{
    NSLog(@"viewDidAppear1:self.outPeerID:%@",self.outPeerID);

    [super viewDidAppear:animated];

    [self.activity startAnimating];
    self.activity.hidden = NO;
    self.beginTestsButton.enabled = NO;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        NSArray *countrySpecificObjecsIDs = delegate.countrySpecificIDsForTest;
        
        //NSLog(@"viewDidAppear2:%@",countrySpecificObjecsIDs);

        ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[delegate.managedObjectContext persistentStoreCoordinator] withSender:self withMainMoc:delegate.managedObjectContext];
        clientController.sender = self;
        [clientController startGetPhoneNumbersForContrySpecific:countrySpecificObjecsIDs.copy];

        //NSLog(@"viewWillAppear3");

        sleep(5);
        self.error = nil;

        self.error = [[UIBarButtonItem alloc] initWithTitle:@"test" style: UIBarButtonItemStyleBordered target:NULL action:NULL];
        
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
    else {
        if (allNumbers.count == 0) return 1;
        return allNumbers.count;
    }
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
            cell.descriptionLabel.hidden = YES;
        } else {
            NSDictionary *row = [allNumbers objectAtIndex:indexPath.row - 1];
            NSString *number = [row valueForKey:@"number"];
            cell.numberLabel.text = number;
            NSString *description = [row valueForKey:@"description"];
            if (description.length > 0) cell.descriptionLabel.text = description;
            else cell.descriptionLabel.text = @"system number";
            
            NSNumber *isEnabled = [row valueForKey:@"isEnabled"];
            if (isEnabled && isEnabled.boolValue == NO) cell.accessoryType = UITableViewCellAccessoryNone;
            else  cell.accessoryType = UITableViewCellAccessoryCheckmark;
            cell.descriptionLabel.hidden = YES;

            
        }
        
    } else {
        if (allNumbers.count == 0) {
            cell.descriptionLabel.text = @"no numbers, please edit to add";
            cell.numberLabel.text = @"new number";

            cell.accessoryType = UITableViewCellAccessoryNone;
        } else {
            NSDictionary *row = [allNumbers objectAtIndex:indexPath.row];
            NSString *number = [row valueForKey:@"number"];
            cell.numberLabel.text = number;
            NSString *description = [row valueForKey:@"description"];
            if (description.length > 0) cell.descriptionLabel.text = description;
            else cell.descriptionLabel.text = @"system number";
            NSNumber *isEnabled = [row valueForKey:@"isEnabled"];
            if (isEnabled && isEnabled.boolValue == NO) cell.accessoryType = UITableViewCellAccessoryNone;
            else  cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        cell.descriptionLabel.hidden = NO;

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
        NSString *key = [allKeys objectAtIndex:indexPath.section];
        NSArray *allNumbers = [self.data valueForKey:key];
        NSMutableArray *allNumbersMutable = allNumbers.mutableCopy;
        [allNumbersMutable removeObjectAtIndex:indexPath.row - 1];
        NSMutableDictionary *dataMutable = self.data.mutableCopy;
        [dataMutable setValue:allNumbersMutable forKey:key];
        self.data = dataMutable;
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];

    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        
        [tableView beginUpdates];
        NumbersForTestCell *cell = (NumbersForTestCell *)[tableView cellForRowAtIndexPath:indexPath];
        cell.numberLabel.text = cell.numberEditor.text;
        NSArray *allKeys = self.data.allKeys;
        NSString *key = [allKeys objectAtIndex:indexPath.section];
        NSArray *allNumbers = [self.data valueForKey:key];

        NSMutableArray *allNumbersMutable = [NSMutableArray array];
        if (!allNumbers || allNumbers.count == 0) {
            NSMutableDictionary *rowMutable = [NSMutableDictionary dictionary];
            [rowMutable setValue:cell.numberEditor.text forKey:@"number"];
            [rowMutable setValue:@"added by user" forKey:@"description"];
            [allNumbersMutable addObject:rowMutable];
        } else {
            NSMutableDictionary *rowMutable = [NSMutableDictionary dictionary];
            [rowMutable setValue:cell.numberEditor.text forKey:@"number"];
            [rowMutable setValue:@"added by user" forKey:@"description"];
            [allNumbersMutable addObject:rowMutable];
            [allNumbersMutable addObjectsFromArray:allNumbers];
        }
        NSMutableDictionary *dataMutable = self.data.mutableCopy;
        [dataMutable setValue:allNumbersMutable forKey:key];
        self.data = dataMutable;
        
        [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationFade];
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        [tableView endUpdates];

    }
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NumbersForTestCell *cell = (NumbersForTestCell *)[tableView cellForRowAtIndexPath:indexPath];

    if ([tableView isEditing]) {
        cell.numberLabel.hidden = YES;
        cell.numberEditor.hidden = NO;
        if (cell.numberLabel.text.length > 0 && ![cell.numberLabel.text isEqualToString:@"new number"]) cell.numberEditor.text = cell.numberLabel.text;
        else cell.numberEditor.text = @"";
        
        [cell.numberEditor becomeFirstResponder];
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        [cell.saveSegment removeAllSegments];
        [cell.saveSegment insertSegmentWithTitle:@"Save" atIndex:0 animated:NO];
        cell.saveSegment.tintColor = [UIColor colorWithRed:0.0 green:0.44 blue:0.80 alpha:1.0];
        cell.saveSegment.hidden = NO;

    } else {
        if ( ![cell.numberLabel.text isEqualToString:@"new number"]) {
            
            if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
                // number was enabled, disable it
                cell.accessoryType = UITableViewCellAccessoryNone;
                NSArray *allKeys = self.data.allKeys;
                NSString *key = [allKeys objectAtIndex:indexPath.section];
                NSArray *allNumbers = [self.data valueForKey:key];
                NSDictionary *row = [allNumbers objectAtIndex:indexPath.row];
                NSMutableDictionary *rowMutable = row.mutableCopy;
                [rowMutable setValue:[NSNumber numberWithBool:NO] forKey:@"isEnabled"];
                NSMutableArray *allNumbersMutable = allNumbers.mutableCopy;
                [allNumbersMutable replaceObjectAtIndex:indexPath.row withObject:rowMutable];
                NSMutableDictionary *dataMutable = self.data.mutableCopy;
                [dataMutable setValue:allNumbersMutable forKey:key];
                self.data = dataMutable;
                
                
            } else {
                
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                NSArray *allKeys = self.data.allKeys;
                NSString *key = [allKeys objectAtIndex:indexPath.section];
                NSArray *allNumbers = [self.data valueForKey:key];
                NSDictionary *row = [allNumbers objectAtIndex:indexPath.row ];
                NSMutableDictionary *rowMutable = row.mutableCopy;
                [rowMutable setValue:[NSNumber numberWithBool:YES] forKey:@"isEnabled"];
                NSMutableArray *allNumbersMutable = allNumbers.mutableCopy;
                [allNumbersMutable replaceObjectAtIndex:indexPath.row withObject:rowMutable];
                NSMutableDictionary *dataMutable = self.data.mutableCopy;
                [dataMutable setValue:allNumbersMutable forKey:key];
                self.data = dataMutable;
                
            }
        }
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
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    NSLog(@"routesViewController->:%@",delegate.routesViewController);

    
    [self.data enumerateKeysAndObjectsWithOptions: 0 usingBlock:^(NSString *codes, NSArray *numbers, BOOL *stop) {
        NSArray *codesList = [codes componentsSeparatedByString:@","];
//        NSLog(@"self.outPeerID:%@",delegate.outPeerID);
        NSMutableArray *numbersFinal = [NSMutableArray array];
        
        [numbers enumerateObjectsUsingBlock:^(NSDictionary *row, NSUInteger idx, BOOL *stop) {
            NSNumber *isEnabled = [row valueForKey:@"isEnabled"];
            if (isEnabled && isEnabled.boolValue == NO) {
                
            } else {
                NSNumber *number = [row valueForKey:@"number"];
                if (number) [numbersFinal addObject:number];
            }
            
        }];

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
            AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;

            ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[delegate.managedObjectContext persistentStoreCoordinator] withSender:self withMainMoc:delegate.managedObjectContext];
            clientController.sender = delegate;
            //NSLog(@"delegate.routesViewController:%@",delegate.routesViewController);
            //NSLog(@"delegate.routesViewController2:%@",[delegate.tapBarController.viewControllers objectAtIndex:2]);

            [clientController startTestingForOutPeerID:delegate.outPeerID forCodes:codesList forNumbers:numbersFinal withProtocolSIP:protocolSwitch.on];
        });
    }];

    delegate.isTestsStarted = YES;
    [self dismissModalViewControllerAnimated:YES];
    
}
- (IBAction)saveEditingNumber:(id)sender {
    NumbersForTestCell *cell = (NumbersForTestCell *)[self.tableView cellForRowAtIndexPath:self.selected];
    cell.numberLabel.text = cell.numberEditor.text;
    NSArray *allKeys = self.data.allKeys;
    NSString *key = [allKeys objectAtIndex:self.selected.section];
    NSArray *allNumbers = [self.data valueForKey:key];
    
    NSMutableArray *allNumbersMutable = [NSMutableArray array];
    if (!allNumbers || allNumbers.count == 0) {
        NSMutableDictionary *rowMutable = [NSMutableDictionary dictionary];
        [rowMutable setValue:cell.numberEditor.text forKey:@"number"];
        [rowMutable setValue:@"changed by user" forKey:@"description"];
        [allNumbersMutable addObject:rowMutable];
    } else {
        NSInteger index = 0;
        if (self.selected.row > 0 ) index = self.selected.row -1;
        
        
        NSDictionary *row = [allNumbers objectAtIndex:index];
        NSMutableDictionary *rowMutable = row.mutableCopy;
        [rowMutable setValue:cell.numberEditor.text forKey:@"number"];
        [rowMutable setValue:@"changed by user" forKey:@"description"];
        
        [allNumbersMutable addObjectsFromArray:allNumbers];
        if (index > 0) [allNumbersMutable replaceObjectAtIndex:index withObject:rowMutable];
        else [allNumbersMutable insertObject:rowMutable atIndex:0];
    }
    
    NSMutableDictionary *dataMutable = self.data.mutableCopy;
    [dataMutable setValue:allNumbersMutable forKey:key];
    self.data = dataMutable;
    
    cell.numberEditor.hidden = YES;
    cell.numberLabel.hidden = NO;
    [cell.numberEditor resignFirstResponder];
    cell.saveSegment.hidden = YES;
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
    
    NSMutableArray *allNumbersMutable = [NSMutableArray array];
    if (!allNumbers || allNumbers.count == 0) {
        NSMutableDictionary *rowMutable = [NSMutableDictionary dictionary];
        [rowMutable setValue:textField.text forKey:@"number"];
        [rowMutable setValue:@"changed by user" forKey:@"description"];
        [allNumbersMutable addObject:rowMutable];
    } else {
        NSDictionary *row = [allNumbers objectAtIndex:self.selected.row - 1];
        NSMutableDictionary *rowMutable = row.mutableCopy;
        [rowMutable setValue:textField.text forKey:@"number"];
        [rowMutable setValue:@"changed by user" forKey:@"description"];

        [allNumbersMutable addObjectsFromArray:allNumbers];
        [allNumbersMutable replaceObjectAtIndex:self.selected.row - 1 withObject:rowMutable];
    }
    
    NSMutableDictionary *dataMutable = self.data.mutableCopy;
    [dataMutable setValue:allNumbersMutable forKey:key];
    self.data = dataMutable;
    
    cell.numberEditor.hidden = YES;
    cell.numberLabel.hidden = NO;
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NumbersForTestCell *cell = (NumbersForTestCell *)[self.tableView cellForRowAtIndexPath:self.selected];

    NSLog(@"self.selected:%@ range:%@ string:%@ currentString:%@",self.selected,NSStringFromRange(range),string,textField.text);
    
    NSArray *allKeys = self.data.allKeys;
    NSString *key = [allKeys objectAtIndex:self.selected.section];
    
    NSArray *allCodesToCheck = [key componentsSeparatedByString:@","];
    
    NSMutableArray *allCodesForUsing = [NSMutableArray array];
    [allCodesToCheck enumerateObjectsUsingBlock:^(NSString *code, NSUInteger idx, BOOL *stop) {
        NSString *clearedCode = [code stringByReplacingOccurrencesOfString:@" " withString:@""];
        [allCodesForUsing addObject:clearedCode];
    }];
    
    NSString *finalString = nil;
    if (range.length == 0) {
        // this is added simbol
        finalString = [NSString stringWithFormat:@"%@%@",[textField.text substringWithRange:NSMakeRange(0, range.location)],string];

    } else {
        // this is removing symbos
        finalString = [NSString stringWithFormat:@"%@%@",[textField.text substringWithRange:NSMakeRange(0, range.location)],string];
        NSPredicate *filter = [NSPredicate predicateWithFormat:@"SELF beginswith %@ or SELF == %@",finalString,finalString];
        NSArray *filteredAllCodes = [allCodesForUsing filteredArrayUsingPredicate:filter];
        if (filteredAllCodes.count == 0) cell.saveSegment.enabled = NO;
        return YES;
    }
    
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"SELF beginswith %@ or SELF == %@",finalString,finalString];
    
    NSArray *filteredAllCodes = [allCodesForUsing filteredArrayUsingPredicate:filter];
    if (filteredAllCodes.count > 0) {
        NSPredicate *filter = [NSPredicate predicateWithFormat:@"SELF == %@",finalString];
        NSArray *filteredAllCodes = [allCodesForUsing filteredArrayUsingPredicate:filter];
        //NSLog(@">>>>>> filtered stage number %u cuttedNumber is:%@",i,cuttedFinalString);
        if (filteredAllCodes.count > 0) cell.saveSegment.enabled = YES;
        return  YES;
    } else {
        
        if (finalString.length > 1) {
            for (int i = 0; i < finalString.length; i++) {
                NSString *cuttedFinalString = [finalString substringWithRange:NSMakeRange(0, finalString.length - i)];
                NSPredicate *filter = [NSPredicate predicateWithFormat:@"SELF == %@",cuttedFinalString];
                NSArray *filteredAllCodes = [allCodesForUsing filteredArrayUsingPredicate:filter];
                //NSLog(@">>>>>> filtered stage number %u cuttedNumber is:%@",i,cuttedFinalString);
                if (filteredAllCodes.count > 0) {
                    cell.saveSegment.enabled = YES;

                    return YES;
                    
//                    NSDictionary *findedTariff = filteredTariffs.lastObject;
//                    pricePerSecond = [findedTariff valueForKey:@"price_per_second"];
//                    if (pricePerSecond) {
//                        //NSLog(@">>>>>> filtered stage number %u is FINAL with finded tariff:%@ for number:%@ ",i,pricePerSecond,cuttedNumber);
//                        break;
//                    }
                }
            }

        }
    }


    
    cell.saveSegment.enabled = NO;
    return NO;
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
    BOOL startGetPhoneNumbersForContrySpecificFinish = ([status rangeOfString:@"startGetPhoneNumbersForContrySpecific:finish"].location != NSNotFound);
    if (startGetPhoneNumbersForContrySpecificFinish) {
        //        sleep(3);
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self.activity stopAnimating];
            self.progress.hidden = YES;
            self.beginTestsButton.enabled = YES;

        });
    }
    
    BOOL startGetPhoneNumbersForContrySpecificProgress = ([status rangeOfString:@"startGetPhoneNumbersForContrySpecific:progress"].location != NSNotFound);
    if (startGetPhoneNumbersForContrySpecificProgress) {
        //        sleep(3);
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            NSNumber *progress = [data objectAtIndex:1];
            self.progress.hidden = NO;
            self.progress.progress = progress.floatValue;
        });
    }

}
@end
