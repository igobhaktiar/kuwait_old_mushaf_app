// function to encode english digits into arabic digits
String encodeToArabicNumbers({required int inputInteger}) {
  String tempInpput = inputInteger.toString();
  List<String> englishNumbers = [
    "0",
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9"
  ];
  List<String> arabicNumbers = [
    "٠",
    "١",
    "٢",
    "٣",
    "٤",
    "٥",
    "٦",
    "٧",
    "٨",
    "٩"
  ];
  for (int i = 0; i < tempInpput.length; i++) {
    for (String engDigit in englishNumbers) {
      if (tempInpput[i] == engDigit) {
        tempInpput = tempInpput.replaceAll(
            engDigit, arabicNumbers[englishNumbers.indexOf(engDigit)]);
      }
    }
    // print("$i: " + _tempInpput);
  }
  return tempInpput;
}

encodeArabbicCharToEn(String arabicString) {
  return arabicString
      .replaceAll(RegExp(r'ء|ا|أ|ع|ؤ|ئ|ة'), "a")
      .replaceAll(RegExp(r'ب'), "b")
      .replaceAll(RegExp(r'ت|ط'), "t")
      .replaceAll(RegExp(r'ث'), "th")
      .replaceAll(RegExp(r'ج'), "j")
      .replaceAll(RegExp(r'ح|ه'), "h")
      .replaceAll(RegExp(r'خ'), "kh")
      .replaceAll(RegExp(r'د|ض'), "d")
      .replaceAll(RegExp(r'ذ|ظ|ز'), "z")
      .replaceAll(RegExp(r'ر'), "r")
      .replaceAll(RegExp(r'س|ص'), "s")
      .replaceAll(RegExp(r'ش'), "sh")
      .replaceAll(RegExp(r'غ'), "g")
      .replaceAll(RegExp(r'ق|ك'), "q")
      .replaceAll(RegExp(r'ل'), "l")
      .replaceAll(RegExp(r'م'), "m")
      .replaceAll(RegExp(r'ن'), "n")
      .replaceAll(RegExp(r'و'), "w")
      .replaceAll(RegExp(r'ي'), "y")
      .replaceAll(RegExp(r' '), "-");
}
