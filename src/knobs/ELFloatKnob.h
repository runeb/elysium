//
//  ELFloatKnob.h
//  Elysium
//
//  Created by Matt Mower on 13/09/2008.
//  Copyright 2008 LucidMac Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "ELRangedKnob.h"
#import "Elysium.h"

@interface ELFloatKnob : ELRangedKnob <NSMutableCopying> {
  float value;
}

- (id)initWithName:(NSString *)name
        floatValue:(float)value
           minimum:(float)minimum
           maximum:(float)maximum
          stepping:(float)stepping
        linkedKnob:(ELKnob *)knob
           enabled:(BOOL)_enabled
        hasEnabled:(BOOL)_hasEnabled
       linkEnabled:(BOOL)_linkEnabled
          hasValue:(BOOL)_hasValue
         linkValue:(BOOL)_linkValue
            oscillator:(ELOscillator *)filter
        linkOscillator:(BOOL)linkFilter;

- (id)initWithName:(NSString *)name floatValue:(float)value minimum:(float)minimum maximum:(float)maximum stepping:(float)stepping;
- (id)initWithName:(NSString *)name linkedToFloatKnob:(ELFloatKnob *)knob;

@property float minimum;
@property float maximum;
@property float stepping;

- (float)value;
- (float)filteredValue;
- (float)filteredValue:(float)value;
- (void)setValue:(float)value;

@end
