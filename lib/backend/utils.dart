import 'dart:math';

String generateCode(int length) {
  List<String> available = ['a','b','c','d','e','f','g','h','i','j','k','l','m',
    'n','o','p','q','r','s','t','u','v','w','x','y','z', 'A','B','C','D','E','F',
    'G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y',
    'Z', '0','1','2','3','4','5','6','7','8','9'];
  Random random = new Random();

  String room = "";
  for (int i = 0; i < length; i++){
    room += available[random.nextInt(available.length)];
  }
  return room;
}


int getTime() {
  return DateTime.now().millisecondsSinceEpoch;
}