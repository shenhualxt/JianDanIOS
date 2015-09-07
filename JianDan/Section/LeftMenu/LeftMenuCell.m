//
//  LeftMenuCell.m
//  JianDan
//
//  Created by 刘献亭 on 15/8/31.
//  Copyright (c) 2015 刘献亭. All rights reserved.
//

#import "LeftMenuCell.h"
#import "LeftMenu.h"

@implementation LeftMenuCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
  self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    self.backgroundColor=[UIColor darkGrayColor];
    self.textLabel.textColor=[UIColor whiteColor];
    self.textLabel.font=[UIFont systemFontOfSize:14];
  }
  return self;
}

- (void)bindViewModel:(LeftMenu *)leftMenu {
    self.textLabel.text=leftMenu.menuName;
    self.imageView.image=[UIImage imageNamed:leftMenu.imageName];
}
 
@end
