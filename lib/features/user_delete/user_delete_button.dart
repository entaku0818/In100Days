import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:in_100_days/features/error/error_alert.dart';
import 'package:in_100_days/provider/secure_storage.dart';
import 'package:in_100_days/style/color.dart';

class UserDeleteButton extends StatelessWidget {
  const UserDeleteButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        child: const Text("ユーザーを削除する"),
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return _alert(context);
              });
        });
  }

  Widget _alert(BuildContext context) {
    return AlertDialog(
        title: const Icon(Icons.warning),
        content: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              "ユーザーを削除します",
              style: TextStyle(color: Colors.black, fontSize: 20),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 15,
            ),
            Text("ユーザーが削除されるとアプリ内にあるデータもすべて消えます",
                style: const TextStyle(color: Colors.grey, fontSize: 16),
                textAlign: TextAlign.center),
          ],
        ),
        actions: [
          TextButton(
            child: const Text(
              "削除する",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: AppColor.danger,
              ),
            ),
            onPressed: () async {
              try {
                const securetStorage = FlutterSecureStorage();
                await securetStorage.delete(
                    key: SecuretStorageKeys.twitterAuthToken);
                await securetStorage.delete(
                    key: SecuretStorageKeys.twitterAuthTokenSecret);

                await FirebaseAuth.instance.currentUser?.delete();
              } catch (error) {
                showErrorAlert(context, error: error);
              }
            },
          ),
          TextButton(
            child: const Text(
              "キャンセル",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: Colors.black,
              ),
            ),
            onPressed: () async {
              Navigator.of(context).pop();
            },
          ),
        ]);
  }
}
