//
//  TOCropOverlayView.m
//
//  Copyright 2015-2018 Timothy Oliver. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//  OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
//  IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "TOCropOverlayView.h"

static const CGFloat kTOCropOverLayerCornerWidth = 20.0f;

@interface TOCropOverlayView ()

@property (nonatomic, strong) NSArray *horizontalGridLines;
@property (nonatomic, strong) NSArray *verticalGridLines;

@property (nonatomic, strong) NSArray *outerLineViews;   //top, right, bottom, left

@property (nonatomic, strong) NSArray *topLeftLineViews; //vertical, horizontal
@property (nonatomic, strong) NSArray *bottomLeftLineViews;
@property (nonatomic, strong) NSArray *bottomRightLineViews;
@property (nonatomic, strong) NSArray *topRightLineViews;

@end

@implementation TOCropOverlayView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.clipsToBounds = NO;
        [self setup];
    }

    return self;
}

- (void)setup
{
    self.displayHorizontalGridLines = YES;
    self.displayVerticalGridLines = YES;

    self.cornerThickness = 3.0f;
    self.outerHalfThickness = 2.0f;

    self.outerColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    self.gridColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5];

    UIView *(^newLineView)(void) = ^UIView *(void){
        return [self createNewLineView];
    };

    _outerLineViews     = @[newLineView(), newLineView(), newLineView(), newLineView()];

    _topLeftLineViews   = @[newLineView(), newLineView()];
    _bottomLeftLineViews = @[newLineView(), newLineView()];
    _topRightLineViews  = @[newLineView(), newLineView()];
    _bottomRightLineViews = @[newLineView(), newLineView()];


}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    if (_outerLineViews) {
        [self layoutLines];
    }
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    if (_outerLineViews) {
        [self layoutLines];
    }
}

- (void)layoutLines
{
    CGSize boundsSize = self.bounds.size;

    CGFloat thickHalf = self.outerHalfThickness;
    CGFloat thick = self.outerHalfThickness * 2;

    //border lines
    for (NSInteger i = 0; i < 4; i++) {
        UIView *lineView = self.outerLineViews[i];

        CGRect frame = CGRectZero;
        switch (i) {
            case 0: frame = (CGRect){-thickHalf,-thickHalf,boundsSize.width+thick, thick}; break; //top
            case 1: frame = (CGRect){boundsSize.width - thickHalf,-thickHalf,thick,boundsSize.height + thick}; break; //right
            case 2: frame = (CGRect){-thickHalf,boundsSize.height - thickHalf,boundsSize.width+thick,thick}; break; //bottom
            case 3: frame = (CGRect){-thickHalf,-thickHalf,thick,boundsSize.height+thick}; break; //left
        }

        lineView.frame = frame;
    }
    CGFloat cornerThick = self.cornerThickness;
    //corner liness
    NSArray *cornerLines = @[self.topLeftLineViews, self.topRightLineViews, self.bottomRightLineViews, self.bottomLeftLineViews];
    for (NSInteger i = 0; i < 4; i++) {
        NSArray *cornerLine = cornerLines[i];

        CGRect verticalFrame = CGRectZero, horizontalFrame = CGRectZero;
        switch (i) {
            case 0: //top left
                verticalFrame = (CGRect){-cornerThick,-cornerThick,cornerThick,kTOCropOverLayerCornerWidth+cornerThick};
                horizontalFrame = (CGRect){0,-cornerThick,kTOCropOverLayerCornerWidth,cornerThick};
                break;
            case 1: //top right
                verticalFrame = (CGRect){boundsSize.width,-cornerThick,cornerThick,kTOCropOverLayerCornerWidth+cornerThick};
                horizontalFrame = (CGRect){boundsSize.width-kTOCropOverLayerCornerWidth,-cornerThick,kTOCropOverLayerCornerWidth,cornerThick};
                break;
            case 2: //bottom right
                verticalFrame = (CGRect){boundsSize.width,boundsSize.height-kTOCropOverLayerCornerWidth,cornerThick,kTOCropOverLayerCornerWidth+cornerThick};
                horizontalFrame = (CGRect){boundsSize.width-kTOCropOverLayerCornerWidth,boundsSize.height,kTOCropOverLayerCornerWidth,cornerThick};
                break;
            case 3: //bottom left
                verticalFrame = (CGRect){-cornerThick,boundsSize.height-kTOCropOverLayerCornerWidth,cornerThick,kTOCropOverLayerCornerWidth};
                horizontalFrame = (CGRect){-cornerThick,boundsSize.height,kTOCropOverLayerCornerWidth+cornerThick,cornerThick};
                break;
        }

        [cornerLine[0] setFrame:verticalFrame];
        [cornerLine[1] setFrame:horizontalFrame];
    }

    //grid lines - horizontal
    CGFloat thickness = 1.0f / [[UIScreen mainScreen] scale];
    NSInteger numberOfLines = self.horizontalGridLines.count;
    CGFloat padding = (CGRectGetHeight(self.bounds) - (thickness*numberOfLines)) / (numberOfLines + 1);
    for (NSInteger i = 0; i < numberOfLines; i++) {
        UIView *lineView = self.horizontalGridLines[i];
        CGRect frame = CGRectZero;
        frame.size.height = thickness;
        frame.size.width = CGRectGetWidth(self.bounds);
        frame.origin.y = (padding * (i+1)) + (thickness * i);
        lineView.frame = frame;
    }

    //grid lines - vertical
    numberOfLines = self.verticalGridLines.count;
    padding = (CGRectGetWidth(self.bounds) - (thickness*numberOfLines)) / (numberOfLines + 1);
    for (NSInteger i = 0; i < numberOfLines; i++) {
        UIView *lineView = self.verticalGridLines[i];
        CGRect frame = CGRectZero;
        frame.size.width = thickness;
        frame.size.height = CGRectGetHeight(self.bounds);
        frame.origin.x = (padding * (i+1)) + (thickness * i);
        lineView.frame = frame;
    }
}

