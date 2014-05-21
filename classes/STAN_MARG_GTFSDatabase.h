//
//  GTFSDatabase.h
//  marguerite
//
//  Created by Kevin Conley on 7/21/13.
//  Copyright (c) 2013 Cardinal Devs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@protocol STAN_MARG_GTFSDatabaseCreationProgressDelegate <NSObject>

- (void) updatingStepNumber:(NSInteger)currentStep outOfTotalSteps:(NSInteger)totalSteps currentStepLabel:(NSString*)stepDesc;

@end

@interface STAN_MARG_GTFSDatabase : FMDatabase

+ (STAN_MARG_GTFSDatabase *) open;
+ (BOOL) create:(NSObject<STAN_MARG_GTFSDatabaseCreationProgressDelegate>*)creationProgressDelegate;
+ (BOOL) activateNewAutoUpdateBuildIfAvailable;
+ (NSString *) getNewAutoUpdateDatabaseBuildPath;

@end
