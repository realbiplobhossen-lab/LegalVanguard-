import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class AdvancedDashboard extends StatefulWidget {
  const AdvancedDashboard({super.key});

  @override
  State<AdvancedDashboard> createState() => _AdvancedDashboardState();
}

class _AdvancedDashboardState extends State<AdvancedDashboard> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  final TextEditingController _voiceController = TextEditingController();

  // আজকের করণীয় কাজের ডাইনামিক লিস্ট
  final List<String> _todayTasks = [
    "কজ লিস্ট চেক করা",
    "সিনিয়র আইনজীবীর সাথে ফাইলিং নিয়ে আলোচনা",
  ];

  // ২৪টি ফিচারের তালিকা (হুবহু আপনার রিকোয়ারমেন্ট অনুযায়ী)
  final List<Map<String, dynamic>> _features = [
    {"name": "Dashboard", "icon": Icons.space_dashboard_rounded, "sub": "আজকের কজ লিস্ট ও শুনানি"},
    {"name": "Case Management", "icon": Icons.folder_special_rounded, "sub": "কেসের যাবতীয় রেকর্ড ও টাইমলাইন"},
    {"name": "Client Management", "icon": Icons.contact_phone_rounded, "sub": "মক্কেলের তথ্য, NID ও WhatsApp"},
    {"name": "Court Diary", "icon": Icons.menu_book_rounded, "sub": "দৈনিক ও জজ ভিত্তিক ডায়েরি"},
    {"name": "Legal Draft Library", "icon": Icons.description_rounded, "sub": "আরজি, জবাব, বেইল পিটিশন ফরম্যাট"},
    {"name": "Bangladesh Laws Library", "icon": Icons.gavel_rounded, "sub": "দণ্ডবিধি, সিপিসি, সিআরপিসি (অফলাইন)"},
    {"name": "Section Search", "icon": Icons.manage_search_rounded, "sub": "আইন, ধারা ও শাস্তির তাৎক্ষণিক সার্চ"},
    {"name": "Case Law Database", "icon": Icons.find_in_page_rounded, "sub": "নজির বা জাজমেন্টের অনুসিদ্ধান্ত"},
    {"name": "AI Legal Assistant", "icon": Icons.psychology_rounded, "sub": "স্মার্ট ড্রাফটিং ও লিগ্যাল এক্সপ্লেনেশন"},
    {"name": "Document Scanner", "icon": Icons.document_scanner_rounded, "sub": "স্ক্যান ও সার্চেবল PDF তৈরি"},
    {"name": "Voice Notes", "icon": Icons.mic_external_on_rounded, "sub": "আদালত পরবর্তী ভয়েস নোট সংরক্ষণ"},
    {"name": "Evidence Manager", "icon": Icons.perm_media_rounded, "sub": "অডিও, ভিডিও ও এক্সিবিট ট্র্যাকিং"},
    {"name": "Fee Management", "icon": Icons.account_balance_wallet_rounded, "sub": "আয়-ব্যয় হিসাব ও বকেয়া ফি ট্র্যাকিং"},
    {"name": "Reminder System", "icon": Icons.add_alert_rounded, "sub": "শুনানি ও ফাইলিং তারিখের রিমাইন্ডার"},
    {"name": "Limitation Calculator", "icon": Icons.calculate_rounded, "sub": "তামাদি মেয়াদের স্বয়ংক্রিয় গণনা"},
    {"name": "Court Directory", "icon": Icons.map_rounded, "sub": "আদালতের ঠিকানা ও বিচারকদের তালিকা"},
    {"name": "Contact Directory", "icon": Icons.badge_rounded, "sub": "আইনজীবী, মুহুরি ও নোটারী পাবলিক যোগাযোগ"},
    {"name": "Legal Research Notebook", "icon": Icons.collections_bookmark_rounded, "sub": "ব্যক্তিগত গবেষণা নোটবুক ও ফোল্ডার"},
    {"name": "AI Timeline", "icon": Icons.timeline_rounded, "sub": "মামলার গতিপ্রকৃতির গ্রাফিকাল রূপ"},
    {"name": "To-Do List", "icon": Icons.fact_check_rounded, "sub": "আজকের সারাদিনের করণীয় কাজের তালিকা"},
    {"name": "Calendar Sync", "icon": Icons.calendar_month_rounded, "sub": "গুগল ক্যালেন্ডার ইন্টিগ্রেশন"},
    {"name": "Chamber Management", "icon": Icons.corporate_fare_rounded, "sub": "জুনিয়র ও কর্মচারীদের টাস্ক এসাইন"},
    {"name": "Secure Vault", "icon": Icons.shield_lock_rounded, "sub": "ফিঙ্গারপ্রিন্ট ও এনক্রিপ্টেড ফাইল সিকিউরিটি"},
    {"name": "Offline Mode", "icon": Icons.signal_wifi_off_rounded, "sub": "ইন্টারনেট ছাড়া ডেটা ও আইন দেখার সুবিধা"},
  ];

  // গুগল ট্রান্সলেট স্টাইলের নিখুঁত রিয়েল-টাইম বাংলা ভয়েস টাইপিং লজিক
  void _startListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onError: (val) => print('ভয়েস এরর: $val'),
        onStatus: (val) => print('ভয়েস স্ট্যাটাস: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          localeId: 'bn_BD', // খাঁটি বাংলা ভাষা ও ফন্টের জন্য বাধ্যতামূলক
          onResult: (val) {
            setState(() {
              _voiceController.text = val.recognizedWords;
            });
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
      if (_voiceController.text.isNotEmpty) {
        setState(() {
          _todayTasks.insert(0, _voiceController.text);
          _voiceController.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🎯 সিনিয়রের টাস্ক সরাসরি "আজকের করণীয় কাজ" পেজে যোগ হয়েছে!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text('LegisMate Pro', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: const Color(0xFF0A192F),
        centerTitle: true,
        elevation: 5,
      ),
      body: Column(
        children: [
          // সিনিয়রের মর্নিং ভয়েস সেকশন (স্ক্রিনশটের মতো ইনপুট বক্স ডিজাইন)
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
                border: Border.all(color: _isListening ? Colors.redAccent : Colors.grey.shade300, width: 1.5),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _voiceController,
                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "সকাল বেলা সিনিয়রের অডিও নির্দেশিকা এখানে টাইপ হবে...",
                        hintStyle: TextStyle(color: Colors.black38, fontSize: 13),
                      ),
                    ),
                  ),
                  // স্ক্রিনশটের মতো লাল গোল দাগ চিহ্নিত স্থানে মাইক্রোফোন বাটন
                  GestureDetector(
                    onTap: _startListening,
                    child: CircleAvatar(
                      backgroundColor: _isListening ? Colors.red.shade100 : Colors.blue.withOpacity(0.1),
                      radius: 22,
                      child: Icon(
                        _isListening ? Icons.stop_circle : Icons.mic,
                        color: _isListening ? Colors.red : const Color(0xFF0A192F),
                        size: 26,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ডাইনামিক লাইভ আপডেট: আজকের করণীয় কাজ
          if (_todayTasks.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A192F),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('📝 আজকের করণীয় কাজ (ভয়েস দ্বারা লাইভ আপডেট)', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 5),
                    Text(_todayTasks.first, style: const TextStyle(color: Colors.white, fontSize: 13, overflow: TextOverflow.ellipsis)),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 10),

          // ২৪টি ফিচারের আকর্ষণীয় ও প্রিমিয়াম গ্রিড ড্যাশবোর্ড
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(14),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // প্রতি সারিতে ২টি বাটন প্রিমিয়াম লুকের জন্য
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.35,
              ),
              itemCount: _features.length,
              itemBuilder: (context, index) {
                final feature = _features[index];
                return InkWell(
                  onTap: () => _openFeatureDetails(context, feature['name'], feature['sub']),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CircleAvatar(
                          backgroundColor: const Color(0xFF0A192F).withOpacity(0.08),
                          radius: 20,
                          child: Icon(feature['icon'], color: const Color(0xFF0A192F), size: 22),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(feature['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0A192F))),
                            const SizedBox(height: 2),
                            Text(feature['sub'], style: const TextStyle(fontSize: 10, color: Colors.black54), maxLines: 2, overflow: TextOverflow.ellipsis),
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
      ),
    );
  }

  // প্রতিটি বাটনে ক্লিক করলে চমৎকার ইউজার ইন্টারফেসে প্রবেশের জন্য ডাইনামিক ফাংশন
  void _openFeatureDetails(BuildContext context, String title, String subtitle) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Icon(Icons.gavel_rounded, color: Color(0xFFD4AF37), size: 28),
                  const SizedBox(width: 10),
                  Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0A192F))),
                ],
              ),
              Text(subtitle, style: const TextStyle(fontSize: 13, color: Colors.grey)),
              const Divider(height: 30),
              
              // ইন্টারেক্টিভ ইন্টারফেস বডি
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.folder_open_outlined, size: 60, color: Colors.grey.shade300),
                      const SizedBox(height: 10),
                      Text('$title মডিউলের প্রফেশনাল ডাটা এন্ট্রি প্যানেল', style: const TextStyle(color: Colors.black54, fontSize: 14)),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0A192F), foregroundColor: Colors.white),
                        onPressed: () {},
                        icon: const Icon(Icons.add_circle_outline),
                        label: const Text('নতুন রেকর্ড যোগ করুন'),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
