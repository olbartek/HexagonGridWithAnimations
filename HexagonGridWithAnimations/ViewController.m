//
//  ViewController.m
//  hexGrid
//
//  Created by Bartosz Olszanowski on 03.09.2015.
//  Copyright (c) 2015 Vorm. All rights reserved.
//

#import "ViewController.h"
#import "HexagonGrid.h"
#import "PortaitImageView.h"
#import <QuartzCore/QuartzCore.h>

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIView *drawingView;
@property (nonatomic, strong) HexagonGrid *hexGrid;
@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIAttachmentBehavior *attachment;
@property (nonatomic, strong) PortaitImageView *mainView;
@property (nonatomic, strong) PortaitImageView *draggedView;
@property (nonatomic, assign) BOOL draggingView;
@property (nonatomic, assign) CGPoint offset;

@end

@implementation ViewController

#pragma mark - Constants

static const NSInteger kNumberOfViews = 19;
// Animation Constants
static const CGFloat kDelayDivider = 60;
static const CGFloat kAnimationDuration = 0.5;
static const CGFloat kAnimationDelay = 0.05;
static const CGFloat kDampingRate = 0.65;
static const CGFloat kInitialVelocity = 0.1;

#pragma mark - Properties

-(UIDynamicAnimator *)animator
{
    if (!_animator) {
        _animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.drawingView];
    }
    return _animator;
}

#pragma mark - VC's Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Add tapGestureRecognizer to self.drawingView
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tapRecognizer.numberOfTapsRequired = 2;
    tapRecognizer.numberOfTouchesRequired = 1;
    [self.drawingView addGestureRecognizer:tapRecognizer];
    
    // Add motion effects
    UIInterpolatingMotionEffect *horizontalMotionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    horizontalMotionEffect.minimumRelativeValue = @(-50);
    horizontalMotionEffect.maximumRelativeValue = @(50);
    
    UIInterpolatingMotionEffect *verticalMotionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    verticalMotionEffect.minimumRelativeValue = @(-50);
    verticalMotionEffect.maximumRelativeValue = @(50);
    
    UIMotionEffectGroup *group = [UIMotionEffectGroup new];
    group.motionEffects = @[horizontalMotionEffect, verticalMotionEffect];
    [self.drawingView addMotionEffect:group];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Initialize hexGrid
    self.hexGrid = [[HexagonGrid alloc] init];
    // Set optional parameters
    self.hexGrid.viewsAreAppearingClockwise = YES;
    self.hexGrid.mainViewRadius = 35;
    self.hexGrid.surroundingViewRadius = 25;
    self.hexGrid.offsetBetweeenViews = 15;
    // Set required parameters
    self.hexGrid.viewFrame = self.drawingView.frame;
    self.hexGrid.numberOfViews = kNumberOfViews;
    
    // Produce UIViews
    for (int i = 0; i < kNumberOfViews; i++) {
        [self performSelector:@selector(drawViewAtIndex:) withObject:@(i) afterDelay:(double)i/5];
    }
}

#pragma mark - Drawing

- (void)drawViewAtIndex:(NSNumber *)i
{
    // Take frame from grid
    CGRect aFrame = [self.hexGrid frameOfViewAtIndex:i.intValue];
    
    // Image View
    PortaitImageView *newView = [[PortaitImageView alloc] initWithFrame:aFrame];
    int randNum = arc4random() % 10;
    newView.image = [UIImage imageNamed:[[self VORMTeamImages] objectAtIndex:randNum]];
    // Set layer
    newView.layer.backgroundColor=[[UIColor clearColor] CGColor];
    newView.layer.cornerRadius = i.intValue == 0 ? self.hexGrid.mainViewRadius : self.hexGrid.surroundingViewRadius;
    newView.layer.masksToBounds = YES;
    newView.layerNumber = [self.hexGrid layerOfViewAtIndex:i.intValue];
    [self.drawingView addSubview:newView];
    
    // Animate View
    [UIView animateWithDuration:0.4
                          delay:0
         usingSpringWithDamping:0.5
          initialSpringVelocity:0.2
                        options:0
                     animations:^{
                            CGFloat newWidth = newView.frame.size.width * 1.1;
                            CGFloat newHeight = newView.frame.size.height * 1.1;
                            newView.frame = CGRectMake(newView.frame.origin.x, newView.frame.origin.y, newWidth, newHeight);
                        }
                     completion:^(BOOL finished) {
                            CGFloat newWidth = newView.frame.size.width / 1.1;
                            CGFloat newHeight = newView.frame.size.height / 1.1;
                            newView.frame = CGRectMake(newView.frame.origin.x, newView.frame.origin.y, newWidth, newHeight);
                        }];
    
    if (i.intValue == 0) {
        self.mainView = newView;
        self.mainView.userInteractionEnabled = YES;
        self.mainView.offsetFromMainView = CGPointZero;
        
    } else {
        CGFloat xOffset = newView.center.x - self.mainView.center.x;
        CGFloat yOffset = newView.center.y - self.mainView.center.y;
        newView.offsetFromMainView = CGPointMake(xOffset, yOffset);
    
    }
    // Add panGestureRecognizer to the View
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    newView.userInteractionEnabled = YES;
    [newView addGestureRecognizer:panRecognizer];
}

