//
//  CLStepSyncHistoryRecord.m
//  NSBE
//

#import "CLStepSyncHistoryRecord.h"

#define ENCODE_OBJECT_FOR_KEY(ENCODER, OBJ) [ENCODER encodeObject:self.OBJ forKey:@#OBJ]
#define DECODE_OBJECT_FOR_KEY(DECODER, OBJ) self.OBJ = [DECODER decodeObjectForKey:@#OBJ]

@implementation CLStepSyncHistoryRecord

- (NSString *)description {
    return [NSString stringWithFormat:@"CLStepSyncHistoryRecord: %@ steps on %@", self.steps, self.date];
}

#pragma mark - NSCoding protocol implementation

- (void)encodeWithCoder:(NSCoder *)aCoder{
    ENCODE_OBJECT_FOR_KEY(aCoder, steps);
    ENCODE_OBJECT_FOR_KEY(aCoder, date);
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    if(self = [super init]) {
        DECODE_OBJECT_FOR_KEY(aDecoder, steps);
        DECODE_OBJECT_FOR_KEY(aDecoder, date);
    }
    return self;
}

@end
