#import <ActionMenu/ActionMenu.h>
#import <MobileCoreServices/MobileCoreServices.h>

@class NSXPCListenerEndpoint;

@interface NSExtension : NSObject

+ (instancetype)extensionWithIdentifier:(NSString *)identifier error:(out NSError **)error;
- (void)instantiateViewControllerWithInputItems:(NSArray *)items listenerEndpoint:(NSXPCListenerEndpoint *)endpoint connectionHandler:(void (^)(id<NSCopying> requestIdentifier, UIViewController *viewController, NSError *error))connectionHandler;

@property(copy, nonatomic) void (^requestCancellationBlock)(id<NSCopying> requestIdentifier, NSError *error);
@property(copy, nonatomic) void (^requestCompletionBlock)(id<NSCopying> requestIdentifier, NSArray *items);

@end

@interface UIResponder (AMRunWorkflow)

- (BOOL)wf_canRunWorkflow;
- (void)wf_runWorkflow;

@end

static NSString * const WFWorkflowActionExtensionIdentifier = @"is.workflow.my.app.Run-Workflow";
static NSString * const WFWorkflowBetaActionExtensionIdentifier = @"com.deskconnect.workflow.app.Run-Workflow";

@implementation UIResponder (AMRunWorkflow)

+ (void)load {
	[[UIMenuController sharedMenuController] registerAction:@selector(wf_runWorkflow) title:@"Run Workflow" canPerform:@selector(wf_canRunWorkflow)];
}

- (NSExtension *)wf_actionExtension {
	NSExtension *extension = [NSExtension extensionWithIdentifier:WFWorkflowActionExtensionIdentifier error:nil];
	if (!extension)
		extension = [NSExtension extensionWithIdentifier:WFWorkflowBetaActionExtensionIdentifier error:nil];

	return extension;
}

- (UIViewController *)wf_containerViewController {
    UIViewController *container = (UIViewController *)self;
    while (container && ![container isKindOfClass:[UIViewController class]])
        container = (UIViewController *)[container nextResponder];
    return container;
}

- (BOOL)wf_canRunWorkflow {
	return (self.selectedTextualRepresentation.length &&
			[self wf_actionExtension] &&
			[self wf_containerViewController]);
}

- (void)wf_runWorkflow {
	NSData *data = [self.selectedTextualRepresentation dataUsingEncoding:NSUTF8StringEncoding];
	
	NSItemProvider *itemProvider = [[NSItemProvider alloc] initWithItem:data typeIdentifier:(id)kUTTypeText];
	NSExtensionItem *item = [[NSExtensionItem alloc] init];
	item.attachments = @[itemProvider];

	__block UIViewController *extensionViewController = nil;
	UIViewController *containerViewController = [self wf_containerViewController];
	NSExtension *extension = [self wf_actionExtension];

	[extension setRequestCompletionBlock:^(id<NSCopying> requestIdentifier, NSArray *items) {
		[extensionViewController dismissViewControllerAnimated:YES completion:nil];
	}];
	[extension setRequestCancellationBlock:^(id<NSCopying> requestIdentifier, NSError *error) {
		[extensionViewController dismissViewControllerAnimated:YES completion:nil];
	}];
	[extension instantiateViewControllerWithInputItems:@[item] listenerEndpoint:nil connectionHandler:^(id<NSCopying> identifier, UIViewController *viewController, NSError *error) {
		extensionViewController = viewController;
        [containerViewController presentViewController:viewController animated:YES completion:nil];
	}];
}

@end
