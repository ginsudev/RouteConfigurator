TARGET := iphone:clang:13.0:11.0
INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = RouteConfiguratorCC
RouteConfiguratorCC_BUNDLE_EXTENSION = bundle
RouteConfiguratorCC_FILES = RouteConfiguratorCC.m
RouteConfiguratorCC_CFLAGS = -fobjc-arc
RouteConfiguratorCC_PRIVATE_FRAMEWORKS = ControlCenterUIKit
RouteConfiguratorCC_INSTALL_PATH = /Library/ControlCenter/Bundles/

include $(THEOS_MAKE_PATH)/bundle.mk
