---
layout: default
title: Xamarin
nav_order: 3
parent: Getting Started
has_children: false
---

# Getting Started with Xamarin
{: .fs-9 }

Learn how to set up your Xamarin app to use QuantumPay to process payment transactions.
{: .fs-5 .fw-300 }

<details open markdown="block">
  <summary>
    Table of contents
  </summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Requirements

<div class="code-example" markdown="1">
- SDKs
    - QuantumPay.Client.dll
    - QuantumPay.Mobile.dll
    - QuantumPay.Peripherals.InfinitePeripherals.iOS.dll
    - QuantumSDK.iOS.dll
- Xcode 11+ / iOS 13+
- Infinite Peripherals payment device
- Infinite Peripherals developer key for your app bundle ID
- Payment related credentials: username/email, password, service name and tenant key
</div>

***If you are missing any of these items, please contact Infinite Peripherals**

---

## Project setup
Before we jump into the code we need to make sure your project is properly configured to use the QuantumPay frameworks. Follow the steps below to get you set up.

### Adding the QuantumPay SDKs

1. Open Visual Studio and create a new folder to put the frameworks in. If you have a place for frameworks already you can skip this.

2. Import the QuantumPay frameworks into your folder.

<p align="center">
  <img src="https://github.com/InfinitePeripherals/QuantumPay/blob/1392806182d2a677a669d5402d349ff1d9f6b23d/docs/assets/images/walkthroughs/xamarin-1.png" style='border:1px solid #000000' />
</p>


### Add MFi protocols to Info.plist
Go to your project's **Info.plist** file and add a new entry for "Supported external accessory protocols" using the following values. Note: in Xcode 13.0+ this has been moved to the "Info" tab in your project's settings.

```
com.datecs.pengine
com.datecs.linea.pro.msr
com.datecs.linea.pro.bar
com.datecs.printer.escpos
com.datecs.iserial.communication
com.datecs.printer.label.zpl
com.datecs.label.zpl
com.datecs.pinpad
```

<p align="center">
  <img src="https://github.com/InfinitePeripherals/QuantumPay/blob/69f4b1c932ee6042b3a09ff0bf29571ee558d234/docs/assets/images/walkthroughs/xamarin-2.png" style='border:1px solid #000000' />
</p>

### Add privacy entries to Info.plist

Also in your project's **Info.plist** file we need to add the four (4) privacy tags listed below. You can enter any string value you want or copy what we have below. Note: in Xcode 13.0+ this has been moved to the "Info" tab in your project's settings.

```
"Privacy - Bluetooth Always Usage Description" 
"Privacy - Bluetooth Peripheral Usage Description"
"Privacy - Location When In Use Usage Description" 
"Privacy - Location Usage Description"
```

<p align="center">
  <img src="https://github.com/InfinitePeripherals/QuantumPay/blob/6fb4d1412c7028d19f214e7a84c59e0ca5b61b1c/docs/assets/images/walkthroughs/xamarin-3.png" style='border:1px solid #000000' />
</p>

---

## Processing a payment
At this point, your Visual Studio project should be configured and ready to use the QuantumPay libraries. This next section will take you through some initial setup all the way to processing a payment.



### Initialize the SDKs
The SDKs need to be initialized with the correct keys provided by Infinite Peripherals. This step is important and should be the first code to run before using other functions from the SDKs. Create tenant in FInishedLaunching function in AppDelegate.cs

```csharp
// These keys are jsut examples and will not work. Please ask IPC to supply you with the correct keys
var hostKey = "US";
var tenant = "IPC";
var developerKey = "0000-0000-0000-0000-0000";

// Create tenant
QuantumPay.Client.Tenant tenant = new QuantumPay.Client.Tenant(hostKey, tenantKey);

// Initialize QuantumPay
InfinitePeripherals.Init(developerKey, tenant);
```

### Create Payment Device
Now initialize a payment device that matches the hardware you are using. The current supported payment devices are: QPC150, QPC250, QPP400, QPP450, QPR250, QPR300. Note that this step is different for payment devices that are connected with Bluetooth LE.

Initialize QPC150, QPC250 (Lightning connector)

```csharp
var paymentDevice = new QPC250();
```

Initialize QPP400, QPP450, QPR250, QPR300 (Bluetooth LE) by supplying its serial number so the PaymentEngine can search for and connect to it. On first connection, the app will prompt you to pair the device. Be sure to press “OK” when the pop-up is shown. To complete the pairing, if using a QPR device, press the small button on top of the device opposite the power button. If using a QPP device, press the green check mark button on the bottom right of the keypad.
// The device serial number is found on the label on the device.

