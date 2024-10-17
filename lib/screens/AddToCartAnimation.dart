import 'package:flutter/material.dart';

class AddToCartAnimation extends StatefulWidget {
  final Widget child;

  AddToCartAnimation({Key? key, required this.child}) : super(key: key);

  @override
  AddToCartAnimationState createState() => AddToCartAnimationState();
}

class AddToCartAnimationState extends State<AddToCartAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  void startAnimation() {
    _isAnimating = true;
    _controller.forward().then((_) {
      _controller.reverse().then((_) {
        setState(() {
          _isAnimating = false;
        });
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        widget.child,
        if (_isAnimating)
          Positioned(
            child: FadeTransition(
              opacity: _animation,
              child: Icon(
                Icons.add_shopping_cart,
                size: 70,
                color: Colors.green,
              ),
            ),
          ),
      ],
    );
  }
}
