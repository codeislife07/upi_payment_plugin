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
    if (selectedUpiApp == null) return;
    UpiPaymentPlugin.initiateUPIPayment(
      payeeUpiId: 'Vyapar.172807280980@hdcbank',
      payeeName: 'payeeName',
      amount: 1.0,
      transactionId: 'txn123456',
      transactionNote: 'Test Transaction',
      merchantCode: '1234',
      link: '',
      transactionRefId: 'ref123456',
      packageName: selectedUpiApp!.packageName,
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
