#import <Foundation/Foundation.h>
#import "MLNTypes.h"
#import "MLNGeometry.h"
#import "MLNMapCamera.h"
#import "MLNStyle.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MLNMapSnapshotterDelegate;

/**
 An overlay that is placed within a `MLNMapSnapshot`.
 To access this object, use `-[MLNMapSnapshotter startWithOverlayHandler:completionHandler:]`.
 */

MLN_EXPORT
@interface MLNMapSnapshotOverlay : NSObject

/**
 The current `CGContext` that snapshot is drawing within. You may use this context
 to perform additional custom drawing.
 */
@property (nonatomic, readonly) CGContextRef context;

#if TARGET_OS_IPHONE
/**
 Converts the specified map coordinate to a point in the coordinate space of the
 context.
 */
- (CGPoint)pointForCoordinate:(CLLocationCoordinate2D)coordinate;

/**
 Converts the specified context point to a map coordinate.
 */
- (CLLocationCoordinate2D)coordinateForPoint:(CGPoint)point;

#else
/**
 Converts the specified map coordinate to a point in the coordinate space of the
 context.
 */
- (NSPoint)pointForCoordinate:(CLLocationCoordinate2D)coordinate;

/**
 Converts the specified context point to a map coordinate.
 */
- (CLLocationCoordinate2D)coordinateForPoint:(NSPoint)point;
#endif

@end

/**
A block provided during the snapshot drawing process, enabling the ability to
draw custom overlays rendered with Core Graphics.

 @param snapshotOverlay The `MLNMapSnapshotOverlay` provided during snapshot drawing.
 */
typedef void (^MLNMapSnapshotOverlayHandler)(MLNMapSnapshotOverlay * snapshotOverlay);

/**
 The options to use when creating images with the `MLNMapSnapshotter`.
 */
MLN_EXPORT
@interface MLNMapSnapshotOptions : NSObject <NSCopying>

/**
 Creates a set of options with the minimum required information.
 
 @param styleURL URL of the map style to snapshot. The URL may be a full HTTP,
    HTTPS URL, canonical URL or a path to a local file relative to
    the application’s resource path. Specify `nil` for the default style.
 @param size The image size.
 */
- (instancetype)initWithStyleURL:(nullable NSURL *)styleURL camera:(MLNMapCamera *)camera size:(CGSize)size;

// MARK: - Configuring the Map

/**
 URL of the map style to snapshot.
 */
@property (nonatomic, readonly) NSURL *styleURL;

/**
 The zoom level.
 
 The default zoom level is 0. If this property is non-zero and the camera
 property is non-nil, the camera’s altitude is ignored in favor of this
 property’s value.
 */
@property (nonatomic) double zoomLevel;

/**
 A camera representing the viewport visible in the snapshot.
 
 If this property is non-nil and the `coordinateBounds` property is set to a
 non-empty coordinate bounds, the camera’s center coordinate and altitude are
 ignored in favor of the `coordinateBounds` property.
 */
@property (nonatomic) MLNMapCamera *camera;

/**
 The coordinate rectangle that encompasses the bounds to capture.
 
 If this property is non-empty and the camera property is non-nil, the camera’s
 center coordinate and altitude are ignored in favor of this property’s value.
 */
@property (nonatomic) MLNCoordinateBounds coordinateBounds;

// MARK: - Configuring the Image

/**
 The size of the output image, measured in points.
 
 */
@property (nonatomic, readonly) CGSize size;

/**
 The scale of the output image. Defaults to the main screen scale.
 
 The minimum scale is 1.
 */
@property (nonatomic) CGFloat scale;

@end

/**
 An image generated by a snapshotter object.
 */
MLN_EXPORT
@interface MLNMapSnapshot : NSObject

#if TARGET_OS_IPHONE
/**
 Converts the specified map coordinate to a point in the coordinate space of the
 image.
 */
- (CGPoint)pointForCoordinate:(CLLocationCoordinate2D)coordinate;

/**
 Converts the specified image point to a map coordinate.
 */
- (CLLocationCoordinate2D)coordinateForPoint:(CGPoint)point;

