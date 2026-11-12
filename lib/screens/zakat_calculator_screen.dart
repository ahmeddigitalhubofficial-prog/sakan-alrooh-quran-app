// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:provider/provider.dart';

import '../models/theme_manager.dart';

class ZakatCalculatorScreen extends StatefulWidget {
  const ZakatCalculatorScreen({super.key});

  @override
  State<ZakatCalculatorScreen> createState() => _ZakatCalculatorScreenState();
}

class _ZakatCalculatorScreenState extends State<ZakatCalculatorScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Controllers for Money Zakat
  final TextEditingController _cashController = TextEditingController();
  final TextEditingController _bankController = TextEditingController();
  final TextEditingController _loansToOthersController = TextEditingController();
  final TextEditingController _debtsController = TextEditingController();

  // Controllers for Gold & Silver Zakat
  final TextEditingController _gold24Controller = TextEditingController();
  final TextEditingController _gold21Controller = TextEditingController();
  final TextEditingController _gold18Controller = TextEditingController();
  final TextEditingController _silverController = TextEditingController();
  final TextEditingController _goldPricePerGramController = TextEditingController(text: '3600'); // السعر الافتراضي للجرام

  // Controllers for Trade & Business
  final TextEditingController _goodsController = TextEditingController();
  final TextEditingController _tradeCashController = TextEditingController();

  // Controllers for Zakat al-Fitr
  int _familyMembers = 1;
  final double _fitrPerPerson = 35.0; // بالجنيه

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _cashController.dispose();
    _bankController.dispose();
    _loansToOthersController.dispose();
    _debtsController.dispose();
    _gold24Controller.dispose();
    _gold21Controller.dispose();
    _gold18Controller.dispose();
    _silverController.dispose();
    _goldPricePerGramController.dispose();
    _goodsController.dispose();
    _tradeCashController.dispose();
    super.dispose();
  }

  double _parse(TextEditingController controller) {
    final text = controller.text.trim().replaceAll(',', '');
    return double.tryParse(text) ?? 0.0;
  }

  // 1. حساب زكاة المال
  double get _totalMoneyAssets => _parse(_cashController) + _parse(_bankController) + _parse(_loansToOthersController) - _parse(_debtsController);
  double get _goldPrice => _parse(_goldPricePerGramController);
  double get _moneyNisab => 85 * (_goldPrice > 0 ? _goldPrice : 3600); // 85 جرام عيار 21
  bool get _isMoneyNisabReached => _totalMoneyAssets >= _moneyNisab;
  double get _moneyZakat => _isMoneyNisabReached ? (_totalMoneyAssets * 0.025) : 0.0;

  // 2. حساب زكاة الذهب والفضة
  double get _totalGoldGrams21Equivalent =>
      (_parse(_gold24Controller) * 24 / 21) +
      _parse(_gold21Controller) +
      (_parse(_gold18Controller) * 18 / 21);

  bool get _isGoldNisabReached => _totalGoldGrams21Equivalent >= 85.0;
  double get _goldZakatValue => _isGoldNisabReached ? (_totalGoldGrams21Equivalent * _goldPrice * 0.025) : 0.0;
  double get _goldZakatGrams => _isGoldNisabReached ? (_totalGoldGrams21Equivalent * 0.025) : 0.0;

  // 3. حساب زكاة التجارة
  double get _totalTradeAssets => _parse(_goodsController) + _parse(_tradeCashController);
  bool get _isTradeNisabReached => _totalTradeAssets >= _moneyNisab;
  double get _tradeZakat => _isTradeNisabReached ? (_totalTradeAssets * 0.025) : 0.0;

  // 4. زكاة الفطر
  double get _fitrTotalZakat => _familyMembers * _fitrPerPerson;

  final NumberFormat _fmt = NumberFormat('#,##0.00', 'ar');

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<AppThemeManager>(context).currentTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'حاسبة الزكاة الذكية 💰',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16.sp),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            // Tabs
            TabBar(
              controller: _tabController,
              indicatorColor: theme.accentColor,
              labelColor: theme.accentColor,
              unselectedLabelColor: theme.subtitleColor,
              labelStyle: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 12.sp),
              tabs: const [
                Tab(text: '💵 زكاة المال'),
                Tab(text: '🥇 الذهب والفضة'),
                Tab(text: '🏪 عروض التجارة'),
                Tab(text: '🌾 زكاة الفطر'),
              ],
            ),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildMoneyZakatTab(theme),
                  _buildGoldZakatTab(theme),
                  _buildTradeZakatTab(theme),
                  _buildFitrZakatTab(theme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== 1. Money Zakat ====================
  Widget _buildMoneyZakatTab(AppTheme theme) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildResultCard(
            title: 'مقدار زكاة المال الواجبة (2.5%)',
            zakatAmount: _moneyZakat,
            isNisabReached: _isMoneyNisabReached,
            nisabText: 'النصاب الشرعي: ${_fmt.format(_moneyNisab)} ج.م (ما يعادل 85 جرام ذهب)',
            theme: theme,
          ),
          SizedBox(height: 16.h),
          _buildInputField('سعر جرام الذهب عيار 21 اليوم (ج.م)', _goldPricePerGramController, theme),
          _buildInputField('النقود السائلة والمدخرات النقدية', _cashController, theme),
          _buildInputField('الأرصدة البنكية والودائع', _bankController, theme),
          _buildInputField('أموال لك مرجوة السداد عند الغير', _loansToOthersController, theme),
          _buildInputField('ديون واجبة السداد عليك (تُخصم)', _debtsController, theme),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  // ==================== 2. Gold & Silver Zakat ====================
  Widget _buildGoldZakatTab(AppTheme theme) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildResultCard(
            title: 'مقدار زكاة الذهب الواجبة',
            zakatAmount: _goldZakatValue,
            customSubtext: _isGoldNisabReached ? 'الوزن الواجب إخراجه: ${_goldZakatGrams.toStringAsFixed(2)} جرام عيار 21' : null,
            isNisabReached: _isGoldNisabReached,
            nisabText: 'نصاب الذهب الشرعي: 85 جرام (عيار 21 أو ما يعادله)',
            theme: theme,
          ),
          SizedBox(height: 16.h),
          _buildInputField('سعر جرام الذهب عيار 21 اليوم (ج.م)', _goldPricePerGramController, theme),
          _buildInputField('وزن الذهب عيار 24 (جرام)', _gold24Controller, theme),
          _buildInputField('وزن الذهب عيار 21 (جرام)', _gold21Controller, theme),
          _buildInputField('وزن الذهب عيار 18 (جرام)', _gold18Controller, theme),
          _buildInputField('وزن الفضة المدخرة (جرام - النصاب 595 جرام)', _silverController, theme),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  // ==================== 3. Trade Zakat ====================
  Widget _buildTradeZakatTab(AppTheme theme) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildResultCard(
            title: 'مقدار زكاة عروض التجارة (2.5%)',
            zakatAmount: _tradeZakat,
            isNisabReached: _isTradeNisabReached,
            nisabText: 'النصاب الشرعي: ${_fmt.format(_moneyNisab)} ج.م',
            theme: theme,
          ),
          SizedBox(height: 16.h),
          _buildInputField('قيمة البضائع المعدة للبيع بسعر السوق الحالي', _goodsController, theme),
          _buildInputField('السيولة النقدية المتوفرة في التجارة', _tradeCashController, theme),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  // ==================== 4. Zakat al-Fitr ====================
  Widget _buildFitrZakatTab(AppTheme theme) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildResultCard(
            title: 'إجمالي زكاة الفطر الواجبة',
            zakatAmount: _fitrTotalZakat,
            isNisabReached: true,
            nisabText: 'تُخرج عن النفس وعن كل من تلزمك نفقته قبل صلاة العيد',
            theme: theme,
          ),
          SizedBox(height: 20.h),
          Container(
            padding: EdgeInsets.all(18.w),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: theme.dividerColor.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'عدد أفراد الأسرة المكلف بالإنفاق عليهم:',
                  style: GoogleFonts.cairo(color: theme.textColor, fontWeight: FontWeight.bold, fontSize: 13.sp),
                ),
                SizedBox(height: 14.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$_familyMembers أفراد',
                      style: GoogleFonts.cairo(color: theme.accentColor, fontWeight: FontWeight.bold, fontSize: 20.sp),
                    ),
                    Row(
                      children: [
                        IconButton.filled(
                          onPressed: () {
                            if (_familyMembers > 1) {
                              setState(() => _familyMembers--);
                            }
                          },
                          icon: const Icon(Icons.remove),
                          style: IconButton.styleFrom(backgroundColor: Colors.white12),
                        ),
                        SizedBox(width: 8.w),
                        IconButton.filled(
                          onPressed: () {
                            setState(() => _familyMembers++);
                          },
                          icon: const Icon(Icons.add),
                          style: IconButton.styleFrom(backgroundColor: theme.accentColor, foregroundColor: Colors.black),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildResultCard({
    required String title,
    required double zakatAmount,
    required bool isNisabReached,
    required String nisabText,
    String? customSubtext,
    required AppTheme theme,
  }) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        gradient: LinearGradient(
          colors: [theme.primaryColor, theme.cardColor],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        border: Border.all(
          color: isNisabReached ? const Color(0xFF00E676).withValues(alpha: 0.5) : theme.accentColor.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: GoogleFonts.cairo(color: Colors.white70, fontSize: 13.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            '${_fmt.format(zakatAmount)} ج.م',
            style: GoogleFonts.cairo(
              color: isNisabReached ? const Color(0xFF69F0AE) : Colors.white,
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (customSubtext != null) ...[
            SizedBox(height: 4.h),
            Text(customSubtext, style: GoogleFonts.cairo(color: Colors.amberAccent, fontSize: 12.sp, fontWeight: FontWeight.bold)),
          ],
          SizedBox(height: 10.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: isNisabReached ? const Color(0xFF0F5A3E).withValues(alpha: 0.4) : Colors.orange.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              isNisabReached ? 'بلغ النصاب الشرعي وتجب فيه الزكاة ✓' : 'لم يبلغ النصاب الشرعي بعد (لا تجب فيه الزكاة)',
              style: GoogleFonts.cairo(
                color: isNisabReached ? const Color(0xFF69F0AE) : Colors.orangeAccent,
                fontWeight: FontWeight.bold,
                fontSize: 11.sp,
              ),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            nisabText,
            style: GoogleFonts.cairo(color: Colors.white54, fontSize: 10.sp),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, AppTheme theme) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: GoogleFonts.cairo(color: theme.textColor, fontWeight: FontWeight.bold, fontSize: 14.sp),
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.cairo(color: theme.subtitleColor, fontSize: 12.sp),
          filled: true,
          fillColor: theme.cardColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide(color: theme.dividerColor.withValues(alpha: 0.2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide(color: theme.accentColor, width: 1.5),
          ),
        ),
      ),
    );
  }
}
