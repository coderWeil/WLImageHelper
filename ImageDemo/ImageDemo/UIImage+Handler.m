//
//  UIImage+Handler.m
//  ImageDemo
//
//  Created by weil on 2019/12/4.
//  Copyright © 2019 AllYoga. All rights reserved.
//

#import "UIImage+Handler.h"

@implementation UIImage (Handler)
+ (UIImage *)wl_captureImageFromView:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, [UIScreen mainScreen].scale);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *captureImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return captureImage;
}
+ (UIImage *) wl_captureImageFromScroll:(UIScrollView *)scrollView
                                        fregment:(BOOL)fregment {
    NSMutableArray<UIImage *> *images = @[].mutableCopy;
    CGFloat contentHeight = scrollView.contentSize.height;
    CGPoint savedContentOffset = scrollView.contentOffset;
    CGRect savedFrame = scrollView.frame;
    if (!fregment) {
        UIGraphicsBeginImageContextWithOptions(scrollView.contentSize, NO, [UIScreen mainScreen].scale);
        scrollView.contentOffset = CGPointZero;
        scrollView.frame = savedFrame;
        [scrollView.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *captureImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        scrollView.contentOffset = savedContentOffset;
        scrollView.frame = savedFrame;
        scrollView.layer.contents = nil;
        return captureImage;
        return nil;
    }
    while (contentHeight > 0) {//将滚动视图分页渲染
        UIGraphicsBeginImageContextWithOptions(scrollView.bounds.size, NO, [UIScreen mainScreen].scale);
        [scrollView.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        scrollView.layer.contents = nil;//释放渲染内存
        [images addObject:image];
        [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y + scrollView.bounds.size.height)];
        contentHeight -= scrollView.bounds.size.height;
    }
    //将分段的图片拼接起来
    UIGraphicsBeginImageContextWithOptions(scrollView.contentSize, NO, [UIScreen mainScreen].scale);
    [images enumerateObjectsUsingBlock:^(UIImage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj drawInRect:CGRectMake(0, scrollView.bounds.size.height * idx, scrollView.bounds.size.width, scrollView.bounds.size.height)];
    }];
    UIImage *captureImage = UIGraphicsGetImageFromCurrentImageContext();
    scrollView.contentOffset = savedContentOffset;
    UIGraphicsEndImageContext();
    return captureImage;
}
+ (UIImage *)wl_combineSourceImage:(UIImage *)sourceImage
                     combinedImage:(UIImage *)combinedImage {
    CGFloat width = sourceImage.size.width;
    CGFloat height = sourceImage.size.height + combinedImage.size.height;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), NO, [UIScreen mainScreen].scale);
    [sourceImage drawInRect:CGRectMake(0, 0, width, sourceImage.size.height)];
    height = combinedImage.size.height*width/combinedImage.size.width;
    [combinedImage drawInRect:CGRectMake(0, sourceImage.size.height, width, height)];
    UIImage *destinatedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return destinatedImage;
}
static void RGBToHSV( float r, float g, float b, float *h, float *s, float *v ) {
    float min, max, delta;
    min = MIN( r, MIN( g, b ));
    max = MAX( r, MAX( g, b ));
    *v = max;               // v
    delta = max - min;
    if( max != 0 )
        *s = delta / max;       // s
    else {
        // r = g = b = 0        // s = 0, v is undefined
        *s = 0;
        *h = -1;
        return;
    }
    if( r == max )
        *h = ( g - b ) / delta;     // between yellow & magenta
    else if( g == max )
        *h = 2 + ( b - r ) / delta; // between cyan & yellow
    else
        *h = 4 + ( r - g ) / delta; // between magenta & cyan
    *h *= 60;               // degrees
    if( *h < 0 )
        *h += 360;
}
- (UIColor *)wl_mostColor {
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1
    int bitmapInfo = kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast;
#else
    int bitmapInfo = kCGImageAlphaPremultipliedLast;
#endif
    CGSize size = CGSizeMake(self.size.width*0.5, self.size.height*0.5);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, size.width, size.height, 8, size.width*4, colorSpace, bitmapInfo);
    CGRect drawRect = CGRectMake(0, 0, size.width, size.height);
    CGContextDrawImage(context, drawRect, self.CGImage);
    CGColorSpaceRelease(colorSpace);
    unsigned char *data = CGBitmapContextGetData(context);
    if (data == NULL) {
        return nil;
    }
    NSArray *mostColor = nil;
    float maxScore=0;
    for (int x=0; x<size.width*size.height; x++) {
        int offset = 4*x;
        int red = data[offset];
        int green = data[offset+1];
        int blue = data[offset+2];
        int alpha =  data[offset+3];
        if (alpha<25)continue;
        float h,s,v;
        RGBToHSV(red, green, blue, &h, &s, &v);
        float y = MIN(abs(red*2104+green*4130+blue*802+4096+131072)>>13, 235);
        y= (y-16)/(235-16);
        if (y>0.9) continue;
        float score = (s+0.1)*x;
        if (score > maxScore) {
            maxScore = score;
        }
        mostColor = @[@(red),@(green),@(blue),@(alpha)];
    }
    CGContextRelease(context);
    return [UIColor colorWithRed:([mostColor[0] intValue]/255.0f) green:([mostColor[1] intValue]/255.0f) blue:([mostColor[2] intValue]/255.0f) alpha:([mostColor[3] intValue]/255.0f)];;
}
- (UIColor *)wl_mostColorInRect:(CGRect)rect {
    UIImage *rectImage = [self _imageFromRect:rect];
    if (rectImage) {
        return [rectImage wl_mostColor];
    }
    return nil;
}
- (UIImage *) _imageFromRect:(CGRect)rect {
    CGImageRef imageRef = self.CGImage;
    CGImageRef newImageRef = CGImageCreateWithImageInRect(imageRef, rect);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    CGImageRelease(newImageRef);
    return newImage;
}
- (UIColor *)wl_mostColorInPoint:(CGPoint)point {
    if (!CGRectContainsPoint(CGRectMake(0.0f, 0.0f, self.size.width, self.size.height), point)) {
        return nil;
    }
    NSInteger pointX = trunc(point.x);
    NSInteger pointY = trunc(point.y);
    CGImageRef cgImage = self.CGImage;
    NSUInteger width = self.size.width;
    NSUInteger height = self.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    int bytesPerPixel = 4;
    int bytesPerRow = bytesPerPixel * 1;
    NSUInteger bitsPerComponent = 8;
    unsigned char pixelData[4] = { 0, 0, 0, 0 };
    CGContextRef context = CGBitmapContextCreate(pixelData, 1, 1, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast |     kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    CGContextTranslateCTM(context, -pointX, pointY-(CGFloat)height);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, (CGFloat)width, (CGFloat)height), cgImage);
    CGContextRelease(context);
    CGFloat red   = (CGFloat)pixelData[0] / 255.0f;
    CGFloat green = (CGFloat)pixelData[1] / 255.0f;
    CGFloat blue  = (CGFloat)pixelData[2] / 255.0f;
    CGFloat alpha = (CGFloat)pixelData[3] / 255.0f;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}
