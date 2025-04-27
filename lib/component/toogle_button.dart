
import 'package:flutter/material.dart';

class ToggleButton extends StatefulWidget {

  final ToggleDecoration decoration;
  final bool Function() callback;
  final void Function(bool isOn) onChanged;

  ToggleButton({super.key, required this.callback, required this.onChanged, ToggleDecoration? decoration}):
      decoration = decoration ?? ToggleDecoration();


  @override
  State<ToggleButton> createState() => _ToggleButtonState();
}

class _ToggleButtonState extends State<ToggleButton> {

  late bool isToggled;

  _onChanged() {
    setState(() {
      isToggled = !isToggled;
    });
    widget.onChanged(isToggled);
  }

  @override
  void initState() {
    isToggled = widget.callback();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    // Padding top, bottom 각각 3씩
    double ballSize = widget.decoration.height - 6;

    return GestureDetector(
      onTap: _onChanged,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: widget.decoration.width,
        height: widget.decoration.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: isToggled ? widget.decoration.color : const Color(0xFFE42323),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              top: 3,
              left: isToggled ? widget.decoration.height - 6.0 : 0.0,
              right: isToggled ? 0.0 : widget.decoration.height - 6.0,
              child: Container(
                width: ballSize,
                height: ballSize,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      offset: const Offset(0, 0),
                      blurRadius: 4,
                      blurStyle: BlurStyle.inner
                    )
                  ],
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: isToggled
                  ? const Icon(Icons.check_rounded, color: Color(0xFF41BA45),)
                  : const Icon(Icons.close_rounded, color: Color(0xFFE42323),),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InnerShadowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.inner, 10.0);

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


class ToggleDecoration {

  final double width;
  final double height;
  final Color color;

  ToggleDecoration({this.width = 35, this.height = 20, Color? color}):
    color = color ?? const Color(0xFF74A9F8);
}