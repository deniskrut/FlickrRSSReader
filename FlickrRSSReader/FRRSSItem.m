//
//  FRRSSEntry.m
//  FlickrRSSReader
//
//  Created by Denis on 19.08.12.
//  Copyright (c) 2012 Denis Krut. All rights reserved.
//

#import "FRRSSItem.h"

@implementation FRRSSItem
@synthesize webURL = _webURL, imageURL = _imageURL, title = _title, date = _date, loadedImage = _loadedImage, loadingImage = _loadingImage;
- (void)dealloc
{
    [_webURL release];
    [_imageURL release];
    [_title release];
    [_date release];
    [_loadedImage release];
    [super dealloc];
}
@end
