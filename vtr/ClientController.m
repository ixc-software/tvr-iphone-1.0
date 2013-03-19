//
//
//  ClientController.m
//  snow
//
//  Created by Oleksii Vynogradov on 04.09.11.
//  Copyright 2011 IXC-USA Corp. All rights reserved.
//

#import "MainSystem.h"

#import "CompanyStuff.h"
#import "CurrentCompany.h"
#import "CompanyAccounts.h"
#import "Carrier.h"
#import "CodesList.h"
#import "CountrySpecificCodeList.h"
#import "DestinationsListPushList.h"
#import "Carrier.h"
#import "CarrierStuff.h"
#import "DestinationsListForSale.h"
#import "DestinationsListWeBuy.h"
#import "DestinationsListTargets.h"
#import "Financial.h"
#import "InvoicesAndPayments.h"
#import "CodesvsDestinationsList.h"
#import "DestinationPerHourStat.h"
#import "DestinationsListWeBuyTesting.h"
#import "DestinationsListWeBuyResults.h"
#import "OutPeer.h"
#import "GrossBookRecord.h"

#import "OperationNecessaryToApprove.h"
#import "Events.h"
#import "ClientController.h"
//#import "JSONKit.h"
#import "ParseCSV.h"
#import "AppDelegate.h"

#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

#import <ifaddrs.h>
#import <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>

#import <CommonCrypto/CommonDigest.h>


static char encodingTable[64] = {
    'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P',
    'Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f',
    'g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v',
    'w','x','y','z','0','1','2','3','4','5','6','7','8','9','+','/' };

@interface NSURLRequest (DummyInterface)
+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString*)host;
+ (void)setAllowsAnyHTTPSCertificate:(BOOL)allow forHost:(NSString*)host;
@end


@implementation ClientController

@synthesize moc,sender,downloadSize,mainMoc,deviceToken64;

- (id)initWithPersistentStoreCoordinator:(NSPersistentStoreCoordinator *)coordinator withSender:(id)senderForThisClass withMainMoc:(NSManagedObjectContext *)itMainMoc;
{
    self = [super init];
    if (self) {
        // Initialization code here.
        mainMoc = itMainMoc;
        //receivedData = [[NSMutableData alloc] init];

        sender = senderForThisClass;
 
//#if defined(SNOW_SERVER)
//
//        mainServer = [[NSURL alloc] initWithString:@"https://mac.ixcglobal.com:8081"];
//#else
//        
//#if defined (SNOW_CLIENT_APPSTORE)
//        mainServer = [[NSURL alloc] initWithString:@"http://mac1.ixcglobal.com:8081"];
//        //mainServer = [[NSURL alloc] initWithString:@"http://127.0.0.1:8081"];
//
//#else
//        
//        //        mainServer = [[NSURL alloc] initWithString:@"https://mac.ixcglobal.com:8081"];
//        
//         //       mainServer = [[NSURL alloc] initWithString:@"https://127.0.0.1:8081"];
//        //mainServer = [[NSURL alloc] initWithString:@"http://192.168.0.58:8081"];
//               // mainServer = [[NSURL alloc] initWithString:@"http://mac1.ixcglobal.com:8081"];
//
//        
//#endif
//     
//#endif
//
        
        
//        mainServer = [[NSURL alloc] initWithString:@"http://127.0.0.1:8081"];
//        mainServer = [[NSURL alloc] initWithString:@"http://91.224.223.42:8081"];
//        mainServer = [[NSURL alloc] initWithString:@"https://192.168.0.58:8081"];
//        mainServer = [[NSURL alloc] initWithString:@"https://193.108.122.154:8081"];

        moc = [[NSManagedObjectContext alloc] init];
        [moc setUndoManager:nil];
        //[moc setStalenessInterval:0.0000001213];
//        [moc setMergePolicy:NSOverwriteMergePolicy];
        [moc setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];

        //[moc setMergePolicy:NSRollbackMergePolicy];
        [moc setPersistentStoreCoordinator:coordinator];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(importerDidSave:) name:NSManagedObjectContextDidSaveNotification object:self.moc];
//        [[NSURLCache sharedURLCache] setMemoryCapacity:0];
//        [[NSURLCache sharedURLCache] setDiskCapacity:0];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:self.moc];
//    [mainMoc release];
    //if (self.mainServer) [self.mainServer release];
    //[receivedData release];
}
#pragma mark -
#pragma mark core multithread methods

- (void)importerDidSave:(NSNotification *)saveNotification {
//    [mainMoc performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:) withObject:saveNotification waitUntilDone:NO];

    //NSLog(@"MERGE in client controller");
//    if ([NSThread isMainThread]) {
//        [mainMoc mergeChangesFromContextDidSaveNotification:saveNotification];
//////        [self performSelectorOnMainThread:@selector(finalSave:) withObject:self.moc waitUntilDone:YES];
////        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"isCurrentUpdateProcessing"];
////
//    } else {
//        [self performSelectorOnMainThread:@selector(importerDidSave:) withObject:saveNotification waitUntilDone:NO];
//    }
////    dispatch_async(dispatch_get_main_queue(), ^(void) { 
////        [self.mainMoc mergeChangesFromContextDidSaveNotification:saveNotification];
////        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"isCurrentUpdateProcessing"];
//    });
    [mainMoc performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:)	
                                                    withObject:saveNotification
                                                 waitUntilDone:YES];

}

- (void)logError:(NSError*)error;
{
    id sub = [[error userInfo] valueForKey:@"NSUnderlyingException"];
    
    if (!sub) {
        sub = [[error userInfo] valueForKey:NSUnderlyingErrorKey];
    }
    
    if (!sub) {
        NSLog(@"%@:%@ Error Received: %@", [self class], NSStringFromSelector(_cmd), 
              [error localizedDescription]);
        return;
    }
    
    if ([sub isKindOfClass:[NSArray class]] || 
        [sub isKindOfClass:[NSSet class]]) {
        for (NSError *subError in sub) {
            NSLog(@"%@:%@ SubError: %@", [self class], NSStringFromSelector(_cmd), 
                  [subError localizedDescription]);
        }
    } else {
        NSLog(@"%@:%@ exception %@", [self class], NSStringFromSelector(_cmd), [sub description]);
    }
}

-(void) finalSave:(NSManagedObjectContext *)mocForSave; 
{
    
    if ([mocForSave hasChanges]) {
        NSError *error = nil;
        if (![mocForSave save: &error]) {
            NSLog(@"Failed to save to data store: %@", [error localizedDescription]);
            NSArray* detailedErrors = [[error userInfo] objectForKey:NSDetailedErrorsKey];
            if(detailedErrors != nil && [detailedErrors count] > 0)
            {
                for(NSError* detailedError in detailedErrors)
                {
                    NSLog(@"  DetailedError: %@", [detailedError userInfo]);
                }
            }
            else
            {
                NSLog(@"  %@", [error userInfo]);
            }
            [self logError:error];
        } //else [mocForSave reset];
    }
    
    return;
    
}



#pragma mark -
#pragma mark helper methods

#define BINARY_UNIT_SIZE 3
#define BASE64_UNIT_SIZE 4

#define xx 65

static unsigned char base64DecodeLookup[256] =
{
    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, 
    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, 
    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, 62, xx, xx, xx, 63, 
    52, 53, 54, 55, 56, 57, 58, 59, 60, 61, xx, xx, xx, xx, xx, xx, 
    xx,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 
    15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, xx, xx, xx, xx, xx, 
    xx, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 
    41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, xx, xx, xx, xx, xx, 
    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, 
    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, 
    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, 
    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, 
    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, 
    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, 
    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, 
    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, 
};

- (NSString *)decodeBase64string:(NSString *)input {
    const char *inputBuffer = [input cStringUsingEncoding:NSASCIIStringEncoding];
    size_t length = strlen(inputBuffer);
 	if (length == -1)
	{
		length = strlen(inputBuffer);
	}
	
	size_t outputBufferSize = (length / BASE64_UNIT_SIZE) * BINARY_UNIT_SIZE;
	unsigned char *outputBuffer = (unsigned char *)malloc(outputBufferSize);
	
	size_t i = 0;
	size_t j = 0;
	while (i < length)
	{
		//
		// Accumulate 4 valid characters (ignore everything else)
		//
		unsigned char accumulated[BASE64_UNIT_SIZE];
		size_t accumulateIndex = 0;
		while (i < length)
		{
			unsigned char decode = base64DecodeLookup[inputBuffer[i++]];
			if (decode != xx)
			{
				accumulated[accumulateIndex] = decode;
				accumulateIndex++;
				
				if (accumulateIndex == BASE64_UNIT_SIZE)
				{
					break;
				}
			}
		}
		
		//
		// Store the 6 bits from each of the 4 characters as 3 bytes
		//
		outputBuffer[j] = (accumulated[0] << 2) | (accumulated[1] >> 4);
		outputBuffer[j + 1] = (accumulated[1] << 4) | (accumulated[2] >> 2);
		outputBuffer[j + 2] = (accumulated[2] << 6) | accumulated[3];
		j += accumulateIndex - 1;
	}   
    NSData * objData = [[NSData alloc] initWithBytes:outputBuffer length:j];
    return [NSString stringWithUTF8String:[objData bytes]];
}
static const short _base64DecodingTable[256] = {
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -1, -1, -2, -1, -1, -2, -2,
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
	-1, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, 62, -2, -2, -2, 63,
	52, 53, 54, 55, 56, 57, 58, 59, 60, 61, -2, -2, -2, -2, -2, -2,
	-2,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14,
	15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, -2, -2, -2, -2, -2,
	-2, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
	41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, -2, -2, -2, -2, -2,
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2
};


- (NSData *)decodeBase64:(NSString *)input {
    const char * objPointer = [input cStringUsingEncoding:NSASCIIStringEncoding];
	unsigned long intLength = strlen(objPointer);
	int intCurrent;
	int i = 0, j = 0, k;
    
	unsigned char * objResult;
	objResult = calloc(intLength, sizeof(char));
    
	// Run through the whole string, converting as we go
	while ( ((intCurrent = *objPointer++) != '\0') && (intLength-- > 0) ) {
		if (intCurrent == '=') {
			if (*objPointer != '=' && ((i % 4) == 1)) {// || (intLength > 0)) {
				// the padding character is invalid at this point -- so this entire string is invalid
				free(objResult);
				return nil;
			}
			continue;
		}
        
		intCurrent = _base64DecodingTable[intCurrent];
		if (intCurrent == -1) {
			// we're at a whitespace -- simply skip over
			continue;
		} else if (intCurrent == -2) {
			// we're at an invalid character
			free(objResult);
			return nil;
		}
        
		switch (i % 4) {
			case 0:
				objResult[j] = intCurrent << 2;
				break;
                
			case 1:
				objResult[j++] |= intCurrent >> 4;
				objResult[j] = (intCurrent & 0x0f) << 4;
				break;
                
			case 2:
				objResult[j++] |= intCurrent >>2;
				objResult[j] = (intCurrent & 0x03) << 6;
				break;
                
			case 3:
				objResult[j++] |= intCurrent;
				break;
		}
		i++;
	}
    
	// mop things up if we ended on a boundary
	k = j;
	if (intCurrent == '=') {
		switch (i % 4) {
			case 1:
				// Invalid state
				free(objResult);
				return nil;
                
			case 2:
				k++;
				// flow through
			case 3:
				objResult[k] = 0;
		}
	}
    
	// Cleanup and setup the return NSData
	NSData * objData = [[NSData alloc] initWithBytes:objResult length:j];
	free(objResult);
    return objData;
}

