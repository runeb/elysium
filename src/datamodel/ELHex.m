//
//  ELHex.m
//  Elysium
//
//  Created by Matt Mower on 20/07/2008.
//  Copyright 2008 LucidMac Software. All rights reserved.
//

#import "Elysium.h"

#import <HoneycombView/LMHoneycombView.h>

#import "ELHex.h"
#import "ELNote.h"
#import "ELLayer.h"
#import "ELPlayer.h"
#import "ELTool.h"
#import "ELPlayhead.h"
#import "ELSurfaceView.h"

#import "ELGenerateTool.h"
#import "ELNoteTool.h"
#import "ELReboundTool.h"
#import "ELAbsorbTool.h"
#import "ELSplitTool.h"
#import "ELSpinTool.h"

@implementation ELHex

- (id)initWithLayer:(ELLayer *)_layer note:(ELNote *)_note column:(int)_col row:(int)_row {
  if( ( self = [super initWithColumn:_col row:_row] ) ) {
    layer     = _layer;
    note      = _note;
    tools     = [[NSMutableArray alloc] init];
    playheads = [[NSMutableArray alloc] init];
    
    [self connectNeighbour:nil direction:N];
    [self connectNeighbour:nil direction:NE];
    [self connectNeighbour:nil direction:SE];
    [self connectNeighbour:nil direction:S];
    [self connectNeighbour:nil direction:SW];
    [self connectNeighbour:nil direction:NW];
  }
  
  return self;
}

// Properties

@synthesize layer;
@synthesize note;

@dynamic generateTool;

- (ELGenerateTool *)generateTool {
  return generateTool;
}

- (void)setGenerateTool:(ELGenerateTool *)_generateTool_ {
  [self removeTool:generateTool];
  generateTool = _generateTool_;
  [self addTool:generateTool];
}

@dynamic noteTool;

- (ELNoteTool *)noteTool {
  return noteTool;
}

- (void)setNoteTool:(ELNoteTool *)_noteTool_ {
  [self removeTool:noteTool];
  noteTool = _noteTool_;
  [self addTool:noteTool];
}

@dynamic reboundTool;

- (ELReboundTool *)reboundTool {
  return reboundTool;
}

- (void)setReboundTool:(ELReboundTool *)_reboundTool_ {
  [self removeTool:reboundTool];
  reboundTool = _reboundTool_;
  [self addTool:reboundTool];
}

@dynamic absorbTool;

- (ELAbsorbTool *)absorbTool {
  return absorbTool;
}

- (void)setAbsorbTool:(ELAbsorbTool *)_absorbTool_ {
  [self removeTool:absorbTool];
  absorbTool = _absorbTool_;
  [self addTool:absorbTool];
}

@dynamic splitTool;

- (ELSplitTool *)splitTool {
  return splitTool;
}

- (void)setSplitTool:(ELSplitTool *)_splitTool_ {
  [self removeTool:splitTool];
  splitTool = _splitTool_;
  [self addTool:splitTool];
}

@dynamic spinTool;

- (ELSpinTool *)spinTool {
  return spinTool;
}

- (void)setSpinTool:(ELSpinTool *)_spinTool_ {
  [self removeTool:spinTool];
  spinTool = _spinTool_;
  [self addTool:spinTool];
}

// Hexes form a grid

- (void)connectToHex:(ELHex *)_hex direction:(Direction)_direction {
  neighbours[_direction] = _hex;
}

- (void)connectNeighbour:(ELHex *)_hex direction:(Direction)_direction {
  [self connectToHex:_hex direction:_direction];
  // [_hex connectToHex:self direction:INVERSE_DIRECTION(_direction)];
}

- (ELHex *)neighbour:(Direction)_direction_ {
  ASSERT_VALID_DIRECTION( _direction_ );
  return neighbours[_direction_];
}

