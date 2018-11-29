//
//  RectangleSpaceView.m
//  Plexteq Trial
//
//  Created by Artem Zinuk on 11/29/18.
//  Copyright © 2018 Artem Zinuk. All rights reserved.
//

#import "RectangleSpaceView.h"
#import "RectangleView.h"

@interface RectangleSpaceView()

// MARK: - Variables

@property (nonatomic, strong) CAShapeLayer *smallCircleLayer;
@property (nonatomic, strong) RectangleView *curentRectangle;

@property (nonatomic, strong) NSMutableArray <RectangleView *> *rectangles;

@property (nonatomic) CGPoint prevLocation;

@end


@implementation RectangleSpaceView

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
    [self initGestures];
}

- (void)initGestures {
    UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapOnView:)];
    [self addGestureRecognizer:singleTapRecognizer];
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanOnView:)];
    [self addGestureRecognizer:panRecognizer];
}

// MARK: - Rectangle Space View Gestures

- (IBAction)handleSingleTapOnView:(UIGestureRecognizer *)sender {
    CGPoint location = [sender locationInView:self];
    
    if (self.smallCircleLayer == nil) {
        [self.rectangles enumerateObjectsUsingBlock:^(RectangleView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.selected = false;
        }];
        
        [self drawSmallCircleInPoint:location];
        self.prevLocation = location;
    } else {
        [self createRectInStartPoint:self.prevLocation finishPoint:location];
        [self.smallCircleLayer removeFromSuperlayer];
        self.smallCircleLayer = nil;
    }
    
}

- (IBAction)handlePanOnView:(UIGestureRecognizer *)sender {
    CGPoint location = [sender locationInView:self];
    UIGestureRecognizerState state = [sender state];
    
    switch (state) {
        case UIGestureRecognizerStateBegan:
            self.curentRectangle.selected = false;
            self.curentRectangle = nil;
            
            if (self.curentRectangle == nil) {
                [self createRectViewInPoint:location];
            }
            
            [self.rectangles addObject:self.curentRectangle];
            [self addSubview:self.curentRectangle];
            break;
        case UIGestureRecognizerStateChanged:
            self.curentRectangle.frame = CGRectMake(self.curentRectangle.frame.origin.x,
                                                    self.curentRectangle.frame.origin.y,
                                                    location.x > self.curentRectangle.frame.origin.x ? location.x - self.curentRectangle.frame.origin.x : 0,    // TODO: AZ refactor if need `all side` creation
                                                    location.y > self.curentRectangle.frame.origin.y ? location.y - self.curentRectangle.frame.origin.y : 0);
            break;
        case UIGestureRecognizerStateEnded:
            [self setMinimumSizeOfRect];
            [self.smallCircleLayer removeFromSuperlayer];
            self.smallCircleLayer = nil;
            self.curentRectangle = nil;
            break;
        default:
            break;
    }
}

// MARK: - Rectangle View Gestures

- (IBAction)handleSingleTapOnRectView:(UIGestureRecognizer *)sender {
    RectangleView *rectangle = (RectangleView *)sender.view;
    [self selectRectangle:rectangle];
}

- (IBAction)handleDoubleTapOnRectView:(UIGestureRecognizer *)sender {
    RectangleView *rectangle = (RectangleView *)sender.view;
    [rectangle removeFromSuperview];
    
    [self.rectangles removeObject:rectangle];
}

- (IBAction)handlePanRectView:(UIPanGestureRecognizer *)sender {
    RectangleView *rectangle = (RectangleView *)sender.view;
    [self selectRectangle:rectangle];
    
    CGPoint location = [sender locationInView:self];
    UIGestureRecognizerState state = [sender state];
    
    switch (state) {
        case UIGestureRecognizerStateBegan:
            self.prevLocation = location;
            break;
        case UIGestureRecognizerStateChanged:
        case UIGestureRecognizerStateEnded:
            [self bringSubviewToFront: sender.view];
            
            CGPoint delta = CGPointMake(location.x - self.prevLocation.x,
                                        location.y - self.prevLocation.y);
            
            CGPoint newCenter = CGPointMake(rectangle.center.x + delta.x,
                                            rectangle.center.y + delta.y);
            
            rectangle.center = newCenter;
            
            self.prevLocation = location;
            break;
        default:
            break;
    }
}

// MARK: - Init New Recrangle

- (void)drawSmallCircleInPoint:(CGPoint)point {
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithArcCenter:point radius:13. startAngle:0 endAngle:2*M_PI clockwise:YES];
    
    _smallCircleLayer = [[CAShapeLayer alloc] init];
    
    [self.smallCircleLayer setPath:circlePath.CGPath];
    [self.smallCircleLayer setStrokeColor:[UIColor blackColor].CGColor];
    [self.smallCircleLayer setFillColor:[UIColor clearColor].CGColor];
    [self.smallCircleLayer setLineWidth:1.0];
    [self.smallCircleLayer setStrokeEnd:1.0];
    
    [self.layer addSublayer:self.smallCircleLayer];
}

- (void) createRectInStartPoint:(CGPoint)startPoint finishPoint:(CGPoint)endPoint {
    CGRect rectangleRect = CGRectMake((startPoint.x < endPoint.x ? startPoint.x : endPoint.x),
                                      (startPoint.y < endPoint.y ? startPoint.y : endPoint.y),
                                      MAX(fabs(startPoint.x - endPoint.x), MIN_RECT_SIDE_SIZE),
                                      MAX(fabs(startPoint.y - endPoint.y), MIN_RECT_SIDE_SIZE));
    
    
    
    RectangleView *newRectangle = [[RectangleView alloc] initWithFrame:rectangleRect];
    [self.rectangles addObject:newRectangle];
    [self addSubview:newRectangle];
    [self addGestureToNewRectangle:newRectangle];
}

- (void)createRectViewInPoint:(CGPoint)point {
    _curentRectangle = [[RectangleView alloc] initWithFrame:CGRectMake(point.x, point.y, 0., 0.)];
    
    [self addGestureToNewRectangle:_curentRectangle];
}

// MARK: - Helpers

- (void)addGestureToNewRectangle:(RectangleView *)rectangle {
    UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapOnRectView:)];
    [rectangle addGestureRecognizer:singleTapRecognizer];
    
    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector (handleDoubleTapOnRectView:)];
    [doubleTapRecognizer setNumberOfTapsRequired:2];
    [singleTapRecognizer requireGestureRecognizerToFail: doubleTapRecognizer];
    [rectangle addGestureRecognizer: doubleTapRecognizer];
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanRectView:)];
    [rectangle addGestureRecognizer:panRecognizer];
}

- (void)setMinimumSizeOfRect {
    if (self.curentRectangle) {
        CGRect frame = self.curentRectangle.frame;
        frame.size.width = MAX(CGRectGetWidth(frame), MIN_RECT_SIDE_SIZE);
        frame.size.height = MAX(CGRectGetHeight(frame), MIN_RECT_SIDE_SIZE);
        self.curentRectangle.frame = frame;
    }
}
- (void)selectRectangle:(RectangleView *)rectangle {
    if (self.curentRectangle) {
        self.curentRectangle.selected = false;
        self.curentRectangle = nil;
    }
    rectangle.selected = true;
    self.curentRectangle = rectangle;
    [self bringSubviewToFront:rectangle];
}

-(NSMutableArray *)rectangles {
    if (_rectangles == nil) {
        _rectangles = [[NSMutableArray alloc] init];
    }
    return _rectangles;
}

@end
