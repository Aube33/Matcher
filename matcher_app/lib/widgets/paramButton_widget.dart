import 'package:flutter/material.dart';

class ParamButton extends StatelessWidget {
  final String text;
  final Function callback;
  const ParamButton({super.key, required this.text, required this.callback});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {
        callback();
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: Theme.of(context).textTheme.displaySmall!.copyWith(
              height: 3
            )
          ),
          const Icon(Icons.arrow_forward_ios_outlined)
        ],
      )
    );
  }
}