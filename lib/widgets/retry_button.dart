import 'package:flutter/material.dart';

class RetryButton extends StatelessWidget {
  void Function() onPressed;

  RetryButton({ required this.onPressed });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Oops!',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            Text(
              'Something Went Wrong.',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            Container(
              padding: EdgeInsets.all(5),
              child: ElevatedButton(
                onPressed: onPressed,
                child: Text(
                  'Try again ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          ]),
    );
  }
}