/**
 The image of the map’s content.
 */
@property (nonatomic, readonly) UIImage *image;
#else
/**
 Converts the specified map coordinate to a point in the coordinate space of the
 image.
 */
- (NSPoint)pointForCoordinate:(CLLocationCoordinate2D)coordinate;

/**
 Converts the specified image point to a map coordinate.
 */
- (CLLocationCoordinate2D)coordinateForPoint:(NSPoint)point;


/**
 The image of the map’s content.
 */
@property (nonatomic, readonly) NSImage *image;
#endif

@end

/**
 A block to processes the result or error of a snapshot request.
 
 @param snapshot The `MLNMapSnapshot` that was generated or `nil` if an error
    occurred.
 @param error The error that occured or `nil` when successful.
 */
typedef void (^MLNMapSnapshotCompletionHandler)(MLNMapSnapshot* _Nullable snapshot, NSError* _Nullable error);

/**
 An `MLNMapSnapshotter` generates static raster images of the map. Each snapshot
 image depicts a portion of a map defined by an `MLNMapSnapshotOptions` object
 you provide. The snapshotter generates an `MLNMapSnapshot` object
 asynchronously, calling `MLNMapSnapshotterDelegate` methods if defined, then
 passing it into a completion handler once tiles and other resources needed for
 the snapshot are finished loading.
 
 You can change the snapshotter’s options at any time and reuse the snapshotter
 for multiple distinct snapshots; however, the snapshotter can only generate one
 snapshot at a time. If you need to generate multiple snapshots concurrently,
 create multiple snapshotter objects.
 
 For an interactive map, use the `MLNMapView` class. Both `MLNMapSnapshotter`
 and `MLNMapView` are compatible with offline packs managed by the
 `MLNOfflineStorage` class.
 
 From a snapshot, you can obtain an image and convert geographic coordinates to
 the image’s coordinate space in order to superimpose markers and overlays. If
 you do not need offline map functionality, you can use the `Snapshot` class in
 [MapboxStatic.swift](https://github.com/mapbox/MapboxStatic.swift/) to generate
 static map images with overlays.
 
 ### Example
 
 ```swift
 let camera = MLNMapCamera(lookingAtCenter: CLLocationCoordinate2D(latitude: 37.7184, longitude: -122.4365), altitude: 100, pitch: 20, heading: 0)
 
 let options = MLNMapSnapshotOptions(styleURL: MLNStyle.satelliteStreetsStyleURL, camera: camera, size: CGSize(width: 320, height: 480))
 options.zoomLevel = 10
 
 let snapshotter = MLNMapSnapshotter(options: options)
 snapshotter.start { (snapshot, error) in
     if let error = error {
         fatalError(error.localizedDescription)
     }
     
     image = snapshot?.image
 }
 ```
 
 #### Related examples
 TODO: Create a static map snapshot, learn how to use the
 `MLNMapSnapshotter` to generate a static image based on an `MLNMapView`
 object's style, camera, and view bounds.
 */
MLN_EXPORT
@interface MLNMapSnapshotter : NSObject <MLNStylable>

- (instancetype)init NS_UNAVAILABLE;

/**
 Initializes and returns a map snapshotter object that produces snapshots
 according to the given options.
 
 @param options The options to use when generating a map snapshot.
 @return An initialized map snapshotter.
 */
- (instancetype)initWithOptions:(MLNMapSnapshotOptions *)options NS_DESIGNATED_INITIALIZER;

/**
 Starts the snapshot creation and executes the specified block with the result.
 
 @param completionHandler The block to call with a finished snapshot. The block
    is executed on the main queue.
 */
- (void)startWithCompletionHandler:(MLNMapSnapshotCompletionHandler)completionHandler;

/**
 Starts the snapshot creation and executes the specified block with the result
 on the specified queue.
 
 @param queue The queue on which to call the block specified in the
    `completionHandler` parameter.
 @param completionHandler The block to call with a finished snapshot. The block
     is executed on the queue specified in the `queue` parameter.
 */
