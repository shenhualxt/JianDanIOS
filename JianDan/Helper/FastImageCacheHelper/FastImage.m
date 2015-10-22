//
//  TestImage.m
//  FICTest
//
//  Created by 刘献亭 on 15/9/25.
//  Copyright © 2015年 刘献亭. All rights reserved.
//

#import "FastImage.h"
#import "FastImageCache/FICUtilities.h"

@implementation FastImage

- (id)initWithResUrl:(NSString *)resUrl {
    if (self = [super init]) {
        self.sourceUrl = resUrl;
    }
    return self;
}

- (NSString *)path {
    return [NSTemporaryDirectory() stringByAppendingPathComponent:[self suffixPath:_sourceUrl]];
}

- (NSString *)suffixPath:(NSString *)url {
    return [[url stringByReplacingOccurrencesOfString:@"/" withString:@"_"] stringByReplacingOccurrencesOfString:@"." withString:@"_"];
}

- (BOOL)imageExsited {
    return [[NSFileManager defaultManager] fileExistsAtPath:[self path]];
}

- (UIImage *)sourceImage {
    return [UIImage imageWithContentsOfFile:[self path]];
}


#pragma mark -FICEntity delegate

//1,UUID是一个FICEntity对象的唯一标识，但是sourceImageUUID不是。因为一个Entity对象的sourceUrl是可以随时变动的。比如用户更新自己的头像。
//2,UUID和sourceImageUUID的hash计算会比较耗资源，只需要计算一次，然后把结果存在我们的模型对象里，比如CoreData对象。
- (NSString *)UUID {
    CFUUIDBytes UUIDBytes = FICUUIDBytesFromMD5HashOfString(_sourceUrl);
    return FICStringWithUUIDBytes(UUIDBytes);
}

- (NSString *)sourceImageUUID {
    return [self UUID];
}

- (NSURL *)sourceImageURLWithFormatName:(NSString *)formatName {
    return [NSURL URLWithString:_sourceUrl];
}

//返回一个FICEntityImageDrawingBlock代码块，最终渲染图片时FastImageCache会执行这个代码块。我们对图片的裁剪、压缩、加圆角或者加水印等操作，都是在这里完成。
- (FICEntityImageDrawingBlock)drawingBlockForImage:(UIImage *)image withFormatName:(NSString *)formatName {
    return ^(CGContextRef contextRef, CGSize contextSize) {
        CGSize size = caculateSize(image.size, contextSize);
        CGRect contextBounds = CGRectZero;

        contextBounds.origin = CGPointMake((contextSize.width - size.width) / 2, (contextSize.height - size.height) / 2);
        contextBounds.size = size;
        CGContextClearRect(contextRef, contextBounds);
        CGContextSetFillColorWithColor(contextRef, [[UIColor purpleColor] CGColor]);
        CGContextFillRect(contextRef, CGRectMake(0, 0, contextSize.width, contextSize.height));

        UIGraphicsPushContext(contextRef);
        [image drawInRect:contextBounds];
        UIGraphicsPopContext();
    };
}

static CGSize caculateSize(CGSize imageSize, CGSize contextSize) {
    CGSize size;
    CGFloat rate = imageSize.width / imageSize.height;
    if (rate > contextSize.width / contextSize.height) {
        size.width = contextSize.width;
        size.height = size.width / rate;
    } else {
        size.height = contextSize.height;
        size.width = size.height * rate;
    }
    return size;
}


@end