- (void)setGridHidden:(BOOL)hidden animated:(BOOL)animated
{
    _gridHidden = hidden;

    if (animated == NO) {
        for (UIView *lineView in self.horizontalGridLines) {
            lineView.alpha = hidden ? 0.0f : 1.0f;
        }

        for (UIView *lineView in self.verticalGridLines) {
            lineView.alpha = hidden ? 0.0f : 1.0f;
        }

        return;
    }

    [UIView animateWithDuration:hidden?0.35f:0.2f animations:^{
        for (UIView *lineView in self.horizontalGridLines)
            lineView.alpha = hidden ? 0.0f : 1.0f;

        for (UIView *lineView in self.verticalGridLines)
            lineView.alpha = hidden ? 0.0f : 1.0f;
    }];
}

#pragma mark - Property methods

- (void)setDisplayHorizontalGridLines:(BOOL)displayHorizontalGridLines {
    _displayHorizontalGridLines = displayHorizontalGridLines;

    [self.horizontalGridLines enumerateObjectsUsingBlock:^(UIView *__nonnull lineView, NSUInteger idx, BOOL * __nonnull stop) {
        [lineView removeFromSuperview];
    }];

    if (_displayHorizontalGridLines) {
        self.horizontalGridLines = @[[self createNewLineView], [self createNewLineView]];
    } else {
        self.horizontalGridLines = @[];
    }
    [self setNeedsDisplay];
}

- (void)setDisplayVerticalGridLines:(BOOL)displayVerticalGridLines {
    _displayVerticalGridLines = displayVerticalGridLines;

    [self.verticalGridLines enumerateObjectsUsingBlock:^(UIView *__nonnull lineView, NSUInteger idx, BOOL * __nonnull stop) {
        [lineView removeFromSuperview];
    }];

    if (_displayVerticalGridLines) {
        self.verticalGridLines = @[[self createNewLineView], [self createNewLineView]];
    } else {
        self.verticalGridLines = @[];
    }
    [self setNeedsDisplay];
}

- (void)setGridHidden:(BOOL)gridHidden
{
    [self setGridHidden:gridHidden animated:NO];
}
- (void)setOuterColor:(UIColor *)color
{
    for (NSInteger i = 0; i < 4; i++) {
        UIView *lineView = self.outerLineViews[i];
        lineView.backgroundColor = color;
    }
    for (NSInteger i = 0; i < 2; i++) {
        UIView *lineView = self.topLeftLineViews[i];
        lineView.backgroundColor = color;
    }
    for (NSInteger i = 0; i < 2; i++) {
        UIView *lineView = self.topRightLineViews[i];
        lineView.backgroundColor = color;
    }
    for (NSInteger i = 0; i < 2; i++) {
        UIView *lineView = self.bottomLeftLineViews[i];
        lineView.backgroundColor = color;
    }
    for (NSInteger i = 0; i < 2; i++) {
        UIView *lineView = self.bottomRightLineViews[i];
        lineView.backgroundColor = color;
    }
}
- (void)setGridColor:(UIColor *)color
{
    NSInteger numberOfLines = self.verticalGridLines.count;
    for (NSInteger i = 0; i < numberOfLines; i++) {
        UIView *lineView = self.verticalGridLines[i];
        lineView.backgroundColor = color;
    }
    numberOfLines = self.horizontalGridLines.count;
    for (NSInteger i = 0; i < numberOfLines; i++) {
        UIView *lineView = self.horizontalGridLines[i];
        lineView.backgroundColor = color;
    }
}

#pragma mark - Private methods

- (nonnull UIView *)createNewLineView {
    UIView *newLine = [[UIView alloc] initWithFrame:CGRectZero];
    newLine.backgroundColor = [UIColor whiteColor];
    [self addSubview:newLine];
    return newLine;
}

@end
