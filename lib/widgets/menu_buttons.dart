import 'package:flutter/material.dart';

class AddNewAreaButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AddNewAreaButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Center(
          child: Text('Add New Area', style: TextStyle(color: Colors.white))),
      onTap: onPressed,
    );
  }
}

class AddNewControllerButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AddNewControllerButton({Key? key, required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Center(
          child: Text('Add New Controller',
              style: TextStyle(color: Colors.white))),
      onTap: onPressed,
    );
  }
}

class CancelButton extends StatelessWidget {
  final VoidCallback onPressed;

  const CancelButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title:
          Center(child: Text('CANCEL', style: TextStyle(color: Colors.white))),
      onTap: onPressed,
    );
  }
}
