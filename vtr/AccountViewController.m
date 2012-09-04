//
//  FirstViewController.m
//  vtr
//
//  Created by Oleksii Vynogradov on 4/22/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import "AccountViewController.h"
#import "ClientController.h"
#import "AppDelegate.h"

#import "CompanyStuff.h"
#import "CurrentCompany.h"


#import <QuartzCore/QuartzCore.h>

@interface AccountViewController ()
@property (readwrite) NSUInteger countTremorAnimation;
@property (readwrite) BOOL isJoinStarted;

@end

@implementation AccountViewController
@synthesize login;
@synthesize registration;
@synthesize errorMessage;
@synthesize emailLabel;
@synthesize passwordLabel;
@synthesize companyNameLabel;
@synthesize loginActivity;
@synthesize operation;
@synthesize operationProgress;
@synthesize backgroundButton;
@synthesize logout;
@synthesize loginButton;
@synthesize operationActivity;
@synthesize companyName;
@synthesize loginOrRegisterButton;
@synthesize countTremorAnimation;
@synthesize isJoinStarted;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
//    [login removeAllSegments];
//    [login insertSegmentWithTitle:@"Login" atIndex:0 animated:NO];
    //loginButton.titleLabel.text = @"Login";
    [loginButton addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
    loginOrRegisterButton.hidden = YES;
    loginButton.enabled = NO;
    operationActivity.alpha = 1.0;
    [operationActivity startAnimating];

//    [registration removeAllSegments];
//    [registration insertSegmentWithTitle:@"Registration" atIndex:0 animated:NO];
//    [registration addTarget:self action:@selector(registration:) forControlEvents:UIControlEventValueChanged];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[delegate.managedObjectContext persistentStoreCoordinator] withSender:self withMainMoc:delegate.managedObjectContext];
        [clientController firstSetup];
        CompanyStuff *admin = [clientController authorization];
        if (admin && admin.isCompanyAdmin.boolValue == YES && [clientController isCurrentUserAuthorized]) {
            dispatch_async(dispatch_get_main_queue(), ^(void) { 
                //[login removeAllSegments];
                //[login insertSegmentWithTitle:@"Logout" atIndex:0 animated:NO];
                //loginButton.titleLabel.text = @"Logout";
                [UIView beginAnimations:@"flipbutton" context:NULL];
                [UIView setAnimationDuration:0.4];
                [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:loginButton cache:YES];
                if (delegate.isPad) {
                    [loginButton setImage:[UIImage imageNamed:@"button_logout_upIPad.png"] forState:UIControlStateNormal];
                    [loginButton setImage:[UIImage imageNamed:@"button_logout_downIPad.png"] forState:UIControlStateSelected];
                } else {
                    [loginButton setImage:[UIImage imageNamed:@"button_logout_upIPhone.png"] forState:UIControlStateNormal];
                    [loginButton setImage:[UIImage imageNamed:@"button_logout_downIPhone.png"] forState:UIControlStateSelected];
                }
                [UIView commitAnimations];

                [loginButton removeTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
                [loginButton addTarget:self action:@selector(logout:) forControlEvents:UIControlEventTouchUpInside];
                
                emailLabel.userInteractionEnabled = NO;
                emailLabel.borderStyle = UITextBorderStyleNone;
                passwordLabel.userInteractionEnabled = NO;
                passwordLabel.borderStyle = UITextBorderStyleNone;
                
                companyNameLabel.userInteractionEnabled = NO;
                companyNameLabel.borderStyle = UITextBorderStyleNone;
                
                ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[delegate.managedObjectContext persistentStoreCoordinator] withSender:self withMainMoc:delegate.managedObjectContext];
                CompanyStuff *admin = [clientController authorization];

                emailLabel.text = admin.email;
                passwordLabel.text = admin.password;
                companyNameLabel.text = admin.currentCompany.name;
                loginButton.enabled = YES;
                operationActivity.alpha = 0.0;
                
                [operationActivity stopAnimating];

                //NSLog(@"email:%@ isCompanyAdmin:%@",admin.email,admin.isCompanyAdmin);
                
                
                /*
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
                    //[clientController getCarriersList];
                    if ([clientController isCurrentUserAuthorized]) {
                        dispatch_async(dispatch_get_main_queue(), ^(void) { 
                            
                            [login setEnabled:YES forSegmentAtIndex:0];
                            [registration setEnabled:YES forSegmentAtIndex:0];
                            loginActivity.hidden = YES;
                            [loginActivity stopAnimating];
                            [emailLabel resignFirstResponder];
                            [passwordLabel resignFirstResponder];
                            [companyNameLabel resignFirstResponder];
                            [clientController finalSave:clientController.moc];
                        });
                        
                    } else {
                        dispatch_async(dispatch_get_main_queue(), ^(void) { 
                            if (![clientController isCurrentUserAuthorized]) [self showErrorMessage:@"not authorized"];
                        });
                    }
                });*/
            });
            [clientController getCarriersList];

        } else {
            
//            if (![clientController isCurrentUserAuthorized]) { 
                dispatch_async(dispatch_get_main_queue(), ^(void) { 
                    loginOrRegisterButton.hidden = NO;
                    loginButton.enabled = YES;

                    //[self showErrorMessage:@"not authorized"];
                    if (delegate.isPad) {
                        [loginButton setImage:[UIImage imageNamed:@"button_login_upIPad.png"] forState:UIControlStateNormal];
                        [loginButton setImage:[UIImage imageNamed:@"button_login_downIPad.png"] forState:UIControlStateSelected];
                    } else {
                        [loginButton setImage:[UIImage imageNamed:@"button_login_upIPhone.png"] forState:UIControlStateNormal];
                        [loginButton setImage:[UIImage imageNamed:@"button_login_downIPhone.png"] forState:UIControlStateSelected];
                    }

                });
//            }
            
            
        }
//        [clientController getCarriersList];
    });

}

