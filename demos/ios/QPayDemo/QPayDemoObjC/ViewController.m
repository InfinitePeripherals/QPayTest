//
//  ViewController.m
//  QPayDemoObjC
//
//  Created by Kyle M on 3/25/21.
//

#import "ViewController.h"

#import <QuantumPayPeripheral/QuantumPayPeripheral.h>
#import <QuantumPayClient/QuantumPayClient.h>
#import <QuantumSDK/QuantumSDK.h>

// All Swift symbols are in this file, so to use Swift in an ObjC project, we just need to import this file for all the Swift classes.
#import "QPayDemoObjC-Swift.h"

/**
 An example of setting the developer key and tenant key once when app starts. This convenient method is from the QuantumPay SDK, if you plan to use both non payment device to scan barcode, and payment device to take payment, then calling InfinitePeripherals.initialize.. in a common place would trim down the unneccesary calls to IPCIQ.registerIQ.setDeveloperKey for just barcode scanner and InfinitePeripherals.initialize.. for payment device.
 
 But you dont have to follow this flow if you dont want to. The point is before using the barcode scanner, the developer key need to be set. It can be set either via IPCIQ.registerIQ.setDeveloperKey or InfinitePeripherals.initialize.. And before the payment engine can be used, a tenant key must be set via InfinitePeripherals.initialize..
 
 If you dont want to follow the common flow, then you can the BarcodeViewController to do just barcode scan, and PaymentViewController to do payment.
 
 - So in a project with only the QuantumSDK to scan barcode only, you would need to set developer key via IPCIQ.registerIQ.setDeveloperKey prior to using IPCDTDevices.sharedDevice object.
 - In a project with both QuantumPay SDK and the QuantumSDK, you can set both the developer key and tenant key all at once via InfinitePeripherals.initialize.., because QuantumPay SDK also use the QuantumSDK, which this function will pass on the developer key to IPCIQ.registerIQ.setDeveloperKey...
 */
@interface ViewController () <IPCIQDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initializeQuantumSDKs];
    
    [self IQSetup];
}

- (void)initializeQuantumSDKs {
    // This is important very first step to initialize both the QuantumPay SDKs and QuantumSDK
    // This must be called first BEFORE any other instances of QuantumPay SDKs and QuantumSDK are used.
    
    // Setup tenant and keys
    Tenant *tenant = [[Tenant alloc] initWithHostKey:PaymentConfig.hostKey tenantKey:PaymentConfig.tenantKey];
    [InfinitePeripherals initializeWithDeveloperKey:PaymentConfig.developerKey tenant:tenant];
}

- (void)IQSetup
{
    // This enable the connection to Quantum IQ backend to manage devices
    [[IPCIQ registerIPCIQ] setCheckInEnabled:YES];
    [[IPCIQ registerIPCIQ] setLocationEnabled:YES];
    
    // Set delegate to see IQ status messages
    [[IPCIQ registerIPCIQ] addDelegate:self];
}

- (void)ipciqStatus:(NSString *)statusMessage
{
    NSLog(@"<IQ> %@", statusMessage);
}

- (IBAction)actionCheckIn:(id)sender
{
    // Force check in outside of grace period
    [[IPCIQ registerIPCIQ] checkIn:YES];
}

@end
