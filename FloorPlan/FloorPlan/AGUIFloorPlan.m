//
//  AGUIFloorPlan.m
//  FloorPlan
//
//  Created by Main on 07.09.15.
//  Copyright (c) 2015 Aptito. All rights reserved.
//

#import "AGUIFloorPlan.h"

@interface AGUIFloorPlan ()
@property (nonatomic, strong) UIImageView *floorBackgroundImageView;
@property (nonatomic, strong) UIView *contentView;
@end

@implementation AGUIFloorPlan

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configureView];
        return self;
    }
    
    return nil;
}

- (void) configureView {
    self.backgroundColor = [UIColor blackColor];
    
    _floorBackgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    _floorBackgroundImageView.backgroundColor = [UIColor clearColor];
    _floorBackgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self addSubview:_floorBackgroundImageView];
    
    _contentView = [[UIImageView alloc] initWithFrame:self.bounds];
    _contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _contentView.backgroundColor = [UIColor clearColor];
    [self addSubview:_contentView];
}

- (void)reloadData {
    NSInteger numberOfTables = [self.delegate numberOfTablesForFloorPlan:self];
    for (NSInteger i = 0; i<numberOfTables; i++) {
        
    }
}


@end
