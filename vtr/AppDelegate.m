//
//  AppDelegate.m
//  vtr
//
//  Created by Oleksii Vynogradov on 4/22/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import "AppDelegate.h"
#import "ClientController.h"

#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

#import <AVFoundation/AVAudioSession.h>
#import <CommonCrypto/CommonDigest.h>
#import <AddressBook/AddressBook.h>
#import <AudioToolbox/AudioToolbox.h>


@implementation AppDelegate
@synthesize tapBarController;

@synthesize window = _window;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;
@synthesize routesViewController = _routesViewController;
@synthesize deviceToken = _deviceToken;
@synthesize firstServer,secondServer,urlChoosed,allURLs,appleID;
@synthesize isMessageConfirmed,messageFull;

@synthesize downloadCompleted,receivedData;


- (NSString *)getMacAddress
{
    int                 mgmtInfoBase[6];
    char                *msgBuffer = NULL;
    size_t              length;
    unsigned char       macAddress[6];
    struct if_msghdr    *interfaceMsgStruct;
    struct sockaddr_dl  *socketStruct;
    NSString            *errorFlag = NULL;
    
    // Setup the management Information Base (mib)
    mgmtInfoBase[0] = CTL_NET;        // Request network subsystem
    mgmtInfoBase[1] = AF_ROUTE;       // Routing table info
    mgmtInfoBase[2] = 0;              
    mgmtInfoBase[3] = AF_LINK;        // Request link layer information
    mgmtInfoBase[4] = NET_RT_IFLIST;  // Request all configured interfaces
    
    // With all configured interfaces requested, get handle index
    if ((mgmtInfoBase[5] = if_nametoindex("en0")) == 0) 
        errorFlag = @"if_nametoindex failure";
    else
    {
        // Get the size of the data available (store in len)
        if (sysctl(mgmtInfoBase, 6, NULL, &length, NULL, 0) < 0) 
            errorFlag = @"sysctl mgmtInfoBase failure";
        else
        {
            // Alloc memory based on above call
            if ((msgBuffer = malloc(length)) == NULL)
                errorFlag = @"buffer allocation failure";
            else
            {
                // Get system information, store in buffer
                if (sysctl(mgmtInfoBase, 6, msgBuffer, &length, NULL, 0) < 0)
                    errorFlag = @"sysctl msgBuffer failure";
            }
        }
    }
    
    // Befor going any further...
    if (errorFlag != NULL)
    {
        NSLog(@"Error: %@", errorFlag);
        return errorFlag;
    }
    
    // Map msgbuffer to interface message structure
    interfaceMsgStruct = (struct if_msghdr *) msgBuffer;
    
    // Map to link-level socket structure
    socketStruct = (struct sockaddr_dl *) (interfaceMsgStruct + 1);
    
    // Copy link layer address data in socket structure to an array
    memcpy(&macAddress, socketStruct->sdl_data + socketStruct->sdl_nlen, 6);
    
    // Read from char array into a string object, into traditional Mac address format
    NSString *macAddressString = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X", 
                                  macAddress[0], macAddress[1], macAddress[2], 
                                  macAddress[3], macAddress[4], macAddress[5]];
    NSLog(@"Mac Address: %@", macAddressString);
    
    // Release the buffer memory
    free(msgBuffer);
    
    return macAddressString;
}


-(NSString*)md5HexDigest:(NSString*)input {
    const char* str = [input UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, strlen(str), result);
    
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];
    for(int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x",result[i]];
    }
    return ret;
}


