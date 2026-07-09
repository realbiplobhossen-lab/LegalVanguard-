import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

// এখানে আপনার জেমিনি এপিআই কি বসাবেন
const String geminiApiKey = "YOUR_GEMINI_API_KEY";

class AdvancedDashboard extends StatefulWidget {
  const AdvancedDashboard({super.key});

  @override
  State<AdvancedDashboard> createState() => _AdvancedDashboardState();
}

class _AdvancedDashboardState extends State<AdvancedDashboard> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  final TextEditingController _voiceController = TextEditingController();
  final List<String> _todayTasks = ["কজ লিস্ট চেক করা", "সিনিয়র আইনজীবীর সাথে ফাইলিং নিয়ে আলোচনা"];

  final List<Map<String, dynamic>> _features = [
    {"name": "Dashboard", "icon": Icons.space_dashboard_rounded, "sub": "আজকের কজ লিস্ট ও শুনানি"},
    {"name": "Case Management", "icon": Icons.folder_special_rounded, "sub": "কেসের যাবতীয় রেকর্ড ও টাইমলাইন"},
    {"name": "Client Management", "icon": Icons.contact_phone_rounded, "sub": "মক্কেলের তথ্য ও যোগাযোগ"},
    {"name": "Court Diary", "icon": Icons.menu_book_rounded, "sub": "দৈনিক ও জজ ভিত্তিক ডায়েরি"},
    {"name": "Legal Draft Library", "icon": Icons.description_rounded, "sub": "আরজি, জবাব, বেইল পিটিশন ফরম্যাট"},
    {"name": "Bangladesh Laws Library", "icon": Icons.gavel_rounded, "sub": "দণ্ডবিধি, সিপিসি, সিআরপিসি"},
    {"name": "Section Search", "icon": Icons.manage_search_rounded, "sub": "AI ভিত্তিক অপরাধ ও ধারা অনুসন্ধান"},
    {"name": "Case Law Database", "icon": Icons.find_in_page_rounded, "sub": "নজির বা জাজমেন্টের অনুসিদ্ধান্ত"},
    {"name": "AI Legal Assistant", "icon": Icons.psychology_rounded, "sub": "স্মার্ট ড্রাফটিং ও এক্সপ্লেনেশন"},
    {"name": "Document Scanner", "icon": Icons.document_scanner_rounded, "sub": "ক্যামেরা স্ক্যান ও PDF তৈরি"},
    {"name": "Voice Notes", "icon": Icons.mic_external_on_rounded, "sub": "আদালত পরবর্তী ভয়েস নোট সংরক্ষণ"},
    {"name": "Evidence Manager", "icon": Icons.perm_media_rounded, "sub": "অডিও, ভিডিও ও এক্সিবিট ট্র্যাকিং"},
    {"name": "Fee Management", "icon": Icons.account_balance_wallet_rounded, "sub": "আয়-ব্যয় হিসাব ও বকেয়া ফি"},
    {"name": "Reminder System", "icon": Icons.add_alert_rounded, "sub": "শুনানি ও ফাইলিং তারিখের রিমাইন্ডার"},
    {"name": "Limitation Calculator", "icon": Icons.calculate_rounded, "sub": "তামাদি মেয়াদের স্বয়ংক্রিয় গণনা"},
    {"name": "Court Directory", "icon": Icons.map_rounded, "sub": "আদালতের ঠিকানা ও বিচারকদের তালিকা"},
    {"name": "Contact Directory", "icon": Icons.badge_rounded, "sub": "আইনজীবী ও মুহুরি যোগাযোগ"},
    {"name": "Legal Research Notebook", "icon": Icons.collections_bookmark_rounded, "sub": "ব্যক্তিগত গবেষণা নোটবুক"},
    {"name": "AI Timeline", "icon": Icons.timeline_rounded, "sub": "মামলার গতিপ্রকৃতির গ্রাফিকাল রূপ"},
    {"name": "To-Do List", "icon": Icons.fact_check_rounded, "sub": "আজকের সারাদিনের করণীয় কাজের তালিকা"},
    {"name": "Calendar Sync", "icon": Icons.calendar_month_rounded, "sub": "গুগল ক্যালেন্ডার ইন্টিগ্রেশন"},
    {"name": "Chamber Management", "icon": Icons.corporate_fare_rounded, "sub": "জুনিয়র ও কর্মচারীদের টাস্ক এসাইন"},
    {"name": "Secure Vault", "icon": Icons.enhanced_encryption_rounded, "sub": "এনক্রিপ্টেড ফাইল সিকিউরিটি"},
    {"name": "Offline Mode", "icon": Icons.signal_wifi_off_rounded, "sub": "ইন্টারনেট ছাড়া ডেটা দেখার সুবিধা"},
  ];

  void _startListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onError: (val) => print('Error: $val'),
        onStatus: (val) => print('Status: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          localeId: 'bn_BD',
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
                        hintText: "গুগল ট্রান্সলেট স্টাইলে রিয়েল-টাইম বাংলা বলুন...",
                        hintStyle: TextStyle(color: Colors.black38, fontSize: 13),
                      ),
                    ),
                  ),
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
          if (_todayTasks.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFF0A192F), borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('📝 লাইভ টাস্ক ট্র্যাকার', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 5),
                    Text(_todayTasks.first, style: const TextStyle(color: Colors.white, fontSize: 13, overflow: TextOverflow.ellipsis)),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 10),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(14),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.35),
              itemCount: _features.length,
              itemBuilder: (context, index) {
                final feature = _features[index];
                return InkWell(
                  onTap: () => _navigateToFeature(context, feature['name']),
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

  void _navigateToFeature(BuildContext context, String featureName) {
    if (featureName == "Section Search") {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const SectionSearchScreen()));
    } else if (featureName == "Document Scanner") {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const DocumentScannerScreen()));
    } else if (featureName == "Case Management") {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const CaseManagementScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$featureName মডিউলটি ডেভলপমেন্ট মোডে আছে।')),
      );
    }
  }
}

