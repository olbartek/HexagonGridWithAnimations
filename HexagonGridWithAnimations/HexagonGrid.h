//
//  HexagonGrid.h
//  HexagonGrid
//
//  Created by Bartosz Olszanowski on 03.09.2015.
//  Copyright (c) 2015 Vorm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIGeometry.h>

#pragma mark - Constants
// Default Values
static const CGFloat kHexGridMainViewRadius = 20.0;
static const CGFloat kHexGridSurroundingViewRadius = 10.0;
static const NSUInteger kHexGridNumberOfViews = 20;
static const CGFloat kHexGridOffsetBetweeenViews = 15.0;

@interface HexagonGrid : NSObject

// required inputs
@property (nonatomic) CGRect viewFrame;                      // overall available frame to put grid into
@property (nonatomic) NSUInteger numberOfViews;              // number of views to calculate their centers

// optional inputs (if not set default values are used)

@property (nonatomic) CGFloat mainViewRadius;
@property (nonatomic) CGFloat surroundingViewRadius;
@property (nonatomic) CGFloat offsetBetweeenViews;

@property (nonatomic, getter=areViewsAppearingClockwise) BOOL viewsAreAppearingClockwise;

- (CGPoint)centerOfViewAtIndex:(NSUInteger)index;
- (CGRect)frameOfViewAtIndex:(NSUInteger)index;
- (int)layerOfViewAtIndex:(NSUInteger)index;

@end
