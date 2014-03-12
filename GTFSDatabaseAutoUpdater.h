//
//  GTFSDatabaseAutoUpdater.h
//  marguerite
//
//

#import <Foundation/Foundation.h>

@interface GTFSDatabaseAutoUpdater : NSObject

- (void) startAutoUpdate;
- (void) cancelAutoUpdate;
+ (NSString*) fullPathToLocalTransitUnzipDir;

@end
