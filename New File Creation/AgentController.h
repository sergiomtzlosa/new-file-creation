//
//  AgentController.h
//  New File Creation
//
//  Created by sid on 07/08/15.
//  Copyright (c) 2015 com.sergiomtzlosa.filecreation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AgentController : NSObject

+ (BOOL)checkLoginForIdentifier:(NSString *)applicationIdentifer;

+ (BOOL)enableLoginItemForIdentifier:(NSString *)applicationIdentifier forStatus:(BOOL)status;

@end
