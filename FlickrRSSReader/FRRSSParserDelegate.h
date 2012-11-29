//
//  FRRSSParserDelegate.h
//  FlickrRSSReader
//
//  Created by Denis on 19.08.12.
//  Copyright (c) 2012 Denis Krut. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FRRSSParserDelegate <NSObject>
- (void)RSSParserSuccededWithArray:(NSArray *)result;
- (void)RSSParserFailedWithError:(NSError *)error;
@end
