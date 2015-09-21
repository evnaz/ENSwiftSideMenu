//
//  AGUIFloorPlan.h
//  FloorPlan
//
//  Created by Main on 07.09.15.
//  Copyright (c) 2015 Aptito. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AGUIFloorPlan;

@protocol AGUIFloorPlanDelegate<NSObject>
- (NSInteger)numberOfTablesForFloorPlan:(AGUIFloorPlan *)floorPlan;
- (UIView *)floorPlan:(AGUIFloorPlan *)floorPlan mapObjectViewAtIndex:(NSInteger)index;
@end


@interface AGUIFloorPlan : UIView <UITableViewDelegate> {
    __weak id<AGUIFloorPlanDelegate> delegate;
}
@property (nonatomic, weak) id<AGUIFloorPlanDelegate>delegate;

- (void)reloadData;
@end
