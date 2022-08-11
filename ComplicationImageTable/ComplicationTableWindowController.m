//
//  ComplicationTableWindowController.m
//  ComplicationImageTable
//
//  Created by Lee Ann Rucker on 8/9/22.
//

#import "ComplicationTableWindowController.h"

#define IOS_DRAWING 0 // Move the ios drawing out of the way. There are other differences, like flipping, that I didn't worry too much about because this is just to get a rough idea.

typedef NS_ENUM(NSInteger, ImageKinds) {
    graphicCornerTextImage = 0,
    graphicCircularStackImage,
    graphicCircularImage,
    graphicRectangularHeaderImage,

    graphicExtraLargeStackImage,
    graphicExtraLargeCircularImage,

    modularSmallStackImage,
    modularSmallSimpleImage,

    utilitarianSmallFlatImage,
    utilitarianSmallSquare,
    circularSmallStackImage,
    circularSmallSimpleImage,
    extraLargeStackImage,

} ;

// This is for making a full color + tinted icon, which I did not bother to replicate on the Mac. The colors are easy to test in the simulated phone's watch face chooser.
typedef enum XTColorDialMode {
    dial_normal,
    dial_onepiece,
    dial_background,
    dial_foreground
} XTColorDialMode;

NSArray *ImageKindLabels = @[@"Gr Corner Text",
                     @"Gr Circular Stack",
                     @"Gr Circular",
                     @"Gr Rectangular",

                     @"Gr XL Stack",
                     @"Gr XL Circular",

                     @"Mod Small Stack",
                     @"Mod Small",

                     @"Util Small Flat",
                     @"Util Small Square",
                     @"Circular Small Stack",
                     @"Circular Small",
                     @"XL Stack"];


// Thanks to http://www.glimsoft.com/02/18/watchos-complications/ for doing all the work to organize the numbers

#define WATCH_COUNT 5

// -1 : not supported at that size.
// These are the pt dimensions, half the px.
static CGFloat CK_ImageSizes[][WATCH_COUNT] =
  {{-1, 20, 21, 22, 24}, // graphicCornerTextImageSizes
   {-1, 14, 15, 16, 16.5}, // graphicCircularStackImageSizes
   {-1, 42, 44.5, 47, 50}, // graphicCircularImageSizes
   {-1, 12, 12.5, 13.5, 14.5}, // graphicRectangularHeaderImageSizes

   {-1, 40, 42, 44, 47}, // graphicExtraLargeStackImageSizes
   {-1, 120, 126, 132, 143}, // graphicExtraLargeCircularImageSizes

   {14, 15, 16, 17, 18}, // modularSmallStackImageSizes
   {26, 29, 30.5, 32, 34.5}, // modularSmallSimpleImageSizes

   {9, 10, 10.5, 11, 12}, // utilitarianSmallFlatImageSizes
   {20, 22, 23.5, 25, 26}, // utilitarianSmallSquareSizes
   {7, 8, 8.5, 9, 9.5}, // circularSmallStackImageSizes
   {16, 18, 19, 20, 21.5}, // circularSmallSimpleImageSizes
   {42, 45, 47.5, 51, 53.5} // extraLargeStackImageSizes
  };

static CGFloat CK_RectangleWidth[WATCH_COUNT] = {-1, 150, 159, 171, 178.5};


@interface CKTableColumn : NSTableColumn
@property NSInteger index; // index into the watch size arrays, set in nib's User Defined Runtime Attributes
@end

@implementation CKTableColumn
@end

@interface ComplicationTableWindowController () <NSTableViewDelegate, NSTableViewDataSource>

@property (weak) IBOutlet NSTableView *tableView;

@end


@implementation ComplicationTableWindowController

- (NSString *)windowNibName {
    return @"ComplicationTableWindowController";
}

- (void)windowDidLoad {
    [super windowDidLoad];
        

    [self.tableView reloadData];
}

// The only essential/required tableview dataSource method.
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return ImageKindLabels.count;
}

- (CGFloat)tableView:(NSTableView *)tableView
         heightOfRow:(NSInteger)row
{
    return CK_ImageSizes[row][WATCH_COUNT-1] + 10;
}

