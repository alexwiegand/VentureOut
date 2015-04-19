// MessageComposerView.h
//
// Copyright (c) 2013 oseparovic. ( http://thegameengine.org )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@protocol MessageComposerViewDelegate <NSObject>
- (void)messageComposerSendMessageClickedWithMessage:(NSString*)message;
@optional
- (void)messageComposerFrameDidChange:(CGRect)frame withAnimationDuration:(float)duration;
- (void)messageComposerUserTyping;
@end

@interface MessageComposerView : UIView<UITextViewDelegate>
@property(nonatomic, strong) id<MessageComposerViewDelegate> delegate;
- (IBAction)sendClicked:(id)sender;
- (void)resizeTextViewForText:(NSString*)text;
- (void)resizeTextViewForText:(NSString*)text animated:(BOOL)animated;
- (void)scrollTextViewToBottom;
// To avoid exposing the UITextView and attempt to prevent bad practice, startEditing and finishEditing
// are available to become and resign first responder. This means you shouldn't have an excuse to
// do [messageComposerView.messageTextView resignFirstResponder] etc.
- (void)startEditing;
- (void)finishEditing;
- (void)setText:(NSString *)text _placeHolder:(NSString *)placeHolder;
- (NSString *)getText;
- (void)hideKeyboard;
- (void)setNextFrame:(CGRect)frame;
@end