- (id)dataWithBase64EncodedString:(NSString *)string;
{
    if (string == nil) return nil; //[NSException raise:NSInvalidArgumentException format:nil];
    if ([string length] == 0)
        return [NSData data];
    
    static char *decodingTable = NULL;
    if (decodingTable == NULL)
    {
        decodingTable = malloc(256);
        if (decodingTable == NULL)
            return nil;
        memset(decodingTable, CHAR_MAX, 256);
        NSUInteger i;
        for (i = 0; i < 64; i++)
            decodingTable[(short)encodingTable[i]] = i;
    }
    
    const char *characters = [string cStringUsingEncoding:NSASCIIStringEncoding];
    if (characters == NULL)     //  Not an ASCII string!
        return nil;
    char *bytes = malloc((([string length] + 3) / 4) * 3);
    if (bytes == NULL)
        return nil;
    NSUInteger length = 0;
    
    NSUInteger i = 0;
    while (YES)
    {
        char buffer[4];
        short bufferLength;
        for (bufferLength = 0; bufferLength < 4; i++)
        {
            if (characters[i] == '\0')
                break;
            if (isspace(characters[i]) || characters[i] == '=')
                continue;
            buffer[bufferLength] = decodingTable[(short)characters[i]];
            if (buffer[bufferLength++] == CHAR_MAX)      //  Illegal character!
            {
                free(bytes);
                return nil;
            }
        }
        
        if (bufferLength == 0)
            break;
        if (bufferLength == 1)      //  At least two characters are needed to produce one byte!
        {
            free(bytes);
            return nil;
        }
        
        //  Decode the characters in the buffer to bytes.
        bytes[length++] = (buffer[0] << 2) | (buffer[1] >> 4);
        if (bufferLength > 2)
            bytes[length++] = (buffer[1] << 4) | (buffer[2] >> 2);
        if (bufferLength > 3)
            bytes[length++] = (buffer[2] << 6) | buffer[3];
    }
    
    bytes = realloc(bytes, length);
    return [NSData dataWithBytesNoCopy:bytes length:length];
}

- (NSString *)base64EncodingData:(NSData *)data;
{
    if ([data length] == 0)
        return @"";
    
    char *characters = malloc((([data length] + 2) / 3) * 4);
    if (characters == NULL)
        return nil;
    NSUInteger length = 0;
    
    NSUInteger i = 0;
    while (i < [data length])
    {
        char buffer[3] = {0,0,0};
        short bufferLength = 0;
        while (bufferLength < 3 && i < [data length])
            buffer[bufferLength++] = ((char *)[data bytes])[i++];
        
        //  Encode the bytes in the buffer to four characters, including padding "=" characters if necessary.
        characters[length++] = encodingTable[(buffer[0] & 0xFC) >> 2];
        characters[length++] = encodingTable[((buffer[0] & 0x03) << 4) | ((buffer[1] & 0xF0) >> 4)];
        if (bufferLength > 1)
            characters[length++] = encodingTable[((buffer[1] & 0x0F) << 2) | ((buffer[2] & 0xC0) >> 6)];
        else characters[length++] = '=';
        if (bufferLength > 2)
            characters[length++] = encodingTable[buffer[2] & 0x3F];
        else characters[length++] = '=';    
    }
    
    return [[NSString alloc] initWithBytesNoCopy:characters length:length encoding:NSASCIIStringEncoding freeWhenDone:YES];
}



-(NSDictionary *) clearNullKeysForDictionary:(NSDictionary *)dictionary
{
    __unsafe_unretained NSMutableDictionary *result = [NSMutableDictionary dictionaryWithDictionary:dictionary];
    
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        //NSLog(@"clearance was start:%@",obj);
        if (!obj || [[obj class] isSubclassOfClass:[NSNull class]]) [result removeObjectForKey:key];
        if ([[obj class] isSubclassOfClass:[NSDate class]]) { 
            [result setValue:[obj description] forKey:key];
            //NSLog(@"date was converted:%@",obj);
        }
        if ([[obj class] isSubclassOfClass:[NSData class]]) { 
            NSString *stringToPass = [[NSString alloc] initWithData:obj encoding:NSASCIIStringEncoding];
            [result setValue:stringToPass forKey:key];
            //NSLog(@"data was converted:%@",obj);
        }

    }];
    return [NSDictionary dictionaryWithDictionary:result];
    
}

-(NSDictionary *) dictionaryFromObject:(NSManagedObject *)object
{
    NSArray *keys = [[[object entity] attributesByName] allKeys];
    NSDictionary *dict = [object dictionaryWithValuesForKeys:keys];
    return [self clearNullKeysForDictionary:dict];
}



-(void) updateUIwithMessage:(NSString *)message withObjectID:(NSManagedObjectID *)objectID withLatestMessage:(BOOL)isItLatestMessage error:(BOOL)isError;
{
    //NSLog(@"CLIENT CONTROLLER: this is UI message:%@",message);
    if (sender && [sender respondsToSelector:@selector(updateUIWithData:)]) {
        [sender performSelector:@selector(updateUIWithData:) withObject:[NSArray arrayWithObjects:message,[NSNumber numberWithInt:0],[NSNumber numberWithBool:isItLatestMessage],[NSNumber numberWithBool:isError],objectID,nil]];
    }

}

-(void) updateUIwithMessage:(NSString *)message andProgressPercent:(NSNumber *)percent withObjectID:(NSManagedObjectID *)objectID;
{
    if (sender && [sender respondsToSelector:@selector(updateUIWithData:)]) {
        [sender performSelector:@selector(updateUIWithData:) withObject:[NSArray arrayWithObjects:message,percent,[NSNumber numberWithBool:NO],[NSNumber numberWithBool:NO],objectID,nil]];
    }

}

-(void) setValuesFromDictionary:(NSDictionary *)values anObject:(NSManagedObject *)object
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy'-'MM'-'dd' 'HH':'mm':'ss' 'Z'"];
    //[formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];


    NSEntityDescription *entity = [object entity];
    NSDictionary *attributes = [entity attributesByName];
    
    NSArray *allKeys = [values allKeys];
    for (NSString *key in allKeys) {
        
        id obj = [values objectForKey:key];
        
        NSAttributeDescription *attribute = [attributes valueForKey:key];
        NSString *className = [attribute attributeValueClassName];
        //NSLog(@"class name::%@",className);
        if ([className isEqualToString:@"NSDate"]){
            //NSLog(@"dateUpdate");
            NSDate *dateToPass = nil;//[formatter dateFromString:obj];
            if ([[obj class] isSubclassOfClass:[NSDate class]]) dateToPass = obj;
            else dateToPass = [formatter dateFromString:obj];
            [object setValue:dateToPass forKey:key];
            continue;
        } 
        
        if ([className isEqualToString:@"NSData"]){
            NSData *dataToPass = [obj dataUsingEncoding:NSASCIIStringEncoding];
            [object setValue:dataToPass forKey:key];
            //[dataToPass release];
            continue;
        } 
        
        [object setValue:obj forKey:key];
    }
    //return object;
}


-(void) setUserDefaultsObject:(id)object forKey:(NSString *)key;
{
    [[NSUserDefaults standardUserDefaults] setObject:object forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(id) userDefaultsObjectForKey:(NSString *)key;
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}
-(NSString *)localStatusForObjectsWithRootGuid:(NSString *)rootObjectGUID;
{
    //NSString *objectGUID = [objects valueForKey:@"rootObjectGUID"];
    NSDictionary *objectStatus =[self userDefaultsObjectForKey:rootObjectGUID];
    NSString *status = nil;
    if (objectStatus) { 
        if ([objectStatus valueForKey:@"update"]) status = [objectStatus valueForKey:@"update"];
        if ([objectStatus valueForKey:@"new"]) status =  [objectStatus valueForKey:@"new"]; 
        if ([objectStatus valueForKey:@"login"]) status =  [objectStatus valueForKey:@"login"]; 
        
    }
    return status;
}


-(void) createCountrySpecificCodesInCoreDataForMainSystem:(MainSystem *)mainSystem;
{
    [self updateUIwithMessage:@"Update codes internal data" andProgressPercent:[NSNumber numberWithDouble:0] withObjectID:nil];
    //NSLog(@"CLIENT CONTROLLER: createCountrySpecificCodesInCoreDataForMainSystem start");
    NSError *error = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CountrySpecificCodeList" inManagedObjectContext:self.moc];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:nil];
    NSUInteger count = [self.moc countForFetchRequest:fetchRequest error:&error];
    if (count == 0) {
        NSString *error;
        NSURL *preparedFile = [[NSBundle mainBundle] URLForResource:@"preparedCodesList" withExtension:@"ary"];
        NSData *data = [NSData dataWithContentsOfURL:preparedFile];
        NSPropertyListFormat format;
        NSArray *decodedData = [NSPropertyListSerialization propertyListFromData:data mutabilityOption:0 format:&format errorDescription:&error];
        if (error) NSLog(@"error decoding codes:%@",error);
        //NSLog(@">>>>>>>>>>>>>>>>>> start");
        [decodedData enumerateObjectsUsingBlock:^(NSDictionary *row, NSUInteger idx, BOOL *stop) {
            CountrySpecificCodeList *newMainCodeRecord = (CountrySpecificCodeList *)[NSEntityDescription insertNewObjectForEntityForName:@"CountrySpecificCodeList" inManagedObjectContext:self.moc]; 
            newMainCodeRecord.country = [row valueForKey:@"country"];
            newMainCodeRecord.specific = [row valueForKey:@"specific"];
            NSString *codes = [row valueForKey:@"codes"];
            newMainCodeRecord.codes = codes;
            NSArray *codesArray = [codes componentsSeparatedByString:@","];
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            [codesArray enumerateObjectsUsingBlock:^(NSString *codeString, NSUInteger idx, BOOL *stop) {
                CodesList *newCode = (CodesList *)[NSEntityDescription insertNewObjectForEntityForName:@"CodesList" inManagedObjectContext:self.moc]; 
                NSNumber *codeNumber = [formatter numberFromString:codeString];
                newCode.code = codeNumber;
                newCode.countrySpecificCodesList = newMainCodeRecord;
            }];
            newMainCodeRecord.mainSystem = mainSystem;
            NSNumber *percentDone = [NSNumber numberWithDouble:([[NSNumber numberWithUnsignedInteger:idx] doubleValue] / [[NSNumber numberWithUnsignedInteger:[decodedData count]] doubleValue])];
            [self updateUIwithMessage:@"Update codes database..." andProgressPercent:percentDone withObjectID:nil];
        }];
        //NSLog(@">>>>>>>>>>>>>>>>>> stop");
    } else {
        //NSLog(@">>>> codes exist");
        [self updateUIwithMessage:@"codes exist" withObjectID:nil withLatestMessage:YES error:NO];
    }
}

- (CompanyStuff *)authorization;
{
    NSString *keyAofAuthorized = @"authorizedUserGUID";
#if defined(SNOW_CLIENT_APPSTORE)
    keyAofAuthorized = @"authorizedUserGUIDclient";
#endif
    NSString *authorizedUserGUID = [self userDefaultsObjectForKey:keyAofAuthorized];
    NSError *error = nil;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(GUID == %@)",authorizedUserGUID];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CompanyStuff" inManagedObjectContext:self.moc];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    NSArray *result = [self.moc executeFetchRequest:fetchRequest error:&error];
    CompanyStuff *stuff = [result lastObject];
    return stuff;
}


-(MainSystem *)getMainSystem;
{
    NSError *error = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MainSystem" inManagedObjectContext:self.moc];
    [fetchRequest setEntity:entity];
    NSArray *result = [self.moc executeFetchRequest:fetchRequest error:&error];
    MainSystem *mainSystem = [result lastObject];
    return mainSystem;
}

-(NSString*)md5HexDigest:(NSString*)input {
    const char* str = [input UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), result);
    
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];
    for(int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x",result[i]];
    }
    return ret;
}


