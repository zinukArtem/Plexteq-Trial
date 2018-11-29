//
//  RectangleView.m
//  Plexteq Trial
//
//  Created by Artem Zinuk on 11/29/18.
//  Copyright © 2018 Artem Zinuk. All rights reserved.
//

#import "RectangleView.h"
@interface RectangleView()

// MARK: - Variables

@property (nonatomic, strong) UIView *topLeftCornerCircle;
@property (nonatomic, strong) UIView *topRightCornerCircle;
@property (nonatomic, strong) UIView *bottomLeftCornerCircle;
@property (nonatomic, strong) UIView *bottomRightCornerCircle;
@property (nonatomic, strong) UIView *topMidCornerCircle;

@property (nonatomic) CGPoint prevLocation;

@end

@implementation RectangleView

// MARK: - Init

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    [self initCircles];
    [self setSelected:false];
    [self setRandomColor];
}

- (void) initCircles {
    _topLeftCornerCircle        = [self createCircleView];
    _bottomLeftCornerCircle     = [self createCircleView];
    _topRightCornerCircle       = [self createCircleView];
    _bottomRightCornerCircle    = [self createCircleView];
    _topMidCornerCircle         = [self createCircleView];
    
    [self addSubview:self.topLeftCornerCircle];
    [self addSubview:self.bottomLeftCornerCircle];
    [self addSubview:self.topRightCornerCircle];
    [self addSubview:self.bottomRightCornerCircle];
    [self addSubview:self.topMidCornerCircle];
    
    [self setCornerCirclePosition];
    [self initGestureRecognizers];
}

- (void) initGestureRecognizers {
    
    NSMutableArray *circleArray = [[NSMutableArray alloc] init];
    
    [circleArray addObject:self.topLeftCornerCircle];
    [circleArray addObject:self.bottomLeftCornerCircle];
    [circleArray addObject:self.bottomRightCornerCircle];
    [circleArray addObject:self.topRightCornerCircle];
    
    for (UIView *circle in circleArray) {
        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanCornerView:)];
        [circle addGestureRecognizer:panGestureRecognizer];
    }
    
    UIPanGestureRecognizer *panTopMidCornerRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotateByDragView:)];
    [self.topMidCornerCircle addGestureRecognizer:panTopMidCornerRecognizer];
    
    UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressView:)];
    UIPinchGestureRecognizer *pinchRecognizer         = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchView:)];
    UIRotationGestureRecognizer *rotateRecognizer     = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotateView:)];
    
    [self addGestureRecognizer:pinchRecognizer];
    [self addGestureRecognizer:longPressRecognizer];
    [self addGestureRecognizer:rotateRecognizer];
}

// MARK: - Logic

- (void)layoutSubviews {
    [super layoutSubviews];
    [self setCornerCirclePosition];
    [self setNeedsDisplay];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    self.topLeftCornerCircle.hidden         = !selected;
    self.bottomLeftCornerCircle.hidden      = !selected;
    self.topRightCornerCircle.hidden        = !selected;
    self.bottomRightCornerCircle.hidden     = !selected;
    self.topMidCornerCircle.hidden          = !selected;
}

// MARK: - Gestures

- (IBAction)handleRotateByDragView:(UIPanGestureRecognizer *)sender {
    CGPoint location = [sender locationInView:self.superview];
    UIGestureRecognizerState state = [sender state];
    
    switch (state) {
        case UIGestureRecognizerStateBegan:
            self.prevLocation = location;
            break;
        case UIGestureRecognizerStateChanged:
        case UIGestureRecognizerStateEnded:
            if ([sender.view isEqual:self.topMidCornerCircle]) {
                CGFloat angle = [self angleBetweenStartPoint:self.prevLocation endPoint:location];
                self.transform =  CGAffineTransformRotate(self.transform, angle);
                
                [self setNeedsDisplay];
            }
            self.prevLocation = location;
            break;
        default:
            break;
    }
}

