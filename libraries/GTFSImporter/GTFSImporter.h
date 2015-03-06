//
//  CSVImporter.h
//  San Jose Transit GTFS
//
//  Created by Vashishtha Jogi on 8/27/11.
//  Copyright 2011 Vashishtha Jogi Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GTFSImporter : NSObject

- (NSString *)parseForFile:(NSString *)file;
- (int) addAgency;
- (int) addCalendar;
- (int) addCalendarDate;
- (int) addFareAttributes;
- (int) addFareRules;
- (int) addRoute;
- (int) addShape;
- (int) addStop;
- (int) addStopRoutes;
- (int) addStopTime;
- (int) addTrip;
- (void) vacuum;
- (void) reindex;


@end
