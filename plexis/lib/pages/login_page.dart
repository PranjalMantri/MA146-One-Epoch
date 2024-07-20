import 'package:flutter/material.dart';
import 'package:plexis/auth/auth_service.dart';
import 'package:plexis/components/my_button.dart';
import 'package:plexis/components/my_textfield.dart';

class LoginPage extends StatelessWidget {

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController  = TextEditingController();

  final void Function()? onTap;

  void login(BuildContext context) async {
    // auth service
    final authService = AuthService();

    try {
      await authService.signInWithEmailPassword(_emailController.text, _pwController.text);
    }catch (e) {
      showDialog(context: context, builder: (context) => AlertDialog(
        title: Text(e.toString()),
      ));
    }

    
  }

  LoginPage({super.key, required this.onTap});

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
            
            // welcome back message

            Text(
              "Welcome back, you've been missed",
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 16
              ),
            ),

            const SizedBox(height: 25),

           MyTextfield(hintText: "Email...", obscureText: false, controller: _emailController,),

          const SizedBox(height: 15,),

          MyTextfield(hintText: "Password...", obscureText: true, controller: _pwController,),

          const SizedBox(height: 15,),

          MyButton(buttonText: "Login", onTap: () => login(context),),

          const SizedBox(height: 15,),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Not a member? ", style: TextStyle(color: Theme.of(context).colorScheme.primary),),
              GestureDetector(
                onTap: onTap,
                child: Text(
                  "Register Now",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              )
            ],
          )
            
          ],
        ),
      ),
    );
  }
}
