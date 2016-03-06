//
//  EC2Instance.m
//  Elastics
//
//  Created by Dmitri Goutnik on 01/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import "NSString+DateConversions.h"
#import "EC2Instance.h"
#import "EC2InstanceState.h"
#import "EC2Tag.h"
#import "EC2Reservation.h"

@interface EC2Instance ()
@property (nonatomic, retain) NSString *instanceId;
@property (nonatomic, retain) NSString *imageId;
@property (nonatomic, retain) NSString *vpcId;
@property (nonatomic, retain) EC2InstanceState *instanceState;
@property (nonatomic, retain) NSString *instanceType;
@property (nonatomic, retain) NSString *dnsName;
@property (nonatomic, retain) NSDate *launchTime;
@property (nonatomic, retain) EC2Placement *placement;
@property (nonatomic, retain) NSString *platform;
@property (nonatomic, retain) EC2Monitoring *monitoring;
@property (nonatomic, retain) NSString *privateIpAddress;
@property (nonatomic, retain) NSString *ipAddress;
@property (nonatomic, retain) NSArray *tagSet;
@end

@implementation EC2Instance

@synthesize instanceId = _instanceId;
@synthesize imageId = _imageId;
@synthesize vpcId = _vpcId;
@synthesize instanceState = _instanceState;
@synthesize instanceType = _instanceType;
@synthesize dnsName = _dnsName;
@synthesize launchTime = _launchTime;
@synthesize placement = _placement;
@synthesize platform = _platform;
@synthesize monitoring = _monitoring;
@synthesize privateIpAddress = _privateIpAddress;
@synthesize ipAddress = _ipAddress;
@synthesize tagSet = _tagSet;

- (id)initFromXMLElement:(TBXMLElement *)element parent:(AWSType *)parent
{
	self = [super initFromXMLElement:element parent:parent];

	if (self) {
		element = element->firstChild;

		while (element) {
			NSString *elementName = [TBXML elementName:element];

			if ([elementName isEqualToString:@"instanceId"])
				self.instanceId = [TBXML textForElement:element];
			else if ([elementName isEqualToString:@"imageId"])
				self.imageId = [TBXML textForElement:element];
			else if ([elementName isEqualToString:@"instanceState"])
				self.instanceState = [EC2InstanceState typeFromXMLElement:element parent:self];
			else if ([elementName isEqualToString:@"instanceType"])
				self.instanceType = [TBXML textForElement:element];
			else if ([elementName isEqualToString:@"dnsName"])
				self.dnsName = [TBXML textForElement:element];
			else if ([elementName isEqualToString:@"launchTime"])
				self.launchTime = [[TBXML textForElement:element] iso8601Date];
			else if ([elementName isEqualToString:@"placement"])
				self.placement = [EC2Placement typeFromXMLElement:element parent:self];
			else if ([elementName isEqualToString:@"platform"])
				self.platform = [TBXML textForElement:element];
			else if ([elementName isEqualToString:@"monitoring"])
				self.monitoring = [EC2Monitoring typeFromXMLElement:element parent:self];
			else if ([elementName isEqualToString:@"privateIpAddress"])
				self.privateIpAddress = [TBXML textForElement:element];
			else if ([elementName isEqualToString:@"ipAddress"])
				self.ipAddress = [TBXML textForElement:element];
			else if ([elementName isEqualToString:@"tagSet"])
				self.tagSet = [self parseElement:element asArrayOf:[EC2Tag class]];
            else if ([elementName isEqualToString:@"vpcId"])
                self.vpcId = [TBXML textForElement:element];
            
            

			element = element->nextSibling;
		}
	}

	return self;
}

- (void)dealloc
{
	TBRelease(_instanceId);
	TBRelease(_imageId);
	TBRelease(_instanceState);
	TBRelease(_instanceType);
	TBRelease(_dnsName);
	TBRelease(_launchTime);
    TBRelease(_placement);
	TBRelease(_platform);
	TBRelease(_monitoring);
	TBRelease(_privateIpAddress);
	TBRelease(_ipAddress);
	TBRelease(_tagSet);
	[super dealloc];
}

- (NSArray *)groupSet
{
	return ((EC2Reservation *)self.parent).groupSet;
}

- (NSString *)securityGroup
{
    if ([[self groupSet] count])
        return [[[self groupSet] objectAtIndex:0] groupId];
    else
        return nil;
}

- (NSString *)nameTag
{
	static NSString *const tagName = @"Name";
	__block NSString *tagValue = nil;

	[_tagSet enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		if ([[obj key] compare:tagName options:NSCaseInsensitiveSearch] == NSOrderedSame) {
			tagValue = [obj value];
			*stop = YES;
		}
	}];

	return [tagValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString *)autoscalingGroupName
{
	static NSString *const tagName = @"aws:autoscaling:groupName";
	__block NSString *tagValue = nil;
    
	[_tagSet enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		if ([[obj key] compare:tagName options:NSCaseInsensitiveSearch] == NSOrderedSame) {
			tagValue = [obj value];
			*stop = YES;
		}
	}];
    
	return [tagValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString *)title
{
	NSString *nameTag = [self nameTag];
	return [nameTag length] > 0 ? nameTag : _instanceId;
}

- (NSComparisonResult)compare:(EC2Instance *)instance
{
    return [self.title compare:instance.title];
}

@end
