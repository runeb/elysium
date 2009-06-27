//
//  ELGenerateToken.m
//  Elysium
//
//  Created by Matt Mower on 20/07/2008.
//  Copyright 2008 Matthew Mower.
//  See MIT-LICENSE for more information.
//

#import "ELGenerateToken.h"

#import "ELCell.h"
#import "ELLayer.h"
#import "ELPlayer.h"
#import "ELPlayhead.h"

@implementation ELGenerateToken

+ (NSString *)tokenType {
  return @"generate";
}


#pragma mark Object initialization

- (id)initWithTriggerModeDial:(ELDial *)triggerModeDial
                directionDial:(ELDial *)directionDial
               timeToLiveDial:(ELDial *)timeToLiveDial
               pulseEveryDial:(ELDial *)pulseEveryDial
                   offsetDial:(ELDial *)offsetDial
{
  if( ( self = [super init] ) ) {
    [self setTriggerModeDial:triggerModeDial];
    [self setDirectionDial:directionDial];
    [self setTimeToLiveDial:timeToLiveDial];
    [self setPulseEveryDial:pulseEveryDial];
    [self setOffsetDial:offsetDial];
  }
  
  return self;
}

- (id)init {
  return [self initWithTriggerModeDial:[ELPlayer defaultTriggerModeDial]
                         directionDial:[ELPlayer defaultDirectionDial]
                        timeToLiveDial:[ELPlayer defaultTimeToLiveDial]
                        pulseEveryDial:[ELPlayer defaultPulseEveryDial]
                            offsetDial:[ELPlayer defaultOffsetDial]];
}


#pragma mark Properties

@synthesize triggerModeDial = _triggerModeDial;

- (void)setTriggerModeDial:(ELDial *)triggerModeDial {
  _triggerModeDial = triggerModeDial;
  [_triggerModeDial setDelegate:self];
}


@synthesize directionDial = _directionDial;

- (void)setDirectionDial:(ELDial *)directionDial {
  _directionDial = directionDial;
  [_directionDial setDelegate:self];
}


@synthesize timeToLiveDial = _timeToLiveDial;

- (void)setTimeToLiveDial:(ELDial *)timeToLiveDial {
  _timeToLiveDial = timeToLiveDial;
  [_timeToLiveDial setDelegate:self];
}


@synthesize pulseEveryDial = _pulseEveryDial;

- (void)setPulseEveryDial:(ELDial *)pulseEveryDial {
  _pulseEveryDial = pulseEveryDial;
  [_pulseEveryDial setDelegate:self];
}


@synthesize offsetDial = _offsetDial;

- (void)setOffsetDial:(ELDial *)offsetDial {
  _offsetDial = offsetDial;
  [_offsetDial setDelegate:self];
}


#pragma mark Layer support

- (void)addedToLayer:(ELLayer *)targetLayer atPosition:(ELCell *)targetCell {
  [super addedToLayer:targetLayer atPosition:targetCell];
  
  if( ![self loaded] ) {
    [[self timeToLiveDial] setParent:[targetLayer timeToLiveDial]];
    [[self timeToLiveDial] setMode:dialInherited];
    
    [[self pulseEveryDial] setParent:[targetLayer pulseEveryDial]];
    [[self pulseEveryDial] setMode:dialInherited];
  }
  
  [targetLayer addGenerator:self];
}


- (void)removedFromLayer:(ELLayer *)targetLayer {
  [targetLayer removeGenerator:self];
  
  [[self timeToLiveDial] setParent:nil];
  [[self pulseEveryDial] setParent:nil];
  
  [super removedFromLayer:targetLayer];
}


// Token runner

- (BOOL)shouldPulseOnBeat:(int)beat {
  BOOL pulse = NO;
  
  if( [[self pulseEveryDial] value] > 0 ) {
    switch( [[self triggerModeDial] value] ) {
      case 0:
        // Beat trigger mode
        pulse = ( ( beat - [[self offsetDial] value] ) % [[self pulseEveryDial] value] ) == 0;
        break;
      
      case 1:
        // Impact trigger mode
        pulse = [[self cell] playheadEntered];
        break;
      
      case 2:
        pulse = [[self layer] receivedMIDINote:[[self cell] note]];
        break;
    }
  }
  
  return pulse;
}


