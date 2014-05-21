//
//  Shape.m
//
//  Created by Kevin Conley on 6/25/2013.
//

#import "STAN_MARG_Shape.h"
#import "STAN_MARG_CSVParser.h"
#import "FMDatabase.h"
#import "STAN_MARG_GTFSDatabase.h"

@interface STAN_MARG_Shape ()
{
    FMDatabase *db;
}

@end

@implementation STAN_MARG_Shape

- (id)initWithDB:(FMDatabase *)fmdb
{
    self = [super init];
	if (self)
	{
		db = fmdb;
	}
	return self;
}

- (void)addShape:(STAN_MARG_Shape *)shape
{
    if (db==nil) {
        db = [FMDatabase databaseWithPath:[STAN_MARG_GTFSDatabase getNewAutoUpdateDatabaseBuildPath]];
        if (![db open]) {
            NSLog(@"Could not open db.");
            return;
        }
    }
    
    [db executeUpdate:@"INSERT into shape(shape_id,shape_pt_lat,shape_pt_lon,shape_pt_sequence,shape_dist_traveled) values(?, ?, ?, ?, ?)",
     shape.shapeId,
     shape.shapePtLat,
     shape.shapePtLon,
     shape.shapePtSequence,
     shape.shapeDistTraveled];
    
    if ([db hadError]) {
        NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        return;
    }
    
}

- (void)cleanupAndCreate
{
    if (db==nil) {
        db = [FMDatabase databaseWithPath:[STAN_MARG_GTFSDatabase getNewAutoUpdateDatabaseBuildPath]];
        if (![db open]) {
            NSLog(@"Could not open db.");
            return;
        }
    }
    
    //Drop table if it exists
    NSString *dropShape = @"DROP TABLE IF EXISTS shape";
    
    [db executeUpdate:dropShape];
    
    if ([db hadError]) {
        NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        return;
    }
    
    //Create table
    NSString *createShape = @"CREATE TABLE 'shape' ('shape_id' varchar(20) NOT NULL, 'shape_pt_lat' varchar(30) NOT NULL, 'shape_pt_lon' varchar(30) NOT NULL, 'shape_pt_sequence' varchar(30) NOT NULL, 'shape_dist_traveled' varchar(30) DEFAULT NULL)";
    
    NSString *createIndex = @"CREATE INDEX shape_id_shape ON shape(shape_id)";
    
    [db executeUpdate:createShape];
    [db executeUpdate:createIndex];
    
    if ([db hadError]) {
        NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        return;
    }
}

- (void)receiveRecord:(NSDictionary *)aRecord
{
    
    STAN_MARG_Shape *shapeRecord = [[STAN_MARG_Shape alloc] init];
    shapeRecord.shapeId = aRecord[@"shape_id"];
    shapeRecord.shapePtLat = aRecord[@"shape_pt_lat"];
    shapeRecord.shapePtLon = aRecord[@"shape_pt_lon"];
    shapeRecord.shapePtSequence = aRecord[@"shape_pt_sequence"];
    shapeRecord.shapeDistTraveled = aRecord[@"shape_dist_traveled"];
    
    [self addShape:shapeRecord];
}



@end
