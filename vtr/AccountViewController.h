//
//  FirstViewController.h
//  vtr
//
//  Created by Oleksii Vynogradov on 4/22/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RRVerificationController.h"

@interface AccountViewController : UIViewController  <UITextFieldDelegate,UIActionSheetDelegate,RRVerificationControllerDelegate,SKPaymentTransactionObserver>
@property (weak, nonatomic) IBOutlet UISegmentedControl *login;
@property (weak, nonatomic) IBOutlet UISegmentedControl *registration;
@property (weak, nonatomic) IBOutlet UISegmentedControl *errorMessage;
@property (weak, nonatomic) IBOutlet UITextField *emailLabel;
@property (weak, nonatomic) IBOutlet UITextField *passwordLabel;
@property (weak, nonatomic) IBOutlet UITextField *companyNameLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loginActivity;
@property (weak, nonatomic) IBOutlet UILabel *operation;
@property (weak, nonatomic) IBOutlet UIProgressView *operationProgress;
@property (weak, nonatomic) IBOutlet UIButton *backgroundButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *logout;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *operationActivity;
@property (weak, nonatomic) IBOutlet UITextField *companyName;
@property (weak, nonatomic) IBOutlet UISegmentedControl *loginOrRegisterButton;
@property (retain) NSString *operationForBuy;
@end
