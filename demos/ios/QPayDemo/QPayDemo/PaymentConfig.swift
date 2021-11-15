//
//  PaymentConfig.swift
//  QPayDemo
//
//  Created by Lucas Netal on 11/1/21.
//

import Foundation

import QuantumPayClient
import QuantumPayMobile
import QuantumPayPeripheral

public class PaymentConfig: NSObject {

    public static let developerKey = "your_key"

    // Attached device. Serial will be collecting directly from the device
    public static let peripheral = QPC250()
    
    public static let hostKey:String = "us"
    
    // QuantumPay Cloud Server Tenant Key
    public static let tenantKey:String = "tenant"
    
    // QuantumPay Device Administrator Username
    public static let username: String = "username";
    
    // QuantumPay Device Administrator Password
    public static let password: String = "password";
    
    // QuantumPay Service Account Key - controls the merchant account the payment will be sent to
    public static let service: String = "service"
    
    // Your unique POS ID that your transactions will be registered against
    // This ID is important, and must the same at every load for app to operate correctly.
    public static let posId: String = Bundle.main.bundleIdentifier!
        
    // Sample code transaction reference
    public static var testReference: String = ""
    
    // Sample code transaction amount
    public static let testAmount: Decimal = 1.00
    
    // Sample code transaction currency
    public static let testCurrency: Currency = Currency.USD;
    
    // Sample code secure format
    public static let useSecureFormat: SecureFormat = SecureFormat.idTech;
}
