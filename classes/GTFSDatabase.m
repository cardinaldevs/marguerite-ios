//
//  GTFSDatabase.m
//  marguerite
//
//  Created by Kevin Conley on 7/21/13.
//  Copyright (c) 2013 Cardinal Devs. All rights reserved.
//

#import "GTFSDatabase.h"
#import "CSVImporter.h"

@interface GTFSDatabase()

+ (BOOL) existsAutoUpdateBuild;
+ (BOOL) existsNewAutoUpdateBuild;
+ (BOOL) copyNewAutoUpdateDatabaseBuild;
+ (BOOL) deleteNewAutoUpdateBuild;
+ (BOOL) isNewAutoUpdateDatabaseBuildInProgress;

@end

@implementation GTFSDatabase

BOOL static __isNewAutoUpdateTempDatabaseBuildInProgress;

+ (BOOL) isNewAutoUpdateDatabaseBuildInProgress {
    return __isNewAutoUpdateTempDatabaseBuildInProgress;
}

/* 
 Open the GTFS database and return a reference to it.
 */
+ (GTFSDatabase *) open
{
    GTFSDatabase *db = nil;
    NSString* databasePath = [self existsAutoUpdateBuild]?[self getAutoUpdatedDatabasePath]:[self getResourcePath];
    if ((db = [self databaseWithPath:databasePath])) {
        [db setShouldCacheStatements:YES];
        if (![db open]) {
            NSLog(@"Could not open GTFS db.");
            return nil;
        }
    }
    return db;
}

+ (void) activateNewAutoUpdateBuildIfAvailable {
    if (![self isNewAutoUpdateDatabaseBuildInProgress]&&[self existsNewAutoUpdateBuild]) {
        [self copyNewAutoUpdateDatabaseBuild];
        [self deleteNewAutoUpdateBuild];
    }
}

/*
 Uses GTFS text files to create an sqlite3 database in the Caches directory.
 Returns YES if gtfs.db exists in Caches directory afterwards, NO otherwise.
 */
+ (BOOL) create
{
    if (![self deleteNewAutoUpdateBuild]) {
        return NO;
    }
    
    __isNewAutoUpdateTempDatabaseBuildInProgress = YES;
    
    CSVImporter *importer = [[CSVImporter alloc] init];
    
    NSLog(@"Importing Agency...");
    [importer addAgency];
    
    NSLog(@"Importing Calendar Dates...");
    [importer addCalendarDate];
    
    NSLog(@"Importing Routes...");
    [importer addRoute];
    
    NSLog(@"Importing Shapes...");
    [importer addShape];
    
    NSLog(@"Importing Stops...");
    [importer addStop];
    
    NSLog(@"Importing Trips...");
    [importer addTrip];
    
    NSLog(@"Importing StopTime...");
    [importer addStopTime];
    
    NSLog(@"Vacumming...");
    [importer vacuum];
    
    NSLog(@"Reindexing...");
    [importer reindex];
    
    //For convinience. This will add an extra column 'routes' which will contain comma seperated route numbers passing through this stop
    NSLog(@"Adding routes to stops...");
    [importer addStopRoutes];
    
    NSLog(@"Vacumming...");
    [importer vacuum];
    
    NSLog(@"Reindexing...");
    [importer reindex];
    
    __isNewAutoUpdateTempDatabaseBuildInProgress = NO;
    
    NSLog(@"Import complete!");
    
    BOOL dbExists = [self existsNewAutoUpdateBuild];
    
    NSLog(@"DB file exists: %s", dbExists ? "true" : "false");
    
    return dbExists;
}

/*
 Returns YES if gtfs.db in Caches directory was deleted (or didn't exist), NO otherwise.
 */
+ (BOOL) deleteAutoUpdateBuild {
    NSError* error;
    if ([self existsAutoUpdateBuild]) {
        @try {
            [[NSFileManager defaultManager] removeItemAtPath:[self getAutoUpdatedDatabasePath] error:&error];
        }
        @catch (NSException *exception) {
            NSLog(@"delete - Exception: %@", [exception reason]);
            return NO;
        }
        @finally {
            if (error) {
                NSString *messageString = [error localizedDescription];
                messageString = [NSString stringWithFormat:@"%@", messageString];
                NSLog(@"delete - Error: %@", messageString);
                return NO;
            }
        }
    }
    return YES;
}

+ (BOOL) deleteNewAutoUpdateBuild {
    NSError* error;
    if ([self existsNewAutoUpdateBuild]) {
        @try {
            [[NSFileManager defaultManager] removeItemAtPath:[self getNewAutoUpdateDatabaseBuildPath] error:&error];
        }
        @catch (NSException *exception) {
            NSLog(@"delete - Exception: %@", [exception reason]);
            return NO;
        }
        @finally {
            if (error) {
                NSString *messageString = [error localizedDescription];
                messageString = [NSString stringWithFormat:@"%@", messageString];
                NSLog(@"delete - Error: %@", messageString);
                return NO;
            }
        }
    }
    return YES;
}

/*
 Returns YES if gtfs.db exists in app bundle, NO otherwise.
 */
+ (BOOL) existsAutoUpdateBuild
{
    return [[NSFileManager defaultManager] fileExistsAtPath:[self getAutoUpdatedDatabasePath]];
}

+ (BOOL) existsNewAutoUpdateBuild
{
    return [[NSFileManager defaultManager] fileExistsAtPath:[self getNewAutoUpdateDatabaseBuildPath]];
}
/*
 Copy the gfts.db file from the Resources folder (bundled with the app) to the Caches directory (/Library/Caches).
 Returns YES if file was copied, returns NO otherwise.
 */
+ (BOOL) copyNewAutoUpdateDatabaseBuild
{
    NSString *dest = [self getAutoUpdatedDatabasePath];
    NSError* error;
    NSString* src = [self getNewAutoUpdateDatabaseBuildPath];

    if (![self existsNewAutoUpdateBuild]) {
        NSLog(@"copyNewAutoUpdateDatabaseToAutoUpdate - GTFS auto update db not available.");
        return NO;
    }
    
    [self deleteAutoUpdateBuild];
    
    @try {
        [[NSFileManager defaultManager] copyItemAtPath:src toPath:dest error:&error];
    }
    @catch (NSException *exception) {
        NSLog(@"copyDatabaseToCacheIfNeeded - Exception: %@", [exception reason]);
    }
    if (error) {
        NSString *messageString = [error localizedDescription];
        messageString = [NSString stringWithFormat:@"%@", messageString];
        NSLog(@"copyDatabaseToCacheIfNeeded - Error: %@", messageString);
        return NO;
    }
    return YES;
}

+ (NSString *) getNewAutoUpdateDatabaseBuildPath {
     NSString* pathToDocumentsDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return [pathToDocumentsDirectory stringByAppendingPathComponent:@"gtfs_auto_update_build.db"];
}

/*
 The path where the GTFS database exists in the Resources folder (bundled with the app).
 */
+ (NSString *) getResourcePath
{
    return [[NSBundle mainBundle] pathForResource:@"gtfs" ofType:@"db"];
}

/*
 The path where the GTFS database exists in the Resources folder (bundled with the app).
 */
+ (NSString *) getAutoUpdatedDatabasePath
{
    NSString* pathToDocumentsDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return [pathToDocumentsDirectory stringByAppendingPathComponent:@"gtfs.db"];
}

@end
