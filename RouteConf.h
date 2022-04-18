@interface MPAVRoute : NSObject
- (NSString *)routeUID;
- (NSString *)routeName;
@end

@interface MPAVOutputDeviceRoute : MPAVRoute
- (id)routeName;
@end

@interface MPAVRoutingController : NSObject
@property (assign,nonatomic) long long discoveryMode;
- (void)setDiscoveryMode:(long long)arg1;
- (MPAVRoute *)pickedRoute;
- (NSArray *)availableRoutes;
- (BOOL)pickRoute:(id)arg1;
- (id)updateAvailableRoutes;
@end

@interface SBMediaController : NSObject {
    MPAVRoutingController* _routingController;
}
+ (id)sharedInstance;
- (void)_updateAVRoutes;
@end

@interface SpringBoard : UIApplication
+ (id)sharedApplication;
- (id)_accessibilityTopDisplay;
- (id)_accessibilityFrontMostApplication;
- (void)switchRouteForBundleID:(NSString *)bundleID;
@end

@interface SBApplication : NSObject
- (NSString *)bundleIdentifier;
- (NSString *)displayName;
@end