- (NSImage *)imageForType:(ImageKinds)type width:(CGFloat)width height:(CGFloat)height watchSize:(NSInteger)watchSize
{
    NSImage *image = nil;
    CGFloat angle = 0.78;
    switch (type) {
        case graphicCircularStackImage:
        case graphicRectangularHeaderImage:
        case graphicExtraLargeStackImage:

        case utilitarianSmallFlatImage:
        case utilitarianSmallSquare:
        case modularSmallStackImage:
        case circularSmallStackImage:
            break;

        case graphicExtraLargeCircularImage:
        case graphicCircularImage:
        case extraLargeStackImage:
            {
            CGFloat ringInset = 2;
            CGFloat imgSize = 6;
            CGFloat handInset = 3;
            if (type == graphicExtraLargeCircularImage) {
                handInset = (width > 126) ? 5 : 3;
                imgSize = 10;
                ringInset = 5;
            }

            image = [self colorImageWithRectSize:width angle:angle mode:dial_normal ringInset:ringInset handInset:handInset dialImageSize:imgSize];
            }
            break;

        case graphicCornerTextImage:
        case circularSmallSimpleImage:
        case modularSmallSimpleImage:
            // hand
            {
            CGFloat lineWidth = (type == graphicCircularImage ? 2 : 1);
            image = [self handWithRectSize:width lineWidth:lineWidth angle:angle includeRing:YES];
            }
            break;
    }
    return image;
}


- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(CKTableColumn *)tableColumn row:(NSInteger)row {
    // Every column has its own prototype, and defines a custom value which is the index into the watch info arrays.
    static NSArray *ColumnNames = @[@"38mm", @"40mm", @"41mm", @"44mm", @"45mm"];

    NSString *identifier = tableColumn.identifier;
    
    if ([identifier isEqualToString:@"KindCell"]) {
        NSTextField *textField = [tableView makeViewWithIdentifier:identifier owner:self];
        textField.objectValue = ImageKindLabels[row];
        return textField;
    } else if ([ColumnNames containsObject:identifier]) {
        NSImageView *imageView = [tableView makeViewWithIdentifier:identifier owner:self];
        imageView.imageScaling = NSImageScaleNone;
        NSInteger index = tableColumn.index;
        CGFloat imgSize = CK_ImageSizes[row][index];
        if (imgSize > 0) {
            CGFloat rectWidth = imgSize;
            if (row == graphicRectangularHeaderImage) {
                rectWidth = CK_RectangleWidth[index];
            }
            NSLog(@"%@ for %ld is %f", identifier, (long)index, imgSize);
            NSImage *image = [self imageForType:row width:rectWidth height:imgSize watchSize:index];
            imageView.toolTip = [NSString stringWithFormat:@"%.0fx%.0f", rectWidth, imgSize];
            [imageView setFrameSize:NSMakeSize(rectWidth, imgSize)];
            imageView.objectValue = image;
            if (tableColumn.width < rectWidth) {
                tableColumn.width = rectWidth;
            }
        } else {
            imageView.hidden = YES;
        }
        return imageView;
    } else {
        NSAssert1(NO, @"Unhandled table column identifier %@", identifier);
    }
    return nil;
}

- (NSImage *)handWithRectSize:(CGFloat)rectSize
                    lineWidth:(CGFloat)lineWidth
                        angle:(CGFloat)radians  // -1 for placeholder with no angle data
                  includeRing:(BOOL)includeRing
                        inset:(CGFloat)inset
                        color:(NSColor *)color
                    ringColor:(NSColor *)ringColor
{
    CGRect outerRect = CGRectMake(0, 0, rectSize, rectSize);
    CGRect rect = CGRectInset(outerRect, inset, inset);
    CGFloat adjustedInset = lineWidth + inset;

    CGFloat dotInset = (rectSize - lineWidth * 2) / 2;
#if IOS_DRAWING
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 2);
    CGContextRef context = UIGraphicsGetCurrentContext();
#else
    CGSize size = outerRect.size;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, size.width, size.height, 8, 0, colorSpace, kCGImageAlphaPremultipliedLast);
    NSGraphicsContext *graphicsContext = [NSGraphicsContext graphicsContextWithCGContext:context flipped:YES];

    NSGraphicsContext *currentContext = [NSGraphicsContext currentContext];
    [NSGraphicsContext setCurrentContext:graphicsContext];
