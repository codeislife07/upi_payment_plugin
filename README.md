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
  upi_payment_plugin:
    path: ../upi_payment_plugin  # Use the correct path or fetch from pub.dev when published
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
import 'package:upi_payment_plugin/upi_payment_plugin.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> upiApps = [];

  @override
  void initState() {
    super.initState();
    fetchUPIApps();
  }

  void fetchUPIApps() async {
    List<String>? apps = await UpiPaymentPlugin.getAvailableUPIApps();
    if (apps != null) {
      setState(() {
        upiApps = apps;
      });
    }
  }

  void startPayment(String packageName) async {
    String? result = await UpiPaymentPlugin.initiateUPIPayment(
      packageName: packageName,
      merchantUPI: "Vyapar.172807280980@hdcbank",
      merchantName: "Merchant Name",
      transactionId: "TXN123456",
      orderId: "ORDER123",
      note: "Payment for Order 123",
      amount: "1.00",
      currency: "INR",
    );

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result ?? "Payment Failed")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("UPI Payment")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (upiApps.isEmpty)
              const CircularProgressIndicator()
            else
              ...upiApps.map(
                (app) => ElevatedButton(
                  onPressed: () => startPayment(app),
                  child: Text("Pay with ${app.split('.').last}"),
                ),
              ),
          ],
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

