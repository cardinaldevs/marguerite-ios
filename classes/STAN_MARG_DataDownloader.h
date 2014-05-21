//
//  DataDownloader.h
//  SNLaunchPad
//
//  Created by Ashok Kunaparaju on 11/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol STAN_MARG_DataDownloadDone <NSObject>

- (void) dataDownloadDone:(NSData*)data;
- (void) cachedDataDownloadDone:(NSData*)data;
- (void) dataDownloadFailed:(NSError*)error;

@end

@interface STAN_MARG_DataDownloader : NSObject<NSURLConnectionDelegate> {

}

- (id) initWithURL:(NSURL*)url localPath:(NSString *)path downloadDelegate:(NSObject<STAN_MARG_DataDownloadDone>*)delegate;
- (void) startDownload;
- (void) cancelDownload;
- (NSDate *) getFileModifiedDate;

@end
