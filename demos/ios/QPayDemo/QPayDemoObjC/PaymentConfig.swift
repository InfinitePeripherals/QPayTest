//
//  SampleConfig.swift
//  QuantumPaySDK_Swift_Test
//
//  Created by Kyle M on 2/23/21.
//

import Foundation

import QuantumPayClient
import QuantumPayMobile
import QuantumPayPeripheral

@objcMembers
public class PaymentConfig: NSObject {
    // Developer key that works with this bundle ID: "com.ipc.QPayObjC"
    public static let developerKey = "LZ2DfYZw/+Uo3fRXZt3xdv1SnBA1Di1ZfvEmSq+i4LSu4RH8qxM41OvVStOyv3Dc"

    // ******* Create a payment device **********
    // Attached device. Serial will be collecting directly from the device
    public static let peripheral = QPC250()                                     // <--------------
    
    // BLE device need the serial to scan for and connect to
    // Set the corresponding BLE payment object type and its serial
    //public static let peripheral = QPR250(serial: device serial here)         // <---------------
    // ******************************************
    
    // ********************** CREDENTIAL *************************
    public static let hostKey:String = "us"
    
    // QuantumPay Cloud Server Tenant Key. Needs value
    public static let tenantKey:String = ""

    // QuantumPay Device Administrator Username. Needs value
    public static let username: String = ""

    // QuantumPay Device Administrator Password. Needs value
    public static let password: String = ""

    // QuantumPay Service Account Key - controls the merchant account the payment will be sent to
    public static let service: String = "EvoPayTest" // or "FreedomPayTest"
    // ************************* END CREDENTIAL ******************
    
    // Your unique POS ID that your transactions will be registered against
    // This ID is important, and must be the same at every lauch for app to operate correctly.
    public static let posId: String = Bundle.main.bundleIdentifier!
        
    // Sample code transaction reference
    public static var testReference: String = ""
    
    // Sample code transaction amount
    public static let testAmount: Decimal = 5.00
    
    // Sample code transaction currency
    public static let testCurrency: Currency = Currency.USD;
    
    // Sample code secure format
    public static let useSecureFormat: SecureFormat = SecureFormat.pinpad;
}
