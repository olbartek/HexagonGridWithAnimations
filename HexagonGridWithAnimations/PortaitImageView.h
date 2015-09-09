//
//  PortaitImageView.h
//  HexagonGridWithAnimations
//
//  Created by Bartosz Olszanowski on 07.09.2015.
//  Copyright (c) 2015 Home. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PortaitImageView : UIImageView

@property (nonatomic, assign) CGPoint offsetFromMainView;
@property (nonatomic, assign) int layerNumber;

@end