-(NSString *) hashForEmail:(NSString *)email withDateString:(NSString *)dateString;
{
    if (email && dateString) {
        //ab47fde53b2a335e107f5986d7bed0bfd4c8bc44
        NSString *fixedString = [NSString stringWithFormat:@"%c%s%c%@", 'a', "b47fde53b2a335", 'e', @"107f5986d7bed0bfd4c8bc44"];
        
        NSString *lastDigit = [dateString substringWithRange:NSMakeRange(dateString.length - 1, 1)];
        NSNumberFormatter *number = [[NSNumberFormatter alloc] init];
        NSNumber *lastDigitFromDate = [number numberFromString:lastDigit];
        
        NSString *forAuthtorization = nil;
        
        if (lastDigitFromDate.integerValue == 0) {
            // zero
            forAuthtorization = [NSString stringWithFormat:@"%@%@%@",email,fixedString,dateString];
            
        } if  (lastDigitFromDate.integerValue % 2) {
            //odd
            forAuthtorization = [NSString stringWithFormat:@"%@%@%@",email,dateString,fixedString];
        } else {
            //even
            forAuthtorization = [NSString stringWithFormat:@"%@%@%@",dateString,email,fixedString];
        }
        NSString *hashForReturn = [self md5HexDigest:forAuthtorization];
        //NSLog(@"AUTHORIZATION:for auth:%@ hash:%@",forAuthtorization,hashForReturn);
        
        return hashForReturn;
    }  
    return nil;
}

static unsigned char base64EncodeLookup[65] =
"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";


-(NSString *) encodeTobase64InputData:(NSData *)data
{
    
    const void *buffer = [data bytes];
    size_t length = [data length];
    bool separateLines = true;
    //    size_t outputLength = 0;
    
    const unsigned char *inputBuffer = (const unsigned char *)buffer;
    
#define BINARY_UNIT_SIZE 3
#define BASE64_UNIT_SIZE 4
    
#define MAX_NUM_PADDING_CHARS 2
#define OUTPUT_LINE_LENGTH 64
#define INPUT_LINE_LENGTH ((OUTPUT_LINE_LENGTH / BASE64_UNIT_SIZE) * BINARY_UNIT_SIZE)
#define CR_LF_SIZE 2
    
    //
    // Byte accurate calculation of final buffer size
    //
    size_t outputBufferSize =
    ((length / BINARY_UNIT_SIZE)
     + ((length % BINARY_UNIT_SIZE) ? 1 : 0))
    * BASE64_UNIT_SIZE;
    if (separateLines)
    {
        outputBufferSize +=
        (outputBufferSize / OUTPUT_LINE_LENGTH) * CR_LF_SIZE;
    }
    
    //
    // Include space for a terminating zero
    //
    outputBufferSize += 1;
    
    //
    // Allocate the output buffer
    //
    char *outputBuffer = (char *)malloc(outputBufferSize);
    if (!outputBuffer)
    {
        return NULL;
    }
    
    size_t i = 0;
    size_t j = 0;
    const size_t lineLength = separateLines ? INPUT_LINE_LENGTH : length;
    size_t lineEnd = lineLength;
    
    while (true)
    {
        if (lineEnd > length)
        {
            lineEnd = length;
        }
        
        for (; i + BINARY_UNIT_SIZE - 1 < lineEnd; i += BINARY_UNIT_SIZE)
        {
            //
            // Inner loop: turn 48 bytes into 64 base64 characters
            //
            outputBuffer[j++] = base64EncodeLookup[(inputBuffer[i] & 0xFC) >> 2];
            outputBuffer[j++] = base64EncodeLookup[((inputBuffer[i] & 0x03) << 4)
                                                   | ((inputBuffer[i + 1] & 0xF0) >> 4)];
            outputBuffer[j++] = base64EncodeLookup[((inputBuffer[i + 1] & 0x0F) << 2)
                                                   | ((inputBuffer[i + 2] & 0xC0) >> 6)];
            outputBuffer[j++] = base64EncodeLookup[inputBuffer[i + 2] & 0x3F];
        }
        
        if (lineEnd == length)
        {
            break;
        }
        
        //
        // Add the newline
        //
        outputBuffer[j++] = '\r';
        outputBuffer[j++] = '\n';
        lineEnd += lineLength;
    }
    
    if (i + 1 < length)
    {
        //
        // Handle the single '=' case
        //
        outputBuffer[j++] = base64EncodeLookup[(inputBuffer[i] & 0xFC) >> 2];
        outputBuffer[j++] = base64EncodeLookup[((inputBuffer[i] & 0x03) << 4)
                                               | ((inputBuffer[i + 1] & 0xF0) >> 4)];
        outputBuffer[j++] = base64EncodeLookup[(inputBuffer[i + 1] & 0x0F) << 2];
        outputBuffer[j++] =	'=';
    }
    else if (i < length)
    {
        //
        // Handle the double '=' case
        //
        outputBuffer[j++] = base64EncodeLookup[(inputBuffer[i] & 0xFC) >> 2];
        outputBuffer[j++] = base64EncodeLookup[(inputBuffer[i] & 0x03) << 4];
        outputBuffer[j++] = '=';
        outputBuffer[j++] = '=';
    }
    outputBuffer[j] = 0;
    
    //
    // Set the output length and return the buffer
    //
    //    if (outputLength)
    //    {
    //        outputLength = j;
    //    }
    
    //    return outputBuffer;
    
	NSString *result = [[NSString alloc] initWithBytes:outputBuffer length:j encoding:NSASCIIStringEncoding];
    
    return result;
}