- (IBAction)handlePanCornerView:(UIPanGestureRecognizer *)sender {
    CGPoint translation = [sender translationInView:self];
    UIGestureRecognizerState state = [sender state];
    
    CGRect rect = self.bounds;
    
    if ([sender.view isEqual:self.topLeftCornerCircle]) {
        if (state == UIGestureRecognizerStateBegan) { // topLeftCornerCircle
            [self setAnchorPoint: CGPointMake(1, 1)];
        }
        
        if (fabs(translation.y) < MIN_TRANSLATION_SENSE) { // TODO: AZ refactor to better solution
            if (rect.size.width - translation.x > MIN_RECT_SIDE_SIZE) {
                rect.size.width -= translation.x;
            }
        } else if (fabs(translation.x) < MIN_TRANSLATION_SENSE) {
            if (rect.size.height - translation.y > MIN_RECT_SIDE_SIZE) {
                rect.size.height -= translation.y;
            }
        } else {
            CGFloat middleValue = (translation.x + translation.y) / 2.;
            if (rect.size.width - translation.x > MIN_RECT_SIDE_SIZE) {
                rect.size.width -= middleValue;
            }
            if (rect.size.height - translation.y > MIN_RECT_SIDE_SIZE) {
                rect.size.height -= middleValue;
            }
        }
        
    } else if ([sender.view isEqual:self.topRightCornerCircle]) {
        if (state == UIGestureRecognizerStateBegan) { // topRightCornerCircle
            [self setAnchorPoint: CGPointMake(0, 1)];
        }
        
        if (fabs(translation.y) < MIN_TRANSLATION_SENSE) { // TODO: AZ refactor to better solution
            if (rect.size.width + translation.x > MIN_RECT_SIDE_SIZE) {
                rect.size.width += translation.x;
            }
        } else if (fabs(translation.x) < MIN_TRANSLATION_SENSE) {
            if (rect.size.height - translation.y > MIN_RECT_SIDE_SIZE) {
                rect.size.height -= translation.y;
            }
        } else {
            CGFloat middleValue = (translation.x + translation.y) / 2.;
            if (rect.size.width + translation.x > MIN_RECT_SIDE_SIZE) {
                rect.size.width += middleValue;
            }
            if (rect.size.height - translation.y > MIN_RECT_SIDE_SIZE) {
                rect.size.height -= middleValue;
            }
        }
        
    } else if ([sender.view isEqual:self.bottomLeftCornerCircle]) {
        if (state == UIGestureRecognizerStateBegan) {
            [self setAnchorPoint: CGPointMake(1, 0)];
        }
        
        if (fabs(translation.y) < MIN_TRANSLATION_SENSE) { // TODO: AZ refactor to better solution
            if (rect.size.width - translation.x > MIN_RECT_SIDE_SIZE) {
                rect.size.width -= translation.x;
            }
        } else if (fabs(translation.x) < MIN_TRANSLATION_SENSE) {
            if (rect.size.height + translation.y > MIN_RECT_SIDE_SIZE) {
                rect.size.height += translation.y;
            }
        } else {
            CGFloat middleValue = (translation.x + translation.y) / 2.;
            if (rect.size.width - translation.x > MIN_RECT_SIDE_SIZE) {
                rect.size.width -= middleValue;
            }
            if (rect.size.height + translation.y > MIN_RECT_SIDE_SIZE) {
                rect.size.height += middleValue;
            }
        }
    } else if ([sender.view isEqual:self.bottomRightCornerCircle]) {
        if (state == UIGestureRecognizerStateBegan) {
            [self setAnchorPoint: CGPointZero];
        }
        if (fabs(translation.y) < MIN_TRANSLATION_SENSE) { // TODO: AZ refactor to better solution
            if (rect.size.width + translation.x > MIN_RECT_SIDE_SIZE) {
                rect.size.width += translation.x;
            }
        } else if (fabs(translation.x) < MIN_TRANSLATION_SENSE) {
            if (rect.size.height + translation.y > MIN_RECT_SIDE_SIZE) {
                rect.size.height += translation.y;
            }
        } else {
            CGFloat middleValue = (translation.x + translation.y) / 2.;
            if (rect.size.width + translation.x > MIN_RECT_SIDE_SIZE) {
                rect.size.width += middleValue;
            }
            if (rect.size.height + translation.y > MIN_RECT_SIDE_SIZE) {
                rect.size.height += middleValue;
            }
        }
    }
    
    self.bounds = rect;
    
    [sender setTranslation:CGPointZero inView:self];
    
    if (state == UIGestureRecognizerStateEnded) {
        [self setAnchorPoint: CGPointMake(0.5, 0.5)];
    }
}

