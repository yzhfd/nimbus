//
// Copyright 2012 Manu Cornet
// Copyright 2011-2012 Jeff Verkoeyen
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "PagingScrollViewController.h"

#import "NimbusPagingScrollView.h"

//
// What's going on in this file:
//
// This is a simple example of instantiating a NIPagingScrollView and implementing the
// NIPagingScrollViewDataSource protocol. This controller implements the bare minimum of
// functionality required to start using a paging scroll view in your own application. The data
// source returns a fixed number of pages and each page is configured to display its page number.
//
// The key understanding you should gain of the paging scroll view is that it only ever has three
// page views in memory. When the user moves from one page to another it adds the now invisible page
// to a recyclable cell queue and then dequeues this view to be displayed at the new page index.
// This is the same way UITableView works with its cell reuse.
//
// You will find the following Nimbus features used:
//
// [pagingscrollview]
// NIPagingScrollView
// NIPagingScrollViewDataSource
//
// This controller requires the following frameworks:
//
// Foundation.framework
// UIKit.framework
// QuartzCore.framework
//

// The reuse identifier for a single page.
static NSString* kPageReuseIdentifier = @"SamplePageIdentifier";

// This is the page view object that we will display for each page of the paging scroll view.
// It must implement the NIPagingScrollViewPage protocol.
@interface SamplePageView : UIView <NIPagingScrollViewPage>
@property (nonatomic, readwrite, retain) UILabel* label;
- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;
@end

@interface PagingScrollViewController() <NIPagingScrollViewDataSource>
// We must retain the paging scroll view in order to autorotate it correctly.
@property (nonatomic, readwrite, retain) NIPagingScrollView* pagingScrollView;
@end

@implementation PagingScrollViewController

@synthesize pagingScrollView = _pagingScrollView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
    self.title = @"Basic Instantiation";
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  self.view.backgroundColor = [UIColor blackColor];

  // Create a paging scroll view the same way we would any other type of view.
  self.pagingScrollView = [[NIPagingScrollView alloc] initWithFrame:self.view.bounds];
  self.pagingScrollView.autoresizingMask = UIViewAutoresizingFlexibleDimensions;

  // A paging scroll view has a data source much like a UITableView.
  self.pagingScrollView.dataSource = self;

  [self.view addSubview:self.pagingScrollView];

  // Tells the paging scroll view to ask the dataSource for information about how to present itself.
  [self.pagingScrollView reloadData];
}

- (void)didReceiveMemoryWarning {
  self.pagingScrollView = nil;

  [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return NIIsSupportedOrientation(interfaceOrientation);
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration {
  [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];

  // The paging scroll view implements autorotation internally so that the current visible page
  // index is maintained correctly. It also provides an opportunity for each visible page view to
  // maintain zoom information correctly.
  [self.pagingScrollView willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration {
  [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];

  // The second part of the paging scroll view's autorotation functionality. Both of these methods
  // must be called in order for the paging scroll view to rotate itself correctly.
  [self.pagingScrollView willAnimateRotationToInterfaceOrientation:toInterfaceOrientation
                                                      duration:duration];
}

// The paging scroll view data source works similarly to UITableViewDataSource. We will return
// the total number of pages in the scroll view as well as each page as it is about to be displayed.
#pragma mark - NIPagingScrollViewDataSource

- (NSInteger)numberOfPagesInPagingScrollView:(NIPagingScrollView *)pagingScrollView {
  // For the sake of this example we'll show a fixed number of pages.
  return 10;
}

// Similar to UITableViewDataSource, we create each page view on demand as the user is scrolling
// through the page view.
// Unlike UITableViewDataSource, this method requests a UIView that conforms to a protocol, rather
// than requiring a specific subclass of a type of view. This allows you to use any UIView as long
// as it conforms to NIPagingScrollView.
- (UIView<NIPagingScrollViewPage> *)pagingScrollView:(NIPagingScrollView *)pagingScrollView
                                    pageViewForIndex:(NSInteger)pageIndex {
  // Check the reusable page queue.
  SamplePageView *page = (SamplePageView *)[pagingScrollView dequeueReusablePageWithIdentifier:kPageReuseIdentifier];
  // If no page was in the reusable queue, we need to create one.
  if (nil == page) {
    page = [[SamplePageView alloc] initWithReuseIdentifier:kPageReuseIdentifier];
  }
  return page;
}

@end

@implementation SamplePageView

@synthesize label = _label;
@synthesize pageIndex = _pageIndex;
@synthesize reuseIdentifier = _reuseIdentifier;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier {
  if ((self = [super initWithFrame:CGRectZero])) {
    _label = [[UILabel alloc] initWithFrame:self.bounds];
    _label.autoresizingMask = UIViewAutoresizingFlexibleDimensions;
    _label.font = [UIFont systemFontOfSize:26];
    _label.textAlignment = UITextAlignmentCenter;
    _label.backgroundColor = [UIColor clearColor];
    
    [self addSubview:_label];
  }
  return self;
}

- (id)initWithFrame:(CGRect)frame {
  return [self initWithReuseIdentifier:nil];
}

- (void)setPageIndex:(NSInteger)pageIndex {
  _pageIndex = pageIndex;

  self.label.text = [NSString stringWithFormat:@"This is page %i", pageIndex];

  UIColor* bgColor;
  UIColor* textColor;
  // Change the background and text color depending on the index.
  switch (pageIndex % 4) {
    case 0:
      bgColor = [UIColor redColor];
      textColor = [UIColor whiteColor];
      break;
    case 1:
      bgColor = [UIColor blueColor];
      textColor = [UIColor whiteColor];
      break;
    case 2:
      bgColor = [UIColor yellowColor];
      textColor = [UIColor blackColor];
      break;
    case 3:
      bgColor = [UIColor greenColor];
      textColor = [UIColor blackColor];
      break;
  }

  self.backgroundColor = bgColor;
  self.label.textColor = textColor;

  [self setNeedsLayout];
}

- (void)prepareForReuse {
  self.label.text = nil;
}

@end