```csharp
var paymentDevice = new QPR250("2320900026");
```

### Create payment engine

The payment engine is the main object that you will interact with to send transactions and receive callbacks.

```csharp
var username = "test@testuser.com";
var password = "P@ssword";
var testPosId = "TestPosId"; // this should be a unique value for your device instance

var paymentEngine = await PaymentEngine.Builder
                                       .AssignLocationsToTransactions() // optional - use precise tracking for assigning locations
                                       .RegistrationCredentials(username, password) // optional - only used to register the device, not required if the device is already registered with the server
                                       .PosId(testPosId) // required - the unique POS ID for your system
                                       .TransactionTimeout(TimeSpan.FromSeconds(30)) // optional - specify the duration that the peripheral will wait for the customer to complete the payment
                                       .AddPeripheral(paymentDevice, autoConnect: false) // required - add your peripheral
                                       .BuildAsync();

```

### Setup handlers
Once the `PaymentEngine` is created, you can use it's handlers to track the operation. The `PaymentEngine` handlers will get called throughout the payment process and will return you the current state of the transaction. You can set these handlers in the completion block of the previous step.

`TransactionStateHandler` will assign the delegate to use for handling transaction state changes.

`TransactionResultHandler` will assign the delegate to use for handling transaction results.

`PeripheralStateHandler` will get called when the state of the peripheral changes during the transaction process. The PeripheralState represents the current state of the peripheral as reported by the peripheral device itself. These include “idle”, “ready”, “contactCardInserted” etc.

`PeripheralMessageHandler` will get called when there is new message about the transaction throughout the process. The peripheral message tells you when to present the card, if the card read is successful or failed, etc. This usually indicates something that should be displayed in the user interface.

```csharp
paymentEngine.SetTransactionStateHandler((peripheral, transaction, transactionState) =>
{
    var scanLabel = $"Transaction State = {transactionState}";

    if (transactionState == TransactionState.CardReadSuccess)
    {
        var dataLabel = transaction.Properties?.MaskedPan;
    }

    if (transactionState.IsFinalState())
    {
        StopEmv(this, EventArgs.Empty);
    }
});

paymentEngine.SetTransactionResultHandler((transactionResult) =>
{
    var dataLabel = $"{transactionResult.Status} {transactionResult.ServerResponse?.GatewayResult} {transactionResult.Reason}";
});

PaymentEngine.SetPeripheralStateHandler((peripheral, peripheralState) =>
{
    MainThread.BeginInvokeOnMainThread(() => { Console.WriteLine(peripheralState); });
});

PaymentEngine.SetPeripheralMessageHandler((peripheral, message) =>
{
    MainThread.BeginInvokeOnMainThread(() => { Console.WriteLine(message); });
});
```

### Connect to payment device
Now that your payment engine is configured and your handlers are set up, lets connect to the payment device. Please make sure the device is attached and turned on. We need to connect to the payment device prior to starting a transaction. The connection state will be returned to the `ConnectionStateHandler` that we set up previously. If you didn't set autoConnect when creating the payment engine, you will need to call `Connect()` before starting a transaction.

`ConnectionStateHandler` will get called when the connection state of the payment device changes between connecting, connected, and disconnected. It is important to make sure your device is connected before attempting to start a transaction.

```csharp
// assign connection state and transaction state handlers
paymentEngine.SetConnectionStateHandler((peripheral, connectionState) =>
{
    switch (connectionState)
    {
        case ConnectionState.Disconnected:
            Console.WriteLine("Peripheral disconnected");
            // update your UI code here
            break;

        case ConnectionState.Connecting:
            Console.WriteLine("Peripheral connecting...");
            // update your UI code here
            break;

        case ConnectionState.Connected:
            Console.WriteLine("Peripheral connected");
            // update your UI code here
            break;
    }
});

  // connect to the peripheral - must be called before any further interaction with the peripheral
  paymentEngine.Connect();

```

### Create an invoice
Time to create an invoice. This invoice object holds information about a purchase order and the items in the order.