- (void)viewDidUnload
{
    [self setLogin:nil];
    [self setRegistration:nil];
    [self setErrorMessage:nil];
    [self setEmailLabel:nil];
    [self setPasswordLabel:nil];
    [self setCompanyNameLabel:nil];
    [self setLoginActivity:nil];
    [self setOperation:nil];
    [self setOperationProgress:nil];
    [self setBackgroundButton:nil];
    [self setLogout:nil];
    [self setLoginButton:nil];
    [self setOperationActivity:nil];
    [self setCompanyName:nil];
    [self setLoginOrRegisterButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}


#pragma mark -
#pragma mark Animation block
-(void) showErrorMessage:(NSString *)message
{
    [errorMessage removeAllSegments];
    [errorMessage insertSegmentWithTitle:message atIndex:0 animated:NO];
    
    [UIView animateWithDuration:2 
                          delay:0 
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         errorMessage.alpha = 1;
                         
                     }
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:2 
                                               delay:3 
                                             options:UIViewAnimationOptionBeginFromCurrentState
                                          animations:^{
                                              errorMessage.alpha = 0;
                                          }
                                          completion:nil];
                     }];
}

-(void) performEmailPasswordTremorIsMovingLeft:(BOOL)isMovingLeft isFirstStep:(BOOL)isFirstStep;
{
    if (isFirstStep) { 
        countTremorAnimation = 0;
    }
    [UIView animateWithDuration:0.05 
                          delay:0 
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         if (isMovingLeft) { 
                             [emailLabel.layer setFrame:CGRectMake(emailLabel.frame.origin.x + 5, emailLabel.frame.origin.y, emailLabel.frame.size.width, emailLabel.frame.size.height)]; 
                             [passwordLabel.layer setFrame:CGRectMake(passwordLabel.frame.origin.x + 5, passwordLabel.frame.origin.y, passwordLabel.frame.size.width, passwordLabel.frame.size.height)]; 
                             [companyNameLabel.layer setFrame:CGRectMake(companyNameLabel.frame.origin.x + 5, companyNameLabel.frame.origin.y, companyNameLabel.frame.size.width, companyNameLabel.frame.size.height)]; 
                             [backgroundButton.layer setFrame:CGRectMake(backgroundButton.frame.origin.x + 5, backgroundButton.frame.origin.y, backgroundButton.frame.size.width, backgroundButton.frame.size.height)]; 
                         } else { 
                             [emailLabel.layer setFrame:CGRectMake(emailLabel.frame.origin.x - 5, emailLabel.frame.origin.y, emailLabel.frame.size.width, emailLabel.frame.size.height)];
                             [passwordLabel.layer setFrame:CGRectMake(passwordLabel.frame.origin.x - 5, passwordLabel.frame.origin.y, passwordLabel.frame.size.width, passwordLabel.frame.size.height)];
                             [companyNameLabel.layer setFrame:CGRectMake(companyNameLabel.frame.origin.x - 5, companyNameLabel.frame.origin.y, companyNameLabel.frame.size.width, companyNameLabel.frame.size.height)];
                             [backgroundButton.layer setFrame:CGRectMake(backgroundButton.frame.origin.x - 5, backgroundButton.frame.origin.y, backgroundButton.frame.size.width, backgroundButton.frame.size.height)];
                         }
                     } 
                     completion:^(BOOL finished){
                         countTremorAnimation++;
                         if (countTremorAnimation < 6) [self performEmailPasswordTremorIsMovingLeft:!isMovingLeft isFirstStep:NO]; 
                     }];
    
}

