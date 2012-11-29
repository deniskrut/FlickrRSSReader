//
//  FRImageLoaderDelegate.h
//  FlickrRSSReader
//
//  Created by Denis on 19.08.12.
//  Copyright (c) 2012 Denis Krut. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FRImageLoaderDelegate <NSObject>
- (void)imageLoaderSuccededForIndexPath:(NSIndexPath *)indexPath withImage:(UIImage *)image;
- (void)imageLoaderFailedForIndexPath:(NSIndexPath *)indexPath withError:(NSError *)error;
@end