import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:in_100_days/features/error/error_alert.dart';
import 'package:in_100_days/provider/user.dart';

import 'state_notifier.dart';

class LoginPage extends HookConsumerWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(loginStateNotifierProvider);
    final stateNotifier = ref.watch(loginStateNotifierProvider.notifier);

    print("[DEBUG] state: $state");
    Future.microtask(() {
      final user = state.user;
      print("[DEBUG] in microtask user: $user");
      if (user != null) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) {
            return ObjectiveSheet(twitterIDName: user.screenName);
          },
        );
      }
    });
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              child: const Text('Sign in with Twitter'),
              onPressed: () async {
                try {
                  final user = await stateNotifier.asyncAction.signIn();

                  await ref
                      .read(userDocumentReferenceProvider(user.id!))
                      .set(user, SetOptions(merge: true));

                  stateNotifier.setUser(user);
                } catch (error) {
                  showErrorAlert(context, error: error);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ObjectiveSheet extends StatelessWidget {
  final String twitterIDName;

  const ObjectiveSheet({Key? key, required this.twitterIDName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "100日後に",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 30,
              ),
            ),
            SizedBox(
              width: 200,
              height: 200,
              child: TextField(
                decoration: const InputDecoration(
                  filled: true,
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(width: 1),
                  ),
                  contentPadding: EdgeInsets.only(bottom: 8),
                ),
                onChanged: (text) {
                  print(text);
                },
              ),
            ),
            Text(
              twitterIDName,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
