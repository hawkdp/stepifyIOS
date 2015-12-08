//
//  CLPushNotification.m
//  NSBE
//

#import "CLPushNotification.h"

@interface CLPushNotification () <NSCoding>

@end

@implementation CLPushNotification

#pragma mark - Initializer

- (id)initWithMessage:(NSString *)message type:(CLPushType)type pictureURL:(NSString *)pictureURL picture:(UIImage *)picture value:(NSInteger)value
{
    self = [super init];
    if (self)
    {
        _message = message;
        _receivedDate = [NSDate date];
        _type = type;
        _profilePictureURL = pictureURL;
        _profilePicture = picture;
        _readFlag = NO;
        _value = value;
    }
    return self;
}

#pragma mark - NSObject

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ { message: %@, type %li, receivedDate %@ }", self, self.message, (long)self.type, self.receivedDate];
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.message forKey:@"message"];
    [aCoder encodeObject:self.receivedDate forKey:@"receivedDate"];
    [aCoder encodeInteger:self.type forKey:@"type"];
    [aCoder encodeObject:self.profilePictureURL forKey:@"profilePictureURL"];
    [aCoder encodeObject:UIImagePNGRepresentation(self.profilePicture) forKey:@"profilePicture"];
    [aCoder encodeBool:self.readFlag forKey:@"readFlag"];
    [aCoder encodeInteger:self.value forKey:@"value"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        _message = [aDecoder decodeObjectForKey:@"message"];
        _receivedDate = [aDecoder decodeObjectForKey:@"receivedDate"];
        _type = [aDecoder decodeIntegerForKey:@"type"];
        _profilePictureURL = [aDecoder decodeObjectForKey:@"profilePictureURL"];
        _profilePicture = [UIImage imageWithData:[aDecoder decodeObjectForKey:@"profilePicture"]];
        _readFlag = [aDecoder decodeBoolForKey:@"readFlag"];
        _value = [aDecoder decodeIntegerForKey:@"value"];
    }
    return self;
}

@end
