//
//  TourViewController.m
//  GoShadow
//
//  Created by Shawn Wall on 9/29/15.
//  Copyright © 2015 Inquiri. All rights reserved.
//

#import "TourViewController.h"

@interface TourViewController () <UIScrollViewDelegate>

@property (strong, nonatomic) NSArray *images;

@end

#define numPages 6

@implementation TourViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.scrollView.pagingEnabled = true;
    CGFloat width = self.view.bounds.size.width;
    self.scrollView.contentSize = CGSizeMake(width*numPages, self.view.bounds.size.height);
    self.scrollView.showsHorizontalScrollIndicator = false;
    self.scrollView.showsVerticalScrollIndicator = false;
    self.scrollView.delegate = self;
    self.pageControl.numberOfPages = numPages;
    
    [self.doneButton setTitleColor:[UIColor gsLightCyanColor] forState:UIControlStateNormal];
    self.images = @[[UIImage imageNamed:@"slide1"],[UIImage imageNamed:@"slide2"],[UIImage imageNamed:@"slide3"],[UIImage imageNamed:@"slide4"],[UIImage imageNamed:@"slide5"],[UIImage imageNamed:@"slide6"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self setupPagedView];
}

- (void)setupPagedView {
    for (UIView *view in self.scrollView.subviews) {
        [view removeFromSuperview];
    }
    
    CGFloat width = self.view.bounds.size.width;
    for (int i = 0; i < numPages; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(width*i, 0, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height)];
        imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        BOOL isiPad = ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad);
        if (isiPad) {
                imageView.contentMode = UIViewContentModeCenter;
        }
        else {
            if (self.view.bounds.size.height <= 480) {
                imageView.contentMode = UIViewContentModeScaleAspectFit;
            }
            else {
                imageView.contentMode = UIViewContentModeCenter;
            }
        }
        imageView.image = self.images[i];
        imageView.backgroundColor = [UIColor clearColor];
        [self.scrollView addSubview:imageView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
}

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width*numPages, self.view.bounds.size.height);
        [self setupPagedView];
        self.scrollView.contentOffset = CGPointMake(self.pageControl.currentPage*self.view.bounds.size.width, 0);
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)done:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskPortrait;
    }
    else {
        return UIInterfaceOrientationMaskAll;
    }
    
}

@end
