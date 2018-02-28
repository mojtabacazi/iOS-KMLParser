//
//  KMLPlacemark.h
//  KMLViewer
//
//  Created by Mojtaba Cazi on 2/27/18.
//

#import "KMLElement.h"
#import "KMLGeometry.h"
#import "KMLPolygon.h"
#import "KMLStyle.h"

@interface KMLPlacemark : KMLElement

- (void)beginName;
- (void)endName;

- (void)beginDescription;
- (void)endDescription;

- (void)beginStyleWithIdentifier:(NSString *)ident;
- (void)endStyle;

- (void)beginGeometryOfType:(NSString *)type withIdentifier:(NSString *)ident;
- (void)endGeometry;

- (void)beginStyleUrl;
- (void)endStyleUrl;

- (MKOverlayPathRenderer *)overlayPathRendererForOverlay:(id)overlay;
- (MKAnnotationView *)annotationViewForPoint:(id)point;

// Corresponds to the title property on MKAnnotation
@property (nonatomic, readonly) NSString *name;
// Corresponds to the subtitle property on MKAnnotation
@property (nonatomic, readonly) NSString *placemarkDescription;

@property (nonatomic, readonly) NSMutableArray <KMLGeometry *> *geometry;

@property (nonatomic, strong) KMLStyle *style;
@property (nonatomic, readonly) NSString *styleUrl;

@property (NS_NONATOMIC_IOSONLY, readonly, strong) NSArray <MKOverlay> *overlays;
@property (NS_NONATOMIC_IOSONLY, readonly, strong) NSArray <MKAnnotation> *points;


@end
