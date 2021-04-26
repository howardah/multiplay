import 'package:flutter/material.dart';

class StyledIconButton extends StatelessWidget {
  final Color hoverColor;
  final Color splashColor;
  final Color highlightColor;
  final void Function() onPressed;
  final Icon icon;

  StyledIconButton({
    this.hoverColor = Colors.transparent,
    this.splashColor = Colors.transparent,
    this.highlightColor = Colors.transparent,
    required this.onPressed,
    required this.icon,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.zero,
      constraints: BoxConstraints(maxWidth: 20.0),
      hoverColor: hoverColor,
      splashColor: splashColor,
      highlightColor: highlightColor,
      onPressed: onPressed,
      icon: icon,
    );
  }
}
