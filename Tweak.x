#import "RouteConf.h"

static BOOL isEnabled;

SBMediaController *controller;
MPAVRoutingController *routingController;
NSArray *availableRoutes;
NSString *frontMostAppDisplayName;
NSString *frontMostAppBundleID;

%group code

%hook SpringBoard
-(void)applicationDidFinishLaunching:(id)application {
    %orig;
  	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentRoutePickerAlert) name:@"RouteConfigurator_RequestAccessToRoutePickerForCurrentlyOpenedApp" object:nil];
}

- (void)frontDisplayDidChange:(id)arg1 {
	%orig;

	//Discovery mode reference:
	// 3 = Scanning.
	// 0 = Not scanning (I think).

	controller = [%c(SBMediaController) sharedInstance];
	routingController = [controller valueForKey:@"_routingController"];
	[routingController setDiscoveryMode:3];

	//[routingController updateAvailableRoutes];
	availableRoutes = [routingController availableRoutes];
	[routingController setDiscoveryMode:0];

	if ([(SpringBoard *)[UIApplication sharedApplication] _accessibilityFrontMostApplication] == nil){
		//On SpringBoard
		[self switchRouteForBundleID:@"com.apple.springboard"];
		frontMostAppDisplayName = @"SpringBoard";
		frontMostAppBundleID = @"com.apple.springboard";

	} else {
		//In app
		SBApplication *currentApplication = [(SpringBoard*)[UIApplication sharedApplication] _accessibilityFrontMostApplication];
		NSString *currentApplication_bundle_id = [currentApplication bundleIdentifier];

		[self switchRouteForBundleID:currentApplication_bundle_id];
		frontMostAppDisplayName = [currentApplication displayName];
		frontMostAppBundleID = [currentApplication bundleIdentifier];
	}
}

%new - (void)switchRouteForBundleID:(NSString *)bundleID {

    MPAVRoute *currentRoute = [routingController pickedRoute];

	NSString *next_route_uid;
	if ([[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"RoutingConfigurator_%@", bundleID]]) {
		next_route_uid = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"RoutingConfigurator_%@", bundleID]];
	} else {
		return;
	}

	for (MPAVOutputDeviceRoute *route in availableRoutes) {
		if ([[route routeUID] isEqualToString:next_route_uid]) {
			if (![[currentRoute routeUID] isEqualToString:next_route_uid]) {
				[routingController pickRoute:route];
			}
		}
	}
}

%new - (void)presentRoutePickerAlert {
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"RouteConfigurator" message:[NSString stringWithFormat:@"Set the preferred audio route for %@.", frontMostAppDisplayName] preferredStyle:UIAlertControllerStyleAlert];

	for (MPAVOutputDeviceRoute *route in availableRoutes) {
		UIAlertAction *button = [UIAlertAction actionWithTitle:[route routeName] style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
			[routingController pickRoute:route];
			[[NSUserDefaults standardUserDefaults] setObject:[route routeUID] forKey:[NSString stringWithFormat:@"RoutingConfigurator_%@", frontMostAppBundleID]];
		}];
		[alert addAction:button];
	}

	UIAlertAction *buttonN = [UIAlertAction actionWithTitle:@"Reset for app" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
		[[NSUserDefaults standardUserDefaults] setObject:nil forKey:[NSString stringWithFormat:@"RoutingConfigurator_%@", frontMostAppBundleID]];
	}];
	[alert addAction:buttonN];


	UIAlertAction *buttonC = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:nil];
	[alert addAction:buttonC];
    
	UIWindow *alertWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
	alertWindow.rootViewController = [[UIViewController alloc] init];
	alertWindow.windowLevel = UIWindowLevelAlert + 1;
	[alertWindow makeKeyAndVisible];
	[alertWindow.rootViewController presentViewController:alert animated:YES completion:nil];
}
%end

%hook SBIconController
-(void)_controlCenterWillPresent:(id)arg1{
    %orig;
    [routingController setDiscoveryMode:3];
	availableRoutes = [routingController availableRoutes];
}

-(void)_controlCenterWillDismiss:(id)arg1{
    %orig;
	[routingController setDiscoveryMode:0];
}
%end

%end

#pragma mark - Prefs
void loadPrefs() {
	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.ginsu.routeconfigurator.plist"];
	if (prefs) {
        isEnabled = ([prefs objectForKey:@"isEnabled"]) ? [[prefs objectForKey:@"isEnabled"] boolValue] : YES;
	}
}

void initPrefs() {
	NSString *path = @"/User/Library/Preferences/com.ginsu.routeconfigurator.plist";
	NSString *pathDefault = @"/Library/PreferenceBundles/routeconfigurator.bundle/defaults.plist";
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if (![fileManager fileExistsAtPath:path]) {
		[fileManager copyItemAtPath:pathDefault toPath:path error:nil];
	}
}

%ctor {
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("com.ginsu.routeconfigurator/prefsupdated"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	initPrefs();
	loadPrefs();
    
    if (isEnabled){
        %init(code);
    }
}