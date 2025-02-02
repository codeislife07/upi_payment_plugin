# UPI Payment Plugin for Flutter

## 📌 Features
- Supports **Android & iOS**
- **Fetches List of UPI Apps** available on the device
- **Handles UPI Transactions** via Google Pay, PhonePe, Paytm, etc.
- **Returns Payment Response**
- Secure **HMAC-SHA256 Signature Generation** (if required by provider)

---

## 📌 Installation
### **1️⃣ Add Dependency**
Add the package to your **pubspec.yaml** file:

```yaml
dependencies:
  upi_payment_plugin: 0.0.1
```
Then, run:
```sh
flutter pub get
```

---

## 📌 Android Configuration
### **2️⃣ Update `AndroidManifest.xml`**
Add the following inside the `<manifest>` tag:

```xml
<queries>
    <intent>
        <action android:name="android.intent.action.VIEW" />
        <data android:scheme="upi" />
    </intent>
</queries>
```

---

## 📌 iOS Configuration
### **3️⃣ Update `Info.plist`**
Add the following inside the `<dict>` tag:

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>upi</string>
    <string>googlepay</string>
    <string>phonepe</string>
    <string>paytm</string>
</array>
```

---

## 📌 Usage Example
### **4️⃣ Import and Use in Your Flutter App**

```dart
import 'package:flutter/material.dart';
import 'package:upi_payment_plugin/model/upi_app_model.dart';
import 'package:upi_payment_plugin/upi_payment_plugin.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<UpiAppModel> upiApps = [];
  UpiAppModel? selectedUpiApp;

  @override
  void initState() {
    fetchUpiApps();
    super.initState();
  }

  Future<void> fetchUpiApps() async {
    List<UpiAppModel> apps = await UpiPaymentPlugin().getUpiApps();
    setState(() {
      upiApps = apps;
    });
  }

  void initiateUPIPayment() {
    // if (selectedUpiApp == null) return;
    UpiPaymentPlugin.initiateUPIPayment(
      payeeUpiId: 'upi@id',
      payeeName: 'payeeName',
      amount: 1.0,
      transactionId: 'txn123456',
      transactionNote: 'Test Transaction',
      merchantCode: '1234',
      link: '',
      transactionRefId: 'ref123456',
      packageName: 'com.google.android.apps.nbu.paisa.user',
      secretKey: '', //provide by upi app
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("UPI Payment")),
        body: Center(
          child: Column(
            children: [
              DropdownButton<UpiAppModel>(
                hint: Text("Select UPI App"),
                value: selectedUpiApp,
                onChanged: (UpiAppModel? newValue) {
                  setState(() {
                    selectedUpiApp = newValue;
                  });
                },
                items: upiApps.map((UpiAppModel app) {
                  return DropdownMenuItem<UpiAppModel>(
                    value: app,
                    child: Text(app.appName),
                  );
                }).toList(),
              ),
              ElevatedButton(
                onPressed: initiateUPIPayment,
                child: Text("Pay Now"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

```

---

## 📌 Supported UPI Apps
Use the following package names to launch specific UPI apps:

| UPI App     | Package Name |
|------------|--------------------------|
| Google Pay | com.google.android.apps.nbu.paisa.user |
| PhonePe    | com.phonepe.app |
| Paytm      | net.one97.paytm |

---

## 📌 Notes
- Ensure the selected UPI app is installed on the device.
- Handle the **UPI response** correctly in your Flutter app to verify transactions.
- The app now **fetches a list of available UPI apps**, allowing users to select their preferred payment method.

🚀 Now you can integrate **UPI payments** in your Flutter app seamlessly! 🎯

