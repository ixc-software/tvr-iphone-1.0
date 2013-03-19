//
//  RoutesCell.m
//  vtr
//
//  Created by Oleksii Vynogradov on 4/23/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import "RoutesCell.h"
#import "OutPeersTableViewController.h"

@implementation RoutesCell
@synthesize outPeerName,latestTestingResults,carrier,prefix,ipsEdited,prefixEdited,nameEdited;
@synthesize indexPath,delegate,activity,testButton,ips;
@synthesize testButtonLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(IBAction)test:(id)sender
{
    if (delegate && [delegate respondsToSelector:@selector(destinationChooseForIndexPath:)]) {
        //NSLog(@">>>>>>>>> tests started");
        if (delegate.tableView.isEditing) return;
        [delegate destinationChooseForIndexPath:self.indexPath];
        activity.alpha = 1.0;
        [activity startAnimating];
        testButton.enabled = NO;
        [self.testButton setImage:[UIImage imageNamed:@"test-button-pressed.png"] forState:UIControlStateNormal];
        //NSLog(@">>>>>>>>> tests started2");
    }
}

@end
