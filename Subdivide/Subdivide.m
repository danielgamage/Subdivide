//
//  Subdivide.m
//  Subdivide
//
//  Created by Daniel Gamage on 10/22/16.
//  Copyright © 2016 Daniel Gamage. All rights reserved.
//

#import "Subdivide.h"
#import <GlyphsCore/GSFont.h>
#import <GlyphsCore/GSFontMaster.h>
#import <GlyphsCore/GSGlyph.h>
#import <GlyphsCore/GSLayer.h>
#import <GlyphsCore/GSPath.h>
#import <GlyphsCore/GSNode.h>

@implementation Subdivide

- (id) init {
	self = [super init];
	[NSBundle loadNibNamed:@"SubdivideDialog" owner:self];
	return self;
}

- (NSUInteger) interfaceVersion {
	// Distinguishes the API verison the plugin was built for. Return 1.
	return 1;
}

- (NSString*) title {
	// Return the name of the tool as it will appear in the menu.
	return @"Subdivide";
}

- (NSString*) actionName {
	// The title of the button in the filter dialog.
	return @"Subdivide";
}

- (NSString*) keyEquivalent {
	// The key together with Cmd+Shift will be the shortcut for the filter.
	// Return nil if you do not want to set a shortcut.
	// Users can set their own shortcuts in System Prefs.
	return nil;
}

- (NSString*)customParameterString {
    return @"Subdivide";
}

- (GSNode*) getSibling:(GSNode*)node next:(bool)next {
    GSPath *path = node.parent;
    NSUInteger index = [path indexOfNode:node];
    NSUInteger length = [path.nodes count];
    NSUInteger siblingIndex;

    if (next == YES) {
        // if last node
        siblingIndex = (index == length - 1) ? 0 : index + 1;
    } else {
        // if first node
        siblingIndex = (index == 0) ? length - 1 : index - 1;
    }

    GSNode *nextNode = [path nodeAtIndex:siblingIndex];
    return nextNode;
}

- (GSNode*) prevNode:(GSNode*)node {
    return [self getSibling:node next:NO];
}

- (GSNode*) nextNode:(GSNode*)node {
    return [self getSibling:node next:YES];
}

- (NSError*) setup {
	if ([_fontMaster.userData objectForKey:@"____TheFirstValue____"]) {
		_firstValue = [[_fontMaster.userData objectForKey:@"____TheFirstValue____"] floatValue];
	}
	else {
		_firstValue = 15; // set default value.
	}
	[_firstValueField setFloatValue:_firstValue];
	return nil;
}

- (void) processLayer:(GSLayer*)Layer {
	// the method should contain all parameters as arguments

	// do stuff with the Layer.

    for (GSPath *path in Layer.paths) {
        // store static node count
        int nodeCount = [path.nodes count];
        double ONE_THIRD = 1.0000000/3;
        double IN_BETWEEN = 1.0000000/2;

        for (int i = nodeCount; i > 0; i--) {
            // insert nodes backwards
            GSNode *pointOne = (i == nodeCount)
                ? [path insertNodeWithPathTime:(i + ONE_THIRD)]
                : [path insertNodeWithPathTime:(i + IN_BETWEEN)];
            GSNode *pointTwo = (i > 1)
                ? [path insertNodeWithPathTime:(i - ONE_THIRD)]
                : [path insertNodeWithPathTime:(i - IN_BETWEEN)];

            // find midpoints
            CGFloat midpointX = (pointOne.position.x + pointTwo.position.x) / 2;
            CGFloat midpointY = (pointOne.position.y + pointTwo.position.y) / 2;
            NSPoint midpoint = NSMakePoint(midpointX, midpointY);

            if (path.nodes[i - 1]) {
                GSNode *node = [self nextNode:path.nodes[i - 1]];
                [node setPosition:midpoint];
            }
        }

        for (int i = 0; i < nodeCount; i++) {
            GSNode *oncurveNode = [self nextNode:path.nodes[i * 3]];
            oncurveNode.type = CURVE;
            oncurveNode.connection = SMOOTH;
            [self prevNode:oncurveNode].type = OFFCURVE;
            [self nextNode:oncurveNode].type = OFFCURVE;
        }
    }
}

- (void) processFont:(GSFont*)Font withArguments:(NSArray*)Arguments {
	// Invoked when called as Custom Parameter in an instance at export.
	// The Arguments come from the custom parameter in the instance settings.
	// The first item in Arguments is the class-name. After that, it depends on the filter.
	NSString * FontMasterId = [Font fontMasterAtIndex:0].id;
//	NSSet * Glyphs = getIncludeExcludeGlyphList(Arguments, &Include);
	for (GSGlyph * Glyph in Font.glyphs) {
//		if (Glyphs && [Glyphs containsObject:Glyph.name] != Include) continue;

		GSLayer * Layer = [Glyph layerForKey:FontMasterId];
		[self processLayer:Layer];
	}
}

- (IBAction) setFirstValue:(id)sender {
	// This is only an example for a setter method.
	// Add methods like this for each option in the dialog.
	CGFloat FirstValue = [sender floatValue];
	if(fabs(FirstValue - _firstValue) > 0.01) {
		_firstValue = FirstValue;
		[self process:nil];
	}
}

// force redraw in preview
- (void)processLayer:(GSLayer*)Layer withArguments:(NSArray*)Arguments {
    [self processLayer:Layer];
}

// from menu
- (void) process:(id)sender {
    [self processLayer:controller.activeLayer];
}

@end