#endif
    // Debugging

    if (inset > 0) {
//        CGContextSetFillColorWithColor(context, [(includeRing ? [NSColor lightGrayColor] : [NSColor magentaColor]) CGColor]);
        CGContextSetFillColorWithColor(context, [[NSColor lightGrayColor] CGColor]);
        CGContextFillRect(context, rect);
    }


    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextSetStrokeColorWithColor(context, [color CGColor]);
    CGFloat radius = rectSize / 2;
    CGPoint center = CGPointMake(radius, radius);
    CGContextSetLineWidth(context, lineWidth);

    CGRect dotRect = CGRectInset(outerRect, dotInset, dotInset);
    CGContextFillEllipseInRect(context, dotRect);

    if (radians >= 0) {
        NSBezierPath *arm = [NSBezierPath bezierPath];
        [arm moveToPoint:CGPointZero];
        [arm lineToPoint:CGPointMake(0, -(radius - (adjustedInset * 2.5)))];
        arm.lineWidth = lineWidth;
        arm.lineCapStyle = NSLineCapStyleRound; //kCGLineCapRound;
#if IOS_DRAWING
        CGAffineTransform position = CGAffineTransformMakeTranslation(center.x, center.y);
        position = CGAffineTransformRotate(position, radians);
#else
        NSAffineTransform *position = [NSAffineTransform transform];
        [position translateXBy:center.x yBy:center.y];
        [position rotateByRadians:radians];
#endif
        [arm transformUsingAffineTransform:position];
        [arm stroke];
    }

    if (includeRing) {
        CGContextSetFillColorWithColor(context, [ringColor CGColor]);
        CGContextSetStrokeColorWithColor(context, [ringColor CGColor]);
        CGContextSetLineWidth(context, adjustedInset);
        CGRect edgeRect = CGRectInset(rect, adjustedInset, adjustedInset);
        CGContextStrokeEllipseInRect(context, edgeRect);
    }
#if IOS_DRAWING
    NSImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
#else
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    [NSGraphicsContext setCurrentContext:currentContext];

    NSImage *image = [[NSImage alloc] initWithCGImage:imageRef size:NSZeroSize];
#endif
    return image;
}

- (NSImage *)handWithRectSize:(CGFloat)rectSize
                    lineWidth:(CGFloat)lineWidth
                        angle:(CGFloat)radians  // -1 for placeholder with no angle data
                  includeRing:(BOOL)includeRing
{
    return [self handWithRectSize:rectSize lineWidth:lineWidth angle:radians includeRing:includeRing inset:0 color:[NSColor blackColor] ringColor:[NSColor blackColor]];
}

- (NSImage *)colorImageWithRectSize:(CGFloat)rectSize
                              angle:(CGFloat)radians
                               mode:(XTColorDialMode)mode
                          ringInset:(CGFloat)ringInset
                          handInset:(CGFloat)handInset
                      dialImageSize:(CGFloat)imgSize
 {
    BOOL tinted = mode != dial_normal;
    CGFloat lineWidth = 1;
    CGRect rect = CGRectMake(0, 0, rectSize, rectSize);
#if IOS_DRAWING
// Note that this is scale==2 but the Mac version isn't. Dealing with CGContextScaleCTM is left as an exercise for the reader :)
// If you get pt, px, and scale out of sync and make a 2x image with px dimensions because UIGraphicsBeginImageContext defaults to scale=1, the Watch will happily take your double-size image, center it, and clip your carefully calculated edge content. This is the bug I discovered with this app :)
    UIGraphicsBeginImageContextWithOptions(rect.size, !tinted, 2);
    CGContextRef context = UIGraphicsGetCurrentContext();
#else
    CGSize size = rect.size;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, size.width, size.height, 8, 0, colorSpace, kCGImageAlphaPremultipliedLast);
    NSGraphicsContext *graphicsContext = [NSGraphicsContext graphicsContextWithCGContext:context flipped:NO];

    NSGraphicsContext *currentContext = [NSGraphicsContext currentContext];
    [NSGraphicsContext setCurrentContext:graphicsContext];
#endif
    NSColor *armColor = tinted ? [NSColor whiteColor] : [NSColor orangeColor];
    NSColor *iconColor = tinted ? [NSColor whiteColor] : [NSColor highlightColor];

#if IOS_DRAWING
    if (mode != dial_foreground) {
        CGContextSetFillColorWithColor(context, [[NSColor colorWithWhite:(tinted ? 0.8 : 0.1) alpha:(tinted ? 0.2 : 1)] CGColor]);
        CGContextFillRect(context, rect);
    }
