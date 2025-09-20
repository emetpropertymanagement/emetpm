import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';
import 'Dashboard.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String errorMessage = "";
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Container(
            margin: const EdgeInsets.all(5),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 60),
                  const Text(
                    "EMET PROPERTY MANAGEMENT",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 0, 148, 5)),
                  ),
                  const SizedBox(height: 40),
                  isLoading
                      ? const CircularProgressIndicator()
                      : SizedBox(
                          width: 250,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all<Color>(
                                Color.fromARGB(255, 0, 148, 5),
                              ),
                              elevation: WidgetStateProperty.all<double>(3),
                              padding: WidgetStateProperty.all(
                                  const EdgeInsets.symmetric(vertical: 16)),
                              shape: WidgetStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                            ),
                            onPressed: signInWithGoogle,
                            child: const Text(
                              'Login with Google',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                  if (errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        errorMessage,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Container(
              margin: const EdgeInsets.only(
                  left: 20.0, top: 20.0, right: 20.0, bottom: 10.0),
              child: const Center(
                  child: Text(
                "Developed by Alfred +256773913902",
                style: TextStyle(color: Color.fromARGB(95, 27, 27, 27)),
              ))),
        ],
      ),
    );
  }

  Future<void> signInWithGoogle() async {
    print('[Login] Google sign-in started');
    setState(() {
      isLoading = true;
      errorMessage = "";
    });
    try {
      await GoogleSignInPlatform.instance.init(const InitParameters());
      final AuthenticationResults? result = await GoogleSignInPlatform.instance
          .attemptLightweightAuthentication(
              const AttemptLightweightAuthenticationParameters());
      final GoogleSignInUserData? user = result?.user;
      print('[Login] Google user: ' + (user?.email ?? 'null'));
      if (user == null) {
        print('[Login] Sign in aborted by user');
        setState(() {
          isLoading = false;
          errorMessage = "Sign in aborted";
        });
        return;
      }
      // Get tokens for Firebase Auth
      final ClientAuthorizationTokenData? tokens = await GoogleSignInPlatform
          .instance
          .clientAuthorizationTokensForScopes(
        ClientAuthorizationTokensForScopesParameters(
          request: AuthorizationRequestDetails(
            scopes: const <String>["email"],
            userId: user.id,
            email: user.email,
            promptIfUnauthorized: false,
          ),
        ),
      );
      if (tokens == null || tokens.accessToken == null) {
        throw Exception('Google sign-in failed: Missing accessToken');
      }
      final credential =
          GoogleAuthProvider.credential(accessToken: tokens.accessToken);
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      print('[Login] Firebase user: ' + (userCredential.user?.email ?? 'null'));
      if (!mounted) return;
      final allowedEmails = [
        'emetpropertymanagementug1@gmail.com',
        'grealmkids@gmail.com',
      ];
      final userEmail = userCredential.user?.email ?? '';
      if (allowedEmails.contains(userEmail)) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Dashboard()),
        );
      } else {
        setState(() {
          errorMessage = "Access Denied!";
        });
      }
    } catch (e) {
      print('[Login] Google sign-in failed: $e');
      setState(() {
        errorMessage = "Google sign-in failed: $e";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
      print('[Login] Google sign-in finished');
    }
  }
}
