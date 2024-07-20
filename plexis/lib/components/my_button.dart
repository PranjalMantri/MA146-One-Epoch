import "package:flutter/material.dart";

class MyButton extends StatelessWidget {
  final void Function()? onTap;
  final String buttonText;

  const MyButton({super.key, required this.buttonText, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary
        ),
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.symmetric(horizontal: 25),
        child: Center(
          child: Text(buttonText),
          ),
      ),
    );
  }
}