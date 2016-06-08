//
//  SRPingHelper.m
//  ping
//
//  Created by guoqingwei on 16/6/1.
//  Copyright © 2016年 cvte. All rights reserved.
//

#import "SRPingHelper.h"
#import "SimplePing.h"

#define PING_TIME_INTERVAL  2

#define PING_TIMEOUT_DELAY  1000

@interface SRPingHelper ()<SimplePingDelegate>

@property (nonatomic) NSTimeInterval startTimeInterval;

@property (nonatomic, assign) NSUInteger delay;

@property (nonatomic, assign) double packetLoss;

@property (nonatomic) NSUInteger sendPackets;

@property (nonatomic) NSUInteger receivePackets;

@property (nonatomic, strong) NSTimer *pingTimer;

@property (nonatomic, strong) SimplePing *simplePing;

@property (nonatomic) dispatch_queue_t ping_queue;

@end

@implementation SRPingHelper

- (id)init
{
    if (self = [super init]) {
        self.ping_queue = dispatch_queue_create("com.myhost.ping", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

+ (instancetype)sharedInstance
{
    static id pingHelper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pingHelper = [[self alloc] init];
    });
    return pingHelper;
}

- (void)startPing
{
    if (self.host) {
        self.sendPackets = 0;
        self.receivePackets = 0;
        
        dispatch_async(self.ping_queue, ^{
            
            self.pingTimer = [NSTimer timerWithTimeInterval:PING_TIME_INTERVAL target:self selector:@selector(doPing) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:self.pingTimer forMode:NSRunLoopCommonModes];
            [[NSRunLoop currentRunLoop] run];
            
        });
        
    } else {
        NSException *exception = [NSException exceptionWithName:@"Null Host" reason:@"Host is Null" userInfo:nil];
        @throw exception;
    }
}

- (void)stopPing
{
    [self.pingTimer invalidate];
    self.pingTimer = nil;
    self.delay = 0;
    self.packetLoss = 0;
}

#pragma mark - SimplePingDelegate

- (void)simplePing:(SimplePing *)pinger didStartWithAddress:(NSData *)address
{
    [pinger sendPingWithData:nil];
}

- (void)simplePing:(SimplePing *)pinger didFailWithError:(NSError *)error
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(pingTimeout) object:nil];
    [self clearSimplePing];
}

- (void)simplePing:(SimplePing *)pinger didSendPacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber
{
    self.sendPackets++;
    
    self.startTimeInterval = [NSDate timeIntervalSinceReferenceDate];
}

- (void)simplePing:(SimplePing *)pinger didFailToSendPacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber error:(NSError *)error
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(pingTimeout) object:nil];
    [self clearSimplePing];
}

- (void)simplePing:(SimplePing *)pinger didReceivePingResponsePacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(pingTimeout) object:nil];
    [self clearSimplePing];
    
    self.receivePackets++;
    
    self.delay = ([NSDate timeIntervalSinceReferenceDate] - self.startTimeInterval) * 1000;
    self.packetLoss = (double)((self.sendPackets - self.receivePackets) * 1.f / self.sendPackets * 100);
    
    // We can get IP address from pinger.hostAddress in here, but I am not do  it.
    
#ifdef DEBUG
    NSLog(@"seq:%ld,latency:%ld, packetloss:%f", self.sendPackets ,self.delay, self.packetLoss);
#endif
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate didReportSequence:self.sendPackets timeout:NO delay:self.delay packetLoss:self.packetLoss];
    });
    
}

- (void)simplePing:(SimplePing *)pinger didReceiveUnexpectedPacket:(NSData *)packet
{
    [pinger stop];
}

#pragma mark - private methods

- (void)doPing
{
    [self clearSimplePing];
    
    self.simplePing = [[SimplePing alloc] initWithHostName:self.host];
    self.simplePing.delegate = self;
    [self.simplePing start];
    
    [self performSelector:@selector(pingTimeout) withObject:nil afterDelay:1.5f];
}

- (void)pingTimeout
{
    
#ifdef DEBUG
    NSLog(@"ping Timeout");
#endif
    
    [self clearSimplePing];
    
    self.delay = PING_TIMEOUT_DELAY;
    self.packetLoss = (double)((self.sendPackets - self.receivePackets) * 1.f / self.sendPackets * 100);
    
#ifdef DEBUG
    NSLog(@"seq:%ld,latency:%ld, packetloss:%f", self.sendPackets ,self.delay, self.packetLoss);
#endif
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate didReportSequence:self.sendPackets timeout:YES delay:self.delay packetLoss:self.packetLoss];
    });
}

- (void)clearSimplePing
{
    if (self.simplePing) {
        [self.simplePing stop];
        self.simplePing.delegate = nil;
        self.simplePing = nil;
    }
}

@end