// ==================== ১. SECTION SEARCH (GEMINI AI ENGINE) ====================
class SectionSearchScreen extends StatefulWidget {
  const SectionSearchScreen({super.key});

  @override
  State<SectionSearchScreen> createState() => _SectionSearchScreenState();
}

class _SectionSearchScreenState extends State<SectionSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _aiResult = "এখানে আপনার অপরাধ অনুসন্ধান বা আইনি সমস্যাটি লিখুন (যেমন: চুরি, ডাকাতি, Theft, Dacoity)...";
  bool _isLoading = false;

  Future<void> _searchLawWithAI(String query) async {
    if (query.isEmpty) return;
    setState(() {
      _isLoading = true;
      _aiResult = "Gemini AI আইন বিশ্লেষণ করছে, দয়া করে অপেক্ষা করুন...";
    });

    try {
      final response = await http.post(
        Uri.parse("https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$geminiApiKey"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {
                  "text": "Act as a senior Bangladeshi legal expert. Analyze the following offense or keyword: '$query'. Provide an exhaustive legal breakdown in clean Bengali including: 1. Relevant Sections and Laws (e.g., Penal Code, CrPC). 2. Judicial procedures and trials. 3. Punishments. 4. Strategic litigation guidelines and arguments for both Prosecution (বাদী) and Defense (বিবাদী) side to build a strong case."
                }
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _aiResult = data['candidates'][0]['content']['parts'][0]['text'];
        });
      } else {
        setState(() => _aiResult = "এপিআই কানেকশন ত্রুটি। অনুগ্রহ করে আপনার API Key চেক করুন।");
      }
    } catch (e) {
      setState(() => _aiResult = "নেটওয়ার্ক ত্রুটি বা এপিআই রেসপন্স পাওয়া যায়নি।");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(title: const Text("AI Section Search Engine"), backgroundColor: const Color(0xFF0A192F), foregroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]),
              child: Row(
                children: [
                  Expanded(child: TextField(controller: _searchController, decoration: const InputDecoration(hintText: "অপরাধের নাম লিখুন...", border: InputBorder.none))),
                  IconButton(icon: const Icon(Icons.search, color: Color(0xFF0A192F)), onPressed: () => _searchLawWithAI(_searchController.text)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF0A192F)))
                    : SingleChildScrollView(child: Text(_aiResult, style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.5))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== ২. DOCUMENT SCANNER (CAMSCANNER STYLE) ====================
class DocumentScannerScreen extends StatefulWidget {
  const DocumentScannerScreen({super.key});

  @override
  State<DocumentScannerScreen> createState() => _DocumentScannerScreenState();
}

