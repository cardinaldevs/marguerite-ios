//
//  MBus.m
//  marguerite
//
//  Created by Kevin Conley on 7/22/13.
//  Copyright (c) 2013 Cardinal Devs. All rights reserved.
//

#import "STAN_MARG_MRealtimeBus.h"
#import "STAN_MARG_MRoute.h"
#import <CoreLocation/CoreLocation.h>

@implementation STAN_MARG_MRealtimeBus

/*
 Create a "real-time" MBus object by looking up the route in the GTFS database. Returns nil if 
 the route does not exist.
 */
- (id) initWithVehicleId:(NSString *) vid andRouteId:(NSString *)route_id andLocation:(CLLocation *)loc
{
    if (self = [super init]) {
        self.vehicleId = vid;
        self.route = [[STAN_MARG_MRoute alloc] initWithRouteIdString:route_id];
        if (self.route == nil) {
            return nil;
        }
        self.location = loc;
    }
    return self;
}

@end
