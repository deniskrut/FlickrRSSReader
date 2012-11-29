//
//  FRMasterViewController.h
//  FlickrRSSReader
//
//  Created by Denis on 19.08.12.
//  Copyright (c) 2012 Denis Krut. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRRSSParser.h"
#import "FRImageLoader.h"

@class FRDetailViewController;

@interface FRMasterViewController : UITableViewController <FRRSSParserDelegate, FRImageLoaderDelegate>{
    FRRSSParser *_parser;
}

@property (retain, nonatomic) FRDetailViewController *detailViewController;

@end
