//
//  FRImageLoader.h
//  FlickrRSSReader
//
//  Created by Denis on 19.08.12.
//  Copyright (c) 2012 Denis Krut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FRImageLoaderDelegate.h"

@interface FRImageLoader : NSOperation{
    NSURL *_url;
    NSIndexPath *_indexPath;
    NSObject<FRImageLoaderDelegate> *_delegate;
}
@property (nonatomic, retain) NSURL *url;
@property (nonatomic, retain) NSIndexPath *indexPath;
@property (nonatomic, assign) NSObject<FRImageLoaderDelegate> *delegate;
@end
