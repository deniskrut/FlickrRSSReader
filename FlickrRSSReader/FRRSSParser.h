//
//  FRRSSParser.h
//  FlickrRSSReader
//
//  Created by Denis on 19.08.12.
//  Copyright (c) 2012 Denis Krut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FRRSSParserDelegate.h"
#import "FRRSSItem.h"

@interface FRRSSParser : NSObject <NSXMLParserDelegate>{
    NSObject<FRRSSParserDelegate> *_delegate;
}
@property (nonatomic, assign) NSObject<FRRSSParserDelegate> *delegate;
- (void)loadWithURL:(NSURL *)url;
- (void)cancel;
@end
