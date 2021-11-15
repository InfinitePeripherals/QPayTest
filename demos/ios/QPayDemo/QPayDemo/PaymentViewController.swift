//
//  PaymentViewController.swift
//  QPayDemo
//
//  Created by Lucas Netal on 11/1/21.
//

import Foundation
import UIKit

import QuantumSDK
import QuantumPayClient
import QuantumPayMobile
import QuantumPayPeripheral

class PaymentViewController: UIViewController {
    
    @IBOutlet weak var outputTextView: UITextView!
    
    var pEngine: PaymentEngine?
    var transaction: Transaction?
    var transactionResult: TransactionResult?
    
    var paymentDevice: QuantumPayPeripheral.InfinitePeripheralsDevice!
    
    let ipcDevice = IPCDTDevices.sharedDevice()!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // *** Dont have this in yet
        self.ipcDevice.addDelegate(self)
        
        initializeQuantumSDKs()
    }
    
    func initializeQuantumSDKs() {
        // Create tenant
        let tenant = Tenant(hostKey: PaymentConfig.hostKey, tenantKey: PaymentConfig.tenantKey)

        // Initialize QuantumPay
        InfinitePeripherals.initialize(developerKey: PaymentConfig.developerKey, tenant: tenant)
        
        // Initialize payment device
        paymentDevice = QPC250()
    }
    
    @IBAction func actionStartEngine(sender: UIButton) {
        do {
            try PaymentEngine.builder()
                // Set server environment to either test or production
                .server(server: ServerEnvironment.test)
                // Credentials used to register hardware devices
                .registrationCredentials(username: PaymentConfig.username, password: PaymentConfig.password)
                // Using the device we created earlier, set the peripheral and capabilities
                // Capabilities are the card input methods (e.g.: Mag stripe, contactless, chip). If you don't want the full array of capabilities provided by the device object, you can pass an array of select input methods only.
                .addPeripheral(peripheral: paymentDevice, capabilities: paymentDevice.availableCapabilities!, autoConnect: false)
                // The Point of Sale ID of the device/app. This posID should be unique for each instance of the app. This is used by the database to access saved transactions.
                .posID(posID: PaymentConfig.posId)
                // Amount of time after transaction has started to wait for card to be presented
                .transactionTimeout(timeoutInSeconds: 30)
                // StoreAndForwardMode for submitting transactions to server
                .storeAndForward(mode: .whenOffline, autoUploadInterval: 60)
                // If this build function is successful, the PaymentEngine will be passed in the completion block.
                .build(handler: { (engine) in
                    // Save the created engine object
                    self.pEngine = engine
                    
                    self.pEngine!.setConnectionStateHandler(handler: { (peripheral, connectionState) in
                        // Handle connection state
                        self.addText("Connection state: \(connectionState)")
                    })
                    
                    self.pEngine!.setTransactionStateHandler(handler: { (peripheral, transaction, transactionState) in
                        // Handle transaction state
                        self.addText("Transaction state: \(transactionState)")
                    })
                    
                    self.pEngine!.setTransactionResultHandler(handler: { (transactionResult) in
                        // Handle the transaction result
                        // TransactionResult.status provides the transaction result
                        // TransactionResult.receipt provides the online receipt when TransactionResult.state == .approved
                        
                        self.addText("Transaction result: \(transactionResult.status)")
                        self.addText("Receipt: \(transactionResult.receipt?.customerReceiptUrl ?? "")")
                        
                        // This object contains the result of the transaction
                        self.transactionResult = transactionResult
                    })
                    
                    self.pEngine!.setPeripheralStateHandler(handler: { (peripheral, state) in
                        // Handle peripheral state
                        self.addText("Peripheral state: \(state)")
                    })
                    
                    self.pEngine!.setPeripheralMessageHandler(handler: { (peripheral, message) in
                        // Handle peripheral message
                        self.addText("Peripheral message: \(message)")
                    })
                })
        }
        catch {
            print("Error creating payment engine: \(error.localizedDescription)")
        }
    }
    
    @IBAction func actionConnect(sender: UIButton) {
        self.pEngine!.connect()
    }
    
    @IBAction func actionStartTransaction(sender: UIButton) {
        let invoiceNum = "17681"
        //let transactionRef = "\(arc4random() % 99999)"
        //let amount = 1
        
        do {
            let invoice = try self.pEngine!
                                // Build invoice with a reference number. This can be anything.
                                .buildInvoice(reference: invoiceNum)
                                // Set company name
                                .companyName(companyName: "ACME SUPPLIES INC.")
                                // Set purchase order reference. This can be anything to identify the order.
                                .purchaseOrderReference(reference: "P01234")
                                // A way to add item to the invoice
                                .addItem(productCode: "SKU1", description: "Discount Voucher for Return Visit", unitPrice: 0)
                                // Another way to add item to the invoice
                                .addItem { (itemBuilder) -> InvoiceItemBuilder in
                                    return itemBuilder
                                        .productCode("SKU2")
                                        .productDescription("In Store Item")
                                        .saleCode(SaleCode.S)
                                        .unitPrice(1.00)
                                        .quantity(1)
                                        .unitOfMeasureCode(.Each)
                                        .calculateTotals()
                                }
                                // Calculate totals on the invoice
                                .calculateTotals()
                                // Builds invoice instance with the provided values
                                .build()
            
            let transaction = try self.pEngine!.buildTransaction(invoice: invoice)
                                    // The transaction is of type Sale
                                    .sale()
                                    // The total amount of all the invoices
                                    .amount(1.00, currency: .USD)
                                    // A unique reference to the transaction, and cannot be reused.
                                    .reference("A reference to this transaction")
                                    // Date and time of the transaction
                                    .dateTime(Date())
                                    // The service code generated by Infinite Peripherals
                                    .service("service")
                                    // Some information about the transaction that you want to add
                                    .metaData(["orderNumber" : invoiceNum, "delivered" : "true"])
                                    // Build the transaction
                                    .build()
            
            try self.pEngine!.startTransaction(transaction: transaction) { (transactionResult, transactionResponse) in
                // Handle the transaction result and response
                // transactionResult.status discloses the state of the transaction after being processed. See `TransactionResultStatus` for more info.
                // transactionResponse discloses the server's response for the submitted transaction. If an error occurs, the object will contain the
                // error's information. See `TransactionResponse` for more info.
                // ....
            }
        }
        catch {
            
        }
        
        
    }
    
    func addText(_ text: String) {
        print(text)
        DispatchQueue.main.async {
            self.outputTextView.text = "\(text)\n" + self.outputTextView.text
        }
    }
}
