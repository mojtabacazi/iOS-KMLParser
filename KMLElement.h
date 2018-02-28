//
//  KMLElement.h
//  KMLViewer
//
//  Created by Mojtaba Cazi on 2/27/18.
//

#import <MapKit/MapKit.h>

@interface KMLElement : NSObject {
    NSString *identifier;
    NSMutableString *accum;
}

- (instancetype)initWithIdentifier:(NSString *)ident;

@property (nonatomic, readonly) NSString *identifier;

// Returns YES if we're currently parsing an element that has character
// data contents that we are interested in saving.
@property (NS_NONATOMIC_IOSONLY, readonly) BOOL canAddString;

// Add character data parsed from the xml
- (void)addString:(NSString *)str;

// Once the character data for an element has been parsed, use clearString to
// reset the character buffer to get ready to parse another element.
- (void)clearString;

@end
