//
//  PingResultViewCell.m
//  SRPingHeplerTest
//
//  Created by guoqingwei on 16/6/1.
//  Copyright © 2016年 seewo. All rights reserved.
//

#import "PingResultViewCell.h"

@interface PingResultViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *resultImageView;
@property (weak, nonatomic) IBOutlet UILabel *seqLabel;
@property (weak, nonatomic) IBOutlet UILabel *hostLabel;
@property (weak, nonatomic) IBOutlet UILabel *ttlLabel;

@end

@implementation PingResultViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)setCellModel:(PingResult *)cellModel
{
    self.resultImageView.image = cellModel.resultImage;
    self.seqLabel.text = [NSString stringWithFormat:@"# %ld", cellModel.seq];
    self.hostLabel.text = cellModel.host;
    self.ttlLabel.text = cellModel.ttl;    
}

@end
