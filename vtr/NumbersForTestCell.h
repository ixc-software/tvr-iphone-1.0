//
//  NumbersForTestCell.h
//  tvr
//
//  Created by Oleksii Vynogradov on 9/6/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NumbersForTestCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UITextField *numberEditor;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@end
