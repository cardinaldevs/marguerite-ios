//
//  NextBusViewController.h
//  marguerite
//
//  Created by Kevin Conley on 6/24/13.
//  Copyright (c) 2013 Cardinal Devs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STAN_MARG_CoreLocationController.h"

@interface STAN_MARG_NextShuttleViewController : UITableViewController <STAN_MARG_CoreLocationControllerDelegate, UITableViewDelegate, UITableViewDataSource, UISearchDisplayDelegate> {
    STAN_MARG_CoreLocationController *CLController;
    NSArray *closestStops;
    NSArray *favoriteStops;
    NSArray *allStops;
    NSArray *searchResults;
}

@end
