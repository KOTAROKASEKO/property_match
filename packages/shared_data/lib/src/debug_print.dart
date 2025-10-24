import 'package:flutter/foundation.dart';

pr(String message){
  if(kDebugMode){
    print("[DEBUG]${message}");
  }
}