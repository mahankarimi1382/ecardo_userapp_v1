import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/app/routes/routes.dart';
import 'package:qunzo_user/src/common/services/settings_service.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';
import 'package:qunzo_user/src/common/widgets/common_loading.dart';
import 'package:qunzo_user/src/presentation/screens/settings/controller/support_ticket_controller.dart';
import 'package:qunzo_user/src/presentation/screens/settings/model/support_ticket_model.dart';
import 'package:qunzo_user/src/presentation/screens/settings/view/support_tickets/replay_ticket/replay_ticket.dart';
import 'package:qunzo_user/src/presentation/screens/settings/view/support_tickets/sub_sections/ticket_details.dart';
import 'package:qunzo_user/src/presentation/widgets/no_data_found.dart';

class SupportTickets extends StatefulWidget {
  const SupportTickets({super.key});

  @override
  State<SupportTickets> createState() => _SupportTicketsState();
}

class _SupportTicketsState extends State<SupportTickets>
    with WidgetsBindingObserver {
  final SupportTicketController controller = Get.find();
  late ScrollController _scrollController;
  final SettingsService settingsService = Get.find();

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
      controller.loadMoreSupportTickets();
    }
  }

  Future<void> loadData() async {
    if (!controller.isInitialDataLoaded.value) {
      controller.isLoading.value = true;
      await controller.fetchSupportTickets();
      controller.isLoading.value = false;
      controller.isInitialDataLoaded.value = true;
    }
  }

  Future<void> refreshData() async {
    controller.isLoading.value = true;
    await controller.fetchSupportTickets();
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
      body: Obx(
        () => Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 16),
                CommonAppBar(title: localization.supportTicketsScreenTitle),
                _buildTransactionsList(),
              ],
            ),

            Visibility(
              visible: controller.isPageLoading.value,
              child: const CommonLoading(),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 40),
        child: SizedBox(
          height: 48,
          width: 150,
          child: FloatingActionButton(
            heroTag: null,
            elevation: 0,
            onPressed: () {
              Get.toNamed(BaseRoute.addNewTicket);
            },
            backgroundColor: AppColors.lightPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(PngAssets.addCommonIcon, width: 22),
                SizedBox(width: 5),
                Text(
                  localization.supportTicketsCreateTicketButton,
                  style: TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 15.5,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionsList() {
    final localization = AppLocalizations.of(context)!;
    final tickets = controller.supportTicketModel.value.data?.tickets ?? [];

    if (controller.isLoading.value) {
      return Expanded(child: CommonLoading());
    }

    if (tickets.isEmpty) {
      return Expanded(child: NoDataFound());
    }

    return Expanded(
      child: RefreshIndicator(
        color: AppColors.lightPrimary,
        onRefresh: () => refreshData(),
        child: controller.isLoading.value
            ? CommonLoading()
            : ListView.separated(
                physics: AlwaysScrollableScrollPhysics(),
                controller: _scrollController,
                padding: const EdgeInsetsDirectional.only(
                  start: 18,
                  end: 18,
                  bottom: 50,
                  top: 30,
                ),
                itemBuilder: (context, index) {
                  final Tickets ticket = tickets[index];

                  return InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Get.bottomSheet(TicketDetails(ticket: ticket));
                    },
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: AppColors.white,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "#${ticket.uuid ?? ""}",
                            style: TextStyle(
                              letterSpacing: 0,
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              color: AppColors.lightTextPrimary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      ticket.title ?? "",
                                      style: TextStyle(
                                        letterSpacing: 0,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 16,
                                        color: AppColors.lightTextPrimary,
                                      ),
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      "${ticket.canReply == true ? localization.supportTicketsLastUpdate : localization.supportTicketsRequestedAt}: "
                                      "${DateFormat("dd MMM,yyyy - hh:mm a").format(DateTime.parse(ticket.canReply == true ? ticket.updatedAt! : ticket.createdAt!))}",
                                      style: TextStyle(
                                        letterSpacing: 0,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                        color: AppColors.lightTextTertiary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsetsDirectional.symmetric(
                                  horizontal: 16,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: ticket.priority == "high"
                                      ? AppColors.lightPrimary.withValues(
                                          alpha: 0.10,
                                        )
                                      : ticket.priority == "medium"
                                      ? AppColors.warning.withValues(
                                          alpha: 0.10,
                                        )
                                      : ticket.priority == "low"
                                      ? AppColors.lightTextPrimary.withValues(
                                          alpha: 0.04,
                                        )
                                      : AppColors.transparent,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Text(
                                  ticket.priority == "high"
                                      ? localization.supportTicketsPriorityHigh
                                      : ticket.priority == "medium"
                                      ? localization
                                            .supportTicketsPriorityMedium
                                      : ticket.priority == "low"
                                      ? localization.supportTicketsPriorityLow
                                      : "",
                                  style: TextStyle(
                                    color: ticket.priority == "high"
                                        ? AppColors.lightPrimary
                                        : ticket.priority == "medium"
                                        ? AppColors.warning
                                        : ticket.priority == "low"
                                        ? AppColors.lightTextPrimary
                                        : AppColors.transparent,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            height: 1,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.white,
                                  AppColors.lightTextPrimary.withValues(
                                    alpha: 0.15,
                                  ),
                                  AppColors.white,
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    localization.supportTicketsStatus,
                                    style: TextStyle(
                                      letterSpacing: 0,
                                      fontSize: 14,
                                      color: AppColors.lightTextTertiary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    ticket.status == "open"
                                        ? localization.supportTicketsStatusOpen
                                        : localization
                                              .supportTicketsStatusClose,
                                    style: TextStyle(
                                      letterSpacing: 0,
                                      fontSize: 14,
                                      color: ticket.status == "open"
                                          ? AppColors.success
                                          : AppColors.error,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              CommonButton(
                                borderRadius: 8,
                                fontSize: 13,
                                text: localization.supportTicketsReplyButton,
                                onPressed: () {
                                  Get.to(
                                    () => ReplayTicket(
                                      ticketUid: ticket.uuid.toString(),
                                    ),
                                  );
                                },
                                width: 60,
                                height: 30,
                                fontWeight: FontWeight.w700,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemCount: tickets.length,
              ),
      ),
    );
  }
}
