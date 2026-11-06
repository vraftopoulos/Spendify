import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:home_widget/home_widget.dart';
import 'database_helper.dart';



void main() {
  runApp(const ExpenseTrackerApp());
}

// ==========================================
// ΔΙΑΧΕΙΡΙΣΗ ΓΛΩΣΣΑΣ & ΜΕΤΑΦΡΑΣΕΙΣ
// ==========================================
class LanguageNotifier extends ValueNotifier<Locale> {
  LanguageNotifier() : super(const Locale('el', 'GR'));

  void changeLanguage(String code) {
    value = Locale(code);
  }
}

final languageNotifier = LanguageNotifier();

Map<String, Map<String, String>> localizedTexts = {
  'el': {
    'app_title': 'Επισκόπηση',
    'total_balance': 'ΣΥΝΟΛΙΚΟ ΥΠΟΛΟΙΠΟ',
    'income': 'Έσοδα',
    'expense': 'Έξοδα',
    'recent': 'Πρόσφατες',
    'view_all': 'Προβολή όλων',
    'no_recent': 'Δεν υπάρχουν πρόσφατες καταχωρήσεις.',
    'new_entry': 'Καταχώρηση',
    'add_title': 'Νέα Καταχώρηση',
    'title_label': 'Τίτλος / Περιγραφή',
    'amount_label': 'Ποσό (€)',
    'save': 'Αποθήκευση',
    'saved_msg': 'Αποθηκεύτηκε',
    'err_msg': 'Συμπληρώστε τίτλο και ποσό!',
    'all_title': 'Όλες οι Συναλλαγές',
    'search_hint': 'Αναζήτηση ή Group τίτλου...',
    'date_filter': 'Φίλτρο Ημερομηνίας',
    'no_entries': 'Δεν βρέθηκαν εγγραφές.',
    'settings_title': 'Ρυθμίσεις',
    'language_select': 'Επιλογή Γλώσσας',
    'greek': 'Ελληνικά',
    'english': 'English',
  },
  'en': {
    'app_title': 'Overview',
    'total_balance': 'TOTAL BALANCE',
    'income': 'Income',
    'expense': 'Expenses',
    'recent': 'Recent',
    'view_all': 'View All',
    'no_recent': 'No recent transactions found.',
    'new_entry': 'Add New',
    'add_title': 'New Entry',
    'title_label': 'Title / Description',
    'amount_label': 'Amount (€)',
    'save': 'Save',
    'saved_msg': 'Saved',
    'err_msg': 'Please enter title and valid amount!',
    'all_title': 'All Transactions',
    'search_hint': 'Search or title group...',
    'date_filter': 'Date Filter',
    'no_entries': 'No transactions found.',
    'settings_title': 'Settings',
    'language_select': 'Select Language',
    'greek': 'Ελληνικά',
    'english': 'English',
  }
};

String tr(String key) {
  final lang = languageNotifier.value.languageCode;
  return localizedTexts[lang]?[key] ?? key;
}

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: languageNotifier,
      builder: (context, locale, child) {
        return MaterialApp(
          title: 'Expense Tracker',
          debugShowCheckedModeBanner: false,
          locale: locale,
          supportedLocales: const [
            Locale('el', 'GR'),
            Locale('en', 'US'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: ThemeData(
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFFF8F9FA),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF0F172A),
              primary: const Color(0xFF0F172A),
              surface: Colors.white,
            ),
          ),
          home: const HomeScreen(),
        );
      },
    );
  }
}

