//
//  AboutViewController.h
//  marguerite
//
//  Created by Kevin Conley on 7/26/13.
//  Copyright (c) 2013 Stanford Devs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STAN_MARG_AboutViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITextField *feedbackField;

@end
