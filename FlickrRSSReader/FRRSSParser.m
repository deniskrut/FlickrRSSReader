//
//  FRRSSParser.m
//  FlickrRSSReader
//
//  Created by Denis on 19.08.12.
//  Copyright (c) 2012 Denis Krut. All rights reserved.
//

#import "FRRSSParser.h"
@interface FRRSSParser() {
    NSLock *_lock;
    NSXMLParser *_currentXMLParser;
    NSMutableArray *_parsedEntries;
    FRRSSItem *_currentItem;
    NSString *_currentElementName;
}
- (void)informDelegateAboutError:(NSError *)error;
- (void)informDelegateAboutSuccess:(NSArray *)result;
- (void)prepareForReuse;
@end

@implementation FRRSSParser
@synthesize delegate = _delegate;
- (id)init
{
    self = [super init];
    if (self) {
        _lock = [[NSLock alloc] init];
    }
    return self;
}
- (void)loadWithURL:(NSURL *)url{
    if ([NSThread isMainThread]){
        [self performSelectorInBackground:@selector(loadWithURL:) withObject:url];
        return;
    }
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    [xmlParser setDelegate:self];
    
    [_lock lock];
    if (_currentXMLParser){
        //as locking operations are expancive decided to do this check here,
        //in order to user single lock for function
        //also no need to support concurrent requests, so no queue here, just quit
        [xmlParser release];
        [_lock unlock];
        return;
    }
    //currentXMLParser is null for sure, so no need to release
    _currentXMLParser = xmlParser;
    [_lock unlock];
    
    [xmlParser parse];
    
    [pool release];
}
- (void)prepareForReuse{
    [_currentXMLParser release];
    _currentXMLParser=nil;
    [_parsedEntries release];
    _parsedEntries = nil;
    [_currentItem release];
    _currentItem = nil;
    [_currentElementName release];
    _currentElementName = nil;
}
- (void)cancel{
    _delegate = nil;
    [_lock lock];
    [_currentXMLParser abortParsing];
    [_currentXMLParser release];
    _currentXMLParser = nil;
    [_lock unlock];
}
- (void)informDelegateAboutError:(NSError *)error{
    [self prepareForReuse];
    [_delegate performSelectorOnMainThread:@selector(RSSParserFailedWithError:) withObject:error waitUntilDone:NO];
}
- (void)informDelegateAboutSuccess:(NSArray *)result{
    [self prepareForReuse];
    [_delegate performSelectorOnMainThread:@selector(RSSParserSuccededWithArray:) withObject:result waitUntilDone:NO];
}

// Document handling methods
- (void)parserDidStartDocument:(NSXMLParser *)parser{
    [_currentItem release];
    _currentItem = nil;
    [_parsedEntries release];
    _parsedEntries = [[NSMutableArray array] retain];
}
// sent when the parser begins parsing of the document.
- (void)parserDidEndDocument:(NSXMLParser *)parser{
    [self informDelegateAboutSuccess:_parsedEntries];
}
// sent when the parser has completed parsing. If this is encountered, the parse was successful.

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    [_currentElementName release];
    _currentElementName = [elementName retain];
    if ([elementName isEqualToString:@"entry"]){
        [_currentItem release];
        _currentItem = [[FRRSSItem alloc] init];
    }
    if (_currentItem && [elementName isEqualToString:@"link"]){
        if ([[attributeDict objectForKey:@"rel"] isEqualToString:@"alternate"]){
            _currentItem.webURL = [NSURL URLWithString:[attributeDict objectForKey:@"href"]];
        }
        if ([[attributeDict objectForKey:@"rel"] isEqualToString:@"enclosure"]){
            _currentItem.imageURL = [NSURL URLWithString:[attributeDict objectForKey:@"href"]];
        }
    }
}
// sent when the parser finds an element start tag.
// In the case of the cvslog tag, the following is what the delegate receives:
//   elementName == cvslog, namespaceURI == http://xml.apple.com/cvslog, qualifiedName == cvslog
// In the case of the radar tag, the following is what's passed in:
//    elementName == radar, namespaceURI == http://xml.apple.com/radar, qualifiedName == radar:radar
// If namespace processing >isn't< on, the xmlns:radar="http://xml.apple.com/radar" is returned as an attribute pair, the elementName is 'radar:radar' and there is no qualifiedName.

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    if ([elementName isEqualToString:@"entry"]){
        [_parsedEntries addObject:_currentItem];
        [_currentItem release];
        _currentItem = nil;
    }
}
// sent when an end tag is encountered. The various parameters are supplied as above.

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    if (_currentItem && !_currentItem.date && [_currentElementName isEqualToString:@"published"]) {
        NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
        [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
        _currentItem.date = [dateFormatter dateFromString:string];
    }
    if (_currentItem && !_currentItem.title && [_currentElementName isEqualToString:@"title"]) {
        _currentItem.title = string;
    }
}
// This returns the string of the characters encountered thus far. You may not necessarily get the longest character run. The parser reserves the right to hand these to the delegate as potentially many calls in a row to -parser:foundCharacters:

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError{
    //@TODO wrap error with message making more sence to the user
    [self informDelegateAboutError:parseError];
}

- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validationError{
    //@TODO wrap error with message making more sence to the user
    [self informDelegateAboutError:validationError];
}
- (void)dealloc
{
    [_currentElementName release];
    [_parsedEntries release];
    [_currentItem release];
    [_currentXMLParser abortParsing];
    [_currentXMLParser release];
    _currentXMLParser = nil;
    [_lock release];
    [super dealloc];
}
@end
