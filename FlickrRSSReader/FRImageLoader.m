//
//  FRImageLoader.m
//  FlickrRSSReader
//
//  Created by Denis on 19.08.12.
//  Copyright (c) 2012 Denis Krut. All rights reserved.
//

#import "FRImageLoader.h"
@interface FRImageLoader()
- (void)notifyDelegateAboutSuceess:(UIImage *)image;
- (void)notifyDelegateAboutFaulure:(NSError *)error;
@end

@implementation FRImageLoader
- (void)notifyDelegateAboutSuceess:(UIImage *)image{
    [_delegate imageLoaderSuccededForIndexPath:_indexPath withImage:image];
}
- (void)notifyDelegateAboutFaulure:(NSError *)error{
    [_delegate imageLoaderFailedForIndexPath:_indexPath withError:error];
}
- (void)main {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSError *error = nil;
    NSURLResponse *response = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:_url] returningResponse:&response error:&error];
    if (error || !data){
        [self performSelectorOnMainThread:@selector(notifyDelegateAboutFaulure:) withObject:error waitUntilDone:NO];
    } else {
        UIImage *image = [UIImage imageWithData:data];//UIImage appears to be thread safe
        [self performSelectorOnMainThread:@selector(notifyDelegateAboutSuceess:) withObject:image waitUntilDone:NO];
    }
    
    [pool release];
}
- (void)dealloc
{
    [_url release];
    [_indexPath release];
    [super dealloc];
}
@end
