//
//  ViewController.m
//  DemoLED
//
//  Created by TienVV on 10/4/15.
//  Copyright (c) 2015 TienVV. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *optionSelector;
@property (weak, nonatomic) IBOutlet UISegmentedControl *optionRepeatTimer;

@end

@implementation ViewController
{
    float _screenWitdh;
    float _screenHeight;
    
    float _positionX;
    float _positionY;
    
    float _ballRadius;
    int _margin; // Margin of First ball or Last ball to screen
    float _space; // Space beetween two ball center
    int _numberOfBallPerRow;
    
    int _tagStart;
    int _tagEnd;
    

    int _rowCount;
    NSTimer* timerRunLed;
    
    int _count;
    int _delta;
    float _timerRepeat;
    SEL selectorTimer;
    
    NSArray* arrayLedColorOption01;
    NSArray* arrayLedColorOption02;
    NSArray* arrayLedColorOption03;
    NSArray* arrayLedColorOption04;
    int _countColorOption02;
    int _countColorOption03;
    int _countColorOption04;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Get screen size of device
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    _screenWitdh = screenRect.size.width;
    _screenHeight = screenRect.size.height;
    
    // Initiate context variable
    UIImage* ballImage = [UIImage imageNamed:@"led_green"];
    _ballRadius = ballImage.size.width / 2;
    _margin = 40;
    
    _numberOfBallPerRow = 8;
    _space = (_screenWitdh - 2 * _margin) / (_numberOfBallPerRow - 1);
    
    NSLog(@"Number Ball Per Row: %d, Margin: %d, Space: %3.1f", _numberOfBallPerRow, _margin, _space);
    // Define array led name
    arrayLedColorOption01 = @[@"led_grey", @"led_blue", @"led_pink", @"led_orange"];
    arrayLedColorOption02 = @[@"led_blue", @"led_pink", @"led_orange", @"led_green"];
    arrayLedColorOption03 = @[@"led_blue", @"led_pink", @"led_orange"];
    arrayLedColorOption04 = @[@"led_blue", @"led_pink", @"led_orange", @"led_green"];
    // Draw ball
    [self drawBall];
    // Run LED
    _count = 0;
    _timerRepeat = 0.2f;
    selectorTimer = @selector(runLedOption01);
    
    timerRunLed = [NSTimer scheduledTimerWithTimeInterval:_timerRepeat
                                                           target:self
                                                         selector:selectorTimer
                                                         userInfo:nil
                                                          repeats:YES];
    
    [_optionSelector setSelectedSegmentIndex:0];
    [_optionRepeatTimer setSelectedSegmentIndex:0];
}

- (void) drawBall {
    // Initiate first position of first row
    _positionX = _margin;
    _positionY = _optionSelector.center.y + _optionSelector.bounds.size.height / 2 + _ballRadius + 20;
    _rowCount = 0;
    // Initiate tag
    _tagStart = 100;
    _tagEnd = _tagStart - 1;
    NSLog(@"BallPerRow: %d, PosX: %3.1f, PosY: %3.1f", _numberOfBallPerRow, _positionX, _positionY);
    // Number of row is decided by screen height
    do {
        _rowCount++;
        // Draw each row
        for (int i = 0; i < _numberOfBallPerRow; i++) {
            _positionX = _margin + i * _space;
            _tagEnd++;
            [self drawGreyBallAtX:_positionX andY:_positionY withTag:_tagEnd];
        }
        _positionY = _positionY + 2 * _ballRadius + 20;
    } while (_positionY < _screenHeight - _optionRepeatTimer.bounds.size.height - _ballRadius - 20);
}

- (void) drawGreyBallAtX: (CGFloat) x
                andY: (CGFloat) y
             withTag: (int) tag {
    UIImageView* imgBall = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"led_grey"]];
    imgBall.center = CGPointMake(x, y);
    imgBall.tag = tag;
    
    [self.view addSubview:imgBall];
}

- (void) removeAllBall {
    for (int i = _tagStart; i <= _tagEnd; i++) {
        UIView* view = [self.view viewWithTag:i];
        // Remove view from super view
        [view removeFromSuperview];
    }
}