-(BOOL)checkIfEmailAndPasswordFilledForLogin:(BOOL)isLogin
{
//    NSArray *emailParts = [emailLabel.text componentsSeparatedByString:@"@"];
//    NSArray *secondPartEmailParts = nil;
//    if ([emailParts count] > 1 ) {
//        NSString *secondPartOfEmail = [emailParts objectAtIndex:1];
//        if (secondPartOfEmail) secondPartEmailParts = [secondPartOfEmail componentsSeparatedByString:@"."];
//    }
    if (isLogin) {
        if ([emailLabel.text isEqualToString:@""] || [passwordLabel.text isEqualToString:@""]) [self performEmailPasswordTremorIsMovingLeft:NO isFirstStep:YES];  else return YES;
    } 
    
    if ([emailLabel.text isEqualToString:@""] || [passwordLabel.text isEqualToString:@""]) [self performEmailPasswordTremorIsMovingLeft:NO isFirstStep:YES];  else return YES;

//    else {
//        if (!companyNameLabel.text || [companyNameLabel.text isEqualToString:@""] || [emailLabel.text isEqualToString:@""] || [emailParts count] < 2 || [passwordLabel.text isEqualToString:@""] || !secondPartEmailParts || [secondPartEmailParts count] < 2 ) [self performEmailPasswordTremorIsMovingLeft:NO isFirstStep:YES];  else return YES;
//    }
    
    return NO;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [login setEnabled:YES forSegmentAtIndex:0];
        [registration setEnabled:YES forSegmentAtIndex:0];
        loginActivity.hidden = YES;
        [loginActivity stopAnimating];
        
    }
    if (buttonIndex == 1) {
        // user like to join to company
        isJoinStarted = YES;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
            AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[delegate.managedObjectContext persistentStoreCoordinator] withSender:self withMainMoc:delegate.managedObjectContext];
            CompanyStuff *admin = [clientController authorization];
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"CurrentCompany" inManagedObjectContext:clientController.moc];
            [fetchRequest setEntity:entity];
            NSError *error = nil;
            NSArray *fetchedObjects = [clientController.moc executeFetchRequest:fetchRequest error:&error];
            //            if ([fetchedObjects count] > 1) {
            //NSLog(@"UIActionSheet starterd");
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(name == %@) AND (companyAdminGUID != %@)",companyNameLabel.text,admin.GUID];
            NSArray *filtered = [fetchedObjects filteredArrayUsingPredicate:predicate];
            CurrentCompany *companyForJoin = [filtered lastObject];
            if (companyForJoin && [filtered count] == 1) {
                admin.currentCompany = companyForJoin;
                [clientController finalSave:clientController.moc];
                [clientController putObjectWithTimeoutWithIDs:[NSArray arrayWithObject:admin.objectID] mustBeApproved:YES];
            } else [self showErrorMessage:@"company for join don't finded"];
            
            
        });
        
        
    }
    if (buttonIndex == 2) {
        // user don't like to join to company, create company with same name
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
            AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[delegate.managedObjectContext persistentStoreCoordinator] withSender:self withMainMoc:delegate.managedObjectContext];
            CompanyStuff *admin = [clientController authorization];
            [clientController putObjectWithTimeoutWithIDs:[NSArray arrayWithObject:[admin.currentCompany objectID]] mustBeApproved:NO];
            [clientController putObjectWithTimeoutWithIDs:[NSArray arrayWithObject:[admin objectID]] mustBeApproved:NO];
            
        });
        
    }
    
}

