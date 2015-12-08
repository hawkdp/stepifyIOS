//
//  CLActivityScreenTableViewCell.h
//  NSBE
//

@import UIKit;

@class CLPushNotification;

@interface CLActivityScreenTableViewCell : UITableViewCell

- (void)configureCellWithPushNotification:(CLPushNotification *)pushNotification
                                indexPath:(NSIndexPath *)indexPath;
@end
