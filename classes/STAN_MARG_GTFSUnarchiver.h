//
//  GTFSDatabaseAutoUpdater.h
//  marguerite
//
//

#import <Foundation/Foundation.h>

@interface STAN_MARG_GTFSUnarchiver : NSObject

- (BOOL) unzipTransitZipFile;
+ (NSString*) fullPathToDownloadedTransitUnzipDir;
+ (NSString*) fullPathToDownloadedTransitZippedFile;

@end
