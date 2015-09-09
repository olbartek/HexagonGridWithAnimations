//
//  HexagonGrid.m
//  HexagonGrid
//
//  Created by Bartosz Olszanowski on 03.09.2015.
//  Copyright (c) 2015 Vorm. All rights reserved.
//

#import "HexagonGrid.h"

@interface HexagonGrid()

@property (nonatomic, strong) NSMutableArray *viewCenters; // of CGPoint containing Views' centers
@property (nonatomic) CGPoint gridViewCenter;
@property (nonatomic) NSInteger numberOfSurroundingLayers;
@property (nonatomic) NSInteger numberOfViewsInTheLastLayer;

@end

@implementation HexagonGrid

@synthesize mainViewRadius, surroundingViewRadius, offsetBetweeenViews;

#pragma mark - Properties

- (void)setViewFrame:(CGRect)viewFrame
{
    _viewFrame = viewFrame;
    
    // Calculate GridView center
    self.gridViewCenter = CGPointMake(_viewFrame.origin.x+_viewFrame.size.width/2, _viewFrame.origin.y+_viewFrame.size.height/2);
    if (!self.viewCenters.count && _numberOfViews>0) {
        [self calculateViewCenters];
    }
}

- (void)setNumberOfViews:(NSUInteger)numberOfViews
{
    _numberOfViews = numberOfViews;
    
    // Calculate number of surrounding layers
    NSInteger numberOfViewsInCurrentLayer = 6;          // first layer
    _numberOfSurroundingLayers = 1;                     // start from first layer
    NSInteger numberOfRemainingViews = numberOfViews-1; // subtract main view
    
    while (numberOfRemainingViews-numberOfViewsInCurrentLayer > 0) {
        numberOfRemainingViews -= numberOfViewsInCurrentLayer;
        numberOfViewsInCurrentLayer += 6;
        _numberOfSurroundingLayers++;
    }
    _numberOfViewsInTheLastLayer = numberOfRemainingViews;
    
    [self calculateViewCenters];
}

-(NSMutableArray *)viewCenters
{
    if (!_viewCenters) {
        _viewCenters = [[NSMutableArray alloc] init];
    }
    return _viewCenters;
}

#pragma mark - Initialization

- (instancetype)init
{
    self = [super init];
    if (self) {
        // Default Initialization
        mainViewRadius = kHexGridMainViewRadius;
        surroundingViewRadius = kHexGridSurroundingViewRadius;
        offsetBetweeenViews = kHexGridOffsetBetweeenViews;
        _viewsAreAppearingClockwise = YES;
    }
    return self;
}

#pragma mark - Get View Location

- (CGPoint)centerOfViewAtIndex:(NSUInteger)index
{
    return [[self.viewCenters objectAtIndex:index] CGPointValue];
}

- (CGRect)frameOfViewAtIndex:(NSUInteger)index
{
    if (index == 0) {
        // Main View
        CGPoint center = [self centerOfViewAtIndex:index];
        return CGRectMake(center.x-mainViewRadius, center.y-mainViewRadius, 2*mainViewRadius, 2*mainViewRadius);
    } else {
        // Surrounding View
        CGPoint center = [self centerOfViewAtIndex:index];
        return CGRectMake(center.x-surroundingViewRadius, center.y-surroundingViewRadius, 2*surroundingViewRadius, 2*surroundingViewRadius);
    }
}

- (int)layerOfViewAtIndex:(NSUInteger)index
{
    if (index == 0) {
        return 0;
    } else {
        // Calculate number of layer
        NSInteger numberOfViewsInCurrentLayer = 6;          // first layer
        int layerNumber = 1;                          // start from first layer
        NSInteger numberOfRemainingViews = index;
        
        while (numberOfRemainingViews-numberOfViewsInCurrentLayer > 0) {
            numberOfRemainingViews -= numberOfViewsInCurrentLayer;
            numberOfViewsInCurrentLayer += 6;
            layerNumber++;
        }
        return layerNumber;
    }
    
}

#pragma mark - View center calculation

