//
//  BarcodeViewController.m
//  QPayDemoObjC
//
//  Created by Kyle M on 3/25/21.
//

#import "BarcodeViewController.h"

#import <QuantumSDK/QuantumSDK.h>
#import "QPayDemoObjC-Swift.h"

@interface BarcodeViewController () <IPCDTDeviceDelegate>

@property (strong, nonatomic) IPCDTDevices *scanner;

@property (weak, nonatomic) IBOutlet UILabel *barcodeLabel;

@end

@implementation BarcodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    /*
    // If you dont want to do the common flow, you would need to set the developer key prior to using IPCDTDevices object
    // In a project that doesnt have the QuantumPay SDK, this call is needed to initialize the QuantumSDK to use the scanner
    NSError *keyError;
    [[IPCIQ registerIPCIQ] setDeveloperKey:PaymentConfig.developerKey withError:&keyError];
    */
    
    // Get shared instance
    self.scanner = [IPCDTDevices sharedDevice];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Set delegate to receive barcode - IPCDTDeviceDelegate protocol
    [self.scanner addDelegate:self];
    
    // Connect scanner
    [self.scanner connect];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // Remove delegate on view disappear, since we dont need it anymore
    [self.scanner removeDelegate:self];
}

- (IBAction)actionStartRF:(id)sender
{
    if (self.scanner.connstate == CONN_CONNECTED) {
        NSError *error;
        [self.scanner rfInitWithPreferredReader:RF_READER_NONE supportedCards:CARD_SUPPORT_TYPE_A | CARD_SUPPORT_TYPE_B fieldGain:0 sleepTimeout:0.1 error:&error];
        if (error) {
            NSLog(@"RF error: %@", error.localizedDescription);
        }
        
        NSLog(@"Starting RF...");
    }
}

- (IBAction)actionStopRF:(id)sender
{
    [self.scanner rfClose:nil];
    NSLog(@"RF closed...");
}

#pragma mark - IPCDTDeviceDelegate
- (void)connectionState:(int)state {
    NSLog(@"Scanner connection state: %i", state);
}

- (void)barcodeData:(NSString *)barcode type:(int)type {
    NSLog(@"Barcode: %@", barcode);
    self.barcodeLabel.text = barcode;
}

- (void)rfCardDetected:(int)cardIndex info:(DTRFCardInfo *)info {
    NSLog(@"RF Card: %@", info.typeStr);
    
    // Remove card from field
    [self.scanner rfRemoveCard:cardIndex error:nil];
}

@end
