//
//  AddNumbersViewController.h
//  tvr
//
//  Created by Oleksii Vynogradov on 5/3/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "OutPeersTableViewController.h"

@interface AddNumbersViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextView *numbers;
@property (weak, nonatomic) IBOutlet UIWebView *webSearchView;
@property (weak, nonatomic) IBOutlet UIButton *returnToRoutes;

@property (retain) NSString *countryName;
@property (retain) OutPeersTableViewController *routesTableViewController;
@property (retain) NSIndexPath *selectedIndexPath;

@end
