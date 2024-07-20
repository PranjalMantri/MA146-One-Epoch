// import 'package:flutter/material.dart';
// import 'package:plexis/auth/auth_service.dart';
// import 'package:plexis/components/my_button.dart';
// import 'package:plexis/components/my_textfield.dart';

// class RegisterPage extends StatelessWidget {
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _pwController = TextEditingController();
//   final TextEditingController _confirmPwController = TextEditingController();

//   final void Function()? onTap;

//   RegisterPage({super.key, required this.onTap});

//   void register(BuildContext context) {
//     final _auth = AuthService();

//     if (_pwController.text == _confirmPwController.text) {
//       try {
//         _auth.signUpWithEmailAndPassword(_emailController.text, _pwController.text);
//       } catch (e) {
//         showDialog(
//           context: context,
//           builder: (context) => AlertDialog(
//             title: Text(e.toString()),
//           ),
//         );
//       }
//     } else {
//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: Text("Passwords do not match"),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Theme.of(context).colorScheme.surface,
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // logo
//             Icon(Icons.security_outlined, size: 70.0, color: Theme.of(context).colorScheme.primary),

//             const SizedBox(height: 50),

//             // welcome message
//             Text(
//               "Let's create an account for you",
//               style: TextStyle(
//                 color: Theme.of(context).colorScheme.primary,
//                 fontSize: 16,
//               ),
//             ),

//             const SizedBox(height: 25),

//             MyTextfield(hintText: "Email...", obscureText: false, controller: _emailController),

//             const SizedBox(height: 15),

//             MyTextfield(hintText: "Password...", obscureText: true, controller: _pwController),

//             const SizedBox(height: 15),

//             MyTextfield(hintText: "Confirm Password...", obscureText: true, controller: _confirmPwController),

//             const SizedBox(height: 15),

//             MyButton(buttonText: "Register", onTap: () => register(context)),

//             const SizedBox(height: 15),

//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text("Already have an account? ", style: TextStyle(color: Theme.of(context).colorScheme.primary)),
//                 GestureDetector(
//                   onTap: onTap,
//                   child: Text(
//                     "Login Now",
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       color: Theme.of(context).colorScheme.primary,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:plexis/components/my_button.dart';
import 'package:plexis/components/my_textfield.dart';

class RegisterPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _confirmPwController = TextEditingController();

  final void Function()? onTap;

  RegisterPage({super.key, required this.onTap});

  Future<void> register(BuildContext context) async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    if (_pwController.text == _confirmPwController.text) {
      try {
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _pwController.text,
        );

        String? fcmToken = await FirebaseMessaging.instance.getToken();

        if (userCredential.user != null && fcmToken != null) {
          await _firestore.collection('users').doc(userCredential.user!.uid).set({
            'email': _emailController.text,
            'fcmToken': fcmToken,
          });
        }

      } catch (e) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(e.toString()),
          ),
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          title: Text("Passwords do not match"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // logo
            Icon(Icons.security_outlined, size: 70.0, color: Theme.of(context).colorScheme.primary),

            const SizedBox(height: 50),

            // welcome message
            Text(
              "Let's create an account for you",
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 25),

            MyTextfield(hintText: "Email...", obscureText: false, controller: _emailController),

            const SizedBox(height: 15),

            MyTextfield(hintText: "Password...", obscureText: true, controller: _pwController),

            const SizedBox(height: 15),

            MyTextfield(hintText: "Confirm Password...", obscureText: true, controller: _confirmPwController),

            const SizedBox(height: 15),

            MyButton(buttonText: "Register", onTap: () => register(context)),

            const SizedBox(height: 15),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Already have an account? ", style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                GestureDetector(
                  onTap: onTap,
                  child: Text(
                    "Login Now",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