-(NSString *) hashForEmail:(NSString *)email withDateString:(NSString *)dateString;
{
    if (email && dateString) {
        // MIICmTCCAYECAQAwVDEoMCYGCSqGSIb3DQEJARY
        NSString *fixedString = [NSString stringWithFormat:@"%c%s%c%@", 'M', "IICmTCCAYECA", 'Q', @"AwVDEoMCYGCSqGSIb3DQEJARY"];
        NSString *lastDigit = [dateString substringWithRange:NSMakeRange(dateString.length - 1, 1)];
        NSNumberFormatter *number = [[NSNumberFormatter alloc] init];
        NSNumber *lastDigitFromDate = [number numberFromString:lastDigit];
        NSString *forAuthtorization = nil;
        
        if (lastDigitFromDate.integerValue == 0) {
            // zero
            forAuthtorization = [NSString stringWithFormat:@"%@%@%@",email,fixedString,dateString];
            
        } else if  (lastDigitFromDate.integerValue % 2) {
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
-(NSString *)Base64Encode:(NSData *)data{
    //Point to start of the data and set buffer sizes
    int inLength = [data length];
    int outLength = ((((inLength * 4)/3)/4)*4) + (((inLength * 4)/3)%4 ? 4 : 0);
    const char *inputBuffer = [data bytes];
    char *outputBuffer = malloc(outLength);
    outputBuffer[outLength] = 0;
    
    //64 digit code
    static char Encode[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    
    //start the count
    int cycle = 0;
    int inpos = 0;
    int outpos = 0;
    char temp;
    
    //Pad the last to bytes, the outbuffer must always be a multiple of 4
    outputBuffer[outLength-1] = '=';
    outputBuffer[outLength-2] = '=';
    
    /* http://en.wikipedia.org/wiki/Base64
     Text content   M           a           n
     ASCII          77          97          110
     8 Bit pattern  01001101    01100001    01101110
     
     6 Bit pattern  010011  010110  000101  101110
     Index          19      22      5       46
     Base64-encoded T       W       F       u
     */
    
    
    while (inpos < inLength){
        switch (cycle) {
            case 0:
                outputBuffer[outpos++] = Encode[(inputBuffer[inpos]&0xFC)>>2];
                cycle = 1;
                break;
            case 1:
                temp = (inputBuffer[inpos++]&0x03)<<4;
                outputBuffer[outpos] = Encode[temp];
                cycle = 2;
                break;
            case 2:
                outputBuffer[outpos++] = Encode[temp|(inputBuffer[inpos]&0xF0)>> 4];
                temp = (inputBuffer[inpos++]&0x0F)<<2;
                outputBuffer[outpos] = Encode[temp];
                cycle = 3;
                break;
            case 3:
                outputBuffer[outpos++] = Encode[temp|(inputBuffer[inpos]&0xC0)>>6];
                cycle = 4;
                break;
            case 4:
                outputBuffer[outpos++] = Encode[inputBuffer[inpos++]&0x3f];
                cycle = 0;
                break;                          
            default:
                cycle = 0;
                break;
        }
    }
    NSString *pictemp = [NSString stringWithUTF8String:outputBuffer];
    free(outputBuffer); 
    return pictemp;
}

- (NSString *)base64EncodedStringWithData:(NSData *)data
{
    //ensure wrapWidth is a multiple of 4
    NSUInteger wrapWidth = 0;//(wrapWidth / 4) * 4;
    
    const char lookup[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    
    long long inputLength = [data length];
    const unsigned char *inputBytes = [data bytes];
    
    long long maxOutputLength = (inputLength / 3 + 1) * 4;
    maxOutputLength += wrapWidth? (maxOutputLength / wrapWidth) * 2: 0;
    unsigned char *outputBytes = (unsigned char *)malloc(maxOutputLength);
    
    long long i;
    long long outputLength = 0;
    for (i = 0; i < inputLength - 2; i += 3)
    {
        outputBytes[outputLength++] = lookup[(inputBytes[i] & 0xFC) >> 2];
        outputBytes[outputLength++] = lookup[((inputBytes[i] & 0x03) << 4) | ((inputBytes[i + 1] & 0xF0) >> 4)];
        outputBytes[outputLength++] = lookup[((inputBytes[i + 1] & 0x0F) << 2) | ((inputBytes[i + 2] & 0xC0) >> 6)];
        outputBytes[outputLength++] = lookup[inputBytes[i + 2] & 0x3F];
        
        //add line break
        if (wrapWidth && (outputLength + 2) % (wrapWidth + 2) == 0)
        {
            outputBytes[outputLength++] = '\r';
            outputBytes[outputLength++] = '\n';
        }
    }
    
    //handle left-over data
    if (i == inputLength - 2)
    {
        // = terminator
        outputBytes[outputLength++] = lookup[(inputBytes[i] & 0xFC) >> 2];
        outputBytes[outputLength++] = lookup[((inputBytes[i] & 0x03) << 4) | ((inputBytes[i + 1] & 0xF0) >> 4)];
        outputBytes[outputLength++] = lookup[(inputBytes[i + 1] & 0x0F) << 2];
        outputBytes[outputLength++] =   '=';
    }
    else if (i == inputLength - 1)
    {
        // == terminator
        outputBytes[outputLength++] = lookup[(inputBytes[i] & 0xFC) >> 2];
        outputBytes[outputLength++] = lookup[(inputBytes[i] & 0x03) << 4];
        outputBytes[outputLength++] = '=';
        outputBytes[outputLength++] = '=';
    }
    
    //truncate data to match actual output length
    outputBytes = realloc(outputBytes, outputLength);
    NSString *result = [[NSString alloc] initWithBytesNoCopy:outputBytes length:outputLength encoding:NSASCIIStringEncoding freeWhenDone:YES];
    
#if !__has_feature(objc_arc)
    [result autorelease];
#endif
    
    return (outputLength >= 4)? result: nil;
}

- (NSString *)getModel {
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *model = malloc(size);
    sysctlbyname("hw.machine", model, &size, NULL, 0);
    NSString *sDeviceModel = [NSString stringWithCString:model encoding:NSUTF8StringEncoding];
    free(model);
    if ([sDeviceModel isEqual:@"i386"])      return @"Simulator";  //iPhone Simulator
    if ([sDeviceModel isEqual:@"iPhone1,1"]) return @"iPhone1G";   //iPhone 1G
    if ([sDeviceModel isEqual:@"iPhone1,2"]) return @"iPhone3G";   //iPhone 3G
    if ([sDeviceModel isEqual:@"iPhone2,1"]) return @"iPhone3GS";  //iPhone 3GS
    if ([sDeviceModel isEqual:@"iPhone3,1"]) return @"iPhone3GS";  //iPhone 4 - AT&T
    if ([sDeviceModel isEqual:@"iPhone3,2"]) return @"iPhone3GS";  //iPhone 4 - Other carrier
    if ([sDeviceModel isEqual:@"iPhone3,3"]) return @"iPhone4";    //iPhone 4 - Other carrier
    if ([sDeviceModel isEqual:@"iPhone4,1"]) return @"iPhone4S";   //iPhone 4S
    if ([sDeviceModel isEqual:@"iPhone5,1"]) return @"iPhone5";   //iPhone 4S
    if ([sDeviceModel isEqual:@"iPhone5,2"]) return @"iPhone5";   //iPhone 4S
    if ([sDeviceModel isEqual:@"iPod1,1"])   return @"iPod1stGen"; //iPod Touch 1G
    if ([sDeviceModel isEqual:@"iPod2,1"])   return @"iPod2ndGen"; //iPod Touch 2G
    if ([sDeviceModel isEqual:@"iPod3,1"])   return @"iPod3rdGen"; //iPod Touch 3G
    if ([sDeviceModel isEqual:@"iPod4,1"])   return @"iPod4thGen"; //iPod Touch 4G
    if ([sDeviceModel isEqual:@"iPad1,1"])   return @"iPadWiFi";   //iPad Wifi
    if ([sDeviceModel isEqual:@"iPad1,2"])   return @"iPad3G";     //iPad 3G
    if ([sDeviceModel isEqual:@"iPad2,1"])   return @"iPad2";      //iPad 2 (WiFi)
    if ([sDeviceModel isEqual:@"iPad2,2"])   return @"iPad2";      //iPad 2 (GSM)
    if ([sDeviceModel isEqual:@"iPad2,3"])   return @"iPad2";      //iPad 2 (CDMA)
    if ([sDeviceModel isEqual:@"iPad3,1"])   return @"iPad3";      //iPad 2 (CDMA)
    if ([sDeviceModel isEqual:@"iPad3,2"])   return @"iPad3";      //iPad 2 (CDMA)
    if ([sDeviceModel isEqual:@"iPad3,3"])   return @"iPad3";      //iPad 2 (CDMA)
    
    NSString *aux = [[sDeviceModel componentsSeparatedByString:@","] objectAtIndex:0];
    
    //If a newer version exist
    if ([aux rangeOfString:@"iPhone"].location!=NSNotFound) {
        int version = [[aux stringByReplacingOccurrencesOfString:@"iPhone" withString:@""] intValue];
        if (version == 3) return @"iPhone4";
        if (version >= 4) return @"iPhone4s";
        
    }
    if ([aux rangeOfString:@"iPod"].location!=NSNotFound) {
        int version = [[aux stringByReplacingOccurrencesOfString:@"iPod" withString:@""] intValue];
        if (version >=4) return @"iPod4thGen";
    }
    if ([aux rangeOfString:@"iPad"].location!=NSNotFound) {
        int version = [[aux stringByReplacingOccurrencesOfString:@"iPad" withString:@""] intValue];
        if (version ==1) return @"iPad3G";
        if (version >=2) return @"iPad2";
    }
    //If none was found, send the original string
    return sDeviceModel;
}

- (NSString *)getIPAddress
{
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0)
    {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL)
        {
            if(temp_addr->ifa_addr->sa_family == AF_INET)
            {
                //NSLog(@"temp_addr->ifa_name->%@",[NSString stringWithUTF8String:temp_addr->ifa_name]);
                
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"] || [[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"pdp_ip0"] || [[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en1"])
                {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    // Free memory
    freeifaddrs(interfaces);
    //    char             baseHostName[256], fullHostName[256];
    //    struct hostent  *host;
    //    struct in_addr **hList;
    //
    //    gethostname (baseHostName, 255);
    //    if (!strstr(baseHostName, ".local"))
    //        sprintf (fullHostName, "%s.local", baseHostName);
    //    else
    //        strcpy (fullHostName, baseHostName);
    //
    //    host = gethostbyname (fullHostName);
    //
    //    if (!host)
    //        return (@"");
    //
    //    hList = (struct in_addr **)host->h_addr_list;
    //    address = [NSString stringWithCString:inet_ntoa(*hList[0]) encoding:NSUTF8StringEncoding];
    //
    //    NSLog(@"address is:%@",address);
    
    return address;
}


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
    //NSLog(@"Mac Address: %@", macAddressString);
    
    // Release the buffer memory
    free(msgBuffer);
    
    return macAddressString;
}



static unsigned char base64EncodeLookup[65] =
"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";


-(NSString *) encodeTobase64InputData:(NSData *)data;
{
    
    const void *buffer = [data bytes];
    size_t length = [data length];
    bool separateLines =  false;
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
    free(outputBuffer);
    
    return result;
}

- (MainSystem *) firstSetup;
{
    NSError *error = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSArray *result = nil;
    __block NSEntityDescription *entity = nil;
    NSString *keyAofAuthorized = @"authorizedUserGUID";
    NSString *autorizedGUID = [self userDefaultsObjectForKey:keyAofAuthorized];
    __block NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(GUID == %@)",autorizedGUID];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"CompanyStuff" inManagedObjectContext:self.moc]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(GUID == %@)",autorizedGUID]];
    //NSLog(@">>>>>> FETCH REQUEST:%@",fetchRequest);
    result = [self.moc executeFetchRequest:fetchRequest error:&error];
    CompanyStuff *stuff = nil;
    CurrentCompany *company = nil;
    if ([result count] == 0) {
        predicate = [NSPredicate predicateWithFormat:@"(name == %@)",@"you company"];
        entity = [NSEntityDescription entityForName:@"CurrentCompany" inManagedObjectContext:self.moc];
        [fetchRequest setEntity:entity];
        [fetchRequest setPredicate:predicate];
        //NSLog(@">>>>>> FETCH REQUEST2:%@",fetchRequest);
        result = [self.moc executeFetchRequest:fetchRequest error:&error];
        if ([result count] > 1) NSLog(@"WARNING  more than 2 you company");
        if ([result count] == 0) {
            company = (CurrentCompany *)[NSEntityDescription
                                         insertNewObjectForEntityForName:@"CurrentCompany" 
                                         inManagedObjectContext:self.moc];
            company.name = @"you company";
        } else company = [result lastObject];
            stuff = (CompanyStuff *)[NSEntityDescription 
                                     insertNewObjectForEntityForName:@"CompanyStuff" 
                                     inManagedObjectContext:self.moc];
            stuff.firstName = @"you first name";
            stuff.lastName = @"you last name";
            stuff.email = @"you@email";
            stuff.password = @"you password";
            NSString *keyAofAuthorized = @"authorizedUserGUID";
            [self setUserDefaultsObject:stuff.GUID forKey:keyAofAuthorized];
            company.companyAdminGUID = stuff.GUID;
            stuff.currentCompany = company;
    } else
    {
        stuff = [result lastObject];
        company = stuff.currentCompany;
    }
    NSAssert(stuff != nil,@"stuff don't found");
    NSAssert(company != nil,@"company don't found");
    [self finalSave:moc];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"MainSystem" inManagedObjectContext:self.moc]];
    [fetchRequest setPredicate:nil];
    [fetchRequest setResultType:NSManagedObjectResultType];
    //NSLog(@">>>>>> FETCH REQUEST4:%@",fetchRequest);
    result = [self.moc executeFetchRequest:fetchRequest error:&error];
    MainSystem *mainSystem = nil;
    if ([result count] == 0) {
        mainSystem = (MainSystem *)[NSEntityDescription insertNewObjectForEntityForName:@"MainSystem" inManagedObjectContext:self.moc];
        [self setUserDefaultsObject:mainSystem.GUID forKey:@"mainSystemGUID"];
        [self.moc save:&error];
        if (error) NSLog(@"%@",[error localizedDescription]);
    } else {
        mainSystem = [result lastObject];
        [self createCountrySpecificCodesInCoreDataForMainSystem:mainSystem];
        [self finalSave:moc];
        return mainSystem;
    }
    [self createCountrySpecificCodesInCoreDataForMainSystem:mainSystem];
    [self finalSave:moc];
    fetchRequest = nil;
    [self updateUIwithMessage:@"first setup completed" withObjectID:nil withLatestMessage:YES error:NO];
    return mainSystem;
}

