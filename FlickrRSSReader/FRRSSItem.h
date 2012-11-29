//
//  FRRSSEntry.h
//  FlickrRSSReader
//
//  Created by Denis on 19.08.12.
//  Copyright (c) 2012 Denis Krut. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FRRSSItem : NSObject{
    NSURL *_webURL, *_imageURL;
    NSString *_title;
    NSDate *_date;
    UIImage *_loadedImage;
    BOOL _loadingImage;
}
@property (nonatomic, retain) NSURL *webURL, *imageURL;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSDate *date;
@property (nonatomic, retain) UIImage *loadedImage;
@property (assign, readwrite) BOOL loadingImage;
@end
