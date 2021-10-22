---
layout: default
title: Scanning a Barcode
nav_order: 4
parent: iOS
grand_parent: Getting Started
---

## Scanning a Barcode
If your payment device supports barcode scanning (e.g.: QPC150, QPC250), in order to receive the barcode data, you will need to set your class to conform to the protocol `IPCDTDeviceDelegate`, and add the class instance as a delegate to receive the barcode. The scanner will only scan if it is connected to the application.
```
self.paymentDevice.device.addDelegate(self)
```
Once a barcode is scanned, it will be sent to this delegate method:
```
func barcodeData(_ barcode: String!, type: Int32) {
    // Handle the barcode
}
```
