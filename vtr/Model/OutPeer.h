//
//  OutPeer.h
//  tvr
//
//  Created by Oleksii Vynogradov on 7/4/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Carrier, DestinationsListWeBuyTesting;

@interface OutPeer : NSManagedObject

@property (nonatomic, retain) NSString * outpeerID;
@property (nonatomic, retain) NSString * outpeerName;
@property (nonatomic, retain) NSNumber * isEnable;
@property (nonatomic, retain) NSString * outpeerPrefix;
@property (nonatomic, retain) NSString * outpeerSecondName;
@property (nonatomic, retain) NSString * outpeerTag;
@property (nonatomic, retain) NSString * guid;
@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSDate * modificationDate;
@property (nonatomic, retain) NSString * ips;
@property (nonatomic, retain) Carrier *carrier;
@property (nonatomic, retain) NSOrderedSet *destinationsListWeBuyTesting;
@end

@interface OutPeer (CoreDataGeneratedAccessors)

- (void)insertObject:(DestinationsListWeBuyTesting *)value inDestinationsListWeBuyTestingAtIndex:(NSUInteger)idx;
- (void)removeObjectFromDestinationsListWeBuyTestingAtIndex:(NSUInteger)idx;
- (void)insertDestinationsListWeBuyTesting:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeDestinationsListWeBuyTestingAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInDestinationsListWeBuyTestingAtIndex:(NSUInteger)idx withObject:(DestinationsListWeBuyTesting *)value;
- (void)replaceDestinationsListWeBuyTestingAtIndexes:(NSIndexSet *)indexes withDestinationsListWeBuyTesting:(NSArray *)values;
- (void)addDestinationsListWeBuyTestingObject:(DestinationsListWeBuyTesting *)value;
- (void)removeDestinationsListWeBuyTestingObject:(DestinationsListWeBuyTesting *)value;
- (void)addDestinationsListWeBuyTesting:(NSOrderedSet *)values;
- (void)removeDestinationsListWeBuyTesting:(NSOrderedSet *)values;
@end
