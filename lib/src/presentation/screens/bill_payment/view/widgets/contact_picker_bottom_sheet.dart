import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';

class ContactItem {
  final String name;
  final String phone;
  final String operatorId;
  final String operatorName;
  final Color avatarColor;

  const ContactItem({
    required this.name,
    required this.phone,
    required this.operatorId,
    required this.operatorName,
    required this.avatarColor,
  });
}

class ContactPickerBottomSheet extends StatefulWidget {
  final Function(String name, String phone, String operatorId) onContactSelected;

  const ContactPickerBottomSheet({
    super.key,
    required this.onContactSelected,
  });

  static Future<void> show(
    BuildContext context, {
    required Function(String name, String phone, String operatorId) onContactSelected,
  }) async {
    await Get.bottomSheet(
      ContactPickerBottomSheet(onContactSelected: onContactSelected),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  State<ContactPickerBottomSheet> createState() => _ContactPickerBottomSheetState();
}

class _ContactPickerBottomSheetState extends State<ContactPickerBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  PermissionStatus? _permissionStatus;
  bool _isCheckingPermission = true;

  static const List<ContactItem> _mockContacts = [
    ContactItem(
      name: 'علی رضایی (Ali Rezaei)',
      phone: '09123456789',
      operatorId: 'mci',
      operatorName: 'همراه اول',
      avatarColor: Color(0xFF00A499),
    ),
    ContactItem(
      name: 'سارا محمدی (Sara Mohammadi)',
      phone: '09359876543',
      operatorId: 'irancell',
      operatorName: 'ایرانسل',
      avatarColor: Color(0xFFFFCC00),
    ),
    ContactItem(
      name: 'مادر (Mom)',
      phone: '09121112233',
      operatorId: 'mci',
      operatorName: 'همراه اول',
      avatarColor: Color(0xFFEC4899),
    ),
    ContactItem(
      name: 'رضا کریمی (Reza Karimi)',
      phone: '09215554321',
      operatorId: 'rightel',
      operatorName: 'رایتل',
      avatarColor: Color(0xFF8E24AA),
    ),
    ContactItem(
      name: 'فرهاد احمدی (Farhad Ahmadi)',
      phone: '09981234567',
      operatorId: 'shatel',
      operatorName: 'شاتل',
      avatarColor: Color(0xFF0288D1),
    ),
    ContactItem(
      name: 'پدر (Dad)',
      phone: '09125556677',
      operatorId: 'mci',
      operatorName: 'همراه اول',
      avatarColor: Color(0xFF3B82F6),
    ),
    ContactItem(
      name: 'همسر (Spouse)',
      phone: '09367778899',
      operatorId: 'irancell',
      operatorName: 'ایرانسل',
      avatarColor: Color(0xFF10B981),
    ),
  ];

  List<ContactItem> _filteredContacts = [];

  @override
  void initState() {
    super.initState();
    _filteredContacts = _mockContacts;
    _checkPermission();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _checkPermission() async {
    try {
      final status = await Permission.contacts.status;
      if (mounted) {
        setState(() {
          _permissionStatus = status;
          _isCheckingPermission = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _permissionStatus = PermissionStatus.granted;
          _isCheckingPermission = false;
        });
      }
    }
  }

  Future<void> _requestPermission() async {
    try {
      final status = await Permission.contacts.request();
      if (mounted) {
        setState(() {
          _permissionStatus = status;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _permissionStatus = PermissionStatus.granted;
        });
      }
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredContacts = _mockContacts;
      } else {
        _filteredContacts = _mockContacts.where((contact) {
          final matchesName = contact.name.toLowerCase().contains(query);
          final matchesPhone = contact.phone.contains(query);
          return matchesName || matchesPhone;
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? AppColors.darkSurface : AppColors.white;

    return Container(
      height: 520.h,
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.15),
            blurRadius: 30,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(height: 12.h),
          Container(
            width: 44.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 14.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: (isDark ? AppColors.mainSoftBlue : AppColors.deepBlack)
                            .withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.contacts_rounded,
                        size: 20.w,
                        color: isDark ? AppColors.mainSoftBlue : AppColors.deepBlack,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'انتخاب مخاطب',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.warmWhite : AppColors.lightTextPrimary,
                          ),
                        ),
                        Text(
                          'Select from Contacts',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(
                    Icons.close_rounded,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 14.h),
          // Search Bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            child: Container(
              height: 46.h,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightBackground,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: TextField(
                controller: _searchController,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: isDark ? AppColors.warmWhite : AppColors.lightTextPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'جستجوی نام یا شماره تلفن...',
                  hintStyle: TextStyle(
                    fontSize: 12.sp,
                    color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    size: 20.w,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear_rounded,
                            size: 16.w,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                          onPressed: () => _searchController.clear(),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10.h),
                ),
              ),
            ),
          ),
          SizedBox(height: 10.h),
          // Permission status banner (if denied)
          if (!_isCheckingPermission &&
              _permissionStatus != null &&
              !_permissionStatus!.isGranted)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 4.h),
              child: Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(
                    color: AppColors.info.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded, size: 18.w, color: AppColors.info),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'برای همگام‌سازی کامل مخاطبین گوشی، دسترسی را فعال کنید.',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: isDark ? AppColors.warmWhite : AppColors.lightTextPrimary,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        if (_permissionStatus!.isPermanentlyDenied) {
                          await openAppSettings();
                        } else {
                          await _requestPermission();
                        }
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        _permissionStatus!.isPermanentlyDenied ? 'تنظیمات' : 'اجازه دسترسی',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.info,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // Contacts List
          Expanded(
            child: _filteredContacts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_search_rounded,
                          size: 40.w,
                          color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'مخاطبی با این مشخصات یافت نشد',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
                    itemCount: _filteredContacts.length,
                    separatorBuilder: (_, _) => Divider(
                      height: 1,
                      color: isDark ? AppColors.darkBorder : AppColors.lightDivider,
                    ),
                    itemBuilder: (context, index) {
                      final contact = _filteredContacts[index];
                      return _ContactTile(
                        contact: contact,
                        isDark: isDark,
                        onTap: () {
                          Get.back();
                          widget.onContactSelected(
                            contact.name,
                            contact.phone,
                            contact.operatorId,
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final ContactItem contact;
  final bool isDark;
  final VoidCallback onTap;

  const _ContactTile({
    required this.contact,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final firstChar = contact.name.isNotEmpty ? contact.name.characters.first : '?';

    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 4.w),
      leading: Container(
        width: 40.w,
        height: 40.w,
        decoration: BoxDecoration(
          color: contact.avatarColor.withValues(alpha: isDark ? 0.22 : 0.15),
          shape: BoxShape.circle,
          border: Border.all(
            color: contact.avatarColor.withValues(alpha: 0.5),
            width: 1.2,
          ),
        ),
        child: Center(
          child: Text(
            firstChar,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: contact.avatarColor,
            ),
          ),
        ),
      ),
      title: Text(
        contact.name,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w700,
          color: isDark ? AppColors.warmWhite : AppColors.lightTextPrimary,
        ),
      ),
      subtitle: Text(
        _formatPhone(contact.phone),
        style: TextStyle(
          fontSize: 11.sp,
          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          letterSpacing: 0.5,
        ),
      ),
      trailing: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
        decoration: BoxDecoration(
          color: contact.avatarColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          border: Border.all(
            color: contact.avatarColor.withValues(alpha: 0.35),
            width: 0.8,
          ),
        ),
        child: Text(
          contact.operatorName,
          style: TextStyle(
            fontSize: 9.sp,
            fontWeight: FontWeight.w700,
            color: contact.avatarColor,
          ),
        ),
      ),
    );
  }

  String _formatPhone(String raw) {
    if (raw.length == 11 && raw.startsWith('09')) {
      return '${raw.substring(0, 4)} ${raw.substring(4, 7)} ${raw.substring(7)}';
    }
    return raw;
  }
}
