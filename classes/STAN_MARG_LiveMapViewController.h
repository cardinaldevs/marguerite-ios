//
//  LiveMapViewController.h
//  marguerite
//
//  Created by Kevin Conley on 7/16/13.
//  Copyright (c) 2013 Cardinal Devs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STAN_MARG_RealtimeBuses.h"
#import "STAN_MARG_MRoutePolyline.h"
#import <GoogleMaps/GoogleMaps.h>
#import "GCDiscreetNotificationView.h"
#import "STAN_MARG_MStop.h"

@interface STAN_MARG_LiveMapViewController : UIViewController <GMSMapViewDelegate> {
    STAN_MARG_RealtimeBuses *buses;
    NSMutableDictionary *stopMarkers;
    NSMutableDictionary *busMarkers;
    NSTimer *timer;
    STAN_MARG_MRoutePolyline *routePolyline;
    BOOL noBusesRunning;
    BOOL busLoadError;
}

@property (weak, nonatomic) GMSMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *stanfordButton;
@property (strong, nonatomic) GCDiscreetNotificationView *HUD;
@property (strong, nonatomic) STAN_MARG_MStop *stopToZoomTo;

- (IBAction)zoomToCampus:(id)sender;
- (void)zoomToStop:(STAN_MARG_MStop *)stop;

@end