#endif

    CGContextSetStrokeColorWithColor(context, [armColor CGColor]);
    CGContextSetLineWidth(context, 0.5);

    CGFloat iconMin = ringInset + 3;
    CGFloat radius = rectSize / 2;
    CGFloat realRadius = (radius - ringInset);
    CGFloat tickInset = (rectSize > 126) ? 8 : 5;
    CGPoint center = CGPointMake(radius, radius);
    //
    CGRect edgeRect = CGRectInset(rect, ringInset, ringInset);
    CGContextStrokeEllipseInRect(context, edgeRect);

    if (mode != dial_background) {
        if (radians >= 0) {
            NSBezierPath *arm = [NSBezierPath bezierPath];
            [arm moveToPoint:CGPointZero];
            [arm lineToPoint:CGPointMake(0, -(realRadius - handInset))];
            arm.lineWidth = lineWidth;
            arm.lineCapStyle = NSLineCapStyleRound;
#if IOS_DRAWING
            CGAffineTransform position = CGAffineTransformMakeTranslation(center.x, center.y);
            position = CGAffineTransformRotate(position, radians);
#else
            NSAffineTransform *position = [NSAffineTransform transform];
            [position translateXBy:center.x yBy:center.y];
            [position rotateByRadians:radians];
#endif
            [arm transformUsingAffineTransform:position];
            [arm stroke];
        }
        CGContextSetFillColorWithColor(context, [armColor CGColor]);
        CGFloat dotInset = (rectSize - 4) / 2;
        CGRect dotRect = CGRectInset(rect, dotInset, dotInset);
        NSBezierPath *dot = [NSBezierPath bezierPathWithOvalInRect:dotRect];
        [dot fill];
    }

    if (mode != dial_foreground) {
        radians = 0;
        CGFloat pi_12 = M_PI_2 / 3;
        CGFloat imgHalf = imgSize / 2;
        CGContextSetFillColorWithColor(context, [iconColor CGColor]);
        CGContextSetStrokeColorWithColor(context, [[NSColor lightGrayColor] CGColor]);
        for (NSInteger i = 0, j = 0; i < 12; i++) {
            BOOL quarter = (i % 3) == 0;
            if (quarter) {
               // hightide lowtide downArrowImage upArrowImage
                NSImage *image;
                [graphicsContext saveGraphicsState]; //UIGraphicsPushContext(context);
                CGFloat iconMax = rectSize - iconMin;
                CGFloat x = iconMin;
                CGFloat y = iconMin;
                // Yes, the top and bottom images need to be swapped for iOS.
                switch (j) {
                    case 0: x = center.x; image = [NSImage imageNamed:@"lowtide"]; break;
                    case 1: y = center.y; image = [NSImage imageNamed:@"upArrowImage"]; break;
                    case 2: x = center.x; y = iconMax; image = [NSImage imageNamed:@"hightide"]; break;
                    case 3: x = iconMax; y = center.y; image = [NSImage imageNamed:@"downArrowImage"]; break;
                }
                [image drawInRect:CGRectMake(x - imgHalf, y - imgHalf, imgSize, imgSize)];

                // pop context
                [graphicsContext restoreGraphicsState];//UIGraphicsPopContext();
                j++;
            } else {
                NSBezierPath *tick = [NSBezierPath bezierPath];
                [tick moveToPoint:CGPointMake(0, -(realRadius - tickInset))];
                [tick lineToPoint:CGPointMake(0, -realRadius)];
                tick.lineWidth = 1;
#if IOS_DRAWING
                CGAffineTransform position = CGAffineTransformMakeTranslation(center.x, center.y);
                position = CGAffineTransformRotate(position, radians);
#else
                NSAffineTransform *position = [NSAffineTransform transform];
                [position translateXBy:center.x yBy:center.y];
                [position rotateByRadians:radians];
#endif
                [tick transformUsingAffineTransform:position];
                [tick stroke];
            }

            radians += pi_12;
        }
    }

#if IOS_DRAWING
    NSImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
#else
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    [NSGraphicsContext setCurrentContext:currentContext];

    NSImage *image = [[NSImage alloc] initWithCGImage:imageRef size:NSZeroSize];
#endif
    return image;
}

@end
