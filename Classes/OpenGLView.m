//
//  OpenGLView.m
//  Substrate
//
//  Created by Jonathan Cooper on 5/26/10.
//  Copyright 2010 Jon Cooper. All rights reserved.
//

#import "OpenGLView.h"
#import "SubstrateRenderer.h"
#import "Renderer.h"

@implementation OpenGLView

@synthesize renderer;
@synthesize animating;

- (id) initWithCoder:(NSCoder *)aDecoder 
{
	if ((self = [super initWithCoder:aDecoder])) {
		
		CAEAGLLayer *eaglLayer = (CAEAGLLayer *) self.layer;
		eaglLayer.opaque = TRUE;
		eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
										[NSNumber numberWithBool:FALSE], kEAGLDrawablePropertyRetainedBacking, 
										kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat,
										nil];
		
		animating = FALSE;
		
		// This is tuned by hand, by timing a [SubstrateRenderer -render] call. Tinkering with it will produce odd/ugly results.
		animationFrameInterval = 2; 
		
		displayLink = nil;
	}
	
	return self;
}

// Core animation wants this, although it doesn't seem to be defined by any protocol I can find. (UIView? TODO)
+ (Class) layerClass 
{
	return [CAEAGLLayer class];
}

- (void) drawView:(id)sender
{
	[renderer render];
}

- (void) layoutSubviews 
{
	[renderer resizeFromLayer:(CAEAGLLayer *)self.layer];
	[self drawView:nil];
}

- (NSInteger) animationFrameInterval
{
	return animationFrameInterval;
}

- (void) setAnimationFrameInterval:(NSInteger)frameInterval
{
	// frameInteval <= 1 is undefined. >= 1 means how many display frames must pass between each time the display link fires, i.e. 2 means 30fps if the refresh loop is at 60fps.
	if (frameInterval >= 1) {
		animationFrameInterval = frameInterval;
		if (animating) {
			[self stopAnimation];
			[self startAnimation];
		}
	}
}

- (void) startAnimation
{
	if (!animating)
	{
		displayLink = [NSClassFromString(@"CADisplayLink") displayLinkWithTarget:self selector:@selector(drawView:)];
		[displayLink setFrameInterval:animationFrameInterval];
		[displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
		animating = TRUE;
	}
}

- (void) stopAnimation 
{
	if (animating) {
		[displayLink invalidate];
		displayLink = nil;
		animating = FALSE;
	}
}

- (void) dealloc
{
	[renderer release];
	[super dealloc];
}

@end
