//
//  ELFilterDesignerController.m
//  Elysium
//
//  Created by Matt Mower on 23/09/2008.
//  Copyright 2008 LucidMac Software. All rights reserved.
//

#import "ELFilterDesignerController.h"

#import "ELRangedKnob.h"

#import "ELSquareFilter.h"
#import "ELSawFilter.h"
#import "ELSineFilter.h"
#import "ELListFilter.h"
#import "ELRandomFilter.h"

@implementation ELFilterDesignerController

- (id)initWithKnob:(ELRangedKnob *)_knob_ {
  if( ( self = [self initWithWindowNibName:@"FilterDesigner"] ) ) {
    knob = _knob_;
    
    NSLog( @"Knob = %@, Min=%f, Max=%f, Stepping=%f, Filter = %@", knob, [knob minimum], [knob maximum], [knob stepping], [knob filter] );
    
    if( [knob filter] ) {
      selectedTag = [[knob filter] type];
    } else {
      selectedTag = nil;
    }
    
    if( [selectedTag isEqualToString:@"Square"] ) {
      squareFilter = (ELSquareFilter *)[knob filter];
    } else {
      squareFilter = [[ELSquareFilter alloc] initEnabled:YES minimum:[knob minimum] maximum:[knob maximum] rest:30000 sustain:30000];
    }
    
    if( [selectedTag isEqualToString:@"Saw"] ) {
      sawFilter = (ELSawFilter *)[knob filter];
    } else {
      sawFilter = [[ELSawFilter alloc] initEnabled:YES minimum:[knob minimum] maximum:[knob maximum] rest:30000 attack:30000 sustain:30000 decay:30000];
    }
    
    if( [selectedTag isKindOfClass:@"Sine"] ) {
      sineFilter = (ELSineFilter *)[knob filter];
    } else {
      sineFilter = [[ELSineFilter alloc] initEnabled:YES minimum:[knob minimum] maximum:[knob maximum] period:30000];
    }
    
    if( [selectedTag isEqualToString:@"List"] ) {
      listFilter = (ELListFilter *)[knob filter];
    } else {
      listFilter = [[ELListFilter alloc] initEnabled:YES values:[NSArray array]];
    }
    
    if( [selectedTag isEqualToString:@"Random"] ) {
      randomFilter = (ELRandomFilter *)[knob filter];
    } else {
      randomFilter = [[ELRandomFilter alloc] initEnabled:YES minimum:[knob minimum] maximum:[knob maximum]];
    }
  }
  
  return self;
}

- (void)awakeFromNib {
  
  // Determine whether the cell formatters for the fields should allow
  // decimals for float values or not
  for( NSTabViewItem *item in [tabView tabViewItems] ) {
    [self setView:[item view] cellsAllowFloats:[knob encodesType:@encode(float)]];
  }
  
  if( selectedTag ) {
    [tabView selectTabViewItemWithIdentifier:selectedTag];
  }
}

@synthesize knob;

@synthesize squareFilter;
@synthesize sawFilter;
@synthesize sineFilter;
@synthesize listFilter;
@synthesize randomFilter;

- (void)setView:(NSView *)_view_ cellsAllowFloats:(BOOL)_allowFloats_ {
  for( NSView *view in [_view_ subviews] ) {
    [self setView:view cellsAllowFloats:_allowFloats_];
  }
  
  id cell, formatter;
  if( [_view_ isKindOfClass:[NSControl class]] ) {
    if( ( cell = [(NSControl *)_view_ cell] ) ) {
      if( ( formatter = [cell formatter] )   ) {
        if( [formatter isKindOfClass:[NSNumberFormatter class]] ) {
          [formatter setAllowsFloats:_allowFloats_];
        }
      }
    }
  }
}

- (IBAction)save:(id)_sender_ {
  NSString *tabId = (NSString *)[[tabView selectedTabViewItem] identifier];
  if( [tabId isEqualToString:@"Square"] ) {
    [knob setFilter:squareFilter];
  } else if( [tabId isEqualToString:@"Saw"] ) {
    [knob setFilter:sawFilter];
  } else if( [tabId isEqualToString:@"Sine"] ) {
    [knob setFilter:sineFilter];
  } else if( [tabId isEqualToString:@"List"] ) {
    [knob setFilter:listFilter];
  } else if( [tabId isEqualToString:@"Random"] ) {
    [knob setFilter:randomFilter];
  }
  
  [self close];
}

- (IBAction)cancel:(id)_sender_ {
  [self close];
}

@end