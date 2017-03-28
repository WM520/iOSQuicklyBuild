//
//  WMCharacterHandle.m
//  iOSQuicklyBuild
//
//  Created by wangmiao on 2017/3/28.
//  Copyright © 2017年 wangmiao. All rights reserved.
//

#import "WMCharacterHandle.h"

@implementation WMCharacterHandle
{
    NSUInteger MAX_NUM;
}

#pragma mark - sharedInstance

+ (WMCharacterHandle *)shareInstance;
{
    static WMCharacterHandle *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[WMCharacterHandle alloc] init];
    });
    
    return sharedInstance;
}

#pragma mark - textField字符长度限制
- (void)addTextLimitWithUITextFiled:(UITextField *)textField
                       textLimitNum:(NSUInteger)num
                withCompletionBlock:(TextFieldHandleBlock)handle{
    
    if (handle) {
        self.handleTextFieldBlock = handle;
    }
    MAX_NUM = num;
    
    [textField addTarget:self action:@selector(textFieldLimitLength:) forControlEvents:UIControlEventEditingChanged];
    
}

-(void)textFieldLimitLength:(UITextField *)sender{
    
    bool isChinese;//判断当前输入法是否是中文
    if ([[[[UIApplication sharedApplication]textInputMode] primaryLanguage] isEqualToString: @"en-US"]) {
        isChinese = false;
    }
    else
    {
        isChinese = true;
    }
    
    // 8位
    NSString *str = [[sender text] stringByReplacingOccurrencesOfString:@"?" withString:@""];
    
    if (isChinese) {
        //中文输入法下
        UITextRange *selectedRange = [sender markedTextRange];
        //获取高亮部分
        UITextPosition *position = [sender positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            //汉字
            if ( str.length>=MAX_NUM) {
                
                NSString *strNew = [NSString stringWithString:str];
                [sender setText:[strNew substringToIndex:MAX_NUM]];
                
                if (self.handleTextFieldBlock) {
                    self.handleTextFieldBlock(YES,@"字数已达到上限");
                }
                
            }
        }
        else{
            //输入的英文还没有转化为汉字的状态
        }
    }else{
        if ([str length]>=MAX_NUM) {
            NSString *strNew = [NSString stringWithString:str];
            [sender setText:[strNew substringToIndex:MAX_NUM]];
            if (self.handleTextFieldBlock) {
                self.handleTextFieldBlock(YES,@"字数已达到上限");
            }
        }
    }
    
}

#pragma mark - textView字符长度限制
- (void)addTextLimitWithUITextView:(UITextView *)textView textLimitNum:(NSUInteger)num withCompletionBlock:(TextViewHandleBlock)handle{
    
    if (handle) {
        self.handleTextViewBlock = handle;
    }
    MAX_NUM = num;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewLimitLength:) name:UITextViewTextDidChangeNotification object:textView];
    
}
-(void)textViewLimitLength:(NSNotification *)obj{
    
    UITextView *textView = (UITextView *)obj.object;
    NSString *toBeString = textView.text;
    NSString *lang = [[[UIApplication sharedApplication] textInputMode] primaryLanguage]; // 键盘输入模式
    
    if ([lang isEqualToString:@"zh-Hans"]) {
        
        // 简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [textView markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
        //没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            
            if (toBeString.length > MAX_NUM) {
                
                textView.text = [toBeString substringToIndex:MAX_NUM];
                if (self.handleTextViewBlock) {
                    self.handleTextViewBlock(YES,@"字数已达到上限", MAX_NUM);
                }
                return;
            }
            if (self.handleTextViewBlock) {
                self.handleTextViewBlock(NO,@"正在输入...",toBeString.length);
            }
        }else{
            //有高亮选择的字符串，则暂不对文字进行统计和限制
        }
    }
    else{
        // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
        if (toBeString.length > MAX_NUM) {
            
            textView.text = [toBeString substringToIndex:MAX_NUM];
            if (self.handleTextViewBlock) {
                self.handleTextViewBlock(YES,@"字数已达到上限", MAX_NUM);
            }
            return;
            
        }
        if (self.handleTextViewBlock) {
            self.handleTextViewBlock(NO,@"正在输入...",toBeString.length);
        }
    }
    
}


#pragma mark - 手机号码验证
- (BOOL)thisStringOfCharactersIsTheValidPhoneNumber:(NSString *)inputString{
    
    BOOL res = YES;
    NSCharacterSet* tmpSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    int i = 0;
    while (i < inputString.length) {
        NSString * string = [inputString substringWithRange:NSMakeRange(i, 1)];
        NSRange range = [string rangeOfCharacterFromSet:tmpSet];
        if (range.length == 0) {
            res = NO;
            break;
        }
        i++;
    }
    return res;
}

