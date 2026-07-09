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
      title: 'LegalVanguard',
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

// মূল নেভিগেশন স্ক্রিন (যা বিভিন্ন পেজ বা মেনু কন্ট্রোল করবে)
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const CaseDiaryScreen(),
    const ClientDatabaseScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_rounded), label: 'ড্যাশবোর্ড'),
          NavigationDestination(icon: Icon(Icons.menu_book_rounded), label: 'কেস ডায়েরি'),
          NavigationDestination(icon: Icon(Icons.people_alt_rounded), label: 'মক্কেল তালিকা'),
          NavigationDestination(icon: Icon(Icons.settings_rounded), label: 'সেটিংস'),
        ],
      ),
    );
  }
}

// ১. ড্যাশবোর্ড স্ক্রিন (হোম পেজ)
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DatabaseService _dbService = DatabaseService();
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _voiceText = "সিনিয়র যা বলবেন তা এখানে লাইভ টাইপ হবে...";

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
      if (_voiceText.isNotEmpty && _voiceText != "সিনিয়র যা বলবেন তা এখানে লাইভ টাইপ হবে...") {
        await _dbService.saveTodayTask(_voiceText);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('আজকের করণীয় তালিকায় নোটটি সেভ হয়েছে!')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LegalVanguard হোম', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0A192F),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.notifications_active, color: Colors.white), onPressed: () {}),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // প্রিমিয়াম স্ট্যাটাস কার্ড
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0A192F),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('অ্যাডভোকেট চেম্বার অ্যাসিস্ট্যান্ট', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 13, fontWeight: FontWeight.w500)),
                  SizedBox(height: 5),
                  Text('আজকের লক্ষ্য: সততা ও দক্ষতা', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // কুইক স্ট্যাটাস কাউন্টার
            Row(
              children: [
                Expanded(child: _buildStatCard('আজকের হাজিরা', '৫ টি', Colors.blue.shade800)),
                const SizedBox(width: 10),
                Expanded(child: _buildStatCard('নতুন মক্কেল', '৩ জন', Colors.amber.shade800)),
              ],
            ),
            const SizedBox(height: 20),
            const Text('🎙️ সিনিয়রের ভয়েস নোট রেকর্ডার', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0A192F))),
            const SizedBox(height: 10),
            
            // ভয়েস এরিয়া
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: SingleChildScrollView(child: Text(_voiceText, style: const TextStyle(fontSize: 15, height: 1.4))),
              ),
            ),
            const SizedBox(height: 15),
            
            Center(
              child: FloatingActionButton.large(
                onPressed: _listen,
                backgroundColor: _isListening ? Colors.red : const Color(0xFF0A192F),
                child: Icon(_isListening ? Icons.stop : Icons.mic, size: 36, color: const Color(0xFFD4AF37)),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String count, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 5),
          Text(count, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// ২. কেস ডায়েরি স্ক্রিন
class CaseDiaryScreen extends StatelessWidget {
  const CaseDiaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ডিজিটাল কেস ডায়েরি', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0A192F),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 4,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const CircleAvatar(backgroundColor: Color(0xFF0A192F), child: Icon(Icons.gavel, color: Colors.white)),
              title: Text('মামলা নং: CR-${120 + index}/2026'),
              subtitle: Text('পরবর্তী তারিখ: ${10 + index}/০৭/২০২৬\nপদক্ষেপ: হাজিরার জন্য ধার্য দিন'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF0A192F),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// ৩. মক্কেল ডাটাবেজ স্ক্রিন
class ClientDatabaseScreen extends StatelessWidget {
  const ClientDatabaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('মক্কেল প্রোফাইল ও ডাটাবেজ', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0A192F),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SearchBar(
              hintText: "মক্কেলের নাম বা ফোন নম্বর দিয়ে খুঁজুন...",
              leading: const Icon(Icons.search),
              padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 16)),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: ListView(
                children: const [
                  Card(
                    child: ListTile(
                      title: Text('মোঃ আবদুর রহমান'),
                      subtitle: Text('ফোন: ০১৭xxxxxxxx\nমামলার ধরন: দেওয়ানি জমিজমা সংক্রান্ত'),
                      trailing: Icon(Icons.phone, color: Colors.green),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: Text('মোসাম্মৎ রোকসানা বেগম'),
                      subtitle: Text('ফোন: ০১৮xxxxxxxx\nমামলার ধরন: পারিবারিক ভরণপোষণ'),
                      trailing: Icon(Icons.phone, color: Colors.green),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ৪. সেটিংস স্ক্রিন
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('অ্যাপ সেটিংস', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0A192F),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const ListTile(
            leading: Icon(Icons.account_circle, color: Color(0xFF0A192F)),
            title: Text('প্রোফাইল কনফিগারেশন'),
            subtitle: Text('আইনজীবী ও চেম্বারের নাম পরিবর্তন'),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.cloud_sync, color: Color(0xFF0A192F)),
            title: Text('ফায়ারবেস ক্লাউড সিঙ্ক'),
            subtitle: Text('অফলাইন ডাটা সার্ভারে ব্যাকআপ করুন'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline, color: Color(0xFF0A192F)),
            title: const Text('LegalVanguard সংস্করণ'),
            subtitle: const Text('v1.0.0 (রিলিজ সংস্করণ)'),
            trailing: TextButton(onPressed: () {}, child: const Text('চেক আপডেট')),
          ),
        ],
      ),
    );
  }
}
