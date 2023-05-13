import 'package:hiqradio/src/utils/constant.dart';
import 'package:hiqradio/src/utils/crypt.dart';
import 'package:intl/intl.dart';
import 'package:ntp/ntp.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CheckLicense {
  CheckLicense._();
  static CheckLicense instance = CheckLicense._();

  Future<DateTime> netNow() async {
    DateTime n = DateTime.now();
    int offset = await NTP.getNtpOffset(lookUpAddress: 'ntp.aliyun.com');
    n = n.add(Duration(milliseconds: offset));
    return n;
  }

  Future<String?> isActiveLicense(String productId, String license) async {
    String? date = Crypt.instance.decryptLicense(productId, license);
    if (date == null) {
      return null;
    }
    try {
      DateTime licenseDate = DateTime.parse(date);
      DateTime now = await netNow();
      if (now.isAfter(licenseDate)) {
        return null;
      }
      date = DateFormat("yyyy-MM-dd").format(licenseDate);
      print('remain: ${now.difference(licenseDate).inDays}');
    } catch (e) {
      return null;
    }
    return date;
  }

  Future<String?> isTryEnd() async {
    DateTime now = await netNow();
    SharedPreferences sp = await SharedPreferences.getInstance();
    String? startTime = sp.getString(kSpAppFistStarted);
    if (startTime == null) {
      sp.setString(
          kSpAppFistStarted, DateFormat("yyyy-MM-dd HH:mm:ss").format(now));
      startTime = DateFormat("yyyy-MM-dd").format(now);
    }
    DateTime date = DateTime.parse(startTime);
    date = date.add(const Duration(days: kTryDays));
    if (now.isAfter(date)) {
      return null;
    }
    print('remain: ${now.difference(date).inDays}');
    return DateFormat("yyyy-MM-dd").format(date);
  }

  Future<String?> checkLicense() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String? license = sp.getString(kSpAppLicense);
    if (license == null) {
      return await isTryEnd();
    }

    return await isActiveLicense(kProductId, license);
  }
}
