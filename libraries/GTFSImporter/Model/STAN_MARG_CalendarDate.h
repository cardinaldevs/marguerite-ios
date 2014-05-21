//
//  CalendarDate.h
//
//  Created by Kevin Conley on 6/25/2013.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"


@interface STAN_MARG_CalendarDate : NSObject

@property (nonatomic, strong) NSString * serviceId;
@property (nonatomic, strong) NSString * date;
@property (nonatomic, strong) NSString * exceptionType;

- (id)initWithDB:(FMDatabase *)fmdb;
- (void)addCalendarDate:(STAN_MARG_CalendarDate *)calendarDate;
- (void)cleanupAndCreate;
- (void)receiveRecord:(NSDictionary *)aRecord;

@end