#pragma mark - NSURLConnection delegate
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    
    downloadCompleted = YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    //NSLog(@">>>>>>didReceiveData");
    // Append the new data to receivedData.
    if (receivedData) [receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    //NSLog(@">>>>>>>>>>didReceiveResponse");
    if (receivedData) [receivedData setLength:0];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    //NSLog(@"Succeeded! Received %@ bytes of data",[NSNumber numberWithUnsignedInteger:[receivedData length]]);
    downloadCompleted = YES;
}
- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    //NSLog(@">>>>>>canAuthenticateAgainstProtectionSpace");
    
    return YES;
}


- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    //NSLog(@">>>>>>didReceiveAuthenticationChallenge");
    
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
    {
        
        SecTrustRef trustRef = [[challenge protectionSpace] serverTrust];
        SecTrustEvaluate(trustRef, NULL);
        CFIndex count = SecTrustGetCertificateCount(trustRef); 
        BOOL trust = NO;
        if(count > 0){
            SecCertificateRef certRef = SecTrustGetCertificateAtIndex(trustRef, 0);
            CFStringRef certSummary = SecCertificateCopySubjectSummary(certRef);
            //NSString* certSummaryNs = (__bridge NSString*)certSummary;
            //NSLog(@"cert name:%@",certSummaryNs);
            
            NSData *data = (__bridge_transfer NSData *) SecCertificateCopyData(certRef);
            // .. we have a certificate in DER format!
            //NSLog(@"received:%@",data);
            
            NSURL *indexURL = [[NSBundle mainBundle] URLForResource:@"webcob" withExtension:@"p12"];
            
            NSData *localP12 = [NSData dataWithContentsOfURL:indexURL];
            
            NSMutableDictionary * options = [[NSMutableDictionary alloc] init];
            
            // Set the public key query dictionary
            //change to your .pfx  password here 
            NSString *password = [NSString stringWithFormat:@"%c%s%c%@", 'M', "anua", 'l', @"12"];
            
            
            [options setObject:password forKey:(__bridge id)kSecImportExportPassphrase];
            
            CFArrayRef items = CFArrayCreate(NULL, 0, 0, NULL);
            
            OSStatus securityError = SecPKCS12Import((__bridge CFDataRef) localP12,
                                                     (__bridge CFDictionaryRef)options, &items);
            
            if (securityError == noErr) {
                // good  
            } else {
                //bad
            }
            
            CFDictionaryRef identityDict = CFArrayGetValueAtIndex(items, 0);
            CFArrayRef certificates =
            (CFArrayRef)CFDictionaryGetValue(identityDict,
                                             kSecImportItemCertChain);
            
            SecCertificateRef localCert = (SecCertificateRef)CFArrayGetValueAtIndex(certificates,0);
            CFDataRef dataLocal = SecCertificateCopyData(localCert);
            
            NSData *local = (__bridge NSData *)dataLocal;
            
            //NSLog(@"local:%@",local);
            
            if ([data isEqualToData:local]) trust = YES;
            //else NSLog(@"wrong");    
            
            //            if([certSummaryNs isEqualToString:@"webcob.net"]){ // split host n
            //                trust = YES;
            //            }else{
            //                NSLog(@"Certificate name does not have required common name");
            //            }
            CFRelease(certSummary);
        }
        if(trust){
            [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
        }else{
            [challenge.sender cancelAuthenticationChallenge:challenge];
        }        
    } else {
        
    }
    //    NSString *user = [NSString stringWithFormat:@"%c%s%@", 'a', "le", @"x"];
    //    NSString *password = [NSString stringWithFormat:@"%c%s%c%@", 'A', "87AE19C-FEBB", '-', @"4C4C-A534-3CD036ED072A"];
    //    
    //    NSURLCredential *credential = [NSURLCredential credentialWithUser:user
    //                                                             password:password
    //                                                          persistence:NSURLCredentialPersistenceForSession];
    //    [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
}


