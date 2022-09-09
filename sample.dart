import 'dart:async';


class Person {
  int? futureNum;
  String? futureName;

  // 数値を入れる
  static Future<void> future1(futureNum) async {
    await futureNum;
    print(futureNum);
  }

  // 文字を入れる
  static Future<String> future2(futureName) async {
    await Future.delayed(Duration(seconds: 3));
    return futureName;
  }
}

Future main() async {
  await Person.future1(33);
  final getName = await Person.future2("Jboy");
  print("3秒後に非道処理が走る：$getNameさんいたよ！");
}