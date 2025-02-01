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

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void startPayment(BuildContext context) async {
    String? result = await UpiPaymentPlugin.initiateUPIPayment(
      packageName: "package_name", 
      merchantUPI: "",
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
        child: ElevatedButton(
          onPressed: () => startPayment(context),
          child: const Text("Pay Now"),
        ),
      ),
    );
  }
}
