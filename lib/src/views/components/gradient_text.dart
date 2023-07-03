import 'package:flutter/material.dart';

/// The type of gradient to apply.
enum GradientType {
  /// A linear gradient.
  linear,

  /// A radial gradient.
  radial,
}

/// Direction to apply in the gradient.
enum GradientDirection {
  /// Bottom to top.
  btt,

  /// Left to right.
  ltr,

  /// Right to left.
  rtl,

  /// Top to bottom.
  ttb,
}

/// A gradient text.
class GradientText extends StatelessWidget {
  /// Colors used to show the gradient.
  final List<Color> colors;

  /// Direction in which the gradient will be displayed.
  final GradientDirection? gradientDirection;

  /// The type of gradient to apply.
  final GradientType gradientType;

  /// How visual overflow should be handled.
  final TextOverflow? overflow;

  /// The radius of the gradient, as a fraction of the shortest side
  /// of the paint box.
  final double radius;

  /// If non-null, the style to use for this text.
  final TextStyle? style;

  /// The text to display.
  final String text;

  /// How the text should be aligned horizontally.
  final TextAlign? textAlign;

  /// How the text should be scaled.
  final double? textScaleFactor;

  /// Maximum number of lines for the text to span.
  final int? maxLines;

  const GradientText(
    this.text, {
    required this.colors,
    this.gradientDirection = GradientDirection.ltr,
    this.gradientType = GradientType.linear,
    Key? key,
    this.overflow,
    this.radius = 1.0,
    this.style,
    this.textAlign,
    this.textScaleFactor,
    this.maxLines,
  })  : assert(
          colors.length >= 2,
          'Colors list must have at least two colors',
        ),
        super(key: key);

  @override
  Widget build(final BuildContext context) {
    return ShaderMask(
      shaderCallback: (final Rect bounds) {
        switch (gradientType) {
          case GradientType.linear:
            final Map<String, Alignment> map = {};
            switch (gradientDirection) {
              case GradientDirection.rtl:
                map['begin'] = Alignment.centerRight;
                map['end'] = Alignment.centerLeft;
                break;
              case GradientDirection.ttb:
                map['begin'] = Alignment.topCenter;
                map['end'] = Alignment.bottomCenter;
                break;
              case GradientDirection.btt:
                map['begin'] = Alignment.bottomCenter;
                map['end'] = Alignment.topCenter;
                break;
              default:
                map['begin'] = Alignment.centerLeft;
                map['end'] = Alignment.centerRight;
                break;
            }
            return LinearGradient(
              begin: map['begin']!,
              colors: colors,
              end: map['end']!,
            ).createShader(bounds);
          case GradientType.radial:
            return RadialGradient(
              colors: colors,
              radius: radius,
            ).createShader(bounds);
        }
      },
      child: Text(
        text,
        overflow: overflow,
        style: style != null
            ? style?.copyWith(color: Colors.white)
            : const TextStyle(color: Colors.white),
        textScaleFactor: textScaleFactor,
        textAlign: textAlign,
        maxLines: maxLines,
      ),
    );
  }
}