-(void) finalizeAllViewsForSuccessLogin;
{
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;

    [UIView beginAnimations:@"flipbutton" context:NULL];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:loginButton cache:YES];
    
    if (delegate.isPad) {
        [loginButton setImage:[UIImage imageNamed:@"button_logout_upIPad.png"] forState:UIControlStateNormal];
        [loginButton setImage:[UIImage imageNamed:@"button_logout_downIPad.png"] forState:UIControlStateSelected];
    } else {
        [loginButton setImage:[UIImage imageNamed:@"button_logout_upIPhone.png"] forState:UIControlStateNormal];
        [loginButton setImage:[UIImage imageNamed:@"button_logout_downIPhone.png"] forState:UIControlStateSelected];
    }
    
    [UIView commitAnimations];
    loginActivity.alpha = 0.0;
    [loginActivity stopAnimating];
    
    [loginButton removeTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
    [loginButton addTarget:self action:@selector(logout:) forControlEvents:UIControlEventTouchUpInside];
    
    //                        [login removeAllSegments];
    //                        [login insertSegmentWithTitle:@"Logout" atIndex:0 animated:NO];
    //                        [login addTarget:self action:@selector(logout:) forControlEvents:UIControlEventValueChanged];
    
    emailLabel.userInteractionEnabled = NO;
    emailLabel.borderStyle = UITextBorderStyleNone;
    passwordLabel.userInteractionEnabled = NO;
    passwordLabel.borderStyle = UITextBorderStyleNone;
    
    companyNameLabel.userInteractionEnabled = NO;
    companyNameLabel.borderStyle = UITextBorderStyleNone;
    
    
    ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[delegate.managedObjectContext persistentStoreCoordinator] withSender:self withMainMoc:delegate.managedObjectContext];
    CompanyStuff *admin = [clientController authorization];
    
    emailLabel.text = admin.email;
    passwordLabel.text = admin.password;
    companyNameLabel.text = admin.currentCompany.name;
    
    [emailLabel resignFirstResponder];
    [passwordLabel resignFirstResponder];
    [companyNameLabel resignFirstResponder];
    admin.isCompanyAdmin = [NSNumber numberWithBool:YES];
    NSLog(@"isCompanyAdmin:1");
    [clientController finalSave:clientController.moc];
    loginOrRegisterButton.hidden = YES;

}


