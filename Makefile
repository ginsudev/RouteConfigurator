ARCHS = arm64 arm64e
THEOS_DEVICE_IP = localhost -p 2222
INSTALL_TARGET_PROCESSES = SpringBoard
TARGET = iphone:clang:14.4:13
PREFIX = $(THEOS)/toolchain/Xcode11.xctoolchain/usr/bin/
PACKAGE_VERSION = 1.0.1-1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = RouteConfigurator

RouteConfigurator_FILES = Tweak.x
RouteConfigurator_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += routeconfigurator
SUBPROJECTS += routeconfiguratorcc
include $(THEOS_MAKE_PATH)/aggregate.mk
