import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:in_100_days/components/user_info.dart';
import 'package:in_100_days/entity/goal.codegen.dart';
import 'package:in_100_days/entity/user.codegen.dart';
import 'package:in_100_days/features/error/error_alert.dart';
import 'package:in_100_days/provider/goal.dart';
import 'package:in_100_days/style/button.dart';
import 'package:in_100_days/style/color.dart';
import 'package:in_100_days/utility/random_element.dart';

class GoalInputSheet extends HookConsumerWidget {
  final User user;

  const GoalInputSheet({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = useState("");
    final textFieldController = useTextEditingController(text: "");

    final estimateStartDate = DateTime.now().add(const Duration(days: 100));
    final startDate = useState<DateTime>(estimateStartDate);
    final latestDays =
        100 - estimateStartDate.difference(startDate.value).inDays;

    const double paddingHorizontal = 20;
    final hashTag = "$latestDays日後に${text.value}${user.twitterID}";
    final fullHashTag = "#" + hashTag;

    return AnnotatedRegion(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(
                vertical: 20, horizontal: paddingHorizontal),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(),
                GestureDetector(
                  onTap: () async {
                    final selected =
                        await _selectDate(context, startDate: startDate.value);
                    if (selected != null) {
                      startDate.value = selected;
                    }
                  },
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "$latestDays日後",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColor.textMain,
                          ),
                        ),
                        const TextSpan(
                          text: "に達成したい目標・なりたい自分を決めましょう",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.normal,
                            color: AppColor.textMain,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                UserInfo(user: user, fullHashTag: fullHashTag),
                const SizedBox(height: 40.5),
                Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          "#$latestDays日後に",
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 24,
                            color: AppColor.textMain,
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width -
                            paddingHorizontal * 2,
                      ),
                      child: TextField(
                        maxLength: 20,
                        minLines: 1,
                        maxLines: 2,
                        textInputAction: TextInputAction.done,
                        controller: textFieldController,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 24,
                          color: AppColor.textMain,
                        ),
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.only(bottom: 8),
                          hintText: pickRandomElement<String>([
                            "海賊王になる",
                            "Twitterを辞める",
                            "100Kgのバーベルをあげる",
                            "猫を飼う",
                            "家を買う",
                            "お腹いっぱいにご飯を食べる"
                          ]),
                          hintStyle: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 24,
                            color: AppColor.textNote,
                          ),
                        ),
                        onChanged: (_text) {
                          text.value = _text;
                        },
                        onEditingComplete: () async {
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Spacer(),
                        Text(
                          user.twitterID,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 24,
                            color: AppColor.textMain,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                PrimaryButton(
                  onPressed: text.value.isEmpty
                      ? null
                      : () async {
                          if (text.value.isEmpty) {
                            return;
                          }
                          try {
                            final goal = Goal(
                              goalAction: text.value,
                              hashTag: hashTag,
                              startDate: startDate.value,
                              createdDateTime: DateTime.now(),
                              purchasedProducts: [],
                            );
                            await goalCollectionReference(userID: user.id!)
                                .doc()
                                .set(goal, SetOptions(merge: true));
                            Navigator.of(context).pop();
                          } catch (error) {
                            showErrorAlert(context, error: error);
                          }
                        },
                  text: "目標を設定する",
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<DateTime?> _selectDate(BuildContext context,
      {required DateTime startDate}) async {
    return await showDatePicker(
      context: context,
      helpText: "開始日を変更できます",
      initialDate: startDate,
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 100)),
    );
  }
}
