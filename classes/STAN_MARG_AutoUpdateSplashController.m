//
//  AutoUpdateSplashController.m
//  marguerite
//
//  Created by Hypnotoad on 4/22/14.
//  Copyright (c) 2014 Cardinal Devs. All rights reserved.
//

#import "STAN_MARG_AutoUpdateSplashController.h"
#import "STAN_MARG_GTFSUnarchiver.h"
#import "STAN_MARG_secrets.h"
#import "STAN_MARG_GTFSDatabase.h"
#import "AppDelegate.h"
#import "STAN_MARG_DataDownloader.h"
#import "STAN_MARG_Constants.h"

@interface STAN_MARG_AutoUpdateSplashController ()<STAN_MARG_GTFSDatabaseCreationProgressDelegate, STAN_MARG_DataDownloadDone>

@property (strong, nonatomic) STAN_MARG_GTFSUnarchiver* gtfsUpdater;
@property (strong, nonatomic) STAN_MARG_DataDownloader* dataDownloader;

@end

@implementation STAN_MARG_AutoUpdateSplashController

@synthesize gtfsUpdater;
@synthesize dataDownloader;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.gtfsUpdater = [[STAN_MARG_GTFSUnarchiver alloc] init];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self startUpdate];
}

- (void) viewWillDisappear:(BOOL)animated {
    [dataDownloader cancelDownload];
    [super viewWillDisappear:animated];
}

- (void) startUpdate {
    self.progressView.progress = 0.0;
    [self.spinner startAnimating];
    NSString* localTransitZipFileFullPath = [STAN_MARG_GTFSUnarchiver fullPathToDownloadedTransitZippedFile];
    self.dataDownloader = [[STAN_MARG_DataDownloader alloc] initWithURL:[NSURL URLWithString:MARGUERITE_TRANSIT_DATA_URL] localPath:localTransitZipFileFullPath downloadDelegate:self];
    [dataDownloader startDownload];
}

#pragma mark data download done delegate

- (void) dataDownloadDone:(NSData*)data {
    NSLog(@"updatedData downloaded");
    _currentActionLabel.text = @"Updating GTFS database";
    _mainStatusLabel.text = @"Updating schedule data...";
    dispatch_queue_t dbUpdateQ = dispatch_queue_create("GTFS DB UPDATE", NULL);
    dispatch_async(dbUpdateQ, ^ {
        BOOL updateSuccess = [gtfsUpdater unzipTransitZipFile] && [STAN_MARG_GTFSDatabase create:self];
        BOOL activateSuccess = [STAN_MARG_GTFSDatabase activateNewAutoUpdateBuildIfAvailable];
        dispatch_async(dispatch_get_main_queue(), ^ {
            if (updateSuccess && activateSuccess) {
                NSDate * date = [dataDownloader getFileModifiedDate];
                [[NSUserDefaults standardUserDefaults] setObject:date forKey:GTFS_DB_LAST_UPDATE_DATE_KEY];
                [self finishedAutoUpdate];
            } else {
                [self showErrorAlert:@"Error updating and activating data. Will retry next launch."];
            }
        });
    });
}

- (void) cachedDataDownloadDone:(NSData*)data {
    NSLog(@"cachedData downloaded");
    [self finishedAutoUpdate];
}

- (void) dataDownloadFailed:(NSError*)error {
    NSLog(@"Error attempting download : %@",[error localizedDescription]);
    [self finishedAutoUpdate];
}

#pragma mark alert view delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self finishedAutoUpdate];
}

#pragma mark updater delegate

- (void) updatingStepNumber:(NSInteger)currentStep outOfTotalSteps:(NSInteger)totalSteps currentStepLabel:(NSString*)stepDesc {
    dispatch_async(dispatch_get_main_queue(), ^ {
        self.currentActionLabel.text = stepDesc;
        self.progressView.progress = (float)currentStep / (float)totalSteps;
        if (currentStep==totalSteps) {
            [self.spinner stopAnimating];
        }
    });
}

#pragma mark private methods

- (void) showErrorAlert:(NSString*)errorMsg {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (void) finishedAutoUpdate {
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    appDelegate.autoUpdateInProgress = NO;
    [self dismissViewControllerAnimated:NO completion:nil];
}

@end