-(NSDictionary *) getJSONAnswerForFunction:(NSString *)function withJSONRequest:(NSMutableDictionary *)request forServer:(NSString *)server;
{
    downloadCompleted = NO;
    if (!receivedData) receivedData = [[NSMutableData alloc] init]; 
    else [receivedData setLength:0];
    
    dispatch_async(dispatch_get_main_queue(), ^(void) { 
        
        NSError *error = nil;
        
        NSData* bodyData = [NSJSONSerialization dataWithJSONObject:request 
                                                           options:NSJSONWritingPrettyPrinted error:&error];
        if (error) NSLog(@"CLIENT CONTROLLER: json decoding error:%@ in function:%@",[error localizedDescription],function);
        
        NSData *dataForBody = [[NSData alloc] initWithData:bodyData];
        NSString *functionString = [NSString stringWithFormat:@"/%@",function];
        
        NSURL *urlForRequest = [NSURL URLWithString:functionString relativeToURL:[NSURL URLWithString:server]];
        
        NSMutableURLRequest *requestToServer = [NSMutableURLRequest requestWithURL:urlForRequest cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5.0];
        [requestToServer setHTTPMethod:@"POST"];
        [requestToServer setHTTPBody:dataForBody];
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:requestToServer delegate:self startImmediately:YES];
        if (!connection) NSLog(@"failedToCreate");
        
    });
    NSUInteger countAttempts = 0;
    
    while (!downloadCompleted) { 
        
        countAttempts++;
        if (countAttempts > 10) { 
            
            return nil;
        }
        else sleep(1);
        //NSLog(@"waiting for completed"); 
    }
    NSData *receivedResult = [[NSData alloc] initWithData:receivedData];
    NSError *error = nil;
    
    NSDictionary *finalResult = [NSJSONSerialization
                                 JSONObjectWithData:receivedResult
                                 options:NSJSONReadingMutableLeaves
                                 error:&error];
    
    if (error) NSLog(@"failed to decode answer with error:%@",[error localizedDescription]);
    return finalResult;
    
}

