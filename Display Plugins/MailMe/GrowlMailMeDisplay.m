//
//  GrowlMailMeDisplay.m
//  Growl Display Plugins
//
//  Copyright 2004 Mac-arena the Bored Zo. All rights reserved.
//
#import "GrowlMailMeDisplay.h"
#import "GrowlMailMePrefs.h"
#import <Message/NSMailDelivery.h>
#import <GrowlDefinesInternal.h>
#import <GrowlDisplayProtocol.h>

#define destAddressKey @"MailMe - Recipient address"

/* for when there is no icon */
#define plainTextMessageFormat @"%@\r\n"\
	@"-- This message was automatically generated by MailMe, a Growl plug-in, --\r\n"\
	@"-- in response to a Growl notification --\r\n"\
	@"-- http://growl.info/ --\r\n"

@implementation GrowlMailMeDisplay

- (void) dealloc {
	[prefPane release];
	[super dealloc];
}

- (NSPreferencePane *) preferencePane {
	if (!prefPane) {
		prefPane = [[GrowlMailMePrefs alloc] initWithBundle:[NSBundle bundleForClass:[GrowlMailMePrefs class]]];
	}
	return prefPane;
}

- (void) displayNotificationWithInfo:(NSDictionary *)noteDict {
	NSString *destAddress = nil;
	READ_GROWL_PREF_VALUE(destAddressKey, @"com.Growl.MailMe", NSString *, &destAddress);

	if (destAddress && [destAddress length]) {
		NSString *title = [noteDict objectForKey:GROWL_NOTIFICATION_TITLE];
		NSString *desc = [noteDict objectForKey:GROWL_NOTIFICATION_DESCRIPTION];
		//hopefully something can be worked out to use the imageData.
		//documentation, Apple, documentation!
		//	NSData *imageData = [noteDict objectForKey:GROWL_NOTIFICATION_ICON];

		BOOL success = [NSMailDelivery deliverMessage:[NSString stringWithFormat:plainTextMessageFormat, desc]
											  subject:title
												   to:destAddress];

		if (!success) {
			NSLog(@"(MailMe) WARNING: Could not send email message \"%@\" to address %@", title, destAddress);
			NSLog(@"(MailMe) description of notification:\n%@", desc);
		} else
			NSLog(@"(MailMe) Successfully sent message \"%@\" to address %@", title, destAddress);
	} else {
		NSLog(@"(MailMe) WARNING: No destination address set");
	}

	[destAddress release];
}

@end
