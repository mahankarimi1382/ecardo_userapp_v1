import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/presentation/screens/home/controller/home_controller.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/presentation/screens/home/view/sub_sections/drop_down/recent_transaction_details.dart';
import 'package:ecardo_user/src/presentation/screens/home/view/sub_sections/section_header.dart';
import 'package:ecardo_user/src/presentation/screens/transactions/model/transactions_model.dart';
import 'package:ecardo_user/src/presentation/widgets/empty_view.dart';
import 'package:ecardo_user/src/helper/responsive.dart';
import 'package:ecardo_user/src/helper/jalali_date_helper.dart';

class RecentTransactionsSection extends StatelessWidget {
  const RecentTransactionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController homeController = Get.find<HomeController>();

    return Obx(() {
      final txList = homeController.transactionsModel.value.data?.transactions ?? [];

      return Column(
        children: [
          SectionHeader(
            sectionName: l10nPick(
              context,
              en: 'Recent Transactions',
              fa: 'تراکنش‌های اخیر',
              ar: 'المعاملات الأخيرة',
              zh: '近期交易记录',
              ru: 'Недавние транзакции',
              tr: 'Son İşlemler',
            ),
            onTap: () => Get.toNamed(BaseRoute.transactions),
          ),
          const SizedBox(height: 12),
          txList.isEmpty
              ? EmptyView(
                  icon: Icons.receipt_long_outlined,
                  title: l10nPick(
                    context,
                    en: 'No transactions yet',
                    fa: 'هنوز تراکنشی ندارید',
                    ar: 'لا توجد معاملات بعد',
                    zh: '暂无交易记录',
                    ru: 'Пока нет транзакций',
                    tr: 'Henüz işlem yok',
                  ),
                  subtitle: l10nPick(
                    context,
                    en: 'Make your first deposit or transfer and it will show up here.',
                    fa: 'اولین واریز یا انتقال خود را انجام دهید تا تاریخچه اینجا نمایش داده شود.',
                    ar: 'قم بأول إيداع أو تحويل وسيظهر هنا.',
                    zh: '完成第一笔充值或转账后，记录会显示在这里。',
                    ru: 'Совершите первое пополнение или перевод, и он отобразится здесь.',
                    tr: 'İlk para yatırma veya transferinizi yapın, burada görünecektir.',
                  ),
                  ctaLabel: l10nPick(
                    context,
                    en: 'First transaction',
                    fa: 'اولین تراکنش',
                    ar: 'أول معاملة',
                    zh: '立即交易',
                    ru: 'Первая операция',
                    tr: 'İlk İşlem',
                  ),
                  onCta: () => Get.toNamed(BaseRoute.transfer),
                )
              : Container(
                  margin: EdgeInsetsDirectional.symmetric(
                    horizontal: Responsive.pagePadding(context),
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.r),
                    color: Theme.of(context).cardColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListView.separated(
                    padding: EdgeInsetsDirectional.symmetric(vertical: 8.h),
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: txList.length > 5 ? 5 : txList.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      thickness: 0.8,
                      indent: 70.w,
                      endIndent: 16.w,
                      color: Colors.grey.withValues(alpha: 0.12),
                    ),
                    itemBuilder: (context, index) {
                      final Transactions transaction = txList[index];
                      final visual = _getVisual(context, transaction.type);
                      final isPlus = transaction.isPlus == true;
                      final isDark =
                          Theme.of(context).brightness == Brightness.dark;

                      return InkWell(
                        onTap: () {
                          Get.bottomSheet(
                            RecentTransactionDetails(transaction: transaction),
                          );
                        },
                        borderRadius: BorderRadius.circular(16.r),
                        child: Padding(
                          padding: EdgeInsetsDirectional.symmetric(
                            vertical: 12.h,
                            horizontal: 16.w,
                          ),
                          child: Row(
                            children: [
                              // 1. Sleek category icon container
                              Container(
                                width: 44.r,
                                height: 44.r,
                                decoration: BoxDecoration(
                                  color: visual.bgColor,
                                  borderRadius: BorderRadius.circular(14.r),
                                ),
                                child: Icon(
                                  visual.icon,
                                  color: visual.iconColor,
                                  size: 22.sp,
                                ),
                              ),
                              SizedBox(width: 14.w),

                              // 2. Localized title and human-friendly date
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      visual.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        letterSpacing: 0,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14.sp,
                                        color: isDark
                                            ? AppColors.darkTextPrimary
                                            : AppColors.lightTextPrimary,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Row(
                                      children: [
                                        Text(
                                          JalaliDateHelper.format(transaction.createdAt),
                                          style: TextStyle(
                                            letterSpacing: 0,
                                            fontSize: 11.5.sp,
                                            color: isDark
                                                ? AppColors.darkTextSecondary
                                                : AppColors.lightTextTertiary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 5.w),
                                          child: Text(
                                            '•',
                                            style: TextStyle(
                                              fontSize: 10.sp,
                                              color: Colors.grey.shade400,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 6.w,
                                            vertical: 2.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.green.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(6.r),
                                          ),
                                          child: Text(
                                            l10nPick(
                                              context,
                                              en: 'Success',
                                              fa: 'موفق',
                                              ar: 'ناجح',
                                              zh: '成功',
                                              ru: 'Успешно',
                                              tr: 'Başarılı',
                                            ),
                                            style: TextStyle(
                                              fontSize: 9.5.sp,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.green.shade700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // 3. Formatted currency amount with tabular figures
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Directionality(
                                    textDirection: TextDirection.ltr,
                                    child: Text(
                                      '${isPlus ? '+' : '-'}${transaction.isCrypto == true ? '' : (transaction.trxCurrencySymbol ?? '\$')} ${transaction.amount ?? '0.00'}${transaction.isCrypto == true ? ' ${transaction.trxCurrencyCode}' : ''}',
                                      style: TextStyle(
                                        letterSpacing: 0.2,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 14.5.sp,
                                        fontFeatures: const [
                                          FontFeature.tabularFigures(),
                                        ],
                                        color: isPlus
                                            ? const Color(0xFF16A34A) // Luxury emerald green
                                            : const Color(0xFFDC2626), // Crisp crimson
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ],
      );
    });
  }

  static _TxVisual _getVisual(BuildContext context, String? type) {
    switch (type?.toLowerCase()) {
      case 'deposit':
      case 'add_money':
        return _TxVisual(
          title: l10nPick(
            context,
            en: 'Deposit to Wallet',
            fa: 'واریز به کیف‌پول',
            ar: 'إيداع في المحفظة',
            zh: '充值到钱包',
            ru: 'Пополнение кошелька',
            tr: 'Cüzdana Para Yatırma',
          ),
          icon: Icons.south_west_rounded,
          iconColor: const Color(0xFF16A34A),
          bgColor: const Color(0xFFDCFCE7),
        );
      case 'virtual_card':
        return _TxVisual(
          title: l10nPick(
            context,
            en: 'Virtual Card Payment',
            fa: 'پرداخت با کارت اعتباری',
            ar: 'دفع بالبطاقة الافتراضية',
            zh: '虚拟卡支付',
            ru: 'Оплата виртуальной картой',
            tr: 'Sanal Kart Ödemesi',
          ),
          icon: Icons.credit_card_rounded,
          iconColor: const Color(0xFF7C3AED),
          bgColor: const Color(0xFFF3E8FF),
        );
      case 'exchange':
        return _TxVisual(
          title: l10nPick(
            context,
            en: 'Currency Exchange',
            fa: 'تبدیل ارز آنی',
            ar: 'صرف العملات',
            zh: '即时货币兑换',
            ru: 'Обмен валюты',
            tr: 'Döviz Dönüşümü',
          ),
          icon: Icons.currency_exchange_rounded,
          iconColor: const Color(0xFF0284C7),
          bgColor: const Color(0xFFE0F2FE),
        );
      case 'transfer':
        return _TxVisual(
          title: l10nPick(
            context,
            en: 'Money Transfer',
            fa: 'انتقال وجه بین‌الملل',
            ar: 'تحويل أموال',
            zh: '跨境转账',
            ru: 'Перевод средств',
            tr: 'Para Transferi',
          ),
          icon: Icons.north_east_rounded,
          iconColor: const Color(0xFFEA580C),
          bgColor: const Color(0xFFFFEDD5),
        );
      case 'withdraw':
      case 'cash_out':
        return _TxVisual(
          title: l10nPick(
            context,
            en: 'Withdrawal',
            fa: 'برداشت وجه',
            ar: 'سحب أموال',
            zh: '账户提现',
            ru: 'Вывод средств',
            tr: 'Para Çekme',
          ),
          icon: Icons.arrow_upward_rounded,
          iconColor: const Color(0xFFE11D48),
          bgColor: const Color(0xFFFFE4E6),
        );
      default:
        return _TxVisual(
          title: type ??
              l10nPick(
                context,
                en: 'Transaction',
                fa: 'تراکنش مالی',
                ar: 'معاملة مالية',
                zh: '财务交易',
                ru: 'Транзакция',
                tr: 'İşlem',
              ),
          icon: Icons.receipt_long_rounded,
          iconColor: const Color(0xFF475569),
          bgColor: const Color(0xFFF1F5F9),
        );
    }
  }
}

class _TxVisual {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;

  const _TxVisual({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
  });
}
