import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';
import 'package:qunzo_user/src/common/widgets/common_loading.dart';
import 'package:qunzo_user/src/presentation/screens/settings/controller/notification_controller.dart';
import 'package:qunzo_user/src/presentation/screens/settings/model/notifications_model.dart';
import 'package:qunzo_user/src/presentation/widgets/notification_dynamic_icon.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications>
    with WidgetsBindingObserver {
  final NotificationController controller = Get.find();
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    loadData();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        controller.hasMorePages.value &&
        !controller.isPageLoading.value) {
      controller.loadMoreNotifications();
    }
  }

  Future<void> loadData() async {
    controller.isLoading.value = true;
    await controller.fetchNotifications();
    controller.isLoading.value = false;
  }

  Future<void> refreshData() async {
    controller.isLoading.value = true;
    await controller.fetchNotifications();
    controller.isLoading.value = false;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: CommonDefaultAppBar(),
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 16),
              CommonAppBar(
                title: localization.notificationsScreenTitle,
                rightSideWidget: Padding(
                  padding: const EdgeInsetsDirectional.only(end: 18),
                  child: CommonButton(
                    onPressed: () => controller.markAsReadNotification(),
                    width: 100,
                    height: 30,
                    text: localization.notificationsMarkAllReadButton,
                    borderRadius: 8,
                    fontSize: 12,
                    backgroundColor: Color(0xFF7D5CFF),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Obx(
                () => Expanded(
                  child: RefreshIndicator(
                    color: AppColors.lightPrimary,
                    onRefresh: () => refreshData(),
                    child: Container(
                      margin: EdgeInsetsDirectional.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: const BorderRadiusDirectional.only(
                          topStart: Radius.circular(16),
                          topEnd: Radius.circular(16),
                        ),
                      ),
                      child: controller.isLoading.value
                          ? CommonLoading()
                          : ListView.builder(
                              controller: _scrollController,
                              itemBuilder: (context, index) {
                                final Notificationss notification = controller
                                    .notificationModel
                                    .value
                                    .data!
                                    .notifications![index];

                                return Container(
                                  decoration: notification.isRead == false
                                      ? BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              AppColors.lightPrimary.withValues(
                                                alpha: 0.01,
                                              ),
                                              AppColors.lightPrimary.withValues(
                                                alpha: 0.02,
                                              ),
                                              AppColors.lightPrimary.withValues(
                                                alpha: 0.09,
                                              ),
                                            ],
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                          ),
                                        )
                                      : BoxDecoration(),
                                  child: Column(
                                    children: [
                                      const SizedBox(height: 16),
                                      Padding(
                                        padding: const EdgeInsetsDirectional.symmetric(
                                          horizontal: 16,
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: 35,
                                              height: 35,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                child: Image.asset(
                                                  NotificationDynamicIcon.getNotificationIcon(
                                                    notification.type,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    notification.title ?? '',
                                                    style: TextStyle(
                                                      letterSpacing: 0,
                                                      overflow:
                                                          TextOverflow.visible,
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      fontSize: 15,
                                                      color: AppColors
                                                          .lightTextPrimary,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Text(
                                                    notification.message ?? '',
                                                    style: TextStyle(
                                                      letterSpacing: 0,
                                                      overflow:
                                                          TextOverflow.visible,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize: 13,
                                                      color: AppColors
                                                          .lightTextTertiary,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Text(
                                                    notification.createdAt ??
                                                        '',
                                                    style: TextStyle(
                                                      letterSpacing: 0,
                                                      overflow:
                                                          TextOverflow.visible,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 13,
                                                      color: AppColors
                                                          .lightTextTertiary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 16),
                                      Divider(
                                        height: 0,
                                        color: AppColors.lightTextPrimary
                                            .withValues(alpha: 0.10),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              itemCount: controller
                                  .notificationModel
                                  .value
                                  .data!
                                  .notifications!
                                  .length,
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Obx(
            () => Visibility(
              visible:
                  controller.isPageLoading.value ||
                  controller.isNotificationsLoading.value,
              child: CommonLoading(),
            ),
          ),
        ],
      ),
    );
  }
}