// ==========================================
// 1. ΑΡΧΙΚΗ ΟΘΟΝΗ (Home Screen)
// ==========================================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List _recentTransactions = [];
  double _totalBalance = 0.0;
  double _totalIncome = 0.0;
  double _totalExpense = 0.0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }


  Future<void> _loadData() async {
    final all = await DatabaseHelper.instance.getAllTransactions();
    final recent = await DatabaseHelper.instance.getRecentTransactions();

    double income = 0.0;
    double expense = 0.0;

    for (var item in all) {
      double amt = (item['amount'] as num).toDouble();
      if (item['type'] == 'INCOME') {
        income += amt;
      } else {
        expense += amt;
      }
    }

    setState(() {
      _recentTransactions = recent;
      _totalIncome = income;
      _totalExpense = expense;
      _totalBalance = income - expense;
    });

    await HomeWidget.saveWidgetData<String>(
      'total_balance',
      '${_totalBalance.toStringAsFixed(2)} €',
    );
    await HomeWidget.updateWidget(
      name: 'ExpenseWidget',
      androidName: 'ExpenseWidget',
    );
  }


  void _openSettingsDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(tr('settings_title')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tr('language_select'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ListTile(
                title: Text(tr('greek')),
                leading: Radio<String>(
                  value: 'el',
                  groupValue: languageNotifier.value.languageCode,
                  onChanged: (val) {
                    if (val != null) {
                      languageNotifier.changeLanguage(val);
                      Navigator.pop(ctx);
                    }
                  },
                ),
              ),
              ListTile(
                title: Text(tr('english')),
                leading: Radio<String>(
                  value: 'en',
                  groupValue: languageNotifier.value.languageCode,
                  onChanged: (val) {
                    if (val != null) {
                      languageNotifier.changeLanguage(val);
                      Navigator.pop(ctx);
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 32,
              width: 32,
            ),
            const SizedBox(width: 10),
            Text(
              tr('app_title'),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Color(0xFF0F172A)),
            onPressed: _openSettingsDialog,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Premium Balance Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr('total_balance'),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_totalBalance.toStringAsFixed(2)} €',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: _buildMiniStat(
                            title: tr('income'),
                            amount: _totalIncome,
                            icon: Icons.arrow_downward_rounded,
                            color: const Color(0xFF10B981),
                          ),
                        ),
                        Container(height: 30, width: 1, color: Colors.white24),
                        Expanded(
                          child: _buildMiniStat(
                            title: tr('expense'),
                            amount: _totalExpense,
                            icon: Icons.arrow_upward_rounded,
                            color: const Color(0xFFF43F5E),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    tr('recent'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (ctx) => const AllTransactionsScreen(),
                        ),
                      );
                      _loadData();
                    },
                    child: Text(
                      tr('view_all'),
                      style: const TextStyle(
                        color: Color(0xFF2563EB),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              _recentTransactions.isEmpty
                  ? Container(
                      height: 180,
                      alignment: Alignment.center,
                      child: Text(
                        tr('no_recent'),
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _recentTransactions.length,
                      itemBuilder: (ctx, index) {
                        final item = _recentTransactions[index];
                        return _buildTransactionCard(item);
                      },
                    ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (ctx) => const AddTransactionScreen(),
            ),
          );
          _loadData();
        },
        elevation: 4,
        icon: const Icon(Icons.add_rounded, size: 24),
        label: Text(
          tr('new_entry'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }

  Widget _buildMiniStat({
    required String title,
    required double amount,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.7)),
            ),
            Text(
              '${amount.toStringAsFixed(2)} €',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> item) {
    final isExpense = item['type'] == 'EXPENSE';
    final accentColor = isExpense ? const Color(0xFFF43F5E) : const Color(0xFF10B981);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isExpense ? Icons.north_east_rounded : Icons.south_west_rounded,
              color: accentColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item['date'].toString().split('T').first,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          Text(
            '${isExpense ? "-" : "+"}${item['amount']} €',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: accentColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 2. ΟΘΟΝΗ ΚΑΤΑΧΩΡΗΣΗΣ (Add Transaction)
// ==========================================
class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  String _transactionType = 'EXPENSE';

  void _submitData() async {
    final title = _titleController.text.trim();
    final amount = double.tryParse(_amountController.text) ?? 0.0;

    if (title.isEmpty || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr('err_msg')),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final newTransaction = {
      'title': title,
      'amount': amount,
      'type': _transactionType,
      'date': DateTime.now().toIso8601String(),
    };

    await DatabaseHelper.instance.insertTransaction(newTransaction);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(tr('saved_msg')),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isExpense = _transactionType == 'EXPENSE';

    return Scaffold(
      appBar: AppBar(
        title: Text(tr('add_title'), style: const TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetectOption(
                      title: tr('expense'),
                      isSelected: isExpense,
                      color: const Color(0xFFF43F5E),
                      onTap: () => setState(() => _transactionType = 'EXPENSE'),
                    ),
                  ),
                  Expanded(
                    child: GestureDetectOption(
                      title: tr('income'),
                      isSelected: !isExpense,
                      color: const Color(0xFF10B981),
                      onTap: () => setState(() => _transactionType = 'INCOME'),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: tr('title_label'),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.edit_note_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: tr('amount_label'),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.euro_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const Spacer(),

            ElevatedButton(
              onPressed: _submitData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                elevation: 2,
              ),
              child: Text(
                tr('save'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GestureDetectOption extends StatelessWidget {
  final String title;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const GestureDetectOption({
    super.key,
    required this.title,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)]
              : [],
        ),
        child: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected ? color : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 3. ΟΘΟΝΗ ΟΛΩΝ ΤΩΝ ΣΥΝΑΛΛΑΓΩΝ & ΦΙΛΤΡΑ
// ==========================================
class AllTransactionsScreen extends StatefulWidget {
  const AllTransactionsScreen({super.key});

  @override
  State<AllTransactionsScreen> createState() => _AllTransactionsScreenState();
}

class _AllTransactionsScreenState extends State<AllTransactionsScreen> {
  List _allTransactions = [];
  List _filteredTransactions = [];

  String _searchGroupTitle = '';
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    final data = await DatabaseHelper.instance.getAllTransactions();
    setState(() {
      _allTransactions = data;
      _applyFilters();
    });
  }

  void _applyFilters() {
    setState(() {
      _filteredTransactions = _allTransactions.where((item) {
        final matchesTitle = item['title']
            .toString()
            .toLowerCase()
            .contains(_searchGroupTitle.toLowerCase());

        bool matchesDate = true;
        if (_selectedDateRange != null) {
          final itemDate = DateTime.parse(item['date']);
          matchesDate = itemDate.isAfter(_selectedDateRange!.start.subtract(const Duration(days: 1))) &&
              itemDate.isBefore(_selectedDateRange!.end.add(const Duration(days: 1)));
        }

        return matchesTitle && matchesDate;
      }).toList();
    });
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      locale: languageNotifier.value,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _selectedDateRange,
    );

    if (picked != null) {
      setState(() => _selectedDateRange = picked);
      _applyFilters();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('all_title'), style: const TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: tr('search_hint'),
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) {
                _searchGroupTitle = val;
                _applyFilters();
              },
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickDateRange,
                    icon: const Icon(Icons.calendar_today_rounded, size: 16),
                    label: Text(
                      _selectedDateRange == null
                          ? tr('date_filter')
                          : '${_selectedDateRange!.start.toString().split(' ').first} - ${_selectedDateRange!.end.toString().split(' ').first}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                if (_selectedDateRange != null)
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.red),
                    onPressed: () {
                      setState(() => _selectedDateRange = null);
                      _applyFilters();
                    },
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _filteredTransactions.isEmpty
                  ? Center(
                      child: Text(tr('no_entries'), style: TextStyle(color: Colors.grey.shade500)),
                    )
                  : ListView.builder(
                      itemCount: _filteredTransactions.length,
                      itemBuilder: (ctx, index) {
                        final item = _filteredTransactions[index];
                        final isExpense = item['type'] == 'EXPENSE';
                        final accentColor = isExpense ? const Color(0xFFF43F5E) : const Color(0xFF10B981);

                        return Dismissible(
                          key: Key(item['id'].toString()),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.only(right: 20),
                            alignment: Alignment.centerRight,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF43F5E),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24),
                          ),
                          onDismissed: (_) async {
                            await DatabaseHelper.instance.deleteTransaction(item['id']);
                            _loadAll();
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: accentColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(
                                    isExpense ? Icons.north_east_rounded : Icons.south_west_rounded,
                                    color: accentColor,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['title'],
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                      ),
                                      Text(
                                        item['date'].toString().split('T').first,
                                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${isExpense ? "-" : "+"}${item['amount']} €',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: accentColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}