- (void)startWithQueue:(dispatch_queue_t)queue completionHandler:(MLNMapSnapshotCompletionHandler)completionHandler;

/**
 Starts the snapshot creation and executes the specified blocks with the result
 on the specified queue. Use this option if you want to add custom drawing on
 top of the resulting `MLNMapSnapshot`.
 
 @param overlayHandler The block to call after the base map finishes drawing but
    before certain built-in overlays draw. The block can use Core Graphics to
    draw custom content directly over the base map. The block is executed on a
    background queue.
 @param completionHandler The block to call with a finished snapshot. The block
     is executed on the main queue.
 */
- (void)startWithOverlayHandler:(MLNMapSnapshotOverlayHandler)overlayHandler completionHandler:(MLNMapSnapshotCompletionHandler)completionHandler;

/**
 Cancels the snapshot creation request, if any.
 
 Once you call this method, you cannot resume the snapshot. In order to obtain
 the snapshot, create a new `MLNMapSnapshotter` object.
 */
- (void)cancel;

/**
 The options to use when generating a map snapshot.
 */
@property (nonatomic) MLNMapSnapshotOptions *options;

/**
 Indicates whether a snapshot is currently being generated.
 */
@property (nonatomic, readonly, getter=isLoading) BOOL loading;

/**
 The snapshotter’s delegate.
 
 The delegate is responsible for responding to significant changes during the
 snapshotting process, such as the style loading. Implement a delegate to
 customize the style that is depicted by the snapshot.
 
 You set the delegate after initializing the snapshotter but before receiving
 the snapshot, typically before starting the snapshot. The snapshotter keeps a
 weak reference to its delegate, so you must keep a strong reference to it to
 ensure that your style customizations apply.
 */
@property (nonatomic, weak) id <MLNMapSnapshotterDelegate> delegate;

/**
 The style displayed in the resulting snapshot.
 
 Unlike the `MLNMapSnapshotOptions.styleURL` property, this property is set to
 an object that allows you to manipulate every aspect of the style locally.
 
 This property is set to `nil` until the style finishes loading. If the style
 has failed to load, this property is set to `nil`. Because the style loads
 asynchronously, you should manipulate it in the
 `-[MLNMapSnapshotterDelegate mapSnapshotter:didFinishLoadingStyle:]` method. It
 is not possible to manipulate the style before it has finished loading.

 @note The default styles provided by Mapbox contain sources and layers with
    identifiers that will change over time. Applications that use APIs that
    manipulate a style’s sources and layers must first set the style URL to an
    explicitly versioned style using a convenience method like
    `+[MLNStyle outdoorsStyleURLWithVersion:]` or a manually constructed
    `NSURL`.
 */
@property (nonatomic, readonly, nullable) MLNStyle *style;

@end

/**
 Optional methods about significant events when creating a snapshot using an
 `MLNMapSnapshotter` object.
 */
@protocol MLNMapSnapshotterDelegate <NSObject>
@optional

/**
 Tells the delegate that the snapshotter was unable to load data needed for
 snapshotting the map.
 
 This method may be called for a variety of reasons, including a network
 connection failure or a failure to fetch the style from the server. You can use
 the given error message to notify the user that map data is unavailable.
 
 @param snapshotter The snapshotter that is unable to load the data.
 @param error The reason the data could not be loaded.
*/
- (void)mapSnapshotterDidFail:(MLNMapSnapshotter *)snapshotter withError:(NSError *)error;

/**
 Tells the delegate that the snapshotter has just finished loading a style.
 
 This method is called in response to
 `-[MLNMapSnapshotter startWithQueue:completionHandler:]` as long as the
 `MLNMapSnapshotter.delegate` property is set. Changes to sources or layers of
 the style being snapshotted do not cause this method to be called.
 
 @param snapshotter The snapshotter that has just loaded a style.
 @param style The style that was loaded.
 */
- (void)mapSnapshotter:(MLNMapSnapshotter *)snapshotter didFinishLoadingStyle:(MLNStyle *)style;

- (void)mapSnapshotter:(MLNMapSnapshotter *)snapshotter didFailLoadingImageNamed:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
