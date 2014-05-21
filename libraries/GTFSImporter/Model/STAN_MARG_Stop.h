//
//  Stop.h
//  GTFS-VTA
//
//  Created by Vashishtha Jogi on 7/31/11.
//  Copyright (c) 2011 Vashishtha Jogi Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import <CoreLocation/CoreLocation.h>

@interface STAN_MARG_Stop : NSObject

@property (nonatomic, strong) NSNumber * stopLat;
@property (nonatomic, strong) NSNumber * stopLon;
@property (nonatomic, strong) NSString * stopId;
@property (nonatomic, strong) NSString * stopName;
@property (nonatomic, strong) NSString * stopDesc;
@property (nonatomic, strong) NSNumber * locationType;
@property (nonatomic, strong) NSString * zoneId;
@property (nonatomic, strong) NSArray  * routes;

- (void)addStop:(STAN_MARG_Stop *)stop;
- (id)initWithDB:(FMDatabase *)fmdb;
- (void)cleanupAndCreate;
- (void)receiveRecord:(NSDictionary *)aRecord;
- (void)updateStopWithRoutes:(NSArray *)routes withStopId:(NSString *)stopId;
- (void)updateRoutes;
+ (NSArray *)getAllStops;

@end