-(void)finalizeRegisterIssuesForLogin:(BOOL)isLogin;
{
    
//    [login setEnabled:NO forSegmentAtIndex:0];
//    [registration setEnabled:NO forSegmentAtIndex:0];
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;

    if (isLogin) {
        if (delegate.isPad) {
            [loginButton setImage:[UIImage imageNamed:@"button_upIPad.png"] forState:UIControlStateNormal];
            [loginButton setImage:[UIImage imageNamed:@"button_downIPad.png"] forState:UIControlStateSelected];
        } else {
            [loginButton setImage:[UIImage imageNamed:@"button_upIPhone.png"] forState:UIControlStateNormal];
            [loginButton setImage:[UIImage imageNamed:@"button_downIPhone.png"] forState:UIControlStateSelected];
        }
    } else {
        if (delegate.isPad) {
            [loginButton setImage:[UIImage imageNamed:@"button_register_upIPad.png"] forState:UIControlStateNormal];
            [loginButton setImage:[UIImage imageNamed:@"button_register_downIPad.png"] forState:UIControlStateSelected];
        } else {
            [loginButton setImage:[UIImage imageNamed:@"button_register_upIPhone.png"] forState:UIControlStateNormal];
            [loginButton setImage:[UIImage imageNamed:@"button_register_downIPhone.png"] forState:UIControlStateSelected];
        }

    }
    loginButton.enabled = NO;
    loginActivity.alpha = 1.0;

    [loginActivity startAnimating];
    [emailLabel resignFirstResponder];
    [passwordLabel resignFirstResponder];
    [companyNameLabel resignFirstResponder];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
        
        ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[delegate.managedObjectContext persistentStoreCoordinator] withSender:self withMainMoc:delegate.managedObjectContext];
        CompanyStuff *admin = [clientController authorization];
        
        //NSLog(@"ADMIN email:%@",admin.email);
        if (isLogin) {
            admin.email = emailLabel.text;
            admin.email = emailLabel.text;
            admin.password = passwordLabel.text;
            if (!companyName.text) admin.currentCompany.name = @"first company";
            
            [clientController finalSave:clientController.moc];
            //NSLog(@"ADMIN email:%@",admin.email);
            //[clientController getCarriersList];
            
            if ([clientController isCurrentUserAuthorized]) {
                dispatch_async(dispatch_get_main_queue(), ^(void) {
//                    //loginButton.titleLabel.text = @"Logout";
                    [self finalizeAllViewsForSuccessLogin];
                    
                });
                
                [clientController getCarriersList];
            } else {
                [self showErrorMessage:@"not authorized"];
            }
        } else {
            // registration
            admin.login = emailLabel.text;
            admin.email = emailLabel.text;
            admin.password = passwordLabel.text;
            if (!companyName.text) admin.currentCompany.name = @"first company";
            
            [clientController finalSave:clientController.moc];
            if ([clientController createOnServerNewUserAndCompany]) {
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    
                    UIAlertView* error = [[UIAlertView alloc]	initWithTitle:NSLocalizedString(@"Registration completed.",@"")
                                                                    message:NSLocalizedString(@"Congratulations. Now you are registered and can make tests.",@"")
                                                                   delegate:nil
                                                          cancelButtonTitle:NSLocalizedString(@"Continue",@"")
                                                          otherButtonTitles:nil];
                    [error show];
                });
                [self finalizeAllViewsForSuccessLogin];
            }
            
        }
        loginButton.enabled = YES;
        loginActivity.alpha = 0.0;
        [loginActivity stopAnimating];

        //        [login setEnabled:YES forSegmentAtIndex:0];
        //        [registration setEnabled:YES forSegmentAtIndex:0];
        
        
    });
    
}


- (IBAction)login:(id)sender {
    if ([self checkIfEmailAndPasswordFilledForLogin:YES]) {
        //do job here
        [emailLabel resignFirstResponder];
        [passwordLabel resignFirstResponder];
        [companyNameLabel resignFirstResponder];
        
        [self finalizeRegisterIssuesForLogin:YES];
    }
    
}

- (IBAction)registration:(id)sender {
    if ([self checkIfEmailAndPasswordFilledForLogin:NO]) {
        //do job here
        [emailLabel resignFirstResponder];
        [passwordLabel resignFirstResponder];
        [companyNameLabel resignFirstResponder];
        
        [self finalizeRegisterIssuesForLogin:NO];
    }
    
}

- (IBAction)logout:(id)sender {
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[delegate.managedObjectContext persistentStoreCoordinator] withSender:self withMainMoc:delegate.managedObjectContext];
    CompanyStuff *admin = [clientController authorization];
    CompanyStuff *adminMain = (CompanyStuff *)[delegate.managedObjectContext objectWithID:admin.objectID];
    
    adminMain.isCompanyAdmin = [NSNumber numberWithBool:NO];
    NSError *error = nil;
    
    [delegate.managedObjectContext save:&error];
    if (error) NSLog(@"error:%@",[error localizedDescription]);
    emailLabel.userInteractionEnabled = YES;
    emailLabel.borderStyle = UITextBorderStyleRoundedRect;
    passwordLabel.userInteractionEnabled = YES;
    passwordLabel.borderStyle = UITextBorderStyleRoundedRect;
    
    companyNameLabel.userInteractionEnabled = YES;
    companyNameLabel.borderStyle = UITextBorderStyleRoundedRect;