class _DocumentScannerScreenState extends State<DocumentScannerScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraReady = false;
  String _statusMessage = "ক্যামেরা দিয়ে লিগ্যাল ডকুমেন্ট স্ক্যান করুন";

  @override
  void initState() {
    super.initState();
    _setupCamera();
  }

  Future<void> _setupCamera() async {
    _cameras = await availableCameras();
    if (_cameras != null && _cameras!.isNotEmpty) {
      _cameraController = CameraController(_cameras![0], ResolutionPreset.high);
      await _cameraController!.initialize();
      if (mounted) {
        setState(() => _isCameraReady = true);
      }
    }
  }

  Future<void> _captureAndConvertToPdf() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;
    setState(() => _statusMessage = "ডকুমেন্ট স্ক্যান ও এনহ্যান্স করা হচ্ছে...");

    try {
      final XFile imageFile = await _cameraController!.takePicture();
      final pdf = pw.Document();
      final image = pw.MemoryImage(File(imageFile.path).readAsBytesSync());

      pdf.addPage(pw.Page(build: (pw.Context context) => pw.Center(child: pw.Image(image))));

      final output = await getExternalStorageDirectory();
      final file = File("${output!.path}/Scan_${DateTime.now().millisecondsSinceEpoch}.pdf");
      await file.writeAsBytes(await pdf.save());

      setState(() => _statusMessage = "PDF সফলভাবে সংরক্ষিত:\n${file.path}");
    } catch (e) {
      setState(() => _statusMessage = "স্ক্যান করতে ব্যর্থ: $e");
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Document Scanner Pro"), backgroundColor: const Color(0xFF0A192F), foregroundColor: Colors.white),
      body: _isCameraReady
          ? Column(
              children: [
                Expanded(child: CameraPreview(_cameraController!)),
                Container(
                  padding: const EdgeInsets.all(20),
                  color: const Color(0xFF0A192F),
                  child: Column(
                    children: [
                      Text(_statusMessage, style: const TextStyle(color: Colors.white, fontSize: 13), textAlign: Center),
                      const SizedBox(height: 15),
                      InkWell(
                        onTap: _captureAndConvertToPdf,
                        child: const CircleAvatar(radius: 30, backgroundColor: Colors.white, child: Icon(Icons.camera_alt, color: Color(0xFF0A192F), size: 30)),
                      ),
                    ],
                  ),
                )
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}

// ==================== ৩. CASE MANAGEMENT & TIMELINE ====================
class CaseManagementScreen extends StatefulWidget {
  const CaseManagementScreen({super.key});

  @override
  State<CaseManagementScreen> createState() => _CaseManagementScreenState();
}

class _CaseManagementScreenState extends State<CaseManagementScreen> {
  final List<Map<String, String>> _caseTimeline = [
    {"stage": "মামলা ফাইলিং ও এফআইআর (FIR)", "date": "১০ মে, ২০২৬", "note": "থানায় মামলা রুজু ও জিডি কপি সংগ্রহ।"},
    {"stage": "চার্জশিট/অভিযোগপত্র দাখিল", "date": "২৫ মে, ২০২৬", "note": "তদন্তকারী কর্মকর্তা কর্তৃক আদালতে প্রতিবেদন দাখিল।"},
    {"stage": "চার্জ গঠন ও শুনানি", "date": "০৫ জুন, ২০২৬", "note": "আসামিপক্ষে অব্যাহতির আবেদন নাকচ ও চার্জ গঠন।"},
    {"stage": "সাক্ষ্য গ্রহণ (Evidence Stage)", "date": "০৯ জুলাই, ২০২৬", "note": "বাদীপক্ষের প্রথম সাক্ষীর জবানবন্দি ও জেরা সম্পন্ন।"},
    {"stage": "পরবর্তী শুনানির তারিখ (Next Fixed Date)", "date": "২২ আগস্ট, ২০২৬", "note": "বাকি সাক্ষীদের সমন জারির নির্দেশ।"}
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(title: const Text("Case Records & Timeline"), backgroundColor: const Color(0xFF0A192F), foregroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: _caseTimeline.length,
          itemBuilder: (context, index) {
            final item = _caseTimeline[index];
            bool isLatest = index == _caseTimeline.length - 1;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    CircleAvatar(radius: 12, backgroundColor: isLatest ? const Color(0xFFD4AF37) : const Color(0xFF0A192F), child: Icon(Icons.check, size: 12, color: Colors.white)),
                    if (index != _caseTimeline.length - 1) Container(width: 2, height: 70, color: const Color(0xFF0A192F)),
                  ],
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.bottom(15),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)]),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(item['stage']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0A192F))),
                            Text(item['date']!, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(item['note']!, style: const TextStyle(fontSize: 12, color: Colors.black64)),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
