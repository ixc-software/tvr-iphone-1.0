//
//  NumbersForTestEditorMain.m
//  tvr
//
//  Created by Oleksii Vynogradov on 9/6/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import "NumbersForTestEditorMain.h"

@interface NumbersForTestEditorMain ()

@end

@implementation NumbersForTestEditorMain

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
