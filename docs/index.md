---
layout: default
title: Home
nav_order: 1
permalink: /
---

# QuantumPay SDK
{: .fs-9 }

Integration with your Point of Sale solution is made simple with the QuantumPay SDK and its support for all major mobile developer platforms.
{: .fs-5 .fw-300 }

[Download QuantumPay SDK](https://github.com/InfinitePeripherals/QuantumPay/releases){: .btn .btn-primary .fs-5 .mb-4 .mb-md-0 .mr-2 } [Visit Our Website](https://ipcmobile.com/products/quantumpay-solution){: .btn .fs-5 .mb-4 .mb-md-0 }

## Why QuantumPay SDK?
- Supports both iOS and Android devices 
- Works with minimal configuration out of the box
- Uses headless APIs so POS developers retain full control of application user interface
- Conforms to payment security standards and best practices
- Support for store & forward payment processing

---

## QuantumPay SDK Libraries
QuantumPay SDK is comprised of 3 separate libraries: QuantumPayClient, QuantumPayMobile and QuantumPayPeripheral. By separating functionality into layers, you have the ability to use only what you need for your specific POS solution. You can chose just one, or up to all three for maximum functionality.

### QuantumPayClient
QuantumPayClient handles communication with web APIs. This is the library you use to configure your server information/credentials and handle the results of your sent transactions. If you want your application to work with different peripherals or not use our payment engine, you could still use this library to send transactions to QuantumPay.

### QuantumPayMobile
QuantumPayMobile is the library that handles payment engine operations. It is in charge of controlling the payment flow and communicating back the state of the transaction back to the host app. This is the library you use to build transactions and utilize store & forward for offline operation.

### QuantumPayPeripheral
QuantumPayPeripheral manages the payment device itself. This library allows you define your own payment device or if you are using an Infinite Peripherals payment device utilize our predefined classes. This is also where you manage the connection to the device, whether its Bluetooth or directly connected. By keeping this separate you are able to swap out peripheral implementations depending on what payment device you are using.