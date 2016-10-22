//
//  Subdivide.h
//  Subdivide
//
//  Created by Daniel Gamage on 10/22/16.
//  Copyright © 2016 Daniel Gamage. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <GlyphsCore/GSFilterPlugin.h>

@interface Subdivide : GSFilterPlugin {
	CGFloat _firstValue;
	NSTextField * __unsafe_unretained _firstValueField;
}
@property (nonatomic, assign) IBOutlet NSTextField* firstValueField;
@end