//    [login removeAllSegments];
//    [login insertSegmentWithTitle:@"Login" atIndex:0 animated:NO];
//    [login addTarget:self action:@selector(login:) forControlEvents:UIControlEventValueChanged];
    //loginButton.titleLabel.text = @"Login";
    [UIView beginAnimations:@"flipbutton" context:NULL];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:loginButton cache:YES];
    
    if (delegate.isPad) {
        [loginButton setImage:[UIImage imageNamed:@"button_login_upIPad.png"] forState:UIControlStateNormal];
        [loginButton setImage:[UIImage imageNamed:@"button_login_downIPad.png"] forState:UIControlStateSelected];
    } else {
        [loginButton setImage:[UIImage imageNamed:@"button_login_upIPhone.png"] forState:UIControlStateNormal];
        [loginButton setImage:[UIImage imageNamed:@"button_login_downIPhone.png"] forState:UIControlStateSelected];
    }

//    [loginButton setImage:[UIImage imageNamed:@"login-button-md.png"] forState:UIControlStateNormal];
//    
    [UIView commitAnimations];

    [loginButton removeTarget:self action:@selector(logout:) forControlEvents:UIControlEventTouchUpInside];
    [loginButton addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
    loginOrRegisterButton.hidden = NO;
     
    CompanyStuff *adminMainNew = (CompanyStuff *)[delegate.managedObjectContext objectWithID:admin.objectID];
    NSLog(@"email:%@ isCompanyAdmin:%@",adminMainNew.email,adminMainNew.isCompanyAdmin);

}

- (IBAction)changeLoginOrRegister:(id)sender {
    if ([sender selectedSegmentIndex] == 0) {
        //login
        [loginButton removeTarget:self action:@selector(registration:) forControlEvents:UIControlEventTouchUpInside];
        [loginButton addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
        
        
        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;

        if (delegate.isPad) {
            [loginButton setImage:[UIImage imageNamed:@"button_login_upIPad.png"] forState:UIControlStateNormal];
            [loginButton setImage:[UIImage imageNamed:@"button_login_downIPad.png"] forState:UIControlStateSelected];
        } else {
            [loginButton setImage:[UIImage imageNamed:@"button_login_upIPhone.png"] forState:UIControlStateNormal];
            [loginButton setImage:[UIImage imageNamed:@"button_login_downIPhone.png"] forState:UIControlStateSelected];
        }

//        [UIView animateWithDuration:1 
//                              delay:0 
//                            options:UIViewAnimationOptionBeginFromCurrentState
//                         animations:^{
//                             
//                             self.loginButton.frame = CGRectMake(115, 200, loginButton.frame.size.width, loginButton.frame.size.height);
//                             self.loginActivity.frame = CGRectMake(126, 203, loginActivity.frame.size.width, loginActivity.frame.size.height);
//                             self.companyName.alpha = 0.0;
//
//                         } completion:nil];
        
        
    } else {
        //register
        [loginButton removeTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
        [loginButton addTarget:self action:@selector(registration:) forControlEvents:UIControlEventTouchUpInside];

        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        if (delegate.isPad) {
            [loginButton setImage:[UIImage imageNamed:@"button_registerStart_upIPad.png"] forState:UIControlStateNormal];
            [loginButton setImage:[UIImage imageNamed:@"button_registerStart_downIPad.png"] forState:UIControlStateSelected];
        } else {
            [loginButton setImage:[UIImage imageNamed:@"button_registerStart_upIPhone.png"] forState:UIControlStateNormal];
            [loginButton setImage:[UIImage imageNamed:@"button_registerStart_downIPhone.png"] forState:UIControlStateSelected];
        }

//        [UIView animateWithDuration:1 
//                              delay:0 
//                            options:UIViewAnimationOptionBeginFromCurrentState
//                         animations:^{
//                             
//                             self.loginButton.frame = CGRectMake(194, 200, loginButton.frame.size.width, loginButton.frame.size.height);
//                             self.loginActivity.frame = CGRectMake(203, 203, loginActivity.frame.size.width, loginActivity.frame.size.height);
//                             self.companyName.alpha = 1.0;
//
//                         } completion:nil];
        
    }
    NSLog(@"changeLoginOrRegister");

}

- (IBAction)finishEditing:(id)sender {
    NSLog(@"finishEditing");

    [sender resignFirstResponder];
}


#pragma mark - 
- (void)textFieldDidEndEditing:(UITextField *)textField;             // may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called
{
    [textField resignFirstResponder];
    NSLog(@"textFieldDidEndEditing");

}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
    
}
#pragma mark - external reload methods

-(void)updateUIWithData:(NSArray *)data;
{
    //sleep(5);
    //NSLog(@"AUTHORIZATION: data:%@",data);
    NSString *status = [data objectAtIndex:0];
    //NSNumber *progress = [data objectAtIndex:1];
    NSNumber *isItLatestMessage = [data objectAtIndex:2];
    NSManagedObjectID *objectID = nil;
    NSNumber *isError = [data objectAtIndex:3];
    if ([isError boolValue]) {             
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self showErrorMessage:status];
//            [login setEnabled:YES forSegmentAtIndex:0];
//            [registration setEnabled:YES forSegmentAtIndex:0];
            operationActivity.hidden = YES;
            [operationActivity stopAnimating];
            
            [self showErrorMessage:status];
        });
        return;
    }