#pragma mark -
#pragma mark NSURLConnection methods
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    downloadSize = [[NSNumber alloc] initWithLongLong:[response expectedContentLength]];
    //NSLog(@"didReceiveResponse:%@ bytes of data",downloadSize);
    [self updateUIwithMessage:@"server download is started" withObjectID:nil withLatestMessage:NO error:NO];
    [receivedData setLength:0];
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSNumber *percentDone = [NSNumber numberWithDouble:[[NSNumber numberWithUnsignedInteger:[receivedData length]] doubleValue] / [self.downloadSize doubleValue]];
   // NSLog(@"Processing! Received %@ percent bytes of data",percentDone);
    [self updateUIwithMessage:@"server download progress" andProgressPercent:percentDone withObjectID:nil];
    [receivedData appendData:data];
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    downloadCompleted = YES;
    [self updateUIwithMessage:[NSString stringWithFormat:@"download error:%@",[error localizedDescription]] withObjectID:nil withLatestMessage:NO error:YES];
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
 //   NSLog(@"Succeeded! Received %@ bytes of data",[NSNumber numberWithUnsignedInteger:[receivedData length]]);
    downloadCompleted = YES;
    [self updateUIwithMessage:@"server download is finished" withObjectID:nil withLatestMessage:NO error:NO];
}
- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    //NSLog(@"can auth");
    //BOOL result = [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
    //NSLog(@"auth:%@",result ? @"YES" : @"NO");
    return YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    //NSLog(@"challenge");
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
            NSURL *indexURL = [[NSBundle mainBundle] URLForResource:@"testvoiproutes.com" withExtension:@"p12"];
            NSData *localP12 = [NSData dataWithContentsOfURL:indexURL];
            NSMutableDictionary * options = [[NSMutableDictionary alloc] init];
            // Set the public key query dictionary
            //change to your .pfx  password here
            NSString *password = [NSString stringWithFormat:@"%c%s%c%@", '6', "17b74c906a", '7', @"7742aab3bdbd11559faf"];
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
            CFRelease(certSummary);
            CFRelease((CFDataRef) dataLocal);
        }
        if(trust){
            [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
        }else{
            [challenge.sender cancelAuthenticationChallenge:challenge];
        }
    }
}
-(NSDictionary *) getJSONAnswerForFunction:(NSString *)function withJSONRequest:(NSMutableDictionary *)request;
{
    [request setValue:@"1.0" forKey:@"version"];
    NSString *userEmail = [request valueForKey:@"authorizedUserEmail"];
    if (!userEmail) userEmail = [request valueForKey:@"login"];
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *formatterDate = [[NSDateFormatter alloc] init];
    [formatterDate setDateFormat:@"yyyyMMddHHmmssSSS"];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [formatterDate setLocale:usLocale];
    NSString *dateString = [formatterDate stringFromDate:currentDate];
    [request setValue:[formatterDate stringFromDate:currentDate] forKey:@"customerTime"];
    [request setValue:[self hashForEmail:userEmail withDateString:dateString] forKey:@"hash"];
    UIDevice *myDevice = [UIDevice currentDevice];
    NSString *deviceUDID = nil;
    if ([myDevice respondsToSelector:@selector(uniqueIdentifier)]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        deviceUDID = [myDevice uniqueIdentifier].copy;
#pragma clang diagnostic pop
    } else {
        if ([myDevice respondsToSelector:@selector(identifierForVendor)]) {
            deviceUDID = [[myDevice identifierForVendor] UUIDString].copy;
        }
    }
    if (deviceUDID) [request setValue:deviceUDID forKey:@"testudid"];
    else [request setValue:@"UDIDNotFound" forKey:@"testudid"];
    NSString *deviceMAC = [self getMacAddress];
    if (deviceUDID) [request setValue:deviceMAC forKey:@"deviceMAC"];
    else [request setValue:@"macNotFound" forKey:@"deviceMAC"];
    downloadCompleted = NO;
    receivedData = [NSMutableData data]; 
    dispatch_async(dispatch_get_main_queue(), ^(void) { 
        NSError *error = nil;
        NSData *bodyData = [NSJSONSerialization dataWithJSONObject:request options:0 error:&error];
        if (error) NSLog(@"CLIENT CONTROLLER: json decoding error:%@ in function:%@",[error localizedDescription],function);
        NSData *dataForBody = [[NSData alloc] initWithData:bodyData];
        //NSLog(@"CLIENT CONTROLLER: string lenght is:%@ bytes",[NSNumber numberWithUnsignedInteger:[dataForBody length]]);
        //NSLog(@"CLIENT CONTROLLER: >>>>>> func:%@ send:%@  ",function,[[NSString alloc] initWithData:bodyData encoding:NSUTF8StringEncoding]);
        NSString *functionString = [NSString stringWithFormat:@"/%@",function];
        NSURL *urlForRequest = [NSURL URLWithString:functionString relativeToURL:mainServer];
        NSMutableURLRequest *requestToServer = [NSMutableURLRequest requestWithURL:urlForRequest];
        //NSLog(@"CLIENT CONTROLLER: URL:%@",requestToServer);
        [requestToServer setHTTPMethod:@"POST"];
        [requestToServer setHTTPBody:dataForBody];
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:requestToServer delegate:self startImmediately:YES];
        if (!connection) NSLog(@"failedToCreate");
    });
    while (!downloadCompleted) {
        sleep(1); 
        //NSLog(@"waiting for completed"); 
    }
    NSData *receivedResult = [[NSData alloc] initWithData:receivedData];
    NSString *answer = [[NSString alloc] initWithData:receivedResult encoding:NSUTF8StringEncoding];
    //NSLog(@"CLIENT CONTROLLER: ANSWER:%@",answer);
    NSError *error = nil;
    NSDictionary *finalResult = [NSJSONSerialization JSONObjectWithData:receivedResult options:NSJSONReadingMutableLeaves error:&error];
    [receivedData setData:[NSData data]];
    //NSLog(@"finalResult:%@",finalResult);
    if (error) { 
        NSLog(@"CLIENT CONTROLLER: failed to decode answer:%@ with error:%@ for function:%@ sended data:%@",answer,[error localizedDescription],function,request);
        return nil;
    }
    return finalResult;
}
#pragma mark -
#pragma mark V5 SOftswitch methods
-(NSDictionary *) isCurrentUserAuthorized;
{
    CompanyStuff *admin = [self authorization];
    if (!admin) return NO;
    mainServer = [[NSURL alloc] initWithString:@"https://flames.ixc.ua/api"];
    //mainServer = [[NSURL alloc] initWithString:@"https://freebsd81.ixc.ua/api"];
    NSMutableDictionary *prepeareForJSONRequest = [NSMutableDictionary dictionary];
    [prepeareForJSONRequest setValue:admin.email forKey:@"login"];
    [prepeareForJSONRequest setValue:admin.password forKey:@"password"];
    //NSLog(@"CLIENT CONTROLLER isCurrentUserAuthorized Sent:%@",prepeareForJSONRequest);
    NSDictionary *receivedObject = [self getJSONAnswerForFunction:@"api/GetUser" withJSONRequest:prepeareForJSONRequest];
    if (!receivedObject) {
        [self updateUIwithMessage:@"auth not passed" withObjectID:admin.objectID withLatestMessage:YES error:NO];
        return nil;
    }
    //NSLog(@"isCurrentUserAuthorized receivedObject:%@",receivedObject);
    NSString *error = [receivedObject valueForKey:@"error"];
    if ([[error class] isSubclassOfClass:[NSArray class]]) {
    } else {
        if (error && error.length > 0) { 
            [self updateUIwithMessage:[NSString stringWithFormat:@"Authorization failed: %@",error] withObjectID:admin.objectID withLatestMessage:YES error:YES];
            return nil;
        }
    }
    NSArray *result = (NSArray *)receivedObject;
    NSDictionary *answer = result.lastObject;
    return answer;
    [self updateUIwithMessage:@"Login success" withObjectID:admin.objectID withLatestMessage:YES error:NO];
    return nil;
}

-(BOOL) createOnServerNewUserAndCompany;
{
    CompanyStuff *admin = [self authorization];
    if (!admin) return NO;
    //if (admin.isCompanyAdmin.boolValue == NO) return NO;
    mainServer = [[NSURL alloc] initWithString:@"https://flames.ixc.ua/api"];
    NSMutableDictionary *prepeareForJSONRequest = [NSMutableDictionary dictionary];
    [prepeareForJSONRequest setValue:@"flames" forKey:@"login"];
    [prepeareForJSONRequest setValue:@"Yi1MMEVXYm5YLTJmaTExNnZDSVJLU0p2Njhte" forKey:@"password"];
    NSString *unique = [[NSProcessInfo processInfo] globallyUniqueString];
    NSString *unique8 = [unique substringWithRange:NSMakeRange(0, 6)];
    [prepeareForJSONRequest setValue:unique8 forKey:@"companyUserName"];
    [prepeareForJSONRequest setValue:admin.password forKey:@"companyUserPassword"];
    [prepeareForJSONRequest setValue:admin.email forKey:@"userEmail"];
    //NSLog(@"CLIENT CONTROLLER createOnServerNewUserAndCompany Sent:%@",prepeareForJSONRequest);
    NSDictionary *receivedObject = [self getJSONAnswerForFunction:@"api/CreateUser" withJSONRequest:prepeareForJSONRequest];
    //NSLog(@"createOnServerNewUserAndCompany receivedObject:%@",receivedObject);
    NSString *error = [receivedObject valueForKey:@"error"];
    if ([[error class] isSubclassOfClass:[NSArray class]]) {
        if (error && error.length > 0) { 
            [self updateUIwithMessage:[NSString stringWithFormat:@"can't create user: %@",error] withObjectID:admin.objectID withLatestMessage:YES error:YES];
            return NO;
        }
    }
    NSString *userID = [receivedObject valueForKey:@"companyUserID"];
    if (userID) {
        NSString *finalUserID = nil;
        if ([[userID class] isSubclassOfClass:[NSNumber class]]) finalUserID = [(NSNumber *)userID stringValue];
        else finalUserID = userID;
        admin.userID = finalUserID;
        [self finalSave:self.moc];
        [prepeareForJSONRequest removeAllObjects];
        [prepeareForJSONRequest setValue:@"flames" forKey:@"login"];
        [prepeareForJSONRequest setValue:@"Yi1MMEVXYm5YLTJmaTExNnZDSVJLU0p2Njhte" forKey:@"password"];
        [prepeareForJSONRequest setValue:userID forKey:@"userID"];
        [prepeareForJSONRequest setValue:@"861071292" forKey:@"companyID"];
        receivedObject = [self getJSONAnswerForFunction:@"api/AssignUser" withJSONRequest:prepeareForJSONRequest];
        //NSLog(@"createOnServerNewUserAndCompany receivedObject:%@",receivedObject);
    }
    error = [receivedObject valueForKey:@"error"];
    if (![[error class] isSubclassOfClass:[NSArray class]]) {
        if (error && error.length > 0) { 
            [self updateUIwithMessage:[NSString stringWithFormat:@"can't assign user: %@",error] withObjectID:admin.objectID withLatestMessage:YES error:YES];
            return NO;
        }
    }
    [self updateUIwithMessage:@"created succesefully" withObjectID:admin.objectID withLatestMessage:YES error:NO];
    return YES;
}