- (void) runLedOption01 {
    NSLog(@"Run LED option 01");
    if (_count == _numberOfBallPerRow - 1) {
        _count = 0;
    } else {
        _count++;
    }
    // Turn ON old led on each row
    for (int row = 0; row < _rowCount; row++) {
        // Turn each led ON
        for (int col = 0; col < _numberOfBallPerRow; col++) {
            for (int j = 0; j < arrayLedColorOption01.count; j++) {
                if ((col - j + _count) % arrayLedColorOption01.count  == 0) {
                    [self turnLedOnWithTag:(100 + row * _numberOfBallPerRow + col) colorLed:[arrayLedColorOption01 objectAtIndex:j]];
                }
            }
        }
    }
}

- (void) runLedOption02 {
    NSLog(@"Run LED option 02");
    // Turn OFF old led
    for (int i = 0; i < _rowCount; i++) {
        [self turnLedOffWithTag:(100 + i * _numberOfBallPerRow + _count)];
    }
    
    if (_count == _numberOfBallPerRow - 1) {
        _delta = -1;
        if (_countColorOption02 == arrayLedColorOption02.count - 1) {
            _countColorOption02 = 0;
        } else {
            _countColorOption02++;
        }
    } else if (_count == 0) {
        _delta = 1;
        if (_countColorOption02 == arrayLedColorOption02.count - 1) {
            _countColorOption02 = 0;
        } else {
            _countColorOption02++;
        }
    }
    _count = _count + _delta * 1;
    
    // Turn ON old led
    for (int i = 0; i < _rowCount; i++) {
        [self turnLedOnWithTag:(100 + i * _numberOfBallPerRow + _count) colorLed:[arrayLedColorOption02 objectAtIndex:_countColorOption02]];
    }
}

- (void) runLedOption03 {
    NSLog(@"Run LED option 03");
    // Turn OFF old led
    for (int i = 0; i < _rowCount; i++) {
        if (i % 2 == 0) {
            [self turnLedOffWithTag:(100 + i * _numberOfBallPerRow + _count)];
        } else {
            [self turnLedOffWithTag:(100 + i * _numberOfBallPerRow + (_numberOfBallPerRow - _count - 1))];
        }
    }
    
    if (_count == _numberOfBallPerRow - 1) {
        _count = 0;
        
        if (_countColorOption03 == arrayLedColorOption03.count - 1) {
            _countColorOption03 = 0;
        } else {
            _countColorOption03++;
        }
    } else {
        _count++;
    }
    
    // Turn ON new led
    for (int i = 0; i < _rowCount; i++) {
        NSString* color = @"led_grey";
        for (int j = 0; j < arrayLedColorOption03.count; j++) {
            if ((i - _countColorOption03 + j) % arrayLedColorOption03.count == 0) {
                color = [arrayLedColorOption03 objectAtIndex:j];
            }
        }
        
        if (i % 2 == 0) {
            [self turnLedOnWithTag:(100 + i * _numberOfBallPerRow + _count) colorLed:color];
        } else {
            [self turnLedOnWithTag:(100 + i * _numberOfBallPerRow + (_numberOfBallPerRow - _count - 1)) colorLed:color];
        }
    }
}

