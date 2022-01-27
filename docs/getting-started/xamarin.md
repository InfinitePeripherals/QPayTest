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

## Project Setup
Before we jump into the code we need to make sure your project is properly configured to use the QuantumPay frameworks. Follow the steps below to get you set up.

### Adding the QuantumPay SDKs

1. Open Visual Studio and create a new folder to put the frameworks in. If you have a place for frameworks already you can skip this.

2. Import the QuantumPay frameworks into your folder.

<p align="center">
  <img src="https://github.com/InfinitePeripherals/QuantumPay/blob/69f4b1c932ee6042b3a09ff0bf29571ee558d234/docs/assets/images/walkthroughs/xamarin-1.png" style='border:1px solid #000000' />
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

### Add Privacy entries to Info.plist

Also in your project's **Info.plist** file we need to add the four (4) privacy tags listed below. You can enter any string value you want or copy what we have below. Note: in Xcode 13.0+ this has been moved to the "Info" tab in your project's settings.

```
"Privacy - Bluetooth Always Usage Description" 
"Privacy - Bluetooth Peripheral Usage Description"
"Privacy - Location When In Use Usage Description" 
"Privacy - Location Usage Description"
```

<p align="center">
  <img src="https://github.com/InfinitePeripherals/QuantumPay/blob/3316806a563f383c0fd0291ce33a16d0334cee54/docs/assets/images/walkthroughs/xamarin-3.png" style='border:1px solid #000000' />
</p>

---

## Processing a Payment
At this point, your Visual Studio project should be configured and ready to use the QuantumPay libraries. This next section will take you through some initial setup all the way to processing a payment.



### Initialize the SDKs
The SDKs need to be initialized with the correct keys provided by Infinite Peripherals. This step is important and should be the first code to run before using other functions from the SDKs. Create tenant in FInishedLaunching function in AppDelegate.cs

```C#
// Create tenant
QuantumPay.Client.Tenant tenant = new QuantumPay.Client.Tenant(Config.HostKey, Config.TenantKey);

// Initialize QuantumPay
InfinitePeripherals.Init(Config.DeveloperKey, tenant);
```

### Create Payment Device
Now initialize a payment device that matches the hardware you are using. The current supported payment devices are: QPC150, QPC250, QPP400, QPP450, QPR250, QPR300. Note that this step is different for payment devices that are connected with Bluetooth LE.
- Initialize QPC150, QPC250 (Lightning connector). 

AppDelegate.cs:

```C#
var infineaPay = new InfineaPayCloudPaymentEngine
{
    Installer = builder =>
    {
        builder.AddPeripheral<Qpc150>(autoConnect: false, capabilities: PeripheralCapability.CardMagStripe);
    }
};
```

Alternatively, you can create a ‘Payment Factory’ and pass this in to the payment engine when it’s created. The following example also demonstrates how to connect to a Bluetooth device. Initialize QPP400, QPP450, QPR250, QPR300 (Bluetooth LE) by supplying its serial number so the `PaymentEngine` can search for and connect to it. On first connection, the app will prompt you to pair the device. Be sure to press "OK" when the pop-up is shown. To complete the pairing, if using a QPR device, press the small button on top of the device opposite the power button. If using a QPP device, press the green check mark button on the bottom right of the keypad.


```C#
// The device serial number is found on the label on the device.
public Func<IPeripheral> CreatePeripheralFactory()
{
    if (App.Instance.PeripheralInfo.RequiresPairingSerialNumber(Peripheral.Type))
    {
        return App.Instance.PeripheralInfo.CreateFactory(Peripheral.Type, “15523444”);
    }

    return App.Instance.PeripheralInfo.CreateFactory(Peripheral.Type);
}
```

---

### Create Payment Engine

The payment engine is the main object that you will interact with to send transactions and receive callbacks.

```C#
public async Task CreatePaymentEngine()
{
    // create the peripheral factory (invoked by the PaymentEngine)
    PeripheralFactory = SamplePeripheral.Wrap(CreatePeripheralFactory());

    // build the payment engine
    PaymentEngine = PaymentEngine.Builder
                                 .Server(ServerConfiguration.Configuration) // optional - the default production server is used if not provided
                                 .SetQueueStrategy(QueueStrategyMode.Value) // optional - call when Store and Forward will be used, options available: Disabled, WhenOffline, Always, AlwaysBatch // default is AlwaysBatch
                                 .RegistrationCredentials(DeviceAdministrator.Username, DeviceAdministrator.Password) // optional - only used to register the device, not required if the device is already registered with the server
                                 .PosId(PosId) // required - the unique POS ID for your system
                                 .EmvApplicationSelectionStrategy(EmvApplicationSelectionStrategy.Value)
                                 .TransactionTimeout(TimeSpan.FromSeconds(transactionTimeout.Timeout)) // optional - specify the duration that the peripheral will wait for the customer to complete the payment
                                 .Logger(new ConsoleLogger()) // optional - add your own logger implementation
                                 .UnhandledExceptionHandler(ex =>
                                  {
                                      // optional - add your own exception handling here - such as crash logger or error dialog, etc
                                      // by default, the engine will log the errors using the logger implementation
                                      Console.WriteLine($"UNHANDLED EXCEPTION:: {ex}");
                                  })
                                 .AddPeripheral(PeripheralFactory, autoConnect: false) // required - add your peripheral
                                 .BuildAsync();
}
```