-(BOOL) getPaymentsList;
{
    CompanyStuff *admin = [self authorization];
    mainServer = [[NSURL alloc] initWithString:@"https://flames.ixc.ua/api"];
    NSMutableDictionary *prepeareForJSONRequest = [NSMutableDictionary dictionary];
    [prepeareForJSONRequest setValue:admin.email forKey:@"login"];
    [prepeareForJSONRequest setValue:admin.password forKey:@"password"];
    [prepeareForJSONRequest setValue:admin.userID forKey:@"userID"];
    //NSLog(@"CLIENT CONTROLLER getPaymentsList Sent:%@",prepeareForJSONRequest);
    NSArray *receivedObject = (NSArray *)[self getJSONAnswerForFunction:@"api/GetPayments" withJSONRequest:prepeareForJSONRequest];
    //NSLog(@"getCarriersList getPaymentsList:%@",receivedObject);
    [receivedObject enumerateObjectsUsingBlock:^(NSDictionary *row, NSUInteger idx, BOOL *stop) {
        NSString *transactionIdentifier = [row valueForKey:@"transactionIdentifier"];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"GrossBookRecord" inManagedObjectContext:self.moc];
        [fetchRequest setEntity:entity];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"transactionIdentifier == %@", transactionIdentifier];
        [fetchRequest setPredicate:predicate];
        NSError *error = nil;
        NSInteger count = [self.moc countForFetchRequest:fetchRequest error:&error];
        if (count == 0) {
            NSNumber *userID = [row valueForKey:@"userID"];
            if ([userID.stringValue isEqualToString:admin.userID]) {
                GrossBookRecord *newRecord = (GrossBookRecord *)[NSEntityDescription insertNewObjectForEntityForName:@"GrossBookRecord" inManagedObjectContext:self.moc];
                NSNumber *paymentAmount = [row valueForKey:@"paymentAmount"];
                NSString *paymentDate = [row valueForKey:@"paymentDate"];
                paymentDate = [paymentDate stringByReplacingOccurrencesOfString:@"T" withString:@""];
                paymentDate = [paymentDate stringByReplacingOccurrencesOfString:@"Z" withString:@""];
                NSDateFormatter *formatterDate = [[NSDateFormatter alloc] init];
                [formatterDate setDateFormat:@"yyyy-MM-ddHH:mm:ss"];
                NSDate *creationDate = [formatterDate dateFromString:paymentDate];
                NSString *tariffPlan = [row valueForKey:@"tariffPlan"];
                NSString *receiptFromItunes64 = [row valueForKey:@"receiptFromItunes64"];
                NSData *receiptFromItunes = [self decodeBase64:receiptFromItunes64];
                if (paymentAmount && ![[paymentAmount class] isSubclassOfClass:[NSNull class]]) newRecord.paymentAmount = paymentAmount;
                newRecord.creationDate = creationDate;
                newRecord.tariffPlan = tariffPlan;
                newRecord.receiptFromItunes = receiptFromItunes;
                newRecord.companyStuff = admin;
                newRecord.transactionIdentifier = transactionIdentifier;
                //NSLog(@"CREATED PAYMENT -> %@",newRecord);
            } else NSLog(@"incorrectUserID");
        }
    }];
    [self finalSave:self.moc];
    [self updateUIwithMessage:@"payments received" withObjectID:admin.objectID withLatestMessage:YES error:NO];
    return YES;
}


-(BOOL) getCarriersList;
{
    CompanyStuff *admin = [self authorization];
    mainServer = [[NSURL alloc] initWithString:@"https://flames.ixc.ua/api"];
    NSMutableDictionary *prepeareForJSONRequest = [NSMutableDictionary dictionary];
    [prepeareForJSONRequest setValue:admin.email forKey:@"login"];
    [prepeareForJSONRequest setValue:admin.password forKey:@"password"];
    //NSLog(@"CLIENT CONTROLLER getCarriersList Sent:%@",prepeareForJSONRequest);
    NSDictionary *receivedObject = [self getJSONAnswerForFunction:@"api/GetCarriers" withJSONRequest:prepeareForJSONRequest];
    //NSLog(@"getCarriersList receivedObject:%@",receivedObject);
    NSString *error = [receivedObject valueForKey:@"error"];
    if ([[error class] isSubclassOfClass:[NSArray class]]) {
    } else {
        if (error && error.length > 0) return NO;
    }
    [self updateUIwithMessage:@"auth passed" withObjectID:admin.objectID withLatestMessage:NO error:NO];
    //NSLog(@"CLIENT CONTROLLER getCarriersList Received:%@",receivedObject);
    NSArray *carriers = (NSArray *)receivedObject;
    [carriers enumerateObjectsUsingBlock:^(NSDictionary *row, NSUInteger idx, BOOL *stop) {
        NSNumber *carrierID = [row valueForKey:@"carrierID"];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Carrier" inManagedObjectContext:self.moc];
        [fetchRequest setEntity:entity];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(externalID == %@)",carrierID];
        [fetchRequest setPredicate:predicate];
        NSError *error = nil;
        NSArray *fetchedObjects = [moc executeFetchRequest:fetchRequest error:&error];
        if (fetchedObjects == nil)  NSLog(@"Failed to executeFetchRequest:%@ to data store: %@ in function:%@",fetchRequest, [error localizedDescription],NSStringFromSelector(_cmd));
        Carrier *findedCarrier = [fetchedObjects lastObject];
        if (!findedCarrier) { 
            //NSLog(@"CLIENT CONTROLLER: warning, carrier not found withName:%@ and will created",[row valueForKey:@"carrierName"]);
            findedCarrier = (Carrier *)[NSEntityDescription 
                                        insertNewObjectForEntityForName:@"Carrier" 
                                        inManagedObjectContext:moc];
            findedCarrier.companyStuff = admin;
        } 
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        findedCarrier.name = [row valueForKey:@"carrierName"];
        findedCarrier.address = [row valueForKey:@"carrierAddress"];
        findedCarrier.emailList = [row valueForKey:@"carrierEmail"];
        findedCarrier.externalID = [formatter stringFromNumber:[row valueForKey:@"carrierID"]];
        findedCarrier.url = [row valueForKey:@"carrierWebsite"];
        //NSLog(@">>>>>> for carrier:%@ we update id:%@",findedCarrier.name,findedCarrier.externalID);
        [self finalSave:self.moc];
        NSMutableDictionary *prepeareForJSONRequest = [NSMutableDictionary dictionary];
        [prepeareForJSONRequest setValue:findedCarrier.externalID forKey:@"carrierID"];
        [prepeareForJSONRequest setValue:admin.email forKey:@"login"];
        [prepeareForJSONRequest setValue:admin.password forKey:@"password"];
        //NSLog(@"CLIENT CONTROLLER GetOutpeersByCarrier Sent:%@",prepeareForJSONRequest);
        NSDictionary *receivedObject = [self getJSONAnswerForFunction:@"api/GetOutpeersByCarrier" withJSONRequest:prepeareForJSONRequest];
        //NSLog(@"CLIENT CONTROLLER GetOutpeersByCarrier Received:%@",receivedObject);
        NSArray *outpeers = (NSArray *)receivedObject;
        __block NSUInteger allObjectsMutableCountOutpeers = outpeers.count;
        [outpeers enumerateObjectsUsingBlock:^(NSDictionary *row, NSUInteger idx, BOOL *stop) {
            NSNumber *percentDone = [NSNumber numberWithDouble:[[NSNumber numberWithUnsignedInteger:idx] doubleValue] / [[NSNumber numberWithUnsignedInteger:allObjectsMutableCountOutpeers] doubleValue]];
            [self updateUIwithMessage:[NSString stringWithFormat:@"progress for update graph:%@",@"DestinationsListWeBuy"] andProgressPercent:percentDone withObjectID:nil];
            if (idx % allObjectsMutableCountOutpeers * 0.05 == 0) { 
                [self finalSave:moc];
                //NSLog(@"CLIENT CONTROLLER: >>>>>>>>>> moc saved every 5 percent");
            } else {
                //NSLog(@"CLIENT CONTROLLER: >>>>>>>>>> moc not saved for idx:%u and count:%u",idx,allObjectsMutableCountOutpeers);
            }
            NSDictionary *outPeer = [row valueForKey:@"outpeer"];
            NSNumber *isEnable = [outPeer valueForKey:@"isEnable"];
            NSNumber *outpeerID = [outPeer valueForKey:@"outpeerID"];
            NSString *outpeerName = [outPeer valueForKey:@"outpeerName"];
            NSString *outpeerPrefix = [outPeer valueForKey:@"outpeerPrefix"];
            NSString *outpeerSecondName = [outPeer valueForKey:@"outpeerSecondName"];
            NSString *outpeerTag = [outPeer valueForKey:@"outpeerTag"];
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"OutPeer" inManagedObjectContext:self.moc];
            [fetchRequest setEntity:entity];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(outpeerID == %@)",outpeerID];
            [fetchRequest setPredicate:predicate];
            NSError *error = nil;
            NSArray *fetchedObjects = [moc executeFetchRequest:fetchRequest error:&error];
            if (fetchedObjects == nil)  NSLog(@"Failed to executeFetchRequest:%@ to data store: %@ in function:%@",fetchRequest, [error localizedDescription],NSStringFromSelector(_cmd));
            OutPeer *findedOutPeer = [fetchedObjects lastObject];
            if (!findedOutPeer) { 
                NSLog(@"CLIENT CONTROLLER: warning, findedOutPeer not found withName:%@ and will created",outpeerName);
                findedOutPeer = (OutPeer *)[NSEntityDescription 
                                            insertNewObjectForEntityForName:@"OutPeer" 
                                            inManagedObjectContext:moc];
                findedOutPeer.carrier = findedCarrier;
            } 
            NSMutableDictionary *prepeareForJSONRequest = [NSMutableDictionary dictionary];
            [prepeareForJSONRequest setValue:outpeerID forKey:@"outpeerID"];
            [prepeareForJSONRequest setValue:admin.email forKey:@"login"];
            [prepeareForJSONRequest setValue:admin.password forKey:@"password"];
            //NSLog(@"CLIENT CONTROLLER GetOutpeer Sent:%@",prepeareForJSONRequest);
            NSDictionary *receivedObject = [self getJSONAnswerForFunction:@"api/GetOutpeer" withJSONRequest:prepeareForJSONRequest];
            //NSLog(@"CLIENT CONTROLLER GetOutpeer Received:%@",receivedObject);
            NSArray *addresses = [receivedObject valueForKey:@"addresses"];
            NSMutableString *ips = [NSMutableString string];
            [addresses enumerateObjectsUsingBlock:^(NSDictionary *row, NSUInteger idx, BOOL *stop) {
                NSString *host = [row valueForKey:@"host"];
                if (ips.length == 0) [ips appendString:host];
                else [ips appendFormat:@",%@",host];
            }];
            findedOutPeer.isEnable = isEnable;
            findedOutPeer.outpeerName = outpeerName;
            findedOutPeer.outpeerPrefix = outpeerPrefix;
            findedOutPeer.outpeerSecondName = outpeerSecondName;
            findedOutPeer.outpeerTag = outpeerTag;
            findedOutPeer.outpeerID = outpeerID.stringValue;
            findedOutPeer.ips = ips;
        }];
    }];
    [self finalSave:self.moc];
    [self updateUIwithMessage:@"done" withObjectID:admin.objectID withLatestMessage:YES error:NO];
    return YES;
}

