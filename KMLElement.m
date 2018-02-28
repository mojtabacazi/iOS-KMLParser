//
//  KMLElement.m
//  KMLViewer
//
//  Created by Mojtaba Cazi on 2/27/18.
//

#import "KMLElement.h"

// Begin the implementations of KMLElement and subclasses.  These objects
// act as state machines during parsing time and then once the document is
// fully parsed they act as an object graph for describing the placemarks and
// styles that have been parsed.

@implementation KMLElement

@synthesize identifier;

- (instancetype)initWithIdentifier:(NSString *)ident {
    if (self = [super init]) {
        identifier = ident;
    }
    return self;
}


- (BOOL)canAddString {
    return NO;
}

- (void)addString:(NSString *)str {
    if ([self canAddString]) {
        if (!accum) {
            accum = [[NSMutableString alloc] init];
        }
        [accum appendString:str];
    }
}

- (void)clearString {
    accum = nil;
}

@end