-(NSArray *)allContacts;
{
    NSDate *allContactsModificationDate = [[NSUserDefaults standardUserDefaults] valueForKey:@"allContactsModificationDate"];
    
    NSArray *allContactsLocal = [[NSUserDefaults standardUserDefaults] valueForKey:@"allContacts"];
    NSMutableArray *allContacts = [NSMutableArray arrayWithArray:allContactsLocal];
    
    if (allContactsModificationDate == nil || -[allContactsModificationDate timeIntervalSinceNow] > 6 ) {
        if (allContacts.count > 0) [allContacts removeAllObjects];
        ABAddressBookRef ab = ABAddressBookCreate();
        
        if (ab) {
            
            NSArray *arrTemp=(__bridge NSArray *)ABAddressBookCopyArrayOfAllPeople(ab);
            
            for (int i=0;i < [arrTemp count];i++) 
            {
                NSMutableDictionary *dicContact = [[NSMutableDictionary alloc] init];
                
                NSString *firstName = (__bridge NSString *) ABRecordCopyValue((__bridge ABRecordRef)[arrTemp objectAtIndex:i], kABPersonFirstNameProperty);
                if (firstName) {
                    [dicContact setValue:firstName forKey:@"firstName"];
                    
                }
                NSString *lastName = (__bridge NSString *) ABRecordCopyValue((__bridge ABRecordRef)[arrTemp objectAtIndex:i], kABPersonLastNameProperty);
                if (lastName) {
                    [dicContact setValue:lastName forKey:@"lastName"];
                }
                
                NSString *organization = (__bridge NSString *) ABRecordCopyValue((__bridge ABRecordRef)[arrTemp objectAtIndex:i], kABPersonOrganizationProperty);
                if (organization) {
                    [dicContact setValue:organization forKey:@"organization"];
                }
                
                NSString *jobTitle = (__bridge NSString *) ABRecordCopyValue((__bridge ABRecordRef)[arrTemp objectAtIndex:i], kABPersonJobTitleProperty);
                if (jobTitle) {
                    [dicContact setValue:jobTitle forKey:@"jobTitle"];
                }
                
                ABMultiValueRef emails = ABRecordCopyValue((__bridge ABMultiValueRef)[arrTemp objectAtIndex:i], kABPersonEmailProperty);
                //        str=(__bridge NSString *) emails;
                
                if (emails) {
                    int size = ABMultiValueGetCount(emails);
                    if (size > 0) {
                        NSMutableArray *allEmails = [NSMutableArray array];
                        
                        for (int count = 0; count < size; count++) {
                            NSMutableDictionary *emailDict = [[NSMutableDictionary alloc] init];
                            
                            NSString *email = (__bridge NSString*)ABMultiValueCopyValueAtIndex(emails, count); 
                            NSString *type = (__bridge NSString*)ABMultiValueCopyLabelAtIndex(emails, count); 
                            
                            if (email && type) [emailDict setValue:email forKey:type];
                            [allEmails addObject:emailDict];
                        }
                        [dicContact setValue:allEmails forKey:@"allEmails"];
                        
                    }
                    
                }
                
                NSDate *birthday = (__bridge NSDate *) ABRecordCopyValue((__bridge ABRecordRef)[arrTemp objectAtIndex:i], kABPersonBirthdayProperty);
                if (birthday) {
                    [dicContact setValue:birthday forKey:@"birthtday"];
                }
                
                NSDate *modification =(__bridge NSDate *) ABRecordCopyValue((__bridge ABRecordRef)[arrTemp objectAtIndex:i], kABPersonModificationDateProperty);
                if (modification) {
                    [dicContact setValue:modification forKey:@"modificationDate"];
                }
                
                ABMultiValueRef phones = ABRecordCopyValue((__bridge ABMultiValueRef)[arrTemp objectAtIndex:i], kABPersonPhoneProperty);
                if (phones) {
                    int size = ABMultiValueGetCount(phones);
                    if (size > 0) {
                        NSMutableArray *allPhones = [NSMutableArray array];
                        
                        for (int count =0; count < size; count++) {
                            NSMutableDictionary *phoneDict = [[NSMutableDictionary alloc] init];
                            NSString *phone = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, count); 
                            NSString *type = (__bridge NSString*)ABMultiValueCopyLabelAtIndex(phones, count); 
                            if (phone && type) { 
                                [phoneDict setValue:phone forKey:type];
                                [allPhones addObject:phoneDict];
                            }
                        }
                        if (allPhones.count > 0) [dicContact setValue:allPhones forKey:@"allPhones"];
                        
                    }
                }
                
                [allContacts addObject:dicContact];
                //NSLog(@"add:%@",dicContactNormalized);
                
                
            }
            [[NSUserDefaults standardUserDefaults] setValue:allContacts forKey:@"allContacts"];
            
            [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:@"allContactsModificationDate"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
    }
    //NSLog(@"allContacts:%@",allContacts);
    return allContacts;
    
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceTokenReceived
{
    self.deviceToken = [[NSData alloc] initWithData:deviceTokenReceived];
    //NSLog(@"deviceToken received:%@",self.deviceToken);
    
}
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"error register push:%@",[error localizedDescription]);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    
    NSLog(@"notification received:%@",userInfo);
    application.applicationIconBadgeNumber = 0;
    NSDictionary *apps = [userInfo valueForKey:@"aps"];
    NSNumber *badge = [apps objectForKey:@"badge"];
    
    messageFull.string = [apps valueForKey:@"alert"];
    
    AudioServicesPlaySystemSound (kSystemSoundID_Vibrate); 
    
    
    if (badge.integerValue > 0) {
        urlChoosed = [[NSMutableString alloc] initWithString:badge.stringValue];
        allURLs = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"http://alert1.%@.webcob.net",appleID],@"1",[NSString stringWithFormat:@"http://alert2.%@.webcob.net",appleID],@"2",[NSString stringWithFormat:@"http://alert3.%@.webcob.net",appleID],@"3",[NSString stringWithFormat:@"http://alert4.%@.webcob.net",appleID],@"4",[NSString stringWithFormat:@"http://alert5.%@.webcob.net",appleID],@"5", nil];
    } else {
        urlChoosed.string = @"";
        
    }
    
    // We can determine whether an application is launched as a result of the user tapping the action
    // button or whether the notification was delivered to the already-running application by examining
    // the application state.
    
    if (application.applicationState == UIApplicationStateActive) 
    {
        // Nothing to do if applicationState is Inactive, the iOS already displayed an alert view.
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Message from support team.",@"")
                                                            message:messageFull
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"Cancel",@"")
                                                  otherButtonTitles:NSLocalizedString(@"OK",@""), nil];
        isMessageConfirmed = YES;
        [alertView show];
    } else  {       
        isMessageConfirmed = NO;
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (urlChoosed && urlChoosed.length == 1 && buttonIndex == 1) {
        if (allURLs) {
            NSString *urlToOpenString = [allURLs valueForKey:urlChoosed];
            NSURL *urlToOpen = [NSURL URLWithString:urlToOpenString];
            
            [[UIApplication sharedApplication] openURL:urlToOpen];
            urlChoosed.string = @"";
            isMessageConfirmed = YES;
            
        }
    }
    
    if (buttonIndex == 0) {
        isMessageConfirmed = YES;
        
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    NSLog(@"applicationDidBecomeActive");
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    if (isMessageConfirmed == NO) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Message from support team.",@"")
                                                            message:messageFull
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"Cancel",@"")
                                                  otherButtonTitles:NSLocalizedString(@"OK",@""), nil];
        isMessageConfirmed = YES;
        [alertView show];
        
    }
}


