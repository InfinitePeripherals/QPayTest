---
layout: default
title: Project Setup
nav_order: 2
parent: iOS
grand_parent: Getting Started
---

## Project Setup

### Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

### Installing QuantumPay SDKs
* Add the framework files into **Frameworks, Libraries and Embedded Content**.
* Set **Embed** to "Embed & Sign". 

### Installing ObjectBox
* Visit [ObjectBox - Swift](https://swift.objectbox.io) and follow the instruction to install ObjectBox for your project.

### Turn off Bitcode support
* Set **Enable Bitcode** to *false* in **Project's Build Setting**.

### Add MFi protocols
Add new entry for "Supported external accessory protocols" to **Info.plist** with these values

* com.datecs.pengine
* com.datecs.linea.pro.msr
* com.datecs.linea.pro.bar
* com.datecs.printer.escpos
* com.datecs.pinpad

### Add **Privacy** entries into **Info.plist**

#### Bluetooth BLE privacy options to connect to payment devices
* "Privacy - Bluetooth Always Usage Description" 
* "Privacy - Bluetooth Peripheral Usage Description"

#### Location privacy to allow the Quantum Pay SDK to work correctly
* "Privacy - Location When In Use Usage Description" 
* "Privacy - Location Usage Description"