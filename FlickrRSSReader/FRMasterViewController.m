//
//  FRMasterViewController.m
//  FlickrRSSReader
//
//  Created by Denis on 19.08.12.
//  Copyright (c) 2012 Denis Krut. All rights reserved.
//

#import "FRMasterViewController.h"
#import "FRDetailViewController.h"
#define RSS_URL @"http://api.flickr.com/services/feeds/photos_public.gne"

@interface FRMasterViewController () {
    NSArray *_objects;
    NSOperationQueue *_operationQueue;
}
@end

@implementation FRMasterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Master", @"Master");
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            self.clearsSelectionOnViewWillAppear = NO;
            self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
        }
    }
    return self;
}
							
- (void)dealloc
{
    [_operationQueue release];
    [_parser cancel];
    [_parser release];
    [_detailViewController release];
    [_objects release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh)] autorelease];
    _operationQueue = [[NSOperationQueue alloc] init];
    [_operationQueue setMaxConcurrentOperationCount:4];
    [self refresh];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)refresh{
    [_parser cancel];
    [_parser release];
    _parser = [[FRRSSParser alloc] init];
    _parser.delegate = self;
    [_parser loadWithURL:[NSURL URLWithString:RSS_URL]];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _objects.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }

    FRRSSItem *object = [_objects objectAtIndex:indexPath.row];
    cell.textLabel.text = object.title;
    cell.detailTextLabel.text = [object.date description];
    if (object.loadedImage)
        cell.imageView.image = object.loadedImage;
    else if (!object.loadingImage){
        FRImageLoader *imageLoader = [[[FRImageLoader alloc] init] autorelease];
        imageLoader.delegate = self;
        imageLoader.indexPath = indexPath;
        imageLoader.url = object.imageURL;
        [_operationQueue addOperation:imageLoader];
        object.loadingImage = YES;
        cell.imageView.image = nil;
    }
    return cell;
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDate *object = [_objects objectAtIndex:indexPath.row];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
	    if (!self.detailViewController) {
	        self.detailViewController = [[[FRDetailViewController alloc] initWithNibName:@"FRDetailViewController_iPhone" bundle:nil] autorelease];
	    }
	    self.detailViewController.detailItem = (FRRSSItem *)object;
        [self.navigationController pushViewController:self.detailViewController animated:YES];
    } else {
        self.detailViewController.detailItem = (FRRSSItem *)object;
    }
}
#pragma mark - Image Loader Delegate
- (void)imageLoaderSuccededForIndexPath:(NSIndexPath *)indexPath withImage:(UIImage *)image {
    FRRSSItem *rssItem = [_objects objectAtIndex:indexPath.row];
    rssItem.loadedImage = image;
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)imageLoaderFailedForIndexPath:(NSIndexPath *)indexPath withError:(NSError *)error {
    //@TODO make special image for error loading
    //for now just ignore
    
}

#pragma mark - RSS Parser Delegate
- (void)RSSParserSuccededWithArray:(NSArray *)result{
    [_objects autorelease];
    _objects = [result retain];
    [self.tableView reloadData];
    [_parser release];
    _parser = nil;
}
- (void)RSSParserFailedWithError:(NSError *)error{
    [[[[UIAlertView alloc] initWithTitle:[error description] message:nil delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] autorelease] show];
    [_parser release];
    _parser = nil;
}
@end
