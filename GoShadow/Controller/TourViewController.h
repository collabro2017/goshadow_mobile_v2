//
//  TourViewController.h
//  GoShadow
//
//  Created by Shawn Wall on 9/29/15.
//  Copyright © 2015 Inquiri. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TourViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;

- (IBAction)done:(id)sender;

@end
