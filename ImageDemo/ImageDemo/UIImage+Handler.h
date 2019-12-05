//
//  UIImage+Handler.h
//  ImageDemo
//
//  Created by weil on 2019/12/4.
//  Copyright © 2019 AllYoga. All rights reserved.
//
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (Handler)
/**从view生成图片
 @param view 需要生成图片的视图
 */
+ (UIImage *) wl_captureImageFromView:(UIView *)view;
/**从view生成图片
@param scrollView 需要生成图片的视图
@param fregment 是否分段渲染
 @return 返回生成的长图
*/
+ (UIImage *) wl_captureImageFromScroll:(UIScrollView *)scrollView
                                        fregment:(BOOL)fregment;
/**将图片拼接到当前图片后,默认是上下拼接,且以源图片的宽为基准渲染
@param sourceImage 源图片
 @param combinedImage 要拼接的图片
@return 返回拼接后的图片
*/
+ (UIImage *) wl_combineSourceImage:(UIImage *)sourceImage
                             combinedImage:(UIImage *)combinedImage;
/**计算图片中出现最多次数的颜色
 */
- (UIColor *) wl_mostColor;
/**计算图片的主色调
 */
- (UIColor *) wl_mainColor;
/**计算图片某一区域的颜色值
 @param rect 指定区域
*/
- (UIColor *) wl_mostColorInRect:(CGRect)rect;
/**计算图片某一点的颜色值
 @param point 指定点
*/
- (UIColor *) wl_mostColorInPoint:(CGPoint)point;
/**修改图片的亮度
 @param brightness 亮度
 @param saturation 饱和度
 @param contrast  对比度
 */
- (UIImage *) wl_changeBrightness:(CGFloat)brightness
                           saturation:(CGFloat)saturation
                             contrast:(CGFloat)contrast;
/**通过h,s,B修改图片的灰度，饱和度和亮度
 @param hueOffset 灰度的偏移量，默认为0
 @param saturationOffset 饱和度的偏移量，默认为0
 @param brightnessOffset 亮度的偏移量，默认为0
 */
- (UIImage *) wl_changeImageWithHueOffset:(CGFloat)hueOffset
                                    saturationOffset:(CGFloat)saturationOffset
                                   brightnessOffset:(CGFloat)brightnessOffset;
/**通过渲染和颜色来修改图片着色
 @param tintColor 要改变的颜色
 @param blendMode 渲染方式
 */
- (UIImage *) wl_changeImageWithTintColor:(UIColor *)tintColor
                                         blendMode:(CGBlendMode)blendMode;
/**使用CoreImage框架删除图片中的某一种颜色
 @param minHue 最小色值
 @param maxHue 最大色值
 */
- (UIImage *) wl_removeColorWithMinHue:(float)minHue
                                         maxHue:(float)maxHue;

@end

NS_ASSUME_NONNULL_END