- (void)start {
  [super start];
  
  [[self directionDial] start];
  [[self timeToLiveDial] start];
  [[self pulseEveryDial] start];
  [[self offsetDial] start];
}


- (void)stop {
  [super stop];
  
  [[self directionDial] stop];
  [[self timeToLiveDial] stop];
  [[self pulseEveryDial] stop];
  [[self offsetDial] stop];
}


- (void)runToken:(ELPlayhead *)playhead {
  [[self layer] addPlayhead:[[ELPlayhead alloc] initWithPosition:[self cell]
                                                       direction:[[self directionDial] value]
                                                             TTL:[[self timeToLiveDial] value]]];
}


#pragma mark Drawing

- (void)drawWithAttributes:(NSDictionary *)attributes {
  NSPoint centre = [[self cell] centre];
  float radius = [[self cell] radius];
  
  NSBezierPath *symbolPath;
  symbolPath = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect( centre.x - radius/3, centre.y - radius/3, 2*radius/3, 2*radius/3 )];
  [symbolPath setLineWidth:2.0];

  [self setTokenDrawColor:attributes];
  [symbolPath stroke];
  
  [[self cell] drawTriangleInDirection:[[self directionDial] value] withAttributes:attributes];
}


#pragma mark Implements ELXmlData

- (NSXMLElement *)controlsXmlRepresentation {
  NSXMLElement *controlsElement = [super controlsXmlRepresentation];
  [controlsElement addChild:[[self triggerModeDial] xmlRepresentation]];
  [controlsElement addChild:[[self directionDial] xmlRepresentation]];
  [controlsElement addChild:[[self timeToLiveDial] xmlRepresentation]];
  [controlsElement addChild:[[self pulseEveryDial] xmlRepresentation]];
  [controlsElement addChild:[[self offsetDial] xmlRepresentation]];
  return controlsElement;
}

- (id)initWithXmlRepresentation:(NSXMLElement *)representation parent:(id)parent player:(ELPlayer *)player error:(NSError **)error {
  if( ( self = [super initWithXmlRepresentation:representation parent:parent player:player error:error] ) ) {
    [self setTriggerModeDial:[[ELDial alloc] initWithXmlRepresentation:[[representation nodesForXPath:@"controls/dial[@name='triggerMode']" error:error] firstXMLElement]
                                                              parent:nil
                                                              player:player
                                                               error:error]];
    [self setDirectionDial:[[ELDial alloc] initWithXmlRepresentation:[[representation nodesForXPath:@"controls/dial[@name='direction']" error:error] firstXMLElement]
                                                              parent:nil
                                                              player:player
                                                               error:error]];
    [self setTimeToLiveDial:[[ELDial alloc] initWithXmlRepresentation:[[representation nodesForXPath:@"controls/dial[@name='timeToLive']" error:error] firstXMLElement]
                                                               parent:nil
                                                               player:player
                                                                error:error]];
    [self setPulseEveryDial:[[ELDial alloc] initWithXmlRepresentation:[[representation nodesForXPath:@"controls/dial[@name='pulseEvery']" error:error] firstXMLElement]
                                                               parent:nil
                                                               player:player
                                                                error:error]];
    [self setOffsetDial:[[ELDial alloc] initWithXmlRepresentation:[[representation nodesForXPath:@"controls/dial[@name='offset']" error:error] firstXMLElement]
                                                           parent:nil
                                                           player:player
                                                            error:error]];
  }
  
  return self;
}


#pragma mark Implements NSMutableCopying

- (id)mutableCopyWithZone:(NSZone *)zone {
  id copy = [super mutableCopyWithZone:zone];
  [copy setTriggerModeDial:[[self triggerModeDial] mutableCopy]];
  [copy setDirectionDial:[[self directionDial] mutableCopy]];
  [copy setTimeToLiveDial:[[self timeToLiveDial] mutableCopy]];
  [copy setPulseEveryDial:[[self pulseEveryDial] mutableCopy]];
  [copy setOffsetDial:[[self offsetDial] mutableCopy]];
  return copy;
}


@end
