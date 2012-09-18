//
//  CarrierCell.m
//  vtr
//
//  Created by Oleksii Vynogradov on 4/23/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import "CarrierCell.h"
#import "AppDelegate.h"

@implementation CarrierCell
@synthesize name,responsibleFirstAndLastName,destinations,ipsEdited,prefixEdited,nameEdited,responsibleLabel;

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

- (void)setFrame:(CGRect)frame {
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (delegate.isPad) {
        frame.origin.x -= 10;
        frame.size.width += 2 * 10;
    }
    [super setFrame:frame];
}

@end
