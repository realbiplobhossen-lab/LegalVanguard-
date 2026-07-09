import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:firebase_core/firebase_core.dart';
import 'database_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LegalVanguardApp());
  Firebase.initializeApp().catchError((error) => print("Firebase Error: $error"));
}

class LegalVanguardApp extends StatelessWidget {
  const LegalVanguardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LegisMate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF0A192F), 
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0A192F),
          primary: const Color(0xFF0A192F),
          secondary: const Color(0xFFD4AF37), 
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F6F9),
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const CaseManagementScreen(),
    const LegalLibraryScreen(),
    const ChamberToolsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_rounded), label: 'ড্যাশবোর্ড'),
          NavigationDestination(icon: Icon(Icons.gavel_rounded), label: 'কেস ডায়েরি'),
          NavigationDestination(icon: Icon(Icons.menu_book_rounded), label: 'আইন লাইব্রেরি'),
          NavigationDestination(icon: Icon(Icons.business_center_rounded), label: 'চেম্বারツール'),
        ],
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DatabaseService _dbService = DatabaseService();
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _voiceText = "সিনিয়র প্রতিদিন সকালে মোবাইল মুখের সামনে নিয়ে যা বলবেন (যেমন: আজকের হাজিরা, কজ লিস্ট, পিটিশন, ফাইল রেডি), তা এখানে হুবহু টাইপ হবে...";

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          localeId: "bn_BD",
          onResult: (val) => setState(() => _voiceText = val.recognizedWords),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
      if (_voiceText.isNotEmpty && !_voiceText.startsWith("সিনিয়র প্রতিদিন")) {
        await _dbService.saveTodayTask(_voiceText);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('সিনিয়রের ভয়েস নোট "আজকের করণীয় কাজ" তালিকায় সেভ হয়েছে!')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LegisMate ড্যাশবোর্ড', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0A192F),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.security, color: Color(0xFFD4AF37)), onPressed: () {}), 
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0A192F),
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('DIGITAL LEGAL CHAMBER', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 12, fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                  Text('আজকের লক্ষ্য: সততা, নিষ্ঠা ও দক্ষতা', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text('📊 কুইক ওভারভিউ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0A192F))),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.1,
              children: [
                _buildCountCard('আজকের কজ লিস্ট', '৮ টি', Colors.blue.shade800),
                _buildCountCard('জরুরি কাজ', '৩ টি', Colors.red.shade700),
                // এখানে Colors.emerald ফিক্স করে Colors.teal করা হয়েছে
                _buildCountCard('বকেয়া ফি', '৳৪৫,০০০', Colors.teal.shade800),
              ],
            ),
            const SizedBox(height: 25),

            const Text('🎙️ সিনিয়রের মর্নিং ভয়েস নির্দেশিকা (অটো টেক্সট)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0A192F))),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              // এখানে সরাসরি minHeight ফিক্স করে constraints ব্যবহার করা হয়েছে
              constraints: const BoxConstraints(minHeight: 120),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _isListening ? Colors.red : Colors.grey.shade300, width: 1.5),
              ),
              child: SingleChildScrollView(
                child: Text(_voiceText, style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.4, fontWeight: _isListening ? FontWeight.bold : FontWeight.normal)),
              ),
            ),
            const SizedBox(height: 15),
            Center(
              child: Column(
                children: [
                  FloatingActionButton.large(
                    onPressed: _listen,
                    backgroundColor: _isListening ? Colors.red : const Color(0xFF0A192F),
                    child: Icon(_isListening ? Icons.stop : Icons.mic, size: 36, color: const Color(0xFFD4AF37)),
                  ),
                  const SizedBox(height: 8),
                  Text(_isListening ? 'রেকর্ড হচ্ছে... সিনিয়রের কথা শেষ হলে বন্ধ করুন' : 'সকালে সিনিয়রের নির্দেশনা রেকর্ড করতে চাপুন', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountCard(String title, String count, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(count, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class CaseManagementScreen extends StatelessWidget {
  const CaseManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('কেস ও মক্কেল ডায়েরি', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0A192F),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildMenuTile(Icons.folder_shared_rounded, 'Case Management', 'Case Title, No, Court, Timeline, Evidence, Order', () {}),
          _buildMenuTile(Icons.assignment_ind_rounded, 'Client Management', 'ছবি, NID, বকেয়া, WhatsApp Shortcut, Call Button', () {}),
          _buildMenuTile(Icons.calendar_month_rounded, 'Court Diary & Reminders', 'Daily, Court & Judge Wise Diary, Limitation Calculator', () {}),
          _buildMenuTile(Icons.analytics_rounded, 'AI Timeline & Evidence Manager', 'পুরো কেস টাইমলাইন এবং এক্সিবিট নাম্বার ট্র্যাকিং', () {}),
        ],
      ),
    );
  }

  Widget _buildMenuTile(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: const Color(0xFF0A192F), child: Icon(icon, color: const Color(0xFFD4AF37))),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
        onTap: onTap,
      ),
    );
  }
}

class LegalLibraryScreen extends StatelessWidget {
  const LegalLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('আইন ও ড্রাফট রিসোর্স', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0A192F),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SearchBar(
              hintText: "Section Search: cheating, 420, bail...",
              leading: const Icon(Icons.search),
              padding: const MaterialStatePropertyAll(EdgeInsets.symmetric(horizontal: 16)),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildMenuTile(Icons.psychology_rounded, 'AI Legal Assistant (শক্তি)', 'Draft Bail Petition, Explain Section, Summarize Judgment', () {}),
                _buildMenuTile(Icons.gavel_rounded, 'Bangladesh Laws Library (Offline)', 'Constitution, Penal Code, CPC, CrPC, Evidence Act', () {}),
                _buildMenuTile(Icons.description_rounded, 'Legal Draft Library', 'Plaint, Writ, Appeal, Bail Petition, Templates', () {}),
                _buildMenuTile(Icons.find_in_page_rounded, 'Case Law Database', 'Citation, Ratio Decidendi, Principles, Keywords', () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: const Color(0xFF0A192F), child: Icon(icon, color: const Color(0xFFD4AF37))),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
        onTap: onTap,
      ),
    );
  }
}

class ChamberToolsScreen extends StatelessWidget {
  const ChamberToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chamber Management', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0A192F),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildMenuTile(Icons.document_scanner_rounded, 'Document Scanner & OCR', 'Scan documents, Make Searchable PDF', () {}),
          _buildMenuTile(Icons.payments_rounded, 'Fee & Account Management', 'Income, Expense, Receipt, Accounts Report', () {}),
          _buildMenuTile(Icons.contact_phone_rounded, 'Directories (Court & Contacts)', 'Lawyers, Judges, Typists, Court Address Map', () {}),
          _buildMenuTile(Icons.cloud_sync_rounded, 'Cloud Backup & Offline Vault', 'Google Drive, Dropbox, Local Storage encryption', () {}),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.workspace_premium_rounded, color: Color(0xFFD4AF37)),
            title: Text('ভবিষ্যতের আপকামিং ফিচারস'),
            subtitle: Text('AI Case Prediction, Client Portal, e-Signature, Dark Mode'),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: const Color(0xFF0A192F), child: Icon(icon, color: const Color(0xFFD4AF37))),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
        onTap: onTap,
      ),
    );
  }
}
