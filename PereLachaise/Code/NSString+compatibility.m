//
//  NSString+compatibility.m
//  PereLachaise
//
//  Created by Maxime Le Moine on 13/04/2014.
//  Copyright (c) 2014 SuperLachaise contributors.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import "NSString+compatibility.h"

#import "PLDeprecatedMethods.h"

@implementation NSString (compatibility)

- (CGSize)compatibilitySizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size
{
    PLTraceIn(@"");
    CGSize result;
    
    if (PLPostVersion7) {
        CGRect rect = [self
                boundingRectWithSize:size
                options:NSStringDrawingUsesLineFragmentOrigin
                attributes:@{ NSFontAttributeName:font }
                context:nil];
        result = rect.size;
    } else {
        result = [(id<PLDeprecatedMethods>)self sizeWithFont:font constrainedToSize:size];
    }
    
    PLTraceOut(@"result: %f %f", result.width, result.height);
    return result;
}

@end
