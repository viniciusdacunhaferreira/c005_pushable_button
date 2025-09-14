import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Padding(
          padding: EdgeInsets.all(16.0),
          // Use Center as layout has unconstrained width (loose constraints),
          // together with SizedBox to specify the max width (tight constraints)
          // See this thread for more info:
          // https://twitter.com/biz84/status/1445400059894542337
          child: Center(
            child: SizedBox(
              width: 400, // max allowed width
              child: PushableButtonPage(),
            ),
          ),
        ),
      ),
    );
  }
}

class PushableButtonPage extends StatefulWidget {
  const PushableButtonPage({super.key});

  @override
  State<PushableButtonPage> createState() => _PushableButtonPageState();
}

class _PushableButtonPageState extends State<PushableButtonPage> {
  String _selection = 'none';

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(
      color: Colors.white,
      fontSize: 24,
      fontWeight: FontWeight.bold,
    );
    final shadow = BoxShadow(
      color: Colors.grey.withOpacity(0.5),
      spreadRadius: 2,
      blurRadius: 4,
      offset: const Offset(0, 2),
    );
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PushableButton(
                height: 60,
                elevation: 8,
                hslColor: const HSLColor.fromAHSL(1.0, 356, 1.0, 0.43),
                shadow: shadow,
                onPressed: () => setState(() => _selection = '1'),
                child: const Text('PUSH ME', style: textStyle),
              ),
              const SizedBox(height: 32),
              PushableButton(
                height: 60,
                elevation: 8,
                hslColor: const HSLColor.fromAHSL(1.0, 120, 1.0, 0.37),
                shadow: shadow,
                onPressed: () => setState(() => _selection = '2'),
                child: const Text('ENROLL NOW', style: textStyle),
              ),
              const SizedBox(height: 32),
              PushableButton(
                height: 60,
                elevation: 8,
                hslColor: const HSLColor.fromAHSL(1.0, 195, 1.0, 0.43),
                shadow: shadow,
                onPressed: () => setState(() => _selection = '3'),
                child: const Text('ADD TO BASKET', style: textStyle),
              ),
              const SizedBox(height: 32),
              Text(
                'Pushed: $_selection',
                style: textStyle.copyWith(color: Colors.black87),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A widget to show a "3D" pushable button
class PushableButton extends StatefulWidget {
  const PushableButton({
    super.key,
    this.child,
    required this.hslColor,
    required this.height,
    this.elevation = 8.0,
    this.shadow,
    this.onPressed,
  }) : assert(height > 0);

  /// child widget (normally a Text or Icon)
  final Widget? child;

  /// Color of the top layer
  /// The color of the bottom layer is derived by decreasing the luminosity by 0.15
  final HSLColor hslColor;

  /// height of the top layer
  final double height;

  /// elevation or "gap" between the top and bottom layer
  final double elevation;

  /// An optional shadow to make the button look better
  /// This is added to the bottom layer only
  final BoxShadow? shadow;

  /// button pressed callback
  final VoidCallback? onPressed;

  @override
  State<PushableButton> createState() => _PushableButtonState();
}

class _PushableButtonState extends State<PushableButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  void _runCallback() {
    if (widget.onPressed != null) widget.onPressed!.call();
  }

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Durations.short1,
    );

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color topColor = widget.hslColor.toColor();

    final Color bottomColor = widget.hslColor
        .withLightness(widget.hslColor.lightness - 0.15)
        .toColor();

    final BorderRadius borderRadius = BorderRadius.circular(widget.height / 2);

    return SizedBox(
      height: widget.elevation + widget.height,
      child: GestureDetector(
        onTap: () {
          _controller.forward().whenComplete(() {
            _runCallback();
            _controller.reverse();
          });
        },
        onTapDown: (_) => _controller.forward(),
        onTapCancel: () => _controller.reverse(),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final boxShadow = widget.shadow == null
                ? null
                : [
                    widget.shadow!.copyWith(
                      spreadRadius:
                          widget.shadow!.spreadRadius * (1 - _controller.value),
                    )
                  ];

            final double elevation = max(
              2,
              (1 - _controller.value) * widget.elevation,
            );

            return Stack(
              children: [
                Positioned.fill(
                  top: null,
                  child: Container(
                    height: widget.height + elevation,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: bottomColor,
                      borderRadius: borderRadius,
                      boxShadow: boxShadow,
                    ),
                  ),
                ),
                Positioned.fill(
                  top: null,
                  bottom: elevation,
                  child: Container(
                    height: widget.height,
                    decoration: BoxDecoration(
                      color: topColor,
                      borderRadius: borderRadius,
                    ),
                    child: Center(child: child),
                  ),
                ),
              ],
            );
          },
          child: widget.child,
        ),
      ),
    );
  }
}
