ARCHS = armv7 arm64
TARGET = iphone:clang:latest:8.0

include theos/makefiles/common.mk

LIBRARY_NAME = AMRunWorkflow
AMRunWorkflow_FILES = AMRunWorkflow.m
AMRunWorkflow_INSTALL_PATH = /Library/ActionMenu/Plugins
AMRunWorkflow_FRAMEWORKS = Foundation UIKit CoreGraphics MobileCoreServices

include $(THEOS_MAKE_PATH)/library.mk
