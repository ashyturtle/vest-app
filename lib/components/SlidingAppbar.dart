import 'package:flutter/material.dart';

class SlidingAppbar extends StatelessWidget implements PreferredSizeWidget {

  final PreferredSizeWidget child;
  final AnimationController controller;
  final bool visible;

  SlidingAppbar({
    required this.child,
    required this.controller,
    required this.visible
});


  @override
  Size get preferredSize => child.preferredSize;

  @override
  Widget build(BuildContext context){
    visible ? controller.reverse() : controller.forward();
    return SlideTransition(
        position: Tween<Offset>(begin: Offset.zero, end: Offset(0, -1))
            .animate(
            CurvedAnimation(
                parent: controller,
                curve: Curves.fastOutSlowIn
            )
        )
    );
  }
}