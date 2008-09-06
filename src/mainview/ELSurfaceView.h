//
//  ELSurfaceView.h
//  Elysium
//
//  Created by Matt Mower on 29/08/2008.
//  Copyright 2008 LucidMac Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <HoneycombView/LMHoneycombView.h>

@class ELHex;

@interface ELSurfaceView : LMHoneycombView {
  NSColor *toolColor;
  NSEvent *savedEvent;
}

@property (assign) NSColor *toolColor;

- (ELHex *)cellUnderMouseLocation:(NSPoint)point;
- (ELHex *)selectedHex;

- (void)addTool:(int)toolTag toCell:(ELHex *)cell;
- (void)dragFromHex:(ELHex *)sourceHex to:(ELHex *)targetHex with:(NSDragOperation)modifiers;

- (void)cellWasUpdated:(NSNotification*)notification;
    
@end
