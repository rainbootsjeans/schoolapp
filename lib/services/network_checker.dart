import 'package:connectivity_plus/connectivity_plus.dart';

Future<bool> isConnectedToNetwork() async {
  var connectivityResult = await Connectivity().checkConnectivity();

  if (connectivityResult.contains(ConnectivityResult.none)) {
    return false;
  } else {
    return true;
  }
}
