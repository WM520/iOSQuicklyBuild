//
//  WMCharacterHandle.h
//  iOSQuicklyBuild
//
//  Created by wangmiao on 2017/3/28.
//  Copyright © 2017年 wangmiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 *  回调字符限制处理情况<UITextField>
 *
 *  @param isReachMaxCountLimit 是否达到最大字符限制
 *  @param message              反馈给开发者的信息
 */
typedef void(^TextFieldHandleBlock)(BOOL isReachMaxCountLimit,NSString * message);
/**
 *  回调字符限制处理情况<UITextView>
 *
 *  @param isReachMaxCountLimit 是否达到最大字符限制
 *  @param message              反馈给开发者的信息
 *  @param inputCharactersCount 输入的字符个数
 */
typedef void(^TextViewHandleBlock)(BOOL isReachMaxCountLimit,NSString * message,NSInteger inputCharactersCount);

@interface WMCharacterHandle : NSObject

@property (nonatomic, copy)TextFieldHandleBlock handleTextFieldBlock;
@property (nonatomic, copy)TextViewHandleBlock handleTextViewBlock;

#pragma mark -shareInstance

/**
 单例

 @return 一个单例对象
 */
+ (WMCharacterHandle *)shareInstance;

#pragma mark - some function
- (void)addTextLimitWithUITextFiled:(UITextField *)textField
                       textLimitNum:(NSUInteger)num
                withCompletionBlock:(TextFieldHandleBlock)handle;

/**
 *  对UITextView的字符输入限制
 *
 *  @param textView 需要限制的textView
 *  @param num       限制输入的字数
 *  @param handle    回调处理
 */
- (void)addTextLimitWithUITextView:(UITextView *)textView
                      textLimitNum:(NSUInteger)num
               withCompletionBlock:(TextViewHandleBlock)handle;

/**
 *  判断是否是有效的电话号码
 *
 *  @param inputString 输入的字符串
 *
 *  @return 返回YES/NO
 */
- (BOOL)thisStringOfCharactersIsTheValidPhoneNumber:(NSString *)inputString;


/**
 *  判断是否是有效的身份证号码
 *
 *  @param inputString 输入的字符串
 *
 *  @return 返回YES/NO
 */
- (BOOL)thisStringOfCharactersIsTheValidIDCardNumber:(NSString *)inputString;


/**
 *  判断是否是有效的邮箱
 *  @param inputString 输入的字符串
 *
 *  @return 返回YES/NO
 */
- (BOOL)thisStringOfCharactersIsTheValidEmail:(NSString *)inputString;

/**
 *  判断是否含有特殊字符
 *
 *  @param inputString 输入的字符串
 *
 *  @return 返回YES/NO
 */
- (BOOL)thisStringOfCharactersContainSpecialCharacters:(NSString *)inputString;


/**
 *  判断是否含有emoji表情
 *
 *  @param inputString 输入的字符串
 *
 *  @return 返回YES/NO
 */
- (BOOL)thisStringOfCharactersContainEmojiEmoticons:(NSString *)inputString;


@end