- (void) runLedOption04 {
    NSLog(@"Run LED option 04");
    // Turn OFF old led
    for (int i = 0; i < _rowCount; i++) {
        for (int col = 0; col < _numberOfBallPerRow; col++) {
            // Row bound
            if (i == _count || i == _rowCount - 1 - _count) {
                if (col >= _count && col <= _numberOfBallPerRow - 1 - _count) {
                    [self turnLedOffWithTag:(100 + i * _numberOfBallPerRow + col)];
                }
            } else if (i >= _count && i <= _rowCount - 1 - _count) {
                if (col == _count || _numberOfBallPerRow - 1 - col == _count){
                    // Column bound
                    [self turnLedOffWithTag:(100 + i * _numberOfBallPerRow + col)];
                }
            }
        }
    }
    
    int bound = 0;
    if (_numberOfBallPerRow % 2 == 0) {
        bound = _numberOfBallPerRow / 2;
    } else {
        bound = _numberOfBallPerRow / 2 + 1;
    }
    
    if (_count == bound - 1) {
        _count = 0;
        if (_countColorOption04 == arrayLedColorOption04.count - 1) {
            _countColorOption04 = 0;
        } else {
            _countColorOption04++;
        }
    } else {
        _count++;
    }
    
    NSString* color = @"led_grey";
    for (int j = 0; j < arrayLedColorOption04.count; j++) {
        if ((_countColorOption04 + j) % arrayLedColorOption04.count == 0) {
            color = [arrayLedColorOption04 objectAtIndex:j];
        }
    }
    
    // Turn ON led
    for (int i = 0; i < _rowCount; i++) {
        for (int col = 0; col < _numberOfBallPerRow; col++) {
            // Row bound
            if (i == _count || i == _rowCount - 1 - _count) {
                if (col >= _count && col <= _numberOfBallPerRow - 1 - _count) {
                    [self turnLedOnWithTag:(100 + i * _numberOfBallPerRow + col) colorLed:color];
                }
            } else if (i >= _count && i <= _rowCount - 1 - _count) {
                if (col == _count || _numberOfBallPerRow - col - 1 == _count){
                    // Column bound
                    [self turnLedOnWithTag:(100 + i * _numberOfBallPerRow + col) colorLed:color];
                }
            }
        }
    }
}

- (void) turnLedOnWithTag: (int) tag colorLed: (NSString*) color {
    UIView* ledView = [self.view viewWithTag:tag];
    if (ledView && [ledView isMemberOfClass:[UIImageView class]]) {
        UIImageView* led = (UIImageView*) ledView;
        led.image = [UIImage imageNamed:color];
    }
}

- (void) turnLedOffWithTag: (int) tag {
    UIView* ledView = [self.view viewWithTag:tag];
    if (ledView && [ledView isMemberOfClass:[UIImageView class]]) {
        UIImageView* led = (UIImageView*) ledView;
        led.image = [UIImage imageNamed:@"led_grey"];
    }
}

- (IBAction)onOptionSelectected:(id)sender {
    int index = (int) [_optionSelector selectedSegmentIndex];
    NSLog(@"Selected option index: %d", index);
    // Turn off current timer
    if ([timerRunLed isValid]) {
        [timerRunLed invalidate];
    }
    // Set all led to grey
    for (int i = _tagStart; i <= _tagEnd; i++) {
        [self turnLedOffWithTag:i];
    }
    
    _count = -1;
    if (index == 0) {
        selectorTimer = @selector(runLedOption01);
    } else if(index == 1) {
        _delta = 1;
        selectorTimer = @selector(runLedOption02);
    } else if (index == 2) {
        selectorTimer = @selector(runLedOption03);
    } else if (index == 3) {
        selectorTimer = @selector(runLedOption04);
    }
    
    if ([timerRunLed isValid]) {
        [timerRunLed invalidate];
    }
    timerRunLed = [NSTimer scheduledTimerWithTimeInterval:_timerRepeat
                                                   target:self
                                                 selector:selectorTimer
                                                 userInfo:nil
                                                  repeats:YES];
}

- (IBAction)onOptionRepeatTimer:(id)sender {
    if (_optionRepeatTimer.selectedSegmentIndex == 0) {
        _timerRepeat = 0.2f;
    } else if (_optionRepeatTimer.selectedSegmentIndex == 1) {
        _timerRepeat = 0.5f;
    } else if (_optionRepeatTimer.selectedSegmentIndex == 2) {
        _timerRepeat = 1.0f;
    }
    if ([timerRunLed isValid]) {
        [timerRunLed invalidate];
    }
    timerRunLed = [NSTimer scheduledTimerWithTimeInterval:_timerRepeat
                                                   target:self
                                                 selector:selectorTimer
                                                 userInfo:nil
                                                  repeats:YES];
}

@end