- (IBAction)handlePinchView:(UIPinchGestureRecognizer *)sender {
    UIGestureRecognizerState state = [sender state];
    
    if ([sender numberOfTouches] > 1) {
        RectangleView *rectangle = (RectangleView *)sender.view;
        
        CGPoint locationOne = [sender locationOfTouch:0 inView:rectangle];
        CGPoint locationTwo = [sender locationOfTouch:1 inView:rectangle];
        
        CGFloat diffX = locationOne.x - locationTwo.x;
        CGFloat diffY = locationOne.y - locationTwo.y;
        
        if (state == UIGestureRecognizerStateBegan) {
            self.prevLocation = CGPointMake(diffX, diffY);
        } else if (state == UIGestureRecognizerStateChanged) {
            
            CGFloat bearingAngle = (diffY == 0) ? M_PI / 2.0 : fabs(atan(diffX/diffY));
            
            CGRect rect = rectangle.bounds;
            
            if (bearingAngle < M_PI / 6.0 ) {
                //vertical
                if (rect.size.height + (fabs(diffY) - fabs(self.prevLocation.y)) > MIN_RECT_SIDE_SIZE) {
                    rect.size.height += (fabs(diffY) - fabs(self.prevLocation.y));
                }
            } else if (bearingAngle < M_PI / 3.0) {
                //diagonal
                if (rect.size.width + (fabs(diffX) - fabs(self.prevLocation.x)) > MIN_RECT_SIDE_SIZE) {
                    rect.size.width += (fabs(diffX) - fabs(self.prevLocation.x));
                }
                if (rect.size.height + (fabs(diffY) - fabs(self.prevLocation.y)) > MIN_RECT_SIDE_SIZE) {
                    rect.size.height += (fabs(diffY) - fabs(self.prevLocation.y));
                }
                
            } else if (bearingAngle <= M_PI / 2.0) {
                //horizontal
                if (rect.size.width + (fabs(diffX) - fabs(self.prevLocation.x)) > MIN_RECT_SIDE_SIZE) {
                    rect.size.width += (fabs(diffX) - fabs(self.prevLocation.x));
                }
            }
            
            rectangle.bounds = rect;
            
            self.prevLocation = CGPointMake(diffX, diffY);
        }
    }
}

- (IBAction)handleRotateView:(UIRotationGestureRecognizer *)sender {
    sender.view.transform =  CGAffineTransformRotate(sender.view.transform, sender.rotation);
    sender.rotation = 0;
}

- (IBAction)handleLongPressView:(UIGestureRecognizer *)sender {
    if ([sender state] == UIGestureRecognizerStateBegan) {
        [self setRandomColor];
    }
}

- (void)setCornerCirclePosition {
    self.topLeftCornerCircle.center         = CGPointMake(CGRectGetMinX(self.bounds), CGRectGetMinY(self.bounds));
    self.bottomLeftCornerCircle.center      = CGPointMake(CGRectGetMinX(self.bounds), CGRectGetMaxY(self.bounds));
    self.topRightCornerCircle.center        = CGPointMake(CGRectGetMaxX(self.bounds), CGRectGetMinY(self.bounds));
    self.bottomRightCornerCircle.center     = CGPointMake(CGRectGetMaxX(self.bounds), CGRectGetMaxY(self.bounds));
    self.topMidCornerCircle.center          = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMinY(self.bounds));
}

// MARK: - Helpers

- (void)setRandomColor {
    float red   = drand48();
    float green = drand48();
    float blue  = drand48();
    self.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
}

- (UIView *)createCircleView {
    UIView *circle = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    
    circle.backgroundColor = [UIColor clearColor];
    
    circle.layer.cornerRadius = 15;
    circle.layer.borderWidth = 1;
    circle.layer.borderColor = [UIColor blackColor].CGColor;
    
    return circle;
}

- (CGFloat)angleBetweenStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint {
    CGFloat startX  = startPoint.x - self.center.x;
    CGFloat startY  = startPoint.y - self.center.y;
    CGFloat endX    = endPoint.x - self.center.x;
    CGFloat endY    = endPoint.y - self.center.y;
    CGFloat atanX   = atan2f(startX, endX);
    CGFloat atanY   = atan2f(startY, endY);
    
    return atanX - atanY;
}

- (void)setAnchorPoint:(CGPoint)anchorPoint {
    CGPoint newPoint = CGPointMake(self.bounds.size.width * anchorPoint.x, self.bounds.size.height * anchorPoint.y);
    CGPoint oldPoint = CGPointMake(self.bounds.size.width * self.layer.anchorPoint.x, self.bounds.size.height * self.layer.anchorPoint.y);
    
    newPoint = CGPointApplyAffineTransform(newPoint, self.transform);
    oldPoint = CGPointApplyAffineTransform(oldPoint, self.transform);
    
    CGPoint position = self.layer.position;
    position.x -= oldPoint.x;
    position.x += newPoint.x;
    position.y -= oldPoint.y;
    position.y += newPoint.y;
    
    self.layer.position = position;
    self.layer.anchorPoint = anchorPoint;
}

@end