//    BOOL isAuthPassed = ([status rangeOfString:@"auth passed"].location != NSNotFound);
//    if (isAuthPassed) {
//        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//        ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[delegate.managedObjectContext persistentStoreCoordinator] withSender:self withMainMoc:delegate.managedObjectContext];
//        CompanyStuff *admin = [clientController authorization];
//
//        admin.isCompanyAdmin = [NSNumber numberWithBool:YES];
//        [clientController finalSave:clientController.moc];
//
//        dispatch_async(dispatch_get_main_queue(), ^(void) {
//            emailLabel.userInteractionEnabled = NO;
//            emailLabel.borderStyle = UITextBorderStyleNone;
//            passwordLabel.userInteractionEnabled = NO;
//            passwordLabel.borderStyle = UITextBorderStyleNone;
//            
//            companyNameLabel.userInteractionEnabled = NO;
//            companyNameLabel.borderStyle = UITextBorderStyleNone;
//            [login removeAllSegments];
//            [login insertSegmentWithTitle:@"Logout" atIndex:0 animated:NO];
//            [login addTarget:self action:@selector(logout:) forControlEvents:UIControlEventValueChanged];
//
//        });
//    }

    
    BOOL isStatusUpdateGraph = ([status rangeOfString:@"progress for update graph:"].location != NSNotFound);
    if (isStatusUpdateGraph) {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            NSNumber *progress = [data objectAtIndex:1];
            operation.alpha = 1.0;
            operationProgress.alpha = 1.0;
            
            operation.text = @"update...";
            operationProgress.progress = progress.floatValue;
            
        });
    }
    
    BOOL isProgressWeBuy = ([status rangeOfString:@"progress for destinations we buy"].location != NSNotFound);
    if (isProgressWeBuy) {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            NSNumber *progress = [data objectAtIndex:1];
            operation.text = @"destinations we buy updating...";
            operationProgress.progress = progress.floatValue;
            operation.alpha = 1.0;
            operationProgress.alpha = 1.0;
            
        });
    }
    BOOL isProgressForSale = ([status rangeOfString:@"progress for destinations for sale"].location != NSNotFound);
    if (isProgressForSale) {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            NSNumber *progress = [data objectAtIndex:1];
            operation.text = @"destinations for sale updating...";
            operationProgress.progress = progress.floatValue;
            operation.alpha = 1.0;
            operationProgress.alpha = 1.0;
            
        });
    }
    
    BOOL isDownloadingStarting = ([status rangeOfString:@"server download is started"].location != NSNotFound);
    if (isDownloadingStarting) {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            NSNumber *progress = [data objectAtIndex:1];
            operation.text = @"downloading...";
            operationProgress.progress = progress.floatValue;
            operation.alpha = 1.0;
            operationProgress.alpha = 1.0;
            
        });
    }
    
    BOOL isDownloadingProgress = ([status rangeOfString:@"server download progress"].location != NSNotFound);
    if (isDownloadingProgress) {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            NSNumber *progress = [data objectAtIndex:1];
            operation.text = @"downloading...";
            operationProgress.progress = progress.floatValue;
            operation.alpha = 1.0;
            operationProgress.alpha = 1.0;
            
        });
    }

    
    BOOL isStatusUpdateCodes = ([status rangeOfString:@"Update codes internal data"].location != NSNotFound);
    if (isStatusUpdateCodes) {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            NSNumber *progress = [data objectAtIndex:1];
            operation.alpha = 1.0;
            operationProgress.alpha = 1.0;
            
            operation.text = @"Update codes.";
            operationProgress.progress = progress.floatValue;
            
        });
    }
    
    BOOL isStatusParseCodes = ([status rangeOfString:@"Parse codes list.."].location != NSNotFound);
    if (isStatusParseCodes) {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            NSNumber *progress = [data objectAtIndex:1];
            operation.alpha = 1.0;
            operationProgress.alpha = 1.0;
            
            operation.text = @"Parse codes list..";
            operationProgress.progress = progress.floatValue;
            
        });
    }

    BOOL isStatusFirstSetupCompleted = ([status rangeOfString:@"first setup completed"].location != NSNotFound);
    if (isStatusFirstSetupCompleted) {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            loginButton.enabled = YES;
            operation.alpha = 0.0;
            operationProgress.alpha = 0.0;

        });
    }

    
    if ([status isEqualToString:@"Login success"]) {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            
//            [UIView animateWithDuration:3 
//                                  delay:4 
//                                options:UIViewAnimationOptionBeginFromCurrentState
//                             animations:^{
//                                 
//                                 self.view.alpha = 0.0;
//                             } completion:nil];
        });
        
    }
    if ([data count] > 4) objectID = [data objectAtIndex:4];
    if (![isItLatestMessage boolValue])
    {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            //operationActivity.alpha = 1.0;
            //[operationActivity startAnimating];
            //operation.alpha = 1.0;
            //operationProgress.alpha = 1.0;

            //loginActivity.hidden = NO;
            //[loginActivity startAnimating];
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            operation.alpha = 0.0;
            operationProgress.alpha = 0.0;

            
            operationActivity.alpha = 0.0;
            [operationActivity stopAnimating];
        });
        if ([status isEqualToString:@"put object finish"] && ![isError boolValue] && isJoinStarted) { 
            [self showErrorMessage:@"you request was sent to admin"];
            
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                
//                [UIView animateWithDuration:3 
//                                      delay:4 
//                                    options:UIViewAnimationOptionBeginFromCurrentState
//                                 animations:^{
//                                     
//                                     self.view.alpha = 0.0;
//                                 } completion:nil];
            });
            
        } else {
            if (![isError boolValue] ) {
                if (objectID) {
//                    mobileAppDelegate *delegate = (mobileAppDelegate *)[UIApplication sharedApplication].delegate;
//                    NSManagedObject *finalObject = [delegate.managedObjectContext objectWithID:objectID];
//                    if ([finalObject.entity.name isEqualToString:@"CompanyStuff"]) {
//                        
//                        
//                    }
                    
                }
                dispatch_async(dispatch_get_main_queue(), ^(void) {
//                    mobileAppDelegate *delegate = (mobileAppDelegate *)[UIApplication sharedApplication].delegate;
//                    NSArray *viewControllers = delegate.tabBarController.viewControllers;
//                    UINavigationController *info = [viewControllers objectAtIndex:0];
//                    InfoViewController *infoObject = [info.viewControllers objectAtIndex:0];
//                    [infoObject updateMainBoard];
//                    
//                    [infoObject.view setNeedsDisplay];
//                    
//                    [UIView animateWithDuration:3 
//                                          delay:0 
//                                        options:UIViewAnimationOptionBeginFromCurrentState
//                                     animations:^{
//                                         
//                                         self.view.alpha = 0.0;
//                                     } completion:^(BOOL finished) {
//                                         
//                                     }];
                });
                
            }
        }
        
    }
}


@end