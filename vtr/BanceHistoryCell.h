//
//  BanceHistoryCell.h
//  tvr
//
//  Created by Oleksii Vynogradov on 1/4/13.
//  Copyright (c) 2013 IXC-USA Corp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BanceHistoryCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *date;
@property ( nonatomic) IBOutlet UIImageView *paidImage;
@property (weak, nonatomic) IBOutlet UILabel *operationLabel;
@property (weak, nonatomic) IBOutlet UILabel *paymentAmount;


@end
