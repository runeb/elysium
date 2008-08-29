//
//  ELHexStartInspectorPlugin.h
//  Elysium
//
//  Created by Matt Mower on 11/08/2008.
//  Copyright 2008 LucidMac Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "ELInspectorPane.h"

@class ELStartTool;

@interface ELHexStartInspectorPlugin : ELInspectorPane {
  IBOutlet  NSButton    *enabledCheckbox;
  IBOutlet  NSTextField *ttlField;
}

@end