#pragma mark - 身份证号码验证
- (BOOL)thisStringOfCharactersIsTheValidIDCardNumber:(NSString *)inputString{
    
    BOOL isMatch  = YES;
    if (inputString.length == 18) {
        
        inputString = [inputString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([inputString length] != 18) {
            return NO;
        }
        NSString *mmdd = @"(((0[13578]|1[02])(0[1-9]|[12][0-9]|3[01]))|((0[469]|11)(0[1-9]|[12][0-9]|30))|(02(0[1-9]|[1][0-9]|2[0-8])))";
        NSString *leapMmdd = @"0229";
        NSString *year = @"(19|20)[0-9]{2}";
        NSString *leapYear = @"(19|20)(0[48]|[2468][048]|[13579][26])";
        NSString *yearMmdd = [NSString stringWithFormat:@"%@%@", year, mmdd];
        NSString *leapyearMmdd = [NSString stringWithFormat:@"%@%@", leapYear, leapMmdd];
        NSString *yyyyMmdd = [NSString stringWithFormat:@"((%@)|(%@)|(%@))", yearMmdd, leapyearMmdd, @"20000229"];
        NSString *area = @"(1[1-5]|2[1-3]|3[1-7]|4[1-6]|5[0-4]|6[1-5]|82|[7-9]1)[0-9]{4}";
        NSString *regex = [NSString stringWithFormat:@"%@%@%@", area, yyyyMmdd  , @"[0-9]{3}[0-9Xx]"];
        
        NSPredicate *regexTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
        if (![regexTest evaluateWithObject:inputString]) {
            return NO;
        }
        int summary = ([inputString substringWithRange:NSMakeRange(0,1)].intValue + [inputString substringWithRange:NSMakeRange(10,1)].intValue) *7
        + ([inputString substringWithRange:NSMakeRange(1,1)].intValue + [inputString substringWithRange:NSMakeRange(11,1)].intValue) *9
        + ([inputString substringWithRange:NSMakeRange(2,1)].intValue + [inputString substringWithRange:NSMakeRange(12,1)].intValue) *10
        + ([inputString substringWithRange:NSMakeRange(3,1)].intValue + [inputString substringWithRange:NSMakeRange(13,1)].intValue) *5
        + ([inputString substringWithRange:NSMakeRange(4,1)].intValue + [inputString substringWithRange:NSMakeRange(14,1)].intValue) *8
        + ([inputString substringWithRange:NSMakeRange(5,1)].intValue + [inputString substringWithRange:NSMakeRange(15,1)].intValue) *4
        + ([inputString substringWithRange:NSMakeRange(6,1)].intValue + [inputString substringWithRange:NSMakeRange(16,1)].intValue) *2
        + [inputString substringWithRange:NSMakeRange(7,1)].intValue *1 + [inputString substringWithRange:NSMakeRange(8,1)].intValue *6
        + [inputString substringWithRange:NSMakeRange(9,1)].intValue *3;
        NSInteger remainder = summary % 11;
        NSString *checkBit = @"";
        NSString *checkString = @"10X98765432";
        checkBit = [checkString substringWithRange:NSMakeRange(remainder,1)];// 判断校验位
        return [checkBit isEqualToString:[[inputString substringWithRange:NSMakeRange(17,1)] uppercaseString]];
        
        
    }else {
        NSCharacterSet* tmpSet = nil;
        if (inputString.length != 17) {
            tmpSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
            
        }else{
            tmpSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789X"];
            
        }
        int i = 0;
        while (i < inputString.length) {
            NSString * string = [inputString substringWithRange:NSMakeRange(i, 1)];
            NSRange range = [string rangeOfCharacterFromSet:tmpSet];
            if (range.length == 0) {
                isMatch = NO;
                break;
            }
            i++;
        }
        
    }
    return isMatch;
    
}

#pragma mark - 邮箱验证
- (BOOL)thisStringOfCharactersIsTheValidEmail:(NSString *)inputString{
    
    NSString *emailCheck = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES%@",emailCheck];
    return [emailTest evaluateWithObject:inputString];
    
}

#pragma mark - 特殊字符验证
- (BOOL)thisStringOfCharactersContainSpecialCharacters:(NSString *)inputString{
    
    NSString *reg = @"^[A-Za-z0-9\u4e00-\u9fa5]+$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", reg];
    
    if(![pred evaluateWithObject: inputString]){
        return  NO;
    }
    return YES;
    
}

#pragma mark - emoji表情验证
- (BOOL)thisStringOfCharactersContainEmojiEmoticons:(NSString *)inputString{
    
    __block BOOL returnValue =NO;
    
    [inputString enumerateSubstringsInRange:NSMakeRange(0, [inputString length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
        const unichar hs = [substring characterAtIndex:0];
        
        // surrogate pair
        
        if (0xd800 <= hs && hs <= 0xdbff) {
            
            if (substring.length > 1) {
                
                const unichar ls = [substring characterAtIndex:1];
                
                const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                
                if (0x1d000 <= uc && uc <= 0x1f77f) {
                    
                    returnValue =YES;
                    
                }
                
            }
            
        }else if (substring.length > 1) {
            
            const unichar ls = [substring characterAtIndex:1];
            
            if (ls == 0x20e3) {
                
                returnValue =YES;
                
            }
            
        }else {
            
            // non surrogate
            
            if (0x2100 <= hs && hs <= 0x27ff) {
                
                returnValue =YES;
                
            }else if (0x2B05 <= hs && hs <= 0x2b07) {
                
                returnValue =YES;
                
            }else if (0x2934 <= hs && hs <= 0x2935) {
                
                returnValue =YES;
                
            }else if (0x3297 <= hs && hs <= 0x3299) {
                
                returnValue =YES;
                
            }else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                
                returnValue =YES;
                
            }
            
        }
        
    }];
    return returnValue;
    
}

@end