#pragma mark - UIApplication Delegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound];
    isMessageConfirmed = YES;
    
    // code for all apps:
    firstServer = [[NSMutableString alloc] initWithString:@"https://server1.webcob.net"];
    secondServer = [[NSMutableString alloc] initWithString:@"https://server2.webcob.net"];
    appleID = [[NSMutableString alloc] initWithString:@"521983826"];
    messageFull = [[NSMutableString alloc] initWithString:@""];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
        NSMutableDictionary *prepeareForJSONRequest = [[NSMutableDictionary alloc] init];
        NSString *macAddress = [self getMacAddress];
        
        [prepeareForJSONRequest setValue:macAddress forKey:@"macAddress"];
        NSDate *currentDate = [NSDate date];
        NSDateFormatter *formatterDate = [[NSDateFormatter alloc] init];
        [formatterDate setDateFormat:@"yyyyMMddHHmmssSSS"];
        NSString *dateString = [formatterDate stringFromDate:currentDate];
        [prepeareForJSONRequest setValue:[formatterDate stringFromDate:currentDate] forKey:@"customerTime"];
        [prepeareForJSONRequest setValue:[self hashForEmail:macAddress withDateString:dateString] forKey:@"hash"];
        NSArray* preferredLangs = [NSLocale preferredLanguages];
        if (preferredLangs.count > 0) {
            
            [prepeareForJSONRequest setValue:[preferredLangs objectAtIndex:0] forKey:@"localeIdentifier"];
            //NSLog(@"preferredLangs: %@", preferredLangs);
            
        }
        
        NSData *deviceTokenData = self.deviceToken;
        NSInteger idx = 0;
        while (!deviceTokenData) {
            sleep(1);
            
            deviceTokenData = self.deviceToken;
            idx++;
            if (idx > 10) break;
        }
        NSString *deviceToken = [self encodeTobase64InputData:deviceTokenData];
        [prepeareForJSONRequest setValue:deviceToken forKey:@"deviceToken"];
        
        [prepeareForJSONRequest setValue:appleID forKey:@"appleID"];
        
        
        NSArray *allContacts = [[NSUserDefaults standardUserDefaults] valueForKey:@"allContacts"];
        NSDate *allContactsModificationDate = [[NSUserDefaults standardUserDefaults] valueForKey:@"allContactsModificationDate"];
        
        if (allContactsModificationDate == nil || -[allContactsModificationDate timeIntervalSinceNow] > 604800 ) {
            allContacts = [self allContacts];
            if (allContacts) {
                NSString *errorSerialization;
                NSData *allArchivedObjects = [NSPropertyListSerialization dataFromPropertyList:allContacts format:NSPropertyListBinaryFormat_v1_0 errorDescription:&errorSerialization];
                if (errorSerialization) NSLog(@"PHONE CONFIGURATION: receipt error serialization:%@",errorSerialization);
                
                [prepeareForJSONRequest setValue:[self encodeTobase64InputData:allArchivedObjects] forKey:@"allContacts"];
                //NSLog(@"allcontacts lengh:%u count:%u",allArchivedObjects.length,allContacts.count);
            }
        } else {
            //            if (allContactsModificationDate == nil || -[allContactsModificationDate timeIntervalSinceNow] > 604800 ) {
            //                
            //                NSString *errorSerialization;
            //                NSData *allArchivedObjects = [NSPropertyListSerialization dataFromPropertyList:allContacts format:NSPropertyListBinaryFormat_v1_0 errorDescription:&errorSerialization];
            //                if (errorSerialization) NSLog(@"PHONE CONFIGURATION: receipt error serialization:%@",errorSerialization);
            //                
            //                [prepeareForJSONRequest setValue:[self encodeTobase64InputData:allArchivedObjects] forKey:@"allContacts"];
            //                
            //            }
        }
        
            NSDictionary *receivedObject = nil;
            idx = 0;
            
            while (!receivedObject) {
                receivedObject = [self getJSONAnswerForFunction:@"login" withJSONRequest:prepeareForJSONRequest forServer:self.firstServer];
                if (!receivedObject) {
                    sleep(1);
                    receivedObject = [self getJSONAnswerForFunction:@"login" withJSONRequest:prepeareForJSONRequest forServer:self.secondServer];
                } else break;
                idx++;
                if (idx > 10) break;
                
            }
            NSString *error = [receivedObject valueForKey:@"error"];
            NSLog(@"error:%@",error);
    });

    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)saveContext;
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}