- (UIColor *)wl_mainColor {
    return nil;
}
- (UIImage *)wl_changeBrightness:(CGFloat)brightness
                      saturation:(CGFloat)saturation
                        contrast:(CGFloat)contrast {
    CIImage *sourceImage = [CIImage imageWithCGImage:self.CGImage];
    CIFilter * filter = [CIFilter filterWithName:@"CIColorControls"];
    [filter setValue:sourceImage forKey:kCIInputImageKey];
    //  饱和度      0---2
    [filter setValue:[NSNumber numberWithFloat:saturation] forKey:@"inputSaturation"];
    //  亮度  10   -1---1
    [filter setValue:[NSNumber numberWithFloat:brightness] forKey:@"inputBrightness"];
    //  对照度 -11  0---4
    [filter setValue:[NSNumber numberWithFloat:contrast] forKey:@"inputContrast"];
    // 得到过滤后的图片
    CIImage *outputImage = [filter outputImage];
    // 转换图片, 创建基于GPU的CIContext对象
    CIContext *context = [CIContext contextWithOptions: nil];
    CGImageRef outImageRef = [context createCGImage:outputImage fromRect:[outputImage extent]];
    UIImage *destinatedImage = [UIImage imageWithCGImage:outImageRef];
    // 释放C对象
    CGImageRelease(outImageRef);
    return destinatedImage;
}
- (UIImage *)wl_changeImageWithHueOffset:(CGFloat)hueOffset
                        saturationOffset:(CGFloat)saturationOffset
                        brightnessOffset:(CGFloat)brightnessOffset {
    size_t width = self.size.width;
    size_t height = self.size.height;
    unsigned char *data = calloc(width*height*4, sizeof(unsigned char));
    size_t bitsPerComponent = 8;
    size_t bytePerRow = width*4;
    CGColorSpaceRef spaceRef = CGColorSpaceCreateDeviceRGB();
    CGContextRef contextRef = CGBitmapContextCreate(data, width, height, bitsPerComponent, bytePerRow, spaceRef, kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(contextRef, CGRectMake(0, 0, width, height), self.CGImage);
    for (size_t i = 0; i < height; ++i) {
        for (size_t j = 0; j < width; ++j) {
            size_t pixelIndex = i*width*4 + j*4;
            unsigned char red = data[pixelIndex];
            unsigned char green = data[pixelIndex + 1];
            unsigned char blue = data[pixelIndex + 2];
            unsigned char a = data[pixelIndex + 3];
            if (a == 0) {
                continue;
            }
            UIColor *color = [[UIColor alloc] initWithRed:red green:green blue:blue alpha:a];
            CGFloat hue, saturation, brightness, alpha;
            BOOL success = [color getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
            if (success) {//计算新的h, s, b, a值
                CGFloat (^block) (CGFloat, CGFloat) = ^(CGFloat value, CGFloat offset) {
                    if (offset) {
                        value = value*360 + offset;
                        if (value > 360) {
                            value -= 360;
                        }
                        value /= 360;
                    }
                    return value;
                };
                hue = block(hue, hueOffset);
                saturation = block(saturation, saturationOffset);
                brightness = block(brightness, brightnessOffset);
                color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:alpha];
                CGFloat r, g, b;
                BOOL success = [color getRed:&r green:&g blue:&b alpha:&alpha];
                if (success) {
                    data[pixelIndex] = r;
                    data[pixelIndex + 1] = g;
                    data[pixelIndex + 2] = b;
                    continue;
                }
            }
            data[pixelIndex] = red;
            data[pixelIndex + 1] = green;
            data[pixelIndex + 2] = blue;
        }
    }
    return [UIImage imageWithCGImage:CGBitmapContextCreateImage(contextRef)];
}
- (UIImage *)wl_changeImageWithTintColor:(UIColor *)tintColor
                               blendMode:(CGBlendMode)blendMode {
    UIGraphicsBeginImageContextWithOptions(self.size, NO, [UIScreen mainScreen].scale);
    [tintColor setFill];
    CGRect bounds = CGRectMake(0, 0, self.size.width, self.size.height);
    UIRectFill(bounds);
    [self drawInRect:bounds blendMode:blendMode alpha:1.0];
    if (blendMode != kCGBlendModeDestinationIn) {
        [self drawInRect:bounds blendMode:kCGBlendModeDestinationIn alpha:1.0];
    }
    UIImage *destinatedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return destinatedImage;
}
- (UIImage *)wl_removeColorWithMinHue:(float)minHue
                               maxHue:(float)maxHue {
    CIImage *sourceImage = [CIImage imageWithCGImage:self.CGImage];
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *renderImage = [self _outPutImageWithOriginalImage:sourceImage minHue:minHue maxHue:maxHue];
    CGImageRef renderImageRef = [context createCGImage:renderImage fromRect:sourceImage.extent];
    UIImage *destinatedImage = [UIImage imageWithCGImage:renderImageRef];
    return destinatedImage;
}
struct CubeMap {
    int length;
    float dimension;
    float *data;
};
- (CIImage *) _outPutImageWithOriginalImage:(CIImage *)originalImage
                                minHue:(float)minHue
                                maxHue:(float)maxHue {
    struct CubeMap cubeMap = createCubMap(minHue, maxHue);
    const unsigned int size = 64;
    NSData *data = [NSData dataWithBytesNoCopy:cubeMap.data
                                        length:cubeMap.length
                                  freeWhenDone:YES];
    CIFilter *colorCube = [CIFilter filterWithName:@"CIColorCube"];
    [colorCube setValue:@(size) forKey:@"inputCubeDimension"];
    [colorCube setValue:data forKey:@"inputCubeData"];
    [colorCube setValue:originalImage forKey:kCIInputImageKey];
    CIImage *result = [colorCube valueForKey:kCIOutputImageKey];
    return result;
}
struct CubeMap createCubMap(float minHue, float maxHue) {
    const unsigned int size = 64;
    struct CubeMap cubeMap;
    cubeMap.length = size * size * size * sizeof (float) * 4;
    cubeMap.dimension = size;
    float *cubeData = (float *)malloc (cubeMap.length);
    float rgb[3], hsv[3], *c = cubeData;
    for (int z = 0; z < size; z++){
        rgb[2] = ((double)z)/(size-1); // Blue value
        for (int y = 0; y < size; y++){
            rgb[1] = ((double)y)/(size-1); // Green value
            for (int x = 0; x < size; x ++){
                rgb[0] = ((double)x)/(size-1); // Red value
                RGBToHSV(rgb[0], rgb[1], rgb[2], &hsv[0], &hsv[1], &hsv[2]);
                float alpha = (hsv[0] > minHue && hsv[0] < maxHue) ? 0.0f: 1.0f;
                c[0] = rgb[0] * alpha;
                c[1] = rgb[1] * alpha;
                c[2] = rgb[2] * alpha;
                c[3] = alpha;
                c += 4;
            }
        }
    }
    cubeMap.data = cubeData;
    return cubeMap;
}
@end