- (NSArray *)VORMTeamImages
{
    return @[@"janposz.jpg", @"antonio.jpg", @"andrew.jpg", @"mike.jpg", @"agajucha.jpg", @"simon.jpg", @"bart.jpg", @"aparcik.jpg", @"bartosz.jpg", @"blazej.jpg"];
}

#pragma mark - Gesture Recognizers

- (void)handleTap:(UITapGestureRecognizer *)gesture
{
    //CGPoint touchPoint = [gesture locationInView:self.drawingView];
    //UIView* draggedView = gesture.view;

    // Move all views to the default position when tapped twice on the screen
    int i = 0;
    for (UIView *aView in self.drawingView.subviews) {
        if ([aView isKindOfClass:[PortaitImageView class]]) {
            PortaitImageView *pView = (PortaitImageView *)aView;
            [self performSelector:@selector(animateViewToCenter:) withObject:pView afterDelay:0.15*pView.layerNumber];
            
        }
        i++;
    }
}

// Move all views according to dragged view's position while panning
-(void)handlePan:(UIPanGestureRecognizer *)gesture
{
    CGPoint touchPoint = [gesture locationInView:self.drawingView];
    UIView* draggedView = gesture.view;
    self.draggedView = (PortaitImageView *)draggedView;
    
    self.offset = CGPointMake(touchPoint.x-(self.drawingView.center.x+self.draggedView.offsetFromMainView.x), touchPoint.y-(self.drawingView.center.y+self.draggedView.offsetFromMainView.y));

    if (gesture.state == UIGestureRecognizerStateBegan) {
        [self.animator removeAllBehaviors];
        self.attachment = [[UIAttachmentBehavior alloc] initWithItem:draggedView attachedToAnchor:touchPoint];
        [self.animator addBehavior:self.attachment];
        NSLog(@"Pan began.");
        
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        [self.attachment setAnchorPoint:touchPoint];
        int i = 0;
        for (UIView *aView in self.drawingView.subviews) {
            if ([aView isKindOfClass:[PortaitImageView class]]) {
                PortaitImageView *pView = (PortaitImageView *)aView;
                if (pView != self.draggedView) {
                    [self performSelector:@selector(animateView:) withObject:pView afterDelay:(double)i/kDelayDivider];
                }
            }
            i++;
        }
        NSLog(@"Pan changed.");
        
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        [self.attachment setAnchorPoint:touchPoint];
        int i = 0;
        for (UIView *aView in self.drawingView.subviews) {
            if ([aView isKindOfClass:[PortaitImageView class]]) {
                PortaitImageView *pView = (PortaitImageView *)aView;
                [self performSelector:@selector(animateView:) withObject:pView afterDelay:(double)i/kDelayDivider];
                i++;
            }
        }
        [self.animator removeBehavior:self.attachment];
        NSLog(@"Pan ended.");
    }
}

#pragma mark - Views' animations

- (void)animateView:(PortaitImageView *)pView
{
    CGPoint pointToMove = pointToMove = CGPointMake(self.drawingView.center.x+pView.offsetFromMainView.x+self.offset.x, self.drawingView.center.y+pView.offsetFromMainView.y+self.offset.y);
        
        [UIView animateWithDuration:kAnimationDuration
                              delay:kAnimationDelay
             usingSpringWithDamping:kDampingRate
              initialSpringVelocity:kInitialVelocity
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             pView.center = pointToMove;
                         }
                         completion:nil];
}

- (void)animateViewToCenter:(PortaitImageView *)pView
{
    [UIView animateWithDuration:kAnimationDuration
                          delay:kAnimationDelay
         usingSpringWithDamping:kDampingRate
          initialSpringVelocity:kInitialVelocity
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
        pView.center = CGPointMake(self.drawingView.center.x+pView.offsetFromMainView.x, self.drawingView.center.y+pView.offsetFromMainView.y);
    }
                     completion:nil];
}

@end