-(void) startGetPhoneNumbersForContrySpecific:(NSArray *)destinations;
{
    __block NSUInteger allObjectsMutableCountDestinations = destinations.count;
    [destinations enumerateObjectsUsingBlock:^(NSManagedObjectID *destinationID, NSUInteger idx, BOOL *stop) {
        NSNumber *percentDone = [NSNumber numberWithDouble:[[NSNumber numberWithUnsignedInteger:idx] doubleValue] / [[NSNumber numberWithUnsignedInteger:allObjectsMutableCountDestinations] doubleValue]];
        [self updateUIwithMessage:[NSString stringWithFormat:@"startGetPhoneNumbersForContrySpecific:progress"] andProgressPercent:percentDone withObjectID:nil];
        //NSLog(@"destinationID:%@",destinationID);
        CountrySpecificCodeList *destinationFromList = (CountrySpecificCodeList *)[self.moc objectWithID:destinationID];
        //NSLog(@"destinationFromList:%@",destinationFromList.country);
        NSArray *codes = destinationFromList.codesList.allObjects;        
        NSMutableArray *normalCodes = [NSMutableArray array];
        NSMutableDictionary *codesList  = [NSMutableDictionary dictionary];
        [codes enumerateObjectsUsingBlock:^(CodesList *anyCode, NSUInteger idx, BOOL *stop) {
            [codesList setValue:anyCode.code forKey:[NSNumber numberWithUnsignedInteger:idx].stringValue];
            [normalCodes addObject:anyCode.code];
        }];
        mainServer = [[NSURL alloc] initWithString:@"https://flames.ixc.ua/api"];
        NSMutableDictionary *prepeareForJSONRequest = [NSMutableDictionary dictionary];
        CompanyStuff *admin = [self authorization];
        [prepeareForJSONRequest setValue:admin.email forKey:@"login"];
        [prepeareForJSONRequest setValue:admin.password forKey:@"password"];        
        [prepeareForJSONRequest setValue:codesList forKey:@"codes"];
        //NSLog(@"CLIENT CONTROLLER getPhoneNumbers StartTesting Sent:%@",prepeareForJSONRequest);
        NSDictionary *receivedObject = [self getJSONAnswerForFunction:@"api/getTestNumbers" withJSONRequest:prepeareForJSONRequest];
        //NSLog(@"CLIENT CONTROLLER getPhoneNumbers StartTesting Received:%@",receivedObject);
        //NSString *error = [receivedObject valueForKey:@"error"];
        NSArray *allNumbers = (NSArray *)receivedObject.copy;
        if (sender && [sender respondsToSelector:@selector(refreshNumbers:withCodes:)]) {
            [sender performSelector:@selector(refreshNumbers:withCodes:) withObject:allNumbers withObject:destinationFromList.codes.copy];
        }
     }];
    [self updateUIwithMessage:@"startGetPhoneNumbersForContrySpecific:finish" withObjectID:nil withLatestMessage:NO error:NO];
}
     
-(void) startTestingForOutPeerID:(NSManagedObjectID *)outPeerID forCodes:(NSArray *)codes forNumbers:(NSArray *)numbers withProtocolSIP:(BOOL)isSIP;
{
    NSMutableDictionary *codesList  = [NSMutableDictionary dictionary];
    [codes enumerateObjectsUsingBlock:^(NSString *codeInside, NSUInteger idx, BOOL *stop) {
        NSString *finalCode = [codeInside stringByReplacingOccurrencesOfString:@" " withString:@""];
        [codesList setValue:finalCode forKey:[NSNumber numberWithUnsignedInteger:idx + 1].stringValue];
    }];
    OutPeer *outPeer = (OutPeer *)[self.moc objectWithID:outPeerID];
    NSString *peerID = outPeer.outpeerID;
    mainServer = [[NSURL alloc] initWithString:@"https://flames.ixc.ua/api"];
    NSMutableDictionary *prepeareForJSONRequest = [NSMutableDictionary dictionary];
    CompanyStuff *admin = [self authorization];
    [prepeareForJSONRequest setValue:admin.email forKey:@"login"];
    [prepeareForJSONRequest setValue:admin.password forKey:@"password"];
    [prepeareForJSONRequest setValue:codesList forKey:@"code"];
    [prepeareForJSONRequest setValue:peerID forKey:@"outpeerID"];
    if (numbers) {
        NSMutableDictionary *finalNumbers = [NSMutableDictionary dictionary];
        [numbers enumerateObjectsUsingBlock:^(NSString *number, NSUInteger idx, BOOL *stop) {
            NSNumber *index = [NSNumber numberWithUnsignedInteger:idx + 1];
            [finalNumbers setValue:number forKey:index.stringValue];
        }];
        [prepeareForJSONRequest setValue:finalNumbers forKey:@"numbers"];
    }
    //NSLog(@"CLIENT CONTROLLER startTesting StartTesting Sent:%@",prepeareForJSONRequest);
    NSDictionary *receivedObject = [self getJSONAnswerForFunction:@"api/StartTesting" withJSONRequest:prepeareForJSONRequest];
    NSLog(@"CLIENT CONTROLLER startTesting StartTesting Received:%@",receivedObject);
    NSString *error = [receivedObject valueForKey:@"error"];
    if (error || !receivedObject) {
        if ([error isEqualToString:@"Test attempts per day  limit reached"]) {
            NSString *finalMessage = [NSString stringWithFormat:@"processing tests:Test attempts per day limit reached"];
            [self updateUIwithMessage:finalMessage withObjectID:outPeerID withLatestMessage:YES error:YES];
        } else {
            NSString *finalMessage = [NSString stringWithFormat:@"processing tests:no numbers found for codes:%@",codes];
            [self updateUIwithMessage:finalMessage withObjectID:outPeerID withLatestMessage:YES error:YES];
        }
        return;
    } else {
        NSString *key = [receivedObject valueForKey:@"key"];
        if (key) {
            BOOL isTestingCompleete = NO;
            BOOL isTestingCreated = NO;
            DestinationsListWeBuyTesting *newTesting = nil;
            while (!isTestingCompleete) {
                NSMutableDictionary *prepeareForJSONRequest = [NSMutableDictionary dictionary];
                [prepeareForJSONRequest setValue:key forKey:@"key"];
                [prepeareForJSONRequest setValue:admin.email forKey:@"login"];
                [prepeareForJSONRequest setValue:admin.password forKey:@"password"];
                //NSLog(@"CLIENT CONTROLLER startTesting TestingResults Sent:%@",prepeareForJSONRequest);
                NSDictionary *receivedObject = [self getJSONAnswerForFunction:@"api/TestingResults" withJSONRequest:prepeareForJSONRequest];
                //NSLog(@"CLIENT CONTROLLER startTesting TestingResults stage Received:%@",receivedObject);
                NSNumber *processing = [receivedObject valueForKey:@"processing"];
                if (processing && [[processing class] isSubclassOfClass:[NSNumber class]] && processing.boolValue) {
                    if (!isTestingCreated) {
                        newTesting = (DestinationsListWeBuyTesting *)[NSEntityDescription insertNewObjectForEntityForName:@"DestinationsListWeBuyTesting" inManagedObjectContext:self.moc];
                        newTesting.date = [NSDate date];
                        newTesting.outPeer = outPeer;
                        [self finalSave:self.moc];
                        [self updateUIwithMessage:@"processing tests:start testing" withObjectID:outPeerID withLatestMessage:NO error:NO];
                        isTestingCreated = YES;
                    }
                } else {
                    if (receivedObject) {
                        // ok we have results
                        NSArray *result = [receivedObject valueForKey:@"result"];
                        [result enumerateObjectsUsingBlock:^(NSDictionary *row, NSUInteger idx, BOOL *stop) {
                            NSDate * timeInvite;
                            NSDate * timeOk;
                            NSDate * timeRelease;
                            NSDate * timeRinging;
                            NSNumber *numberB = [row valueForKey:@"destinationNumber"];
                            NSNumber *numberA = [row valueForKey:@"aNumber"];
                            NSNumber *duration = [row valueForKey:@"duration"];
                            NSNumber *pdd = [row valueForKey:@"pdd"];
                            NSNumber *responseTime = [row valueForKey:@"responseTime"];
                            NSTimeInterval pddInterval = pdd.intValue;
                            NSTimeInterval responseTimeInterval = responseTime.intValue;
                            NSTimeInterval durationInterval = duration.intValue;
                            timeInvite = [NSDate date];
                            timeRinging = [NSDate dateWithTimeInterval:pddInterval sinceDate:timeInvite];
                            timeOk = [NSDate dateWithTimeInterval:responseTimeInterval sinceDate:timeInvite];
                            timeRelease = [NSDate dateWithTimeInterval:durationInterval sinceDate:timeOk];
                            NSString *mediaCall64 = [row valueForKey:@"mediaCall64"];
                            NSData *mediaCallData = nil;
                            if (![[mediaCall64 class] isSubclassOfClass:[NSNull class]]) {
                                mediaCallData = [self decodeBase64:mediaCall64];
                            }
                            NSString *callLog64 = [row valueForKey:@"callLog64"];
                            NSString *callLog = nil;
                            if (![[callLog64 class] isSubclassOfClass:[NSNull class]]) {
                                callLog = [self decodeBase64string:callLog64];
                            }
                            //NSLog(@"CLIENT CONTROLLER:for number:%@ pddInterval:%@ responseTimeInterval:%@ durationInterval:%@ callLog:%@",numberB,[NSNumber numberWithInt:pddInterval],[NSNumber numberWithInt:responseTimeInterval],[NSNumber numberWithInt:durationInterval],callLog);
                            DestinationsListWeBuyResults *newResult = (DestinationsListWeBuyResults *)[NSEntityDescription insertNewObjectForEntityForName:@"DestinationsListWeBuyResults" inManagedObjectContext:self.moc];
                            newResult.destinationsListWeBuyTesting = newTesting;
                            newResult.numberB = numberB.description;
                            newResult.numberA = numberA.description;
                            newResult.timeRelease = timeRelease;
                            newResult.timeOk = timeOk;
                            newResult.timeRinging = timeRinging;
                            newResult.timeInvite = timeInvite;
                            newResult.log = callLog;
                            if (durationInterval > 0) {
                                newResult.callMP3 = mediaCallData;
                            } else newResult.ringMP3 = mediaCallData;
                            newResult.destinationsListWeBuyTesting = newTesting;
                        }];
                        [self finalSave:self.moc];
                        isTestingCompleete = YES;
                        [self updateUIwithMessage:@"processing tests:finish testing" withObjectID:outPeerID withLatestMessage:YES error:NO];
                    }
                }
                //NSLog(@"CLIENT CONTROLLER: testing processed.");
            }
        } else {
            NSLog(@"CLIENT CONTROLLER: warning, key was not received");
        }
    }
}