- (void)calculateViewCenters
{
    CGPoint point;
    CGFloat pointOffset;
    NSValue *newPoint;
    float deltaAngle = 2*M_PI/6;
    
    if (_viewCenters.count) {
        [_viewCenters removeAllObjects];
    }
    
    // Main View Center
    point = _gridViewCenter;
    newPoint = [NSValue valueWithCGPoint:point];
    [_viewCenters addObject:newPoint];
    
    // Surrounding Views Centers
    // For all layers
    for (NSUInteger layer=1; layer <= _numberOfSurroundingLayers; layer++) {
        
        pointOffset = mainViewRadius + layer*offsetBetweeenViews + (2*layer-1)*surroundingViewRadius;
        NSInteger numOfPointsToAddBetweenCorners = layer-1;
        NSMutableArray *cornerPointsInCurrentLayer = [[NSMutableArray alloc] init];
        NSMutableArray *pointsBetweenCorners = [[NSMutableArray alloc] init];
        
        // Calculate Hexagon Corner Points
        for (int i = 0; i < 6; i++) {
            
            float t = i*deltaAngle;
            float x, y;
            if (self.areViewsAppearingClockwise) {
                x = pointOffset*sinf(t) + _gridViewCenter.x;
                y = -pointOffset*cosf(t) + _gridViewCenter.y;
            } else {
                x = -pointOffset*sinf(t) + _gridViewCenter.x;
                y = -pointOffset*cosf(t) + _gridViewCenter.y;
            }
            point = CGPointMake(x, y);
            newPoint = [NSValue valueWithCGPoint:point];
            [cornerPointsInCurrentLayer addObject:newPoint];
            
            // Calculate centers which are between hexagon corners
            if (i >= 1 && numOfPointsToAddBetweenCorners > 0) {
                // Calculate delta between points
                CGPoint aPoint = [[cornerPointsInCurrentLayer objectAtIndex:i-1] CGPointValue];
                CGPoint bPoint = [[cornerPointsInCurrentLayer objectAtIndex:i] CGPointValue];
                
                CGFloat xOffset = (bPoint.x-aPoint.x)/(numOfPointsToAddBetweenCorners+1);
                CGFloat yOffset = (bPoint.y-aPoint.y)/(numOfPointsToAddBetweenCorners+1);
                
                for (int j = 1; j <= numOfPointsToAddBetweenCorners; j++) {
                    point = CGPointMake(aPoint.x+j*xOffset, aPoint.y+j*yOffset);
                    newPoint = [NSValue valueWithCGPoint:point];
                    [pointsBetweenCorners addObject:newPoint];
                }
            }
            
            // Calculate centers between last and first corner
            if (i ==5 && numOfPointsToAddBetweenCorners > 0) {
                // Calculate delta between points
                CGPoint aPoint = [[cornerPointsInCurrentLayer objectAtIndex:i] CGPointValue];
                CGPoint bPoint = [[cornerPointsInCurrentLayer objectAtIndex:0] CGPointValue];
                
                CGFloat xOffset = (bPoint.x-aPoint.x)/(numOfPointsToAddBetweenCorners+1);
                CGFloat yOffset = (bPoint.y-aPoint.y)/(numOfPointsToAddBetweenCorners+1);
                
                for (int j = 1; j <= numOfPointsToAddBetweenCorners; j++) {
                    point = CGPointMake(aPoint.x+j*xOffset, aPoint.y+j*yOffset);
                    newPoint = [NSValue valueWithCGPoint:point];
                    [pointsBetweenCorners addObject:newPoint];
                }
            }
        }
        
        // Add points to the array
        int pointIndex = 0;
        for (int i = 0; i < 6; i++) {
            NSValue *pointToAdd = [cornerPointsInCurrentLayer objectAtIndex:i];
            [_viewCenters addObject:pointToAdd];
            // add points which are between corners
            for (int j = pointIndex; j < pointIndex+numOfPointsToAddBetweenCorners; j++) {
                NSValue *pointToAdd = [pointsBetweenCorners objectAtIndex:j];
                [_viewCenters addObject:pointToAdd];
            }
            if (numOfPointsToAddBetweenCorners) {
                pointIndex += numOfPointsToAddBetweenCorners;
            }
        }
    }
    
}

@end
