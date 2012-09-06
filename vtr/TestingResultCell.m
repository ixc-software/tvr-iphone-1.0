//
//  TestingResultCell.m
//  vtr
//
//  Created by Oleksii Vynogradov on 4/23/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import "TestingResultCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation TestingResultCell
@synthesize numberA;
@synthesize number;
@synthesize playButton;
@synthesize responseTime;
@synthesize pddTime;
@synthesize callTime;
@synthesize delegate,indexPath,isPlayingCall,isPlayingRing;
@synthesize bk;
@synthesize carrierLabel;
@synthesize outPeerLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(IBAction)playRing:(id)sender
{
    if (delegate && [delegate respondsToSelector:@selector(playRingForIndexPath:)]) {
        if (isPlayingRing) {
            [delegate playRingForIndexPath:self.indexPath];
            [self.playButton setImage:[UIImage imageNamed:@"btn_play.png"] forState:UIControlStateNormal];
            self.isPlayingRing = NO;
            
        } else {
            self.isPlayingRing = YES;
            
            [delegate stopPlayRingForIndexPath:self.indexPath];
            [self.playButton setImage:[UIImage imageNamed:@"btn_stop.png"] forState:UIControlStateNormal];
            
        }
        
    }
    
}


-(IBAction)playCall:(id)sender
{
    if (delegate && [delegate respondsToSelector:@selector(playCallForIndexPath:)]) {
        if (isPlayingCall) {
            [UIView beginAnimations:@"flipbutton" context:NULL];
            [UIView setAnimationDuration:0.4];
            [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.playButton cache:YES];
            
            [self.playButton setImage:[UIImage imageNamed:@"btn_play.png"] forState:UIControlStateNormal];
            
            [UIView commitAnimations];
            [delegate stopPlayCallForIndexPath:self.indexPath];

            //[self.playButton setImage:[UIImage imageNamed:@"btn_play.png"] forState:UIControlStateNormal];
            self.isPlayingCall = NO;
            
        } else {
            self.isPlayingCall = YES;
            
            [UIView beginAnimations:@"flipbutton" context:NULL];
            [UIView setAnimationDuration:0.4];
            [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.playButton cache:YES];
            
            [self.playButton setImage:[UIImage imageNamed:@"btn_stop.png"] forState:UIControlStateNormal];
            
            [UIView commitAnimations];
            [delegate playCallForIndexPath:self.indexPath];

            //[self.playButton setImage:[UIImage imageNamed:@"btn_pause.png"] forState:UIControlStateNormal];
            
        }
    }
    
}
        
@end
