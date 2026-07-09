import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:firebase_core/firebase_core.dart'; // ফায়ারবেস কোর ইম্পোর্ট করা হলো
import 'database_service.dart';

void main() async {
  // ১. ফ্লাটার উইজেট বাইন্ডিং নিশ্চিত করা (এটি সাদা স্ক্রিন দূর করার মূল চাবিকাঠি)
  WidgetsFlutterBinding.ensureInitialized();
  
  // ২. ফায়ারবেস ক্লাউড সিস্টেমকে অ্যাপের সাথে সচল করা
  await Firebase.initializeApp();
  
  runApp(const LegalVanguardApp());
}

class LegalVanguardApp extends StatelessWidget {
  const LegalVanguardApp({super.key}); // কি-এর আধুনিক ফ্লাটার স্ট্রাকচার ফিক্স

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LegalVanguard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF0A192F), // রয়েল ডার্ক ব্লু
        scaffoldBackgroundColor: const Color(0xFFF4F6F9),
      ),
      home: const DashboardScreen(),
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
  String _voiceText = "সিনিয়র যা বলবেন তা এখানে লাইভ টাইপ হবে...";

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('Status: $val'),
        onError: (val) => print('Error: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          localeId: "bn_BD", // বাংলা ভাষা সিলেক্ট করা হয়েছে
          onResult: (val) => setState(() {
            _voiceText = val.recognizedWords;
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
      // ভয়েস শেষ হওয়া মাত্রই তা ফায়ারবেস ক্লাউডে অটোমেটিক সেভ হয়ে যাবে
      if (_voiceText.isNotEmpty && _voiceText != "সিনিয়র যা বলবেন তা এখানে লাইভ টাইপ হবে...") {
        await _dbService.saveTodayTask(_voiceText);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('আজকের করণীয় তালিকায় নোটটি সফলভাবে সেভ হয়েছে!')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LegalVanguard ড্যাশবোর্ড', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0A192F),
        centerTitle: true,
        elevation: 5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: Cross CrossAxisAlignment.start,
          children: [
            // প্রিমিয়াম স্ট্যাটাস কার্ড
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0A192F),
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('অ্যাডভোকেট চেম্বার অ্যাসিস্ট্যান্ট', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 14, fontWeight: FontWeight.w500)),
                  SizedBox(height: 5),
                  Text('আজকের লক্ষ্য: সততা ও দক্ষতা', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 25),
            const Text('🎙️ সিনিয়রের ভয়েস নোট রেকর্ডার', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0A192F))),
            const SizedBox(height: 10),
            
            // ভয়েস টেক্সট ডিসপ্লে এরিয়া
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _voiceText,
                    style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // প্রীমিয়াম অ্যানিমেটেড মাইক্রোফোন বাটন
            Center(
              child: GestureDetector(
                onTap: _listen,
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: _isListening ? Colors.red : const Color(0xFF0A192F),
                  child: Icon(
                    _isListening ? Icons.stop : Icons.mic,
                    size: 40,
                    color: _isListening ? Colors.white : const Color(0xFFD4AF37),
                  ),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _isListening ? 'রেকর্ড হচ্ছে... বন্ধ করতে আবার চাপুন' : 'সিনিয়রের কথা রেকর্ড করতে চাপুন',
                  style: TextStyle(color: _isListening ? Colors.red : Colors.grey.shade600, fontWeight: FontWeight.w500),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

