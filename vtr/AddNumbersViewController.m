//
//  AddNumbersViewController.m
//  tvr
//
//  Created by Oleksii Vynogradov on 5/3/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import "AddNumbersViewController.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>

@interface AddNumbersViewController ()

@end

@implementation AddNumbersViewController
@synthesize numbers;
@synthesize webSearchView;
@synthesize returnToRoutes;
@synthesize countryName,selectedIndexPath;
@synthesize routesTableViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    //NSManagedObject *finalObject = [delegate.managedObjectContext objectWithID:selectedDestinationID];
    
    NSString *country = countryName;//[finalObject valueForKey:@"country"];
    
    
    NSString *finalSearchURL = [NSString stringWithFormat:@"http://www.google.com/search?client=safari&rls=en&q=phone+number+hotel+in+%@&ie=UTF-8&oe=UTF-8",[country stringByReplacingOccurrencesOfString:@" " withString:@"+"]];
    
    [self.webSearchView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:finalSearchURL]]];
    numbers.layer.cornerRadius = 5;
    numbers.layer.borderWidth = 2;
    numbers.layer.borderColor = [UIColor blackColor].CGColor;
    
    webSearchView.layer.cornerRadius = 5;
    webSearchView.layer.borderWidth = 2;
    webSearchView.layer.borderColor = [UIColor blackColor].CGColor;
    
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self setNumbers:nil];
    [self setWebSearchView:nil];
    [self setReturnToRoutes:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (IBAction)returnBack:(id)sender {
    NSString *numbersToParse = self.numbers.text;
    
    NSArray *allNumbers = [numbersToParse componentsSeparatedByString:@"\n"];
    self.routesTableViewController.numbers = allNumbers;
    //[self.routesTableViewController destinationChooseForIndexPath:selectedIndexPath];
    [self.routesTableViewController testStartForDestinations:routesTableViewController.destinationsForTest forOutPeerID:routesTableViewController.outpeerIDForTest];

    [self dismissModalViewControllerAnimated:YES];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
    
}
- (IBAction)cancelTesting:(id)sender {
    [self dismissModalViewControllerAnimated:YES];

}


#pragma mark - UISearchBarDelegate
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBarLocal
{
    [searchBarLocal resignFirstResponder];
}
@end
