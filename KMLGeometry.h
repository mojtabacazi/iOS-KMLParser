//
//  KMLGeometry.h
//  KMLViewer
//
//  Created by Mojtaba Cazi on 2/27/18.
//

#import "KMLElement.h"

@interface KMLGeometry : KMLElement {
    struct {
        int inCoords:1;
    } flags;
}

- (void)beginCoordinates;
- (void)endCoordinates;

// Create (if necessary) and return the corresponding Map Kit MKShape object
// corresponding to this KML Geometry node.
@property (NS_NONATOMIC_IOSONLY, readonly, strong) MKShape *mapkitShape;

// Create (if necessary) and return the corresponding MKOverlayPathRenderer for
// the MKShape object.
- (MKOverlayPathRenderer *)createOverlayPathRenderer:(MKShape *)shape;

@end