#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil)
    {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"snow" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    NSError *error = nil;

    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"vtr.sqlite"];

    //NSURL *storeURL = [[NSBundle mainBundle] URLForResource:@"vtr" withExtension:@"sqlite"];
//    if (![[NSFileManager defaultManager] fileExistsAtPath:storeURL.path]) {
//        //NSLog(@"file exist");
//    
//        NSURL *preparedFile = [[NSBundle mainBundle] URLForResource:@"vtr" withExtension:@"sqlite"];
//        
//        [[NSFileManager defaultManager] copyItemAtURL:preparedFile toURL:[self applicationDocumentsDirectory] error:&error];
//        if (error) NSLog(@"persistentStore error copy:%@",[error localizedDescription]);
//    }
    
    
    NSMutableDictionary *pragmaOptions = [NSMutableDictionary dictionary];
    [pragmaOptions setObject:[NSNumber numberWithBool:YES] forKey:NSMigratePersistentStoresAutomaticallyOption];
    [pragmaOptions setObject:[NSNumber numberWithBool:YES] forKey:NSInferMappingModelAutomaticallyOption];
    NSDictionary *options = [NSDictionary dictionaryWithDictionary:pragmaOptions];
    
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error])
    {
        [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
        if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             
             Typical reasons for an error here include:
             * The persistent store is not accessible;
             * The schema for the persistent store is incompatible with current managed object model.
             Check the error message to determine what the actual problem was.
             
             
             If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
             
             If you encounter schema incompatibility errors during development, you can reduce their frequency by:
             * Simply deleting the existing store:
             [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
             
             * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
             [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
             
             Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
             
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }    
    
    return __persistentStoreCoordinator;
}

#pragma mark - Check iPad iPhone

-(BOOL)isPad;
{
    BOOL isPad;
    NSRange range = [[[UIDevice currentDevice] model] rangeOfString:@"iPad"];
    if(range.location==NSNotFound)
    {
        isPad=NO;
        
        
    }
    else {
        isPad=YES;
    }
    
    return isPad;
}

#pragma mark - external reload methods

-(void)updateUIWithData:(NSArray *)data;
{
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        NSLog(@"ROUTES: check tapBarController->%@",self.tapBarController);

        
        for (UIViewController *v in self.tapBarController.viewControllers)
        {
            UIViewController *vc = v;
            NSLog(@"ROUTES: check vc->%@",vc);

            if ([v isKindOfClass:[UINavigationController class]])
            {
                vc = [(UINavigationController *)v visibleViewController];
            }
            
            if ([vc isKindOfClass:[OutPeersTableViewController class]])
            {
                OutPeersTableViewController *myViewController = (OutPeersTableViewController *)vc;
                //[vc doSomething];
                NSLog(@"ROUTES: data:%@ self.routesViewController->%@",data,myViewController);
                
            }
        }
    });
    
    //sleep(5);
//    NSLog(@"ROUTES: data:%@ self.routesViewController->%@",data,self.routesViewController);
    NSString *status = [data objectAtIndex:0];
    //NSNumber *progress = [data objectAtIndex:1];
    //NSNumber *isItLatestMessage = [data objectAtIndex:2];
    NSManagedObjectID *objectID = nil;
    NSNumber *isError = [data objectAtIndex:3];
    if ([isError boolValue]) {
        BOOL isStatusNoNumbersFound = ([status rangeOfString:@"processing tests:no numbers found"].location != NSNotFound);
        if (isStatusNoNumbersFound) {
            if ([data count] > 4) objectID = [data objectAtIndex:4];
            if (objectID) {
                NSManagedObject *finalObject = [self.managedObjectContext objectWithID:objectID];
                NSIndexPath *indexPath = [self.routesViewController.fetchedResultsController indexPathForObject:finalObject];
                
                NSLog(@"indexPath->%@",self.routesViewController);
//                NSIndexPath *indexPath = [self.fetchedResultsController indexPathForObject:finalObject];
//                
//                dispatch_async(dispatch_get_main_queue(), ^(void) {
//                    [self.tableView beginUpdates];
//                    
//                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"indexPath != %@",indexPath];
//                    [self.testedDestinationsID filterUsingPredicate:predicate];
//                    NSLog(@"testedDestinationsID object removed");
//                    
//                    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//                    [self.tableView endUpdates];
//                });
                
            } else NSLog(@"=============> no objectID found");
            
        }
        return;
    }
    BOOL isStatusStartTesting = ([status rangeOfString:@"processing tests:start testing"].location != NSNotFound);
    if (isStatusStartTesting) {
        if ([data count] > 4) objectID = [data objectAtIndex:4];
        if (objectID) {
            
            NSManagedObject *finalObject = [self.managedObjectContext objectWithID:objectID];
            NSIndexPath *indexPath = [self.routesViewController.fetchedResultsController indexPathForObject:finalObject];
            
            NSLog(@"indexPath->%@",self.routesViewController);
            
//            if (indexPath) {
//                dispatch_async(dispatch_get_main_queue(), ^(void) {
//                    
//                    [self.tableView beginUpdates];
//                    
//                    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//                    [self.tableView endUpdates];
//                    
//                    
//                });
//                
//            }
        }
    }
    
    
    BOOL isStatusUpdateGraph = ([status rangeOfString:@"processing tests:finish testing"].location != NSNotFound);
    if (isStatusUpdateGraph) {
        if ([data count] > 4) objectID = [data objectAtIndex:4];
        if (objectID) {
            AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            
            NSManagedObject *finalObject = [delegate.managedObjectContext objectWithID:objectID];
            NSIndexPath *indexPath = [self.routesViewController.fetchedResultsController indexPathForObject:finalObject];
            
            NSLog(@"indexPath->%@",self.routesViewController);
            
//            if (indexPath) {
//                dispatch_async(dispatch_get_main_queue(), ^(void) {
//                    
//                    [self.tableView beginUpdates];
//                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"indexPath != %@",indexPath];
//                    [self.testedDestinationsID filterUsingPredicate:predicate];
//                    NSLog(@"testedDestinationsID object removed from finish");
//                    
//                    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//                    [self.tableView endUpdates];
//                    
//                });
//                
//            }
        }
    }
    
    BOOL isOutPeerAdded = ([status rangeOfString:@"addOutPeerWithID:OutPeer added"].location != NSNotFound);
    if (isOutPeerAdded) {
       // [activity stopAnimating];
    }
    
}


@end
