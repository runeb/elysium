//
//  ELRandomFilter.m
//  Elysium
//
//  Created by Matt Mower on 21/10/2008.
//  Copyright 2008 LucidMac Software. All rights reserved.
//

#import "ELRandomFilter.h"

@implementation ELRandomFilter

+ (void)initialize {
  srandomdev();
}

- (float)generate {
  long lrange = range * 100;
  return minimum + ( ( random() % lrange ) / 100 );
}

@end
