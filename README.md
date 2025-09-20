this error has persisted. would it help if you describe for me a detailed prd and i just create a new flutter app  that works the same way but doesnt have the errors in the current app?  flutter pub cache repair
Resetting Git repository for assets_for_android_views 0.2.0...
Reinstalled 880 packages.
Reactivating flutterfire_cli 1.3.1...
Downloading packages... 
Building package executables... (4.9s)
Built flutterfire_cli:flutterfire.
Installed executable flutterfire.
Reactivated 1 package.
PS C:\Users\dell\flutter projects\EMET APP_Aug> flutter run -d 122697054E007663
Resolving dependencies... (1.4s)
Downloading packages... 
  characters 1.4.0 (1.4.1 available)
  device_info_plus 11.5.0 (12.1.0 available)
  material_color_utilities 0.11.1 (0.13.0 available)
  meta 1.16.0 (1.17.0 available)
  test_api 0.7.6 (0.7.7 available)
Got dependencies!
5 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
Launching lib\main.dart on Infinix X6525D in debug mode...
Warning: Flutter support for your project's Gradle version (8.5.0) will soon be dropped. Please upgrade your Gradle version to a version of at least 8.7.0 soon.
Alternatively, use the flag "--android-skip-build-dependency-validation" to bypass this check.

Potential fix: Your project's gradle version is typically defined in the gradle wrapper file. By default, this can be found at C:\Users\dell\flutter projects\EMET APP_Aug\android/gradle/wrapper/gradle-wrapper.properties.
For more information, see https://docs.gradle.org/current/userguide/gradle_wrapper.html.

Warning: Flutter support for your project's Android Gradle Plugin version (Android Gradle Plugin version 8.1.1) will soon be dropped. Please upgrade your Android Gradle Plugin version to a version of at least Android Gradle Plugin version 8.6.0 soon.
Alternatively, use the flag "--android-skip-build-dependency-validation" to bypass this check.

Potential fix: Your project's AGP version is typically defined in the plugins block of the `settings.gradle` file (C:\Users\dell\flutter projects\EMET APP_Aug\android/settings.gradle), by a plugin with the id of com.android.application.
If you don't see a plugins block, your project was likely created with an older template version. In this case it is most likely defined in the top-level build.gradle file (C:\Users\dell\flutter projects\EMET APP_Aug\android/build.gradle) by the following line in the dependencies block of the buildscript: "classpath 'com.android.tools.build:gradle:<version>'".

Warning: Flutter support for your project's Kotlin version (1.9.22) will soon be dropped. Please upgrade your Kotlin version to a version of at least 2.1.0 soon.
Alternatively, use the flag "--android-skip-build-dependency-validation" to bypass this check.

Potential fix: Your project's KGP version is typically defined in the plugins block of the `settings.gradle` file (C:\Users\dell\flutter projects\EMET APP_Aug\android/settings.gradle), by a plugin with the id of org.jetbrains.kotlin.android.
If you don't see a plugins block, your project was likely created with an older template version, in which case it is most likely defined in the top-level build.gradle file (C:\Users\dell\flutter projects\EMET APP_Aug\android/build.gradle) by the ext.kotlin_version property.

lib/pages/home.dart:101:28: Error: Couldn't find constructor 'GoogleSignIn'.
      final googleSignIn = GoogleSignIn(scopes: <String>["email"]);
                           ^^^^^^^^^^^^
Target kernel_snapshot_program failed: Exception


FAILURE: Build failed with an exception.

* What went wrong:
Execution failed for task ':app:compileFlutterBuildDebug'.
> Process 'command 'C:\Users\dell\flutter\bin\flutter.bat'' finished with non-zero exit value 1

* Try:
> Run with --stacktrace option to get the stack trace.
> Run with --info or --debug option to get more log output.
> Run with --scan to get full insights.
> Get more help at https://help.gradle.org.

BUILD FAILED in 23s
Running Gradle task 'assembleDebug'...                             23.9s
Error: Gradle task assembleDebug failed with exit code 1
PS C:\Users\dell\flutter projects\EMET APP_Aug> 