- (NSArray *)triad:(int)_triad_ {
  NSMutableArray *hexes = [[NSMutableArray alloc] init];
  [hexes addObject:[self note]];
  switch( _triad_) {
    case 1:
      if( [self neighbour:N] ) {
        [hexes addObject:[[self neighbour:N] note]];
      }
      if( [self neighbour:NE] ) {
        [hexes addObject:[[self neighbour:NE] note]];
      }
      break;
    
    case 2:
      if( [self neighbour:NE] ) {
        [hexes addObject:[[self neighbour:NE] note]];
      }
      if( [self neighbour:SE] ) {
        [hexes addObject:[[self neighbour:SE] note]];
      }
      break;
    
    case 3:
      if( [self neighbour:SE] ) {
        [hexes addObject:[[self neighbour:SE] note]];
      }
      if( [self neighbour:S] ) {
        [hexes addObject:[[self neighbour:S] note]];
      }
      break;
    
    case 4:
      if( [self neighbour:S] ) {
        [hexes addObject:[[self neighbour:S] note]];
      }
      if( [self neighbour:SW] ) {
        [hexes addObject:[[self neighbour:SW] note]];
      }
      break;
    
    case 5:
      if( [self neighbour:SW] ) {
        [hexes addObject:[[self neighbour:SW] note]];
      }
      if( [self neighbour:NW] ) {
        [hexes addObject:[[self neighbour:NW] note]];
      }
      break;
    
    case 6:
      if( [self neighbour:NW] ) {
        [hexes addObject:[[self neighbour:NW] note]];
      }
      if( [self neighbour:N] ) {
        [hexes addObject:[[self neighbour:N] note]];
      }
      break;
  }
  
  return hexes;
}

// Tool support

- (BOOL)shouldBeSaved {
  return [tools count] > 0;
}

- (void)run:(ELPlayhead *)_playhead_ {
  [noteTool run:_playhead_];
  [splitTool run:_playhead_];
  [reboundTool run:_playhead_];
  [absorbTool run:_playhead_];
  [spinTool run:_playhead_];
}

- (void)addTool:(ELTool *)_tool_ {
  if( _tool_ ) {
    [tools addObject:_tool_];
    [_tool_ addedToLayer:layer atPosition:self];

    for( NSString *keyPath in [_tool_ observableValues] ) {
      [_tool_ addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil]; //)
    }
  }
}

- (void)removeTool:(ELTool *)_tool_ {
  if( _tool_ ) {
    for( NSString *keyPath in [_tool_ observableValues] ) {
      [_tool_ removeObserver:self forKeyPath:keyPath];
    }
    [_tool_ removedFromLayer:layer];
    [tools removeObject:_tool_];
  }
}

- (void)observeValueForKeyPath:(NSString *)_keyPath_ ofObject:(id)_object_ change:(NSDictionary *)_changes_ context:(id)_context_ {
  [layer needsDisplay];
}

- (void)removeAllTools {
  [self setGenerateTool:nil];
  [self setNoteTool:nil];
  [self setReboundTool:nil];
  [self setAbsorbTool:nil];
  [self setSplitTool:nil];
  [self setSpinTool:nil];
}

- (NSArray *)tools {
  return [tools copy];
}

- (NSArray *)toolsExceptType:(NSString *)_type_ {
  NSPredicate *typePredicate = [NSPredicate predicateWithFormat:@"toolType != %@",_type_];
  return [tools filteredArrayUsingPredicate:typePredicate];
}

- (void)copyToolsFrom:(ELHex *)_hex_ {
  [self setGenerateTool:[[_hex_ generateTool] mutableCopy]];
  [self setNoteTool:[[_hex_ noteTool] mutableCopy]];
  [self setReboundTool:[[_hex_ reboundTool] mutableCopy]];
  [self setAbsorbTool:[[_hex_ absorbTool] mutableCopy]];
  [self setSplitTool:[[_hex_ splitTool] mutableCopy]];
  [self setSpinTool:[[_hex_ spinTool] mutableCopy]];
}

- (NSString *)description {
  return [NSString stringWithFormat:@"Hex %d,%d - %@", col, row, note];
}

// Playheads

- (void)playheadEntering:(ELPlayhead *)_playhead {
  [playheads addObject:_playhead];
}

- (void)playheadLeaving:(ELPlayhead *)_playhead {
  [playheads removeObject:_playhead];
}

// Context menu

- (NSMenu *)contextMenu {
  NSMenu *menu = [[NSMenu alloc] initWithTitle:@"Context Menu"];
  
  NSMenuItem *item = [menu insertItemWithTitle:@"Beep" action:@selector(beep:) keyEquivalent:@"" atIndex:0];
  [item setTarget:self];
  
  return menu;
}

// Drawing

- (void)drawText:(NSString *)_text_ withAttributes:(NSMutableDictionary *)_attributes_ {
  NSMutableDictionary *textAttributes = [[NSMutableDictionary alloc] init];
  [textAttributes setObject:[NSFont fontWithName:@"Helvetica" size:9]
                 forKey:NSFontAttributeName];
  [textAttributes setObject:[_attributes_ objectForKey:ELDefaultToolColor]
                 forKey:NSForegroundColorAttributeName];
  
  NSSize strSize = [_text_ sizeWithAttributes:textAttributes];
  
  NSPoint strOrigin;
  strOrigin.x = [path bounds].origin.x + ( [path bounds].size.width - strSize.width ) / 2;
  strOrigin.y = [path bounds].origin.y + ( [path bounds].size.height - strSize.height ) / 2;
  
  [_text_ drawAtPoint:strOrigin withAttributes:textAttributes];
}

int mapPathSection( Direction d ) {
  switch( d % 6 ) {
    case N:
    return 2;
    case NE:
    return 1;
    case SE:
    return 0;
    case S:
    return 5;
    case SW:
    return 4;
    case NW:
    return 3;
    default:
    NSLog( @"Well this shouldn't happen! (Direction = %d)", d );
    assert( NO );
  }
}

NSString* elementDescription( NSBezierPathElement elt ) {
  switch( elt ) {
    case NSMoveToBezierPathElement:
      return @"MOVE";
    case NSLineToBezierPathElement:
      return @"LINE";
    case NSCurveToBezierPathElement:
      return @"CURVE";
    case NSClosePathBezierPathElement:
      return @"CLOSE";
    default:
    NSLog( @"Well this shouldn't happen either" );
    assert( NO );
  }
}

// Draw a triangle to represent the direction a playhead might leave a hex
//
// The strategy is to draw a triangle heading north, then rotate it
// appropriately.
//
- (void)drawTriangleInDirection:(Direction)_direction_ withAttributes:(NSDictionary *)_attributes_ {
  NSPoint base1 = NSMakePoint( [self centre].x - [self radius] / 4, [self centre].y + [self radius] / 2 );
  NSPoint base2 = NSMakePoint( [self centre].x + [self radius] / 4, [self centre].y + [self radius] / 2 );
  NSPoint apex = NSMakePoint( [self centre].x, [self centre].y + 3 * [self radius] / 4 );
  
  NSBezierPath *trianglePath = [NSBezierPath bezierPath];
  [trianglePath moveToPoint:base1];
  [trianglePath lineToPoint:apex];
  [trianglePath lineToPoint:base2];
  [trianglePath lineToPoint:base1];
  [trianglePath closePath];
  
  if( _direction_ != 0 ) {
    NSAffineTransform *transform = [NSAffineTransform transform];
    [transform translateXBy:centre.x yBy:centre.y];
    [transform rotateByDegrees:(360.0 - ( _direction_ * 60 ))];
    [transform translateXBy:-centre.x yBy:-centre.y];
    [trianglePath transformUsingAffineTransform:transform];
  }
  
  [[_attributes_ objectForKey:ELDefaultToolColor] set];
  [trianglePath setLineWidth:2.0];
  [trianglePath stroke];
}

- (void)drawOnHoneycombView:(LMHoneycombView *)_view_ withAttributes:(NSMutableDictionary *)_attributes_ {
  if( [playheads count] > 0 ) {
    int minTTL = 5;
    for( ELPlayhead *playhead in playheads ) {
      if( [playhead TTL] < minTTL ) {
        minTTL = [playhead TTL];
      }
    }
    
    CGFloat fader = 0.5 + ( 0.5 * ((float)minTTL/5) );
    
    [_attributes_ setObject:[[_attributes_ objectForKey:ELDefaultActivePlayheadColor] colorWithAlphaComponent:fader] forKey:LMHoneycombViewDefaultColor];
  } else {
    [_attributes_ setObject:[(ELSurfaceView *)_view_ octaveColor:[note octave]] forKey:LMHoneycombViewDefaultColor];
  }
  // } else if( [[self tools] count] > 0 ) {
  //   [_attributes_ setObject:[NSColor colorWithDeviceRed:(40.0/255) green:(121.0/255) blue:(241.0/255) alpha:0.8] forKey:LMHoneycombViewDefaultColor];
  // }
  
  [super drawOnHoneycombView:_view_ withAttributes:_attributes_];
  
  if( [[layer player] showNotes] ) {
    [self drawText:[note name] withAttributes:_attributes_];
  }
  
  [[self tools] makeObjectsPerformSelector:@selector(drawWithAttributes:) withObject:_attributes_];
}

// Implement the ELXmlData protocol

- (NSXMLElement *)xmlRepresentation {
  NSXMLElement *cellElement = [NSXMLNode elementWithName:@"cell"];
  NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
  [attributes setObject:[NSNumber numberWithInt:col] forKey:@"col"];
  [attributes setObject:[NSNumber numberWithInt:row] forKey:@"row"];
  [cellElement setAttributesAsDictionary:attributes];
  
  for( ELTool *tool in [self tools] ) {
    [cellElement addChild:[tool xmlRepresentation]];
  }
  
  return cellElement;
}

// This method is slightly different in that we know the object already
// exists within the layer, we're sort of over-initing it
- (id)initWithXmlRepresentation:(NSXMLElement *)_representation_ parent:(id)_parent_ player:(ELPlayer *)_player_ {
  NSArray *nodes;
  
  nodes = [_representation_ nodesForXPath:@"generate" error:nil];
  if( [nodes count] > 0 ) {
    [self setGenerateTool:[[ELTool toolAlloc:@"generate"] initWithXmlRepresentation:(NSXMLElement *)[nodes objectAtIndex:0] parent:self player:_player_]];
  }
  
  nodes = [_representation_ nodesForXPath:@"note" error:nil];
  if( [nodes count] > 0 ) {
    [self setNoteTool:[[ELTool toolAlloc:@"note"] initWithXmlRepresentation:(NSXMLElement *)[nodes objectAtIndex:0] parent:self player:_player_]];
  }
  
  nodes = [_representation_ nodesForXPath:@"rebound" error:nil];
  if( [nodes count] > 0 ) {
    [self setReboundTool:[[ELTool toolAlloc:@"rebound"] initWithXmlRepresentation:(NSXMLElement *)[nodes objectAtIndex:0] parent:self player:_player_]];
  }
  
  nodes = [_representation_ nodesForXPath:@"absorb" error:nil];
  if( [nodes count] > 0 ) {
    [self setAbsorbTool:[[ELTool toolAlloc:@"absorb"] initWithXmlRepresentation:(NSXMLElement *)[nodes objectAtIndex:0] parent:self player:_player_]];
  }
  
  nodes = [_representation_ nodesForXPath:@"split" error:nil];
  if( [nodes count] > 0 ) {
    [self setSplitTool:[[ELTool toolAlloc:@"split"] initWithXmlRepresentation:(NSXMLElement *)[nodes objectAtIndex:0] parent:self player:_player_]];
  }
  
  nodes = [_representation_ nodesForXPath:@"spin" error:nil];
  if( [nodes count] > 0 ) {
    [self setSpinTool:[[ELTool toolAlloc:@"spin"] initWithXmlRepresentation:(NSXMLElement *)[nodes objectAtIndex:0] parent:self player:_player_]];
  }
  
  return self;
}

// Actions

- (IBAction)beep:(id)sender {
  NSBeep();
}

@end
