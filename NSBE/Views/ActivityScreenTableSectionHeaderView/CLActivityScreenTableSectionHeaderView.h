//
//  CLActivityScreenTableSectionHeaderView.h
//  NSBE
//

@import UIKit;

@interface CLActivityScreenTableSectionHeaderView : UIView
- (instancetype)initForTableView:(UITableView *)tableView; //@designated initializer

- (void)setLabelFormattedTextWithDateString:(NSString *)dateString;
@end
