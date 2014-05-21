//
//  StopViewController.h
//  marguerite
//
//  Created by Kevin Conley on 7/10/13.
//  Copyright (c) 2013 Cardinal Devs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STAN_MARG_MStop.h"

@interface STAN_MARG_StopViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) STAN_MARG_MStop *stop;
@property BOOL isFavoriteStop;
@property (strong, nonatomic) NSArray *nextBuses;

@end
