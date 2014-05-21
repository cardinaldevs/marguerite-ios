//
//  MRoutePolyline.h
//  marguerite
//
//  Created by Kevin Conley on 8/26/13.
//  Copyright (c) 2013 Cardinal Devs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <GoogleMaps/GoogleMaps.h>
#import "STAN_MARG_MRoute.h"

@interface STAN_MARG_MRoutePolyline : GMSPolyline

- (id) initWithRoute:(STAN_MARG_MRoute *) route;

@end