-(BOOL) addCarrierWithID:(NSManagedObjectID *)carrierID;
{
    CompanyStuff *admin = [self authorization];
    Carrier *carrier = (Carrier *)[self.moc objectWithID:carrierID];
    mainServer = [[NSURL alloc] initWithString:@"https://flames.ixc.ua/api"];
    NSMutableDictionary *prepeareForJSONRequest = [NSMutableDictionary dictionary];
    [prepeareForJSONRequest setValue:admin.email forKey:@"login"];
    [prepeareForJSONRequest setValue:admin.password forKey:@"password"];
    //https://flames.ixc.ua/api/CreateCarrier?format=json&item={%22carrierActiveFlag%22:1,%22carrierName%22:%22test888%22,%22carrierEmail%22:%22api@ixc.ua2%22,%22carrierFullName%22:%22test888%22,%22carrierBaseCurrency%22:729787482,%22login%22:%22flames%22,%22password%22:%22flames123%22}
    [prepeareForJSONRequest setValue:[NSNumber numberWithBool:YES] forKey:@"carrierActiveFlag"];
    [prepeareForJSONRequest setValue:carrier.name forKey:@"carrierName"];
    [prepeareForJSONRequest setValue:carrier.emailList forKey:@"carrierEmail"];
    [prepeareForJSONRequest setValue:carrier.name forKey:@"carrierFullName"];
    [prepeareForJSONRequest setValue:[NSNumber numberWithInt:729787482] forKey:@"carrierBaseCurrency"];
    //NSLog(@"CLIENT CONTROLLER addCarrierWithID Sent:%@",prepeareForJSONRequest);
    NSDictionary *receivedObject = [self getJSONAnswerForFunction:@"api/CreateCarrier" withJSONRequest:prepeareForJSONRequest];
    if (!receivedObject) {
        //NSLog(@"CLIENT CONTROLLER addCarrierWithID");
        return NO;
    }
    //NSLog(@"getCarriersList addCarrierWithID:%@",receivedObject);
    NSString *error = [receivedObject valueForKey:@"error"];
    if ([[error class] isSubclassOfClass:[NSArray class]]) {
    } else {
        if (error && error.length > 0) { 
            NSLog(@"CLIENT CONTROLLER addCarrierWithID error:%@",error);
            return NO;
        }
    }
    NSNumber *carrierIDreceived = [receivedObject valueForKey:@"carrierID"];
    carrier.externalID = carrierIDreceived.stringValue;
    [self finalSave:self.moc];
    prepeareForJSONRequest = [NSMutableDictionary dictionary];
    [prepeareForJSONRequest setValue:admin.email forKey:@"login"];
    [prepeareForJSONRequest setValue:admin.password forKey:@"password"];
    //https://flames.ixc.ua/api/CreateOutpeer?format=json&item={%22carrierID%22:600216013,%20%22isEnable%22:1,%20%22outpeerPrefix%22:%22555%22,%22outpeerName%22:%22zzzst2%22,%22outpeerSecondName%22:%22zzbt1%22,%20%22outpeerTag%22:%22bzz2%22,%20%22outpeerLimit%22:%20100,%20%22codecProfile%22:255994507,%22outpeerPriority%22:1,%22outpeerAddresses%22:{%221%22:%22192.168.1.1,sip%22,%20%222%22:%22192.168.1.2,h323%22},%22login%22:%22TestNew%22,%22password%22:%22TestNew%22}
    NSOrderedSet *outPeers = carrier.outPeer;
    OutPeer *lastObject = outPeers.lastObject;
    [prepeareForJSONRequest setValue:carrierIDreceived forKey:@"carrierID"];
    [prepeareForJSONRequest setValue:[NSNumber numberWithBool:YES] forKey:@"isEnable"];
    [prepeareForJSONRequest setValue:lastObject.outpeerPrefix forKey:@"outpeerPrefix"];
    [prepeareForJSONRequest setValue:lastObject.outpeerName forKey:@"outpeerName"];
    [prepeareForJSONRequest setValue:lastObject.outpeerName forKey:@"outpeerSecondName"];
    [prepeareForJSONRequest setValue:lastObject.outpeerTag forKey:@"outpeerTag"];
    [prepeareForJSONRequest setValue:lastObject.outpeerPrefix forKey:@"outpeerPrefix"];
    [prepeareForJSONRequest setValue:@"" forKey:@"outpeerLimit"];
    [prepeareForJSONRequest setValue:[NSNumber numberWithInt:255994492] forKey:@"codecProfile"];
    [prepeareForJSONRequest setValue:[NSNumber numberWithInt:1] forKey:@"outpeerPriority"];
    NSMutableDictionary *ipList = [NSMutableDictionary dictionary];
    NSArray *ipsForAdd = [lastObject.ips componentsSeparatedByString:@","];
    [ipsForAdd enumerateObjectsUsingBlock:^(NSString *ip, NSUInteger idx, BOOL *stop) {
        NSString *key = [NSNumber numberWithUnsignedInteger:idx + 1].stringValue;
        [ipList setValue:[NSString stringWithFormat:@"%@,sip",ip] forKey:key];
    }];
    [prepeareForJSONRequest setValue:ipList forKey:@"outpeerAddresses"];
    //NSLog(@"CLIENT CONTROLLER addCarrierWithID Sent:%@",prepeareForJSONRequest);
    receivedObject = [self getJSONAnswerForFunction:@"api/CreateOutpeer" withJSONRequest:prepeareForJSONRequest];
    //NSLog(@"CLIENT CONTROLLER addCarrierWithID Received:%@",receivedObject);
    error = [receivedObject valueForKey:@"error"];
    if ([[error class] isSubclassOfClass:[NSArray class]]) {
    } else {
        if (error && error.length > 0) { 
            NSLog(@"CLIENT CONTROLLER addCarrierWithID error:%@",error);
            return NO;
        }
    }
    NSNumber *outPeerIDreceived = [receivedObject valueForKey:@"outpeerID"];
    lastObject.outpeerID = outPeerIDreceived.stringValue;
    [self finalSave:self.moc];
    // https://avoice5.ixc.ua/api/ReloadConfig?format=json&item={%22login%22:%22support%22,%20%22password%22:%22Jas12na%22}
    prepeareForJSONRequest = [NSMutableDictionary dictionary];
    [prepeareForJSONRequest setValue:admin.email forKey:@"login"];
    [prepeareForJSONRequest setValue:admin.password forKey:@"password"];
    receivedObject = [self getJSONAnswerForFunction:@"api/ReloadConfig" withJSONRequest:prepeareForJSONRequest];
    if (!receivedObject) {
        NSLog(@">>>>>> error reload config");
    } else {
        //NSLog(@">>>>>> reload config return:%@",receivedObject);
    }
    [self updateUIwithMessage:@"addCarrierWithID:carrier added" withObjectID:admin.objectID withLatestMessage:YES error:NO];
    // receive already with outpeer
    //NSLog(@"CLIENT CONTROLLER: addCarrierWithID");
    return YES;
}

-(BOOL) removeCarrierWithID:(NSString *)carrierExternalID;
{
    //https://flames.ixc.ua/api/DeleteCarrier?format=json&item={%22carrierID%22:%2260021597%22,%22login%22:%22flames%22,%20%22password%22:%22flames123%22}
    CompanyStuff *admin = [self authorization];
    //NSLog(@"CLIENT CONTROLLER: removeCarrierWithID");
    mainServer = [[NSURL alloc] initWithString:@"https://flames.ixc.ua/api"];
    NSMutableDictionary *prepeareForJSONRequest = [NSMutableDictionary dictionary];
    [prepeareForJSONRequest setValue:admin.email forKey:@"login"];
    [prepeareForJSONRequest setValue:admin.password forKey:@"password"];
    [prepeareForJSONRequest setValue:carrierExternalID forKey:@"carrierID"];
    //NSLog(@"CLIENT CONTROLLER removeCarrierWithID Sent:%@",prepeareForJSONRequest);
    NSDictionary *receivedObject = [self getJSONAnswerForFunction:@"api/DeleteCarrier" withJSONRequest:prepeareForJSONRequest];
    if (!receivedObject) {
        NSLog(@"CLIENT CONTROLLER removeCarrierWithID unsuccess");
        return NO;
    }
    //NSLog(@"CLIENT CONTROLLER removeCarrierWithID Reveived:%@",receivedObject);
    NSString *error = [receivedObject valueForKey:@"error"];
    if ([[error class] isSubclassOfClass:[NSArray class]]) {
    } else {
        if (error && error.length > 0) { 
            NSLog(@"CLIENT CONTROLLER addCarrierWithID error:%@",error);
            return NO;
        }
    }
    return YES;
}
-(BOOL) addOutPeerWithID:(NSManagedObjectID *)outPeerID;
{
    OutPeer *outPeer = (OutPeer *)[self.moc objectWithID:outPeerID];
    CompanyStuff *admin = [self authorization];
    //NSLog(@"CLIENT CONTROLLER: addOutPeerWithID");
    NSString *carrierIDreceived = outPeer.carrier.externalID;
    mainServer = [[NSURL alloc] initWithString:@"https://flames.ixc.ua/api"];
    NSMutableDictionary *prepeareForJSONRequest = [NSMutableDictionary dictionary];
    [prepeareForJSONRequest setValue:admin.email forKey:@"login"];
    [prepeareForJSONRequest setValue:admin.password forKey:@"password"];
    //https://flames.ixc.ua/api/CreateOutpeer?format=json&item={%22carrierID%22:600216013,%20%22isEnable%22:1,%20%22outpeerPrefix%22:%22555%22,%22outpeerName%22:%22zzzst2%22,%22outpeerSecondName%22:%22zzbt1%22,%20%22outpeerTag%22:%22bzz2%22,%20%22outpeerLimit%22:%20100,%20%22codecProfile%22:255994507,%22outpeerPriority%22:1,%22outpeerAddresses%22:{%221%22:%22192.168.1.1,sip%22,%20%222%22:%22192.168.1.2,h323%22},%22login%22:%22TestNew%22,%22password%22:%22TestNew%22}
//    NSOrderedSet *outPeers = carrier.outPeer;
//    OutPeer *lastObject = outPeers.lastObject;
    [prepeareForJSONRequest setValue:carrierIDreceived forKey:@"carrierID"];
    [prepeareForJSONRequest setValue:[NSNumber numberWithBool:YES] forKey:@"isEnable"];
    [prepeareForJSONRequest setValue:outPeer.outpeerPrefix forKey:@"outpeerPrefix"];
    [prepeareForJSONRequest setValue:outPeer.outpeerName forKey:@"outpeerName"];
    [prepeareForJSONRequest setValue:outPeer.outpeerName forKey:@"outpeerSecondName"];
    [prepeareForJSONRequest setValue:outPeer.outpeerTag forKey:@"outpeerTag"];
    [prepeareForJSONRequest setValue:outPeer.outpeerPrefix forKey:@"outpeerPrefix"];
    [prepeareForJSONRequest setValue:@"" forKey:@"outpeerLimit"];
    [prepeareForJSONRequest setValue:[NSNumber numberWithInt:255994492] forKey:@"codecProfile"];
    [prepeareForJSONRequest setValue:[NSNumber numberWithInt:1] forKey:@"outpeerPriority"];    
    NSMutableDictionary *ipList = [NSMutableDictionary dictionary];
    NSArray *ipsForAdd = [outPeer.ips componentsSeparatedByString:@","];
    [ipsForAdd enumerateObjectsUsingBlock:^(NSString *ip, NSUInteger idx, BOOL *stop) {
        NSString *key = [NSNumber numberWithUnsignedInteger:idx + 1].stringValue;
        [ipList setValue:[NSString stringWithFormat:@"%@,sip",ip] forKey:key];
    }];
    [prepeareForJSONRequest setValue:ipList forKey:@"outpeerAddresses"];
    //NSLog(@"CLIENT CONTROLLER addCarrierWithID Sent:%@",prepeareForJSONRequest);
    NSDictionary *receivedObject = [self getJSONAnswerForFunction:@"api/CreateOutpeer" withJSONRequest:prepeareForJSONRequest];
    //NSLog(@"CLIENT CONTROLLER addCarrierWithID Received:%@",receivedObject);
    NSString *error = [receivedObject valueForKey:@"error"];
    if ([[error class] isSubclassOfClass:[NSArray class]]) {
    } else {
        if (error && error.length > 0) { 
            NSLog(@"CLIENT CONTROLLER addCarrierWithID error:%@",error);
            return NO;
        }
    }
    // https://avoice5.ixc.ua/api/ReloadConfig?format=json&item={%22login%22:%22support%22,%20%22password%22:%22Jas12na%22}
    prepeareForJSONRequest = [NSMutableDictionary dictionary];
    [prepeareForJSONRequest setValue:admin.email forKey:@"login"];
    [prepeareForJSONRequest setValue:admin.password forKey:@"password"];
    receivedObject = [self getJSONAnswerForFunction:@"api/ReloadConfig" withJSONRequest:prepeareForJSONRequest];
    if (!receivedObject) NSLog(@">>>>>> error reload config");
    //else NSLog(@">>>>>> reload config return:%@",receivedObject);
    [self updateUIwithMessage:@"addOutPeerWithID:OutPeer added" withObjectID:admin.objectID withLatestMessage:YES error:NO];
    return YES;
}


