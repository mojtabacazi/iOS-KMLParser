//
//  KMLPlacemark.m
//  KMLViewer
//
//  Created by Mojtaba Cazi on 2/27/18.
//

#import "KMLPlacemark.h"
#import "KMLPoint.h"
#import "KMLLineString.h"
#import "kml_com.h"

@interface KMLPlacemark ()

// Corresponds to the title property on MKAnnotation
@property (nonatomic, strong) NSString *name;
// Corresponds to the subtitle property on MKAnnotation
@property (nonatomic, strong) NSString *placemarkDescription;

@property (nonatomic, strong) NSMutableArray <KMLGeometry *> *geometry;
@property (unsafe_unretained, nonatomic) KMLPolygon *polygon;

@property (nonatomic, strong) NSString *styleUrl;

@property (NS_NONATOMIC_IOSONLY, strong) NSArray <MKOverlay> *overlays;
@property (NS_NONATOMIC_IOSONLY, strong) NSArray <MKAnnotation> *points;


@end

typedef struct {
    int inName:1;
    int inDescription:1;
    int inStyle:1;
    int inGeometry:1;
    int inStyleUrl:1;
} KMLFlagType;

@implementation KMLPlacemark {
    MKAnnotationView *_annotationView;
    MKOverlayPathRenderer *_overlayPathRenderer;
    
    KMLFlagType _flags;
}

- (instancetype)initWithIdentifier:(NSString *)ident
{
    self = [super initWithIdentifier:ident];
    if (self) {
        _geometry = [NSMutableArray array];
    }
    return self;
}

- (BOOL)canAddString {
    return _flags.inName || _flags.inStyleUrl || _flags.inDescription;
}

- (void)addString:(NSString *)str {
    if (_flags.inStyle) {
        [_style addString:str];
    } else if (_flags.inGeometry) {
        [_geometry.lastObject addString:str];
    } else {
        [super addString:str];
    }
}

- (void)beginName {
    _flags.inName = YES;
}

- (void)endName {
    _flags.inName = NO;
    _name = [accum copy];
    [self clearString];
}

- (void)beginDescription {
    _flags.inDescription = YES;
}

- (void)endDescription {
    _flags.inDescription = NO;
    _placemarkDescription = [accum copy];
    [self clearString];
}

- (void)beginStyleUrl {
    _flags.inStyleUrl = YES;
}

- (void)endStyleUrl {
    _flags.inStyleUrl = NO;
    _styleUrl = [accum copy];
    [self clearString];
}

- (void)beginStyleWithIdentifier:(NSString *)ident {
    _flags.inStyle = YES;
    _style = [[KMLStyle alloc] initWithIdentifier:ident];
}

- (void)endStyle {
    _flags.inStyle = NO;
}

- (void)beginGeometryOfType:(NSString *)elementName withIdentifier:(NSString *)ident {
    _flags.inGeometry = YES;
    if (ELTYPE(Point)) {
        [_geometry addObject:[[KMLPoint alloc] initWithIdentifier:ident]];
    } else if (ELTYPE(Polygon)) {
        [_geometry addObject:[[KMLPolygon alloc] initWithIdentifier:ident]];
    } else if (ELTYPE(LineString)) {
        [_geometry addObject:[[KMLLineString alloc] initWithIdentifier:ident]];
    }
}

- (void)endGeometry {
    _flags.inGeometry = NO;
}


- (NSArray <id<MKOverlay>> *)overlays {
    if (_overlays) {
        return _overlays;
    }
   
    NSMutableArray *shapes = [NSMutableArray array];
    for (KMLGeometry *geometry in _geometry) {
        MKShape *shape = [geometry mapkitShape];
        shape.title = _name;
        // Skip setting the subtitle for now because they're frequently
        // too verbose for viewing on in a callout in most kml files.
        // mkShape.subtitle = placemarkDescription;
        if ([shape conformsToProtocol:@protocol(MKOverlay)]) {
            [shapes addObject:shape];
        }
    }
    _overlays = [shapes copy];
    return _overlays;
}

- (NSArray <id<MKAnnotation>> *)points {
    if (_points) {
        return _points;
    }
    
    // Make sure to check if this is an MKPointAnnotation.  MKOverlays also
    // conform to MKAnnotation, so it isn't sufficient to just check to
    // conformance to MKAnnotation.
    NSMutableArray *shapes = [NSMutableArray array];
    for (KMLGeometry *geometry in _geometry) {
        MKShape *shape = [geometry mapkitShape];
        shape.title = _name;
        // Skip setting the subtitle for now because they're frequently
        // too verbose for viewing on in a callout in most kml files.
        // mkShape.subtitle = placemarkDescription;
        
        if ([shape isKindOfClass:[MKPointAnnotation class]]) {
            [shapes addObject:shape];
        }
    }
    _points = [shapes copy];
    return _points;
}

- (MKOverlayPathRenderer *)overlayPathRendererForOverlay:(id)overlay
{
    NSUInteger idx = [self.overlays indexOfObject:overlay];
    if (idx >= _geometry.count) {
        return nil;
    }
    
    MKOverlayPathRenderer *renderer = [_geometry[idx] createOverlayPathRenderer:overlay];
    [_style applyToOverlayPathRenderer:renderer];
    return renderer;
}

- (MKAnnotationView *)annotationViewForPoint:(id)point
{
    MKPinAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:point reuseIdentifier:nil];
    pin.canShowCallout = YES;
    pin.animatesDrop = YES;

    return pin;
}

@end
