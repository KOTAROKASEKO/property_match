export 'widgets/sign_in_button_mobile.dart'
    // If compiling for web (dart.library.html is available), export the web one instead
    if (dart.library.html) 'widgets/sign_in_button_web.dart';