#import "RouteConfiguratorCC.h"

@implementation RouteConfiguratorCC

//Return the icon of your module here
- (UIImage *)iconGlyph
{
	return [UIImage imageNamed:@"icon" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
}

//Return the color selection color of your module here
- (UIColor *)selectedColor
{
	return [UIColor blueColor];
}

- (BOOL)isSelected
{
  return NO;
}

- (void)setSelected:(BOOL)selected
{
	_selected = selected;

  [super refreshState];

  [[NSNotificationCenter defaultCenter] postNotificationName:@"RouteConfigurator_RequestAccessToRoutePickerForCurrentlyOpenedApp" object:nil];
}

@end
