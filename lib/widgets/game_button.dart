import 'package:flutter/material.dart';

class GameButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final double width;
  final double height;
  final bool isActive;
  final bool isSmall;

  const GameButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.width = double.infinity,
    this.height = 56,
    this.isActive = true,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(isSmall ? 8 : 12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Button frame/border
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: const Color(0xFF3D2314), // Wood-like brown
              borderRadius: BorderRadius.circular(isSmall ? 8 : 12),
              border: Border.all(
                color: const Color(0xFF8D6E63),
                width: isSmall ? 2 : 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 2,
                  offset: const Offset(0, 2),
                )
              ],
            ),
          ),

          // Button inner padding for 3D effect
          Positioned(
            top: 3,
            left: 3,
            right: 3,
            bottom: 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(isSmall ? 6 : 10),
              child: MaterialButton(
                onPressed: isActive ? onPressed : null,
                padding: EdgeInsets.zero,
                color: isActive ? const Color(0xFFFF7D2A) : const Color(0xFF8D6E63),
                elevation: 0,
                highlightElevation: 0,
                splashColor: const Color(0xFFFFAA33).withOpacity(0.3),
                highlightColor: const Color(0xFFFFAA33).withOpacity(0.1),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(isSmall ? 6 : 10),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: isActive
                        ? const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFFFFAA33),
                              Color(0xFFFF7D2A),
                              Color(0xFFFF5722),
                            ],
                          )
                        : null,
                  ),
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmall ? 8 : 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[
                          Icon(
                            icon,
                            color: Colors.white,
                            size: isSmall ? 16 : 24,
                          ),
                          SizedBox(width: isSmall ? 4 : 8),
                        ],
                        Text(
                          text,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: isSmall ? 12 : 16,
                            fontFamily: 'RubikDirt',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CircularGameButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final double size;
  final bool isActive;

  const CircularGameButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 50,
    this.isActive = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.transparent,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Button frame/border
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: const Color(0xFF3D2314), // Wood-like brown
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF8D6E63),
                width: 3,
              ),
            ),
          ),

          // Button inner padding for 3D effect
          Positioned(
            top: 3,
            left: 3,
            right: 3,
            bottom: 3,
            child: ClipOval(
              child: MaterialButton(
                onPressed: isActive ? onPressed : null,
                padding: EdgeInsets.zero,
                color: isActive ? const Color(0xFFFF7D2A) : const Color(0xFF8D6E63),
                elevation: 0,
                highlightElevation: 0,
                splashColor: const Color(0xFFFFAA33).withOpacity(0.3),
                highlightColor: const Color(0xFFFFAA33).withOpacity(0.1),
                shape: const CircleBorder(),
                child: Ink(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: isActive
                        ? const RadialGradient(
                            center: Alignment(0, -0.2),
                            radius: 1.0,
                            colors: [
                              Color(0xFFFFAA33),
                              Color(0xFFFF7D2A),
                              Color(0xFFFF5722),
                            ],
                          )
                        : null,
                  ),
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    alignment: Alignment.center,
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: size * 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GameToggleButton extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const GameToggleButton({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        width: 80,
        height: 32,
        decoration: BoxDecoration(
          color: const Color(0xFF3D2314),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF8D6E63),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 2,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Stack(
          children: [
            // Background labels
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'OFF',
                      style: TextStyle(
                        color: !value ? Colors.white : Colors.white30,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'RubikDirt',
                      ),
                    ),
                    Text(
                      'ON',
                      style: TextStyle(
                        color: value ? Colors.white : Colors.white30,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'RubikDirt',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Sliding toggle
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              left: value ? 44 : 4,
              top: 4,
              child: Container(
                width: 32,
                height: 24,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFFFAA33),
                      Color(0xFFFF7D2A),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 1,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GamePanel extends StatelessWidget {
  final Widget child;
  final String? title;
  final double? width;
  final double? height;
  final Color? borderColor;
  final EdgeInsets padding;

  const GamePanel({
    super.key,
    required this.child,
    this.title,
    this.width,
    this.height,
    this.borderColor,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF3D2314),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor ?? const Color(0xFF8D6E63),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFF7D2A),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFFFAA33),
                    Color(0xFFFF7D2A),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 2,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                title!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  fontFamily: 'RubikDirt',
                ),
              ),
            ),
          Padding(
            padding: padding,
            child: child,
          ),
        ],
      ),
    );
  }
}