```csharp
var orderNum = 1;

var invoice = paymentEngine.BuildInvoice(orderNum.ToString())
                           .CompanyName("ACME SUPPLIES INC.")
                           .PurchaseOrderReference("PO1234")
                           .AddItem("SKU1", "Discount Voucher for Return Visit", 0M)
                           .AddItem(item => item.ProductCode("SKU2")
                              .Description("In Store Item")
                              .SaleCode(SaleCode.Sale)
                              .Price(amount)
                              .Quantity(4)
                              .UnitOfMeasure(UnitOfMeasure.Each)) // defines the association between quantity and price
                           .CalculateTotals()
                           .Build();
                 
```

### Create a transaction

The transaction object holds information about the invoice, the total amount for the transaction and the type of the transaction (e.g.: sale, auth, refund, etc.)

```csharp
var reference = "3423-2234-222"
var service = "TestService";
var amount = 5.00M; // $5.00 USD

var txn = paymentEngine.BuildTransaction(invoice)
                       .Sale() // other optons: refund(), auth(), capture(), void()
                       .Amount(amount, Currency.USD)
                       .Reference(reference) // required - unique transaction reference, such as your application order number
                       .Service(service) // optional - allow customer to control the merchant account that will process the transaction in business that have multiple services / legal entities
                       .MetaData(new Dictionary<string, string> {{"OrderNumber", orderNum.ToString()}, {"Delivered", "Y"}}) // optional - store data object to associate with the transaction
                       .Build();
```

### Start transaction

Now that everything is ready we can start the transaction and take payment. Watch the handler messages and status updates to track the transaction throughout the process.

```csharp
return await paymentEngine.StartTransactionAsync(txn);
```

### Transaction receipt

Once the transaction is completed and approved, the receipt is sent to the TransactionResultHandler callback.

```csharp
// The url for customer receipt
transactionResult.receipt?.customerReceiptUrl

// The url for merchant receipt
transactionResult.receipt?.merchantReceiptUrl
```

## Disconnect payment device
Now that the transaction is complete you are free to disconnect the payment device if you wish. Please note that this should not be called before or during the transaction process.

```csharp
paymentEngine.Disconnect()
```
---

## Connect bluetooth peripheral to iOS device using the camera

It is possible to connect any of our bluetooth devices to your app using the camera to scan the peripheral barcode.

### Add permisions to Info.plist

First you will need to allow the app to use the camera and also enable bluetooth, do this by adding the following code to the info.plist

```xml
<key>NSBluetoothPeripheralUsageDescription</key>
<string>This app communicates with an external peripheral via Bluetooth to enable functionality such as reading cards and scanning barcodes.</string>
<key>NSBluetoothAlwaysUsageDescription</key>
<string>This app communicates with an external peripheral via Bluetooth to enable functionality such as reading cards and scanning barcodes.</string>
<key>NSCameraUsageDescription</key>
<string>Please allow the camera to be used for scanning barcodes</string>
```

### Implement scanner page

The simplist way to achieve this is to use a package, for this example you can use the zxing scanner 'https://www.nuget.org/packages/ZXing.Net.Mobile.Forms/'. You can however create your own scanner implementation if you so wish. 

ScanPage.xaml
```xml
<zxing:ZXingScannerView x:Name="ScanView"
                        OnScanResult="Handle_OnScanResult" 
                        IsScanning="true" />
<zxing:ZXingDefaultOverlay/>
```

ScanPage.xaml.cs
```csharp
public void Handle_OnScanResult(Result result)
{
    Device.BeginInvokeOnMainThread(async() =>
    {
         DeviceSerialNumber = result.Text;
    });
}
```
---
## Scan product barcodes

### Scanning a Barcode

Some of our payment devices also support barcode scanning (e.g., QPC150, QPC250). In order to receive the barcode data, you will need to set your class to conform to the protocol IPCDTDeviceDelegate, to do this set an instance of the IPCDTDeviceDelegateEvents:

```csharp
// Gets the Infinite Peripherals object
private IPCDTDevices Peripheral { get; } = IPCDTDevices.Instance;

private IPCDTDeviceDelegateEvents PeripheralEvents { get; } = new IPCDTDeviceDelegateEvents();

PeripheralEvents.BarcodeNSDataType += OnBarcodeScanned;

// register the peripheral events delegate - must be set before connecting to the peripheral
Peripheral.AddDelegate(PeripheralEvents);

```

Next, implement the function that handles the scan and the dat returned

```csharp
private void OnBarcodeScanned(object sender, BarcodeNSDataTypeEventArgs e)
{
    Console.WriteLine($"Barcode scanned: {e.Barcode} ({e.Type})");
    //update UI code here 
}
```
