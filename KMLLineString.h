//
//  KMLLineString.h
//  KMLViewer
//
//  Created by Mojtaba Cazi on 2/27/18.
//

#import "KMLGeometry.h"

@interface KMLLineString : KMLGeometry {
    CLLocationCoordinate2D *points;
    NSUInteger length;
}

@property (nonatomic, readonly) CLLocationCoordinate2D *points;
@property (nonatomic, readonly) NSUInteger length;

@end