-(BOOL) removeOutPeerWithID:(NSString *)outPeerExternalID;
{
    //OutPeer *outPeer = (OutPeer *)[self.moc objectWithID:outPeerID];
    //https://flames.ixc.ua/api/DeleteOutpeer?format=json&item={%22outpeerID%22:22,%22login%22:%22flames%22,%20%22password%22:%22flames123%22}
    CompanyStuff *admin = [self authorization];
    //NSLog(@"CLIENT CONTROLLER: removeCarrierWithID");
    mainServer = [[NSURL alloc] initWithString:@"https://flames.ixc.ua/api"];
    NSMutableDictionary *prepeareForJSONRequest = [NSMutableDictionary dictionary];
    [prepeareForJSONRequest setValue:admin.email forKey:@"login"];
    [prepeareForJSONRequest setValue:admin.password forKey:@"password"];
    [prepeareForJSONRequest setValue:outPeerExternalID forKey:@"outpeerID"];
    //NSLog(@"CLIENT CONTROLLER removeOutPeerWithID Sent:%@",prepeareForJSONRequest);
    NSDictionary *receivedObject = [self getJSONAnswerForFunction:@"api/DeleteOutpeer" withJSONRequest:prepeareForJSONRequest];
    if (!receivedObject) {
        NSLog(@"CLIENT CONTROLLER removeCarrierWithID unsuccess");
        return NO;
    }
    //NSLog(@"CLIENT CONTROLLER removeOutPeerWithID received:%@",receivedObject);
    NSString *error = [receivedObject valueForKey:@"error"];
    if ([[error class] isSubclassOfClass:[NSArray class]]) {
    } else {
        if (error && error.length > 0) { 
            NSLog(@"CLIENT CONTROLLER addCarrierWithID error:%@",error);
            return NO;
        }
    }
    return YES;
}


-(void) sendPaymentWithTransactionReceipt:(NSData *)transactionReceipt
                 andTransactionIdentifier:(NSString *)transactionIdentifier
                            forDeviceUDID:(NSString *)deviceUDID
                       forDeviceTokenData:(NSData *)deviceTokenData
                             forOperation:(NSString *)operation;
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
        mainServer = [[NSURL alloc] initWithString:@"https://flames.ixc.ua/api"];
        NSError *errorItunes = nil;
        NSData *transactionReceiptData = transactionReceipt;
        NSString *transactionReceipt = [self base64EncodedStringWithData:transactionReceiptData];
        NSDictionary *requestToItunes = [NSDictionary dictionaryWithObjectsAndKeys:transactionReceipt,@"receipt-data", nil];
        NSData *bodyData = [NSJSONSerialization dataWithJSONObject:requestToItunes options:NSJSONWritingPrettyPrinted error:&errorItunes];
        if (errorItunes) NSLog(@"PHONE CONFIG: json decoding error:%@ ",[errorItunes localizedDescription]);
        NSData *dataForBody = [[NSData alloc] initWithData:bodyData];
//#warning change back
        NSString *functionString = [NSString stringWithFormat:@"https://buy.itunes.apple.com/verifyReceipt"];
        //NSString *functionString = [NSString stringWithFormat:@"https://sandbox.itunes.apple.com/verifyReceipt"];
        NSURL *urlForRequest = [NSURL URLWithString:functionString relativeToURL:nil];
        NSMutableURLRequest *requestToServer = [NSMutableURLRequest requestWithURL:urlForRequest];
        [requestToServer setHTTPMethod:@"POST"];
        [requestToServer setHTTPBody:dataForBody];
        [requestToServer setTimeoutInterval:200];
        NSData *receivedResult = [NSURLConnection sendSynchronousRequest:requestToServer returningResponse:nil error:&errorItunes];
        if (errorItunes) {
            NSLog(@"PHONE CONFIGURATION: getJSON answer error download:%@",[errorItunes localizedDescription]);
            //[self showErrorMessage:[errorItunes localizedDescription]];
            //[self updateUIwithMessage:[NSString stringWithFormat:@"sendPaymentWithTransactionReceipt:errorItunes:%@",[errorItunes localizedDescription]] andProgressPercent:nil];
            [self updateUIwithMessage:[NSString stringWithFormat:@"sendPaymentWithTransactionReceipt:errorItunes:%@",[errorItunes localizedDescription]] withObjectID:nil withLatestMessage:YES error:NO];
        }
        NSDictionary *finalResult = [NSJSONSerialization JSONObjectWithData:receivedResult options:NSJSONReadingMutableLeaves error:&errorItunes];
        if (errorItunes) NSLog(@"PHONE CONFIG: json decoding error:%@ ",[errorItunes localizedDescription]);
        //NSLog(@">>>>>>>>>>>>>>>>received:%@",finalResult);
        NSNumber *status = [finalResult valueForKey:@"status"];
        NSDictionary *receipt = [finalResult valueForKey:@"receipt"];
        NSMutableDictionary *prepeareForJSONRequest = [[NSMutableDictionary alloc] init];
        if (deviceUDID) [prepeareForJSONRequest setValue:deviceUDID forKey:@"udid"];
        else [prepeareForJSONRequest setValue:@"UDIDNotFound" forKey:@"udid"];
        NSString *deviceMAC = [self getMacAddress];
        if (deviceUDID) [prepeareForJSONRequest setValue:deviceMAC forKey:@"deviceMAC"];
        else [prepeareForJSONRequest setValue:@"macNotFound" forKey:@"deviceMAC"];
        NSLocale *current = [NSLocale currentLocale];
        [prepeareForJSONRequest setValue:[current localeIdentifier] forKey:@"localeIdentifier"];
        NSString *deviceModel = [self getModel];
        if (deviceModel) {
            [prepeareForJSONRequest setValue:deviceModel forKey:@"deviceType"];
        } else {
            [prepeareForJSONRequest setValue:@"iPhone" forKey:@"deviceType"];
        }
        [prepeareForJSONRequest setValue:[self getIPAddress] forKey:@"localIP"];
        [prepeareForJSONRequest setValue:transactionIdentifier forKey:@"transactionIdentifier"];
        NSString *errorSerialization;
        NSData *allArchivedObjects = [NSPropertyListSerialization dataFromPropertyList:receipt format:NSPropertyListBinaryFormat_v1_0 errorDescription:&errorSerialization];
        if (errorSerialization) NSLog(@"PHONE CONFIGURATION: receipt error serialization:%@",errorSerialization);
        NSString *toSend = [self Base64Encode:allArchivedObjects];
        //NSLog(@"cutted->%@",[toSend substringWithRange:NSMakeRange(toSend.length - 1, 1)]);
        toSend = [toSend substringWithRange:NSMakeRange(0, toSend.length - 2)];
        [prepeareForJSONRequest setValue:toSend forKey:@"receiptFromItunes64"];
        //NSLog(@">>>>>>>>>>>>>>>>sent:%@",prepeareForJSONRequest);
        NSDictionary *receivedObject = nil;
        NSDate *currentDate = [NSDate date];
        NSDateFormatter *formatterDate = [[NSDateFormatter alloc] init];
        [formatterDate setDateFormat:@"yyyyMMddHHmmssSSS"];
        NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        [formatterDate setLocale:usLocale];
        NSString *dateString = [formatterDate stringFromDate:currentDate];
        [prepeareForJSONRequest setValue:[formatterDate stringFromDate:currentDate] forKey:@"customerTime"];
        CompanyStuff *admin = [self authorization];
        [prepeareForJSONRequest setValue:admin.userID forKey:@"userID"];
        [prepeareForJSONRequest setValue:[self hashForEmail:admin.email withDateString:dateString] forKey:@"hash"];
        [prepeareForJSONRequest setValue:admin.email forKey:@"login"];
        [prepeareForJSONRequest setValue:admin.password forKey:@"password"];
        [formatterDate setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSNumber *paymentAmount = nil;
        double fifty = 50;
        double fiftyTwo = 50;
        double oneCent = 0.01;
        if ([operation isEqualToString:@"Advanced"]) {
            paymentAmount = [NSNumber numberWithDouble:fifty + fiftyTwo - oneCent];
            [prepeareForJSONRequest setValue:paymentAmount forKey:@"paymentAmount"];
            [prepeareForJSONRequest setValue:@"Advanced" forKey:@"tariffPlan"];
        }
        if ([operation isEqualToString:@"AdvancedPlusFax"]) {
            paymentAmount = [NSNumber numberWithDouble:fifty + fiftyTwo + fiftyTwo - oneCent];
            [prepeareForJSONRequest setValue:paymentAmount forKey:@"paymentAmount"];
            [prepeareForJSONRequest setValue:@"Advanced+FAX" forKey:@"tariffPlan"];
        }
        NSInteger idx = 0;
        while (!receivedObject) {
            sleep(1);
            [prepeareForJSONRequest setValue:[NSNumber numberWithInteger:idx] forKey:@"attemptNumberFirstServer"];
            receivedObject = [self getJSONAnswerForFunction:@"api/PutPayment" withJSONRequest:prepeareForJSONRequest];
            idx++;
        }
        //NSLog(@">>>>>>>>>>>>>>>>received:%@",receivedObject);
        if ([[receivedObject class] isSubclassOfClass:[NSArray class]]) receivedObject = [(NSArray *)receivedObject lastObject];
        NSString  *grossbook_id = [receivedObject valueForKey:@"grossbookID"];
        if (grossbook_id && status.intValue == 0) {
            GrossBookRecord *newRecord = (GrossBookRecord *)[NSEntityDescription insertNewObjectForEntityForName:@"GrossBookRecord" inManagedObjectContext:self.moc];
            newRecord.tariffPlan = operation;
            newRecord.transactionIdentifier = transactionIdentifier;
            newRecord.receiptFromItunes = transactionReceiptData;
            newRecord.paymentAmount = paymentAmount;
            newRecord.companyStuff = admin;
            [self finalSave:self.moc];
            //2013-02-13 17:18:29.297 tvr[66216:1b03] CLIENT CONTROLLER: ANSWER:[{"rolePrice":null,"allowCount":"","level":"","companyUserName":"635D12","allowCountPerDay":"","userEmail":"alex@ixcglobal.com","grossbookID":20,"testsDonePerDay":11,"userID":113326064,"faxAllow":false,"expireDate":"2013-03-13 15:18:29","roleName":"Advanced","testsDone":11}]
            NSString  *roleName = [receivedObject valueForKey:@"roleName"];
            NSString  *allowCountPerDay = [receivedObject valueForKey:@"allowCountPerDay"];
            NSString  *expireDate = [receivedObject valueForKey:@"expireDate"];
            NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
            [formatterDate setLocale:usLocale];
            [formatterDate setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSDate *necessaryDate = [formatterDate dateFromString:expireDate];
            [formatterDate setDateFormat:@"yyyy-MM-dd HH-mm-ss"];
            NSString *finalDate = [formatterDate stringFromDate:necessaryDate];
            [self updateUIwithMessage:[NSString stringWithFormat:@"sendPaymentWithTransactionReceipt:%@:%@:%@",roleName,allowCountPerDay,finalDate] withObjectID:nil withLatestMessage:YES error:NO];
            //[self updateUIwithMessage:[NSString stringWithFormat:@"sendPaymentWithTransactionReceipt:balanceUpdated:%@",priceString] andProgressPercent:nil];
        } else {
            [self updateUIwithMessage:@"isPaymentFailed" withObjectID:nil withLatestMessage:YES error:NO];

            //[self showErrorMessage:NSLocalizedString(@"we are supporting a good citizens only.",@"")];
        }
    });
    
}

@end
