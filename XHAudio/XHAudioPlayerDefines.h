//
//  XHAudioPlayerDefines.h
//  XHKitDemo
//
//  Created by 向洪 on 2019/11/1.
//  Copyright © 2019 向洪. All rights reserved.
//

#ifndef XHAudioPlayerDefines_h
#define XHAudioPlayerDefines_h

static inline NSString *XHAudioBundlePathForResource(NSString *name) {
    NSBundle *bundle = [NSBundle bundleForClass:NSClassFromString(@"XHAudioPlayer")];
    NSURL *url = [bundle URLForResource:@"xh.audio" withExtension:@"bundle"];
    bundle = [NSBundle bundleWithURL:url];
    name = [UIScreen mainScreen].scale==3?[name stringByAppendingString:@"@3x"]:[name stringByAppendingString:@"@2x"];
    NSString *imagePath = [bundle pathForResource:name ofType:@"png"];
    return imagePath;
}

#define XHAudioImage(name) [UIImage imageWithContentsOfFile:XHAudioBundlePathForResource(name)]

#endif /* XHAudioPlayerDefines_h */
