//
//  KMLPoint.h
//  KMLViewer
//
//  Created by Mojtaba Cazi on 2/27/18.
//

#import "KMLGeometry.h"

// A KMLPoint element corresponds to an MKAnnotation and MKPinAnnotationView
@interface KMLPoint : KMLGeometry {
    CLLocationCoordinate2D point;
}

@property (nonatomic, readonly) CLLocationCoordinate2D point;

@end
