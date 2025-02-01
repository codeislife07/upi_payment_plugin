class UpiAppModel {
  final String packageName;
  final String appName;
  final String? icon;

  UpiAppModel({
    required this.packageName,
    required this.appName,
    this.icon,
  });

  factory UpiAppModel.fromMap(Map<String, dynamic> map) {
    return UpiAppModel(
      packageName: map['packageName'] ?? '',
      appName: map['appName'] ?? '',
      icon: map['icon'],
    );
  }
}

// class UpiPaymentPlugin {
//   Future<List<UpiAppModel>> getUpiApps() async {
//     // Simulating fetching list of UPI apps
//     List<Map<String, dynamic>> appsData = [
//       {'packageName': 'com.google.pay', 'appName': 'Google Pay', 'icon': 'gpay_icon.png'},
//       {'packageName': 'com.phonepe.app', 'appName': 'PhonePe', 'icon': 'phonepe_icon.png'},
//       {'packageName': 'com.paytm.app', 'appName': 'Paytm', 'icon': 'paytm_icon.png'}
//     ];
//     return appsData.map((app) => UpiAppModel.fromMap(app)).toList();
//   }
// }
