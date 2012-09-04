//
//  CarrierCell.h
//  vtr
//
//  Created by Oleksii Vynogradov on 4/23/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CarrierCell : UITableViewCell

@property ( nonatomic) IBOutlet UILabel *name;
@property ( nonatomic) IBOutlet UILabel *responsibleFirstAndLastName;
@property ( nonatomic) IBOutlet UILabel *destinations;

@property ( nonatomic) IBOutlet UILabel *responsibleLabel;

@property ( nonatomic) IBOutlet UITextField *nameEdited;
@property ( nonatomic) IBOutlet UITextField *ipsEdited;
@property ( nonatomic) IBOutlet UITextField *prefixEdited;

@end