### Setup Handlers
Once the `PaymentEngine` is created, you can use it's handlers to track the operation. The `PaymentEngine` handlers will get called throughout the payment process and will return you the current state of the transaction. You can set these handlers in the completion block of the previous step.

`PeripheralStateHandler` will get called when the state of the peripheral changes during the transaction process. The PeripheralState represents the current state of the peripheral as reported by the peripheral device itself. These include “idle”, “ready”, “contactCardInserted” etc.

`PeripheralMessageHandler` will get called when there is new message about the transaction throughout the process. The peripheral message tells you when to present the card, if the card read is successful or failed, etc. This usually indicates something that should be displayed in the user interface.

`EmvApplicationHandler` will get called if the EmvApplicationSelection is required.

```C#
private void SetPaymentEngineHandlers()
{
    PaymentEngine.SetPeripheralStateHandler((peripheral, peripheralState) =>
    {
        MainThread.BeginInvokeOnMainThread(() => { PeripheralState = peripheralState; });
    });

    PaymentEngine.SetPeripheralMessageHandler((peripheral, message) =>
    {
        MainThread.BeginInvokeOnMainThread(() => { PeripheralMessage = message; });
    });

    PaymentEngine.SetEmvApplicationSelectionHandler((peripheral, transaction, selection) =>
    {
        MainThread.BeginInvokeOnMainThread(async() =>
        {
            await ShowEmvApplicationSelectionAction(selection);
        });
    });

}
```

### Connect to Payment Device
Now that your payment engine is configured and your handlers are set up, lets connect to the payment device. Please make sure the device is attached and turned on. We need to connect to the payment device prior to starting a transaction. The connection state will be returned to the `ConnectionStateHandler` that we set up previously. If you didn't set autoConnect when creating the payment engine, you will need to call `connect()` before starting a transaction.

`ConnectionStateHandler` will get called when the connection state of the payment device changes between connecting, connected, and disconnected. It is important to make sure your device is connected before attempting to start a transaction.

```C#
public void ConnectToPeripheral()
{
    // assign connection state and transaction state handlers
    PaymentEngine.SetConnectionStateHandler((peripheral, connectionState) =>
    {
        ConnectionState = connectionState;

        switch (connectionState)
        {
            case ConnectionState.Disconnected:
                ConnectionMessage = "Disconnected";
                break;

            case ConnectionState.Connecting:
                ConnectionMessage = "Connecting";
                break;

            case ConnectionState.Connected:
                ConnectionMessage = "Connected";
                break;
        }
    });

    // connect to the peripheral - must be called before any further interaction with the peripheral
    PaymentEngine.Connect();
}
```

### Create an Invoice
Time to create an invoice. This invoice object holds information about a purchase order and the items in the order.

```C#
var invoiceBuilder = PaymentEngine.BuildInvoice(InvoiceNum)
                                  .CompanyName(CompanyName)
                                  .PurchaseOrderReference(PurchaseOrderReference);

                                  foreach (var invoiceItem in InvoiceItems)
                                  {
                                      invoiceBuilder.AddItem(item => item.ProductCode(invoiceItem.ProductCode)
                                                      .Description(invoiceItem.Description)
                                                      .SaleCode(invoiceItem.SaleCode)
                                                      .UnitPrice(invoiceItem.UnitPrice)
                                                      .Quantity(invoiceItem.Quantity)
                                                      //.UnitOfMeasure(invoiceItem.UnitOfMeasureCode) //todo: task #3235
                                                    );
                                  }

var invoice = invoiceBuilder.CalculateTotals().Build();
                
```

### Create a Transaction

The transaction object holds information about the invoice, the total amount for the transaction and the type of the transaction (e.g.: sale, auth, refund, etc.)

```C#
var txnBuilder = PaymentEngine.BuildTransaction(invoice)
                              .Amount(amount, SelectedCurrency.Currency)
                              .Reference(Reference) // required - unique transaction reference, such as your application order number
                              .DateTime(DateTimeOffset.Now) // optional - defaults to the current local date time
                              .Sale(); // options: .Sale(), .Auth(), .Capture(TransactionId), .Refund(TransactionId), .Undo(TransactionId), .Void(TransactionId)
                              .Capabilities(selectedCapabilities);
                              .FallbackReason(TransactionFallbackReason.Value);
                              .Service(Service) // optional - allow customer to control the merchant account that will process the transaction in business that have multiple services / legal entities
                                                //.SecureFormat(SecureFormat.Value) // optional - use a different secure format only when required by the merchant account
                              .MetaData(new Dictionary<string, string>
                              {
                                  ["OrderNumber"] = invoiceNum.ToString(),
                                  ["Delivered"] = "Y"
                              }); // optional - store data object to associate with the transactio
                
var txn = txnBuilder.Build();
```

### Start Transaction

Now that everything is ready we can start the transaction and take payment. Watch the handler messages and status updates to track the transaction throughout the process.

`return await PaymentEngine.StartTransactionAsync(txn);`

### Transaction Receipt

Once the transaction is completed and approved, the receipt is sent to the TransactionResultHandler callback.

```C#
// The url for customer receipt
transactionResult.receipt?.customerReceiptUrl

// The url for merchant receipt
transactionResult.receipt?.merchantReceiptUrl
```

## Disconnect Payment Device
Now that the transaction is complete you are free to disconnect the payment device if you wish. Please note that this should not be called before or during the transaction process.

`PaymentEngine.Disconnect()`

