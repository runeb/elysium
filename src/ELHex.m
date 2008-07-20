//
//  ELHex.m
//  Elysium
//
//  Created by Matt Mower on 20/07/2008.
//  Copyright 2008 LucidMac Software. All rights reserved.
//

#import "Elysium.h"

#import "ELHex.h"
#import "ELNote.h"

@implementation ELHex

- (id)initWithLayer:(ELLayer *)_layer note:(ELNote *)_note col:(int)_col row:(int)_row {
  if( self = [super init] ) {
    layer = _layer;
    note = _note;
    col = _col;
    row = _row;
  }
  
  return self;
}

- (ELHex *)neighbour:(Direction)direction {
  switch( direction ) {
    case N: return [self neighbourNorth];
    case NE: return [self neighbourNorthEast];
    case SE: return [self neighbourSouthEast];
    case S: return [self neighbourSouth];
    case SW: return [self neighbourSouthWest];
    case NW: return [self neighbourNorthWest];
    default: return nil;
  }
}

- (ELHex *)neighbourNorth {
  return nil;
}

- (ELHex *)neighbourNorthEast {
  return nil;
}

- (ELHex *)neighbourSouthEast {
  return nil;
}

- (ELHex *)neighbourSouth {
  return nil;
}

- (ELHex *)neighbourSouthWest {
  return nil;
}

- (ELHex *)neighbourNorthWest {
  return nil;
}

@end
