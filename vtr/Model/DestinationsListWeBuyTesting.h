//
//  DestinationsListWeBuyTesting.h
//  tvr
//
//  Created by Oleksii Vynogradov on 7/2/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DestinationsListWeBuy, DestinationsListWeBuyResults, OutPeer;

@interface DestinationsListWeBuyTesting : NSManagedObject

@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * dstnums;
@property (nonatomic, retain) NSString * GUID;
@property (nonatomic, retain) NSNumber * iD;
@property (nonatomic, retain) NSDate * modificationDate;
@property (nonatomic, retain) NSNumber * peerId;
@property (nonatomic, retain) DestinationsListWeBuy *destinationsListWeBuy;
@property (nonatomic, retain) NSSet *destinationsListWeBuyResults;
@property (nonatomic, retain) OutPeer *outPeer;
@end

@interface DestinationsListWeBuyTesting (CoreDataGeneratedAccessors)

- (void)addDestinationsListWeBuyResultsObject:(DestinationsListWeBuyResults *)value;
- (void)removeDestinationsListWeBuyResultsObject:(DestinationsListWeBuyResults *)value;
- (void)addDestinationsListWeBuyResults:(NSSet *)values;
- (void)removeDestinationsListWeBuyResults:(NSSet *)values;

@end
