//
//  Created by Björn Sållarp on 2010-03-13.
//  NO Copyright 2010 MightyLittle Industries. NO rights reserved.
// 
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//

#import "BSAddressComponent.h"


@implementation BSAddressComponent
@synthesize shortName, longName, types;


-(void)dealloc
{
	[shortName release];
	[longName release];
	[types release];
	[super dealloc];
}
@end
