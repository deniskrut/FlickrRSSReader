//
//  FRDetailViewController.h
//  FlickrRSSReader
//
//  Created by Denis on 19.08.12.
//  Copyright (c) 2012 Denis Krut. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRRSSItem.h"

@interface FRDetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (retain, nonatomic) FRRSSItem *detailItem;

@property (retain, nonatomic) IBOutlet UIWebView *webView;

@end
