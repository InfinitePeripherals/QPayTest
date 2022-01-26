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

---

