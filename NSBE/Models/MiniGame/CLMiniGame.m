//
//  CLMiniGame.m
//  NSBE

#import "CLMiniGame.h"

#define ENCODE_OBJECT_FOR_KEY(ENCODER, OBJ) [ENCODER encodeObject:self.OBJ forKey:@#OBJ]
#define DECODE_OBJECT_FOR_KEY(DECODER, OBJ) self.OBJ = [DECODER decodeObjectForKey:@#OBJ]
#define ENCODE_INTEGER_FOR_KEY(ENCODER, OBJ) [ENCODER encodeInteger:self.OBJ forKey:@#OBJ]
#define DECODE_INTEGER_FOR_KEY(DECODER, OBJ) self.OBJ = [DECODER decodeIntegerForKey:@#OBJ]

@implementation CLMiniGame

#pragma mark - NSCoding protocol implementation

- (NSSet *)setOfRules {
    if (!_setOfRules) {
        _setOfRules = [[NSSet alloc] init];
    }
    return _setOfRules;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    ENCODE_OBJECT_FOR_KEY(aCoder, minigameId);
    ENCODE_OBJECT_FOR_KEY(aCoder, startDate);
    ENCODE_INTEGER_FOR_KEY(aCoder, durationDays);
//    ENCODE_OBJECT_FOR_KEY(aCoder, setOfRules);
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        DECODE_OBJECT_FOR_KEY(aDecoder, minigameId);
        DECODE_OBJECT_FOR_KEY(aDecoder, startDate);
        DECODE_INTEGER_FOR_KEY(aDecoder, durationDays);
//        DECODE_OBJECT_FOR_KEY(aDecoder, setOfRules);
    }
    return self;
}

@end
