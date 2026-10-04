import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';

class OperatorInfo {
  final String id;
  final String nameFa;
  final String nameEn;
  final Color primaryColor;
  final Color accentColor;
  final String prefixHint;
  final String tag;

  const OperatorInfo({
    required this.id,
    required this.nameFa,
    required this.nameEn,
    required this.primaryColor,
    required this.accentColor,
    required this.prefixHint,
    required this.tag,
  });
}

class OperatorSelectorWidget extends StatelessWidget {
  final String? selectedOperatorId;
  final ValueChanged<OperatorInfo> onOperatorSelected;
  final bool showTitle;
  final String? title;

  static const List<OperatorInfo> operators = [
    OperatorInfo(
      id: 'mci',
      nameFa: 'همراه اول',
      nameEn: 'MCI',
      primaryColor: Color(0xFF00A499),
      accentColor: Color(0xFFF58220),
      prefixHint: '091X',
      tag: 'سراسری',
    ),
    OperatorInfo(
      id: 'irancell',
      nameFa: 'ایرانسل',
      nameEn: 'Irancell',
      primaryColor: Color(0xFFFFCC00),
      accentColor: Color(0xFF231F20),
      prefixHint: '093X',
      tag: '5G / دیتا',
    ),
    OperatorInfo(
      id: 'rightel',
      nameFa: 'رایتل',
      nameEn: 'Rightel',
      primaryColor: Color(0xFF8E24AA),
      accentColor: Color(0xFFAB47BC),
      prefixHint: '092X',
      tag: 'اینترنت',
    ),
    OperatorInfo(
      id: 'shatel',
      nameFa: 'شاتل',
      nameEn: 'Shatel',
      primaryColor: Color(0xFF0288D1),
      accentColor: Color(0xFF01579B),
      prefixHint: '0998',
      tag: 'پوشش کامل',
    ),
  ];

  const OperatorSelectorWidget({
    super.key,
    required this.selectedOperatorId,
    required this.onOperatorSelected,
    this.showTitle = true,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showTitle) ...[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title ?? 'انتخاب اپراتور / Select Operator',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.warmWhite : AppColors.lightTextPrimary,
                  ),
                ),
                Text(
                  'شناسایی خودکار پیش‌شماره',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
        ],
        Row(
          children: operators.map((operator) {
            final isSelected = selectedOperatorId == operator.id;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: _OperatorCard(
                  operator: operator,
                  isSelected: isSelected,
                  isDark: isDark,
                  onTap: () => onOperatorSelected(operator),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _OperatorCard extends StatelessWidget {
  final OperatorInfo operator;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _OperatorCard({
    required this.operator,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeBg = isDark
        ? operator.primaryColor.withValues(alpha: 0.18)
        : operator.primaryColor.withValues(alpha: 0.08);

    final inactiveBg = isDark ? AppColors.darkSurfaceVariant : AppColors.lightBackground;

    return AnimatedContainer(
      duration: AppDurations.fast,
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: isSelected ? activeBg : inactiveBg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: isSelected
              ? operator.primaryColor
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          width: isSelected ? 2.0 : 1.0,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: operator.primaryColor.withValues(alpha: isDark ? 0.35 : 0.22),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    _OperatorLogoBadge(operator: operator, isSelected: isSelected),
                    if (isSelected)
                      Positioned(
                        top: -2,
                        right: -2,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: operator.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            size: 10,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 6.h),
                Text(
                  operator.nameFa,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected
                        ? (isDark ? Colors.white : operator.primaryColor)
                        : (isDark ? AppColors.warmWhite : AppColors.lightTextPrimary),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  operator.nameEn,
                  style: TextStyle(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OperatorLogoBadge extends StatelessWidget {
  final OperatorInfo operator;
  final bool isSelected;

  const _OperatorLogoBadge({
    required this.operator,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38.w,
      height: 38.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            operator.primaryColor,
            operator.accentColor,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: operator.primaryColor.withValues(alpha: 0.35),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: _buildBadgeGlyph(operator.id),
      ),
    );
  }

  Widget _buildBadgeGlyph(String id) {
    switch (id) {
      case 'mci':
        // MCI Turquoise & Orange dual petal emblem
        return CustomPaint(
          size: const Size(20, 20),
          painter: _MciLogoPainter(),
        );
      case 'irancell':
        // MTN Irancell Yellow oval & bold ring
        return CustomPaint(
          size: const Size(20, 20),
          painter: _IrancellLogoPainter(),
        );
      case 'rightel':
        // Rightel purple circular ripple emblem
        return CustomPaint(
          size: const Size(20, 20),
          painter: _RightelLogoPainter(),
        );
      case 'shatel':
      default:
        // Shatel blue wave signal emblem
        return CustomPaint(
          size: const Size(20, 20),
          painter: _ShatelLogoPainter(),
        );
    }
  }
}

class _MciLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final paint2 = Paint()
      ..color = const Color(0xFFF58220)
      ..style = PaintingStyle.fill;

    // Draw MCI abstract overlapping curved swooshes
    final path1 = Path()
      ..moveTo(size.width * 0.3, size.height * 0.7)
      ..quadraticBezierTo(size.width * 0.1, size.height * 0.3, size.width * 0.5, size.height * 0.15)
      ..quadraticBezierTo(size.width * 0.4, size.height * 0.5, size.width * 0.3, size.height * 0.7);
    canvas.drawPath(path1, paint1);

    final path2 = Path()
      ..moveTo(size.width * 0.7, size.height * 0.3)
      ..quadraticBezierTo(size.width * 0.9, size.height * 0.7, size.width * 0.5, size.height * 0.85)
      ..quadraticBezierTo(size.width * 0.6, size.height * 0.5, size.width * 0.7, size.height * 0.3);
    canvas.drawPath(path2, paint2);

    final centerDot = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.5), 2.0, centerDot);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _IrancellLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final ringPaint = Paint()
      ..color = const Color(0xFF231F20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;

    final dotPaint = Paint()
      ..color = const Color(0xFF231F20)
      ..style = PaintingStyle.fill;

    // Central oval
    final rect = Rect.fromCenter(
      center: Offset(size.width * 0.5, size.height * 0.5),
      width: size.width * 0.7,
      height: size.height * 0.5,
    );
    canvas.drawOval(rect, ringPaint);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.5), 2.5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RightelLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final ringPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.5), size.width * 0.35, ringPaint);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.5), size.width * 0.18, ringPaint);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.5), 2.2, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ShatelLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.0;

    // Draw 3 broadcast arcs
    final center = Offset(size.width * 0.25, size.height * 0.75);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: size.width * 0.25),
      -1.4,
      1.2,
      false,
      paint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: size.width * 0.45),
      -1.4,
      1.2,
      false,
      paint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: size.width * 0.65),
      -1.4,
      1.2,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
