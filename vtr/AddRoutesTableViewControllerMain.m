//
//  AddRoutesTableViewControllerMain.m
//  tvr
//
//  Created by Oleksii Vynogradov on 7/2/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import "AddRoutesTableViewControllerMain.h"
#import "AppDelegate.h"
#import "OutPeersTableViewController.h"

@interface AddRoutesTableViewControllerMain ()

@end

@implementation AddRoutesTableViewControllerMain

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
    
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
