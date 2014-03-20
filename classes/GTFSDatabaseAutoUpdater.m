//
//  GTFSDatabaseAutoUpdater.m
//  marguerite
//
//

#import "GTFSDatabaseAutoUpdater.h"
#import <AFHTTPFileUpdateOperation/AFHTTPFileUpdateOperation.h>
#import <SSZipArchive.h>
#import "secrets.h"
#import "GTFSDatabase.h"
#import "Util.h"

NSString* const TRANSIT_ZIP_FILE_NAME = @"transit.zip";
NSString* const TRANSIT_UNZIP_TO_DIR = @"TransitFilesUnzipped";

@interface GTFSDatabaseAutoUpdater()

@property (strong, nonatomic) AFHTTPFileUpdateOperation* fileUpdateOp;

@end

@implementation GTFSDatabaseAutoUpdater

@synthesize fileUpdateOp;

#pragma mark public methods

- (void) startAutoUpdate {
    NSString* localTransitZipFileFullPath = [self fullPathToLocalTransitZippedFile];
    NSURLRequest* transitFileRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:MARGUERITE_TRANSIT_DATA_URL]];
    //this downloader only downloads the zip of the file has been updated on the server. otherwise uses a local downloaded copy.
    self.fileUpdateOp = [[AFHTTPFileUpdateOperation alloc] initWithRequest:transitFileRequest localPath:localTransitZipFileFullPath];
    GTFSDatabaseAutoUpdater* autoUpdater = self;
    [fileUpdateOp setCompletionBlockWithSuccess:^(AFHTTPFileUpdateOperation *operation, NSData *data) {
        //parse asynchronously as it is time consuming and will block the app otherwise
        void(^completionBlock) (void) = ^{
            NSLog(@"Transit file downloaded successfully!");
            BOOL unzipSuccess = [autoUpdater unzipTransitZipFile];
            if (unzipSuccess) {
                [GTFSDatabase create];
            }};
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),completionBlock);
    } failure:^(AFHTTPFileUpdateOperation *operation, NSError *error) {
        NSLog(@"Transit data zip download failed with error:%@!",[error localizedDescription]);
    }];
    [fileUpdateOp start];
}

- (void) cancelAutoUpdate {
    [fileUpdateOp cancel];
}

+ (NSString*) fullPathToLocalTransitUnzipDir {
    NSString* documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* localTransitUnzipDirFullPath = [documentsDirectoryPath stringByAppendingPathComponent:TRANSIT_UNZIP_TO_DIR];
    return localTransitUnzipDirFullPath;
}

#pragma mark private methods

- (BOOL) unzipTransitZipFile {
    //first clean all previously unzipped files
    NSString* unzipDirFullPath = [GTFSDatabaseAutoUpdater fullPathToLocalTransitUnzipDir];
    if ([self deleteAndRecreateUnzipDir:unzipDirFullPath]) {
        NSString* zipFileFullPath = [self fullPathToLocalTransitZippedFile];
        NSError* error;
        BOOL unzipSuccess = [SSZipArchive unzipFileAtPath:zipFileFullPath toDestination:unzipDirFullPath overwrite:YES password:nil error:&error];
//        [self logUnzippedDirContents];
        NSLog(@"Unzip result : %@. %@",unzipSuccess?@"success":@"fail", unzipSuccess?@"":[error localizedDescription]);
        return unzipSuccess;
    }
    return NO;
}

- (BOOL) deleteAndRecreateUnzipDir:(NSString*)unzipDirFullPath {
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSError* error;
    if ([fileManager fileExistsAtPath:unzipDirFullPath]) {
        BOOL dirCleanSuccess = [fileManager removeItemAtPath:unzipDirFullPath error:&error];
        NSLog(@"Deleting unzip dir result : %@. %@",dirCleanSuccess?@"success":@"fail", dirCleanSuccess?@"":[error localizedDescription]);
        if (dirCleanSuccess) {
            BOOL dirCreateSuccess = [[NSFileManager defaultManager] createDirectoryAtPath:unzipDirFullPath withIntermediateDirectories:YES attributes:Nil error:&error];
            NSLog(@"Creating unzip dir result : %@. %@",dirCreateSuccess?@"success":@"fail", dirCreateSuccess?@"":[error localizedDescription]);
        }
        return dirCleanSuccess;
    }
    return YES;
}

- (NSString*) fullPathToLocalTransitZippedFile {
    NSString* documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* localTransitZipFileFullPath = [documentsDirectoryPath stringByAppendingPathComponent:TRANSIT_ZIP_FILE_NAME];
    return localTransitZipFileFullPath;
}


- (void) logUnzippedDirContents {
    NSString* localTransitZipFileUnzipDirFullPath = [GTFSDatabaseAutoUpdater fullPathToLocalTransitUnzipDir];
    NSError* error;
    NSArray* contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:localTransitZipFileUnzipDirFullPath error:&error];
    if (!contents) {
        NSLog(@"Could not list contents of unzip directory! Error : %@",[error localizedDescription]);
    } else {
        for (NSString* contentPath in contents) {
            NSLog(@"Unzip dir content : %@",contentPath);
        }
    }
}

@end
