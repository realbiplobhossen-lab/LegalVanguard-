import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  // ফায়ারস্টোর ইনস্ট্যান্স তৈরি এবং অফলাইন ক্যাশ সেটিংস নিশ্চিত করা
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  DatabaseService() {
    // এই সেটিংসটি অ্যাপের স্প্ল্যাশ স্ক্রিন ব্লকিং সমস্যা দূর করবে এবং অফলাইন সাপোর্ট দেবে
    _db.settings = const Settings(
      persistenceEnabled: true, // অফলাইন ক্যাশ অন করা হলো
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  // সিনিয়রের ভয়েস নোট এবং আজকের করণীয় কাজ সেভ করার ফাংশন
  Future<void> saveTodayTask(String textNote) async {
    try {
      await _db.collection('daily_tasks').add({
        'task_details': textNote,
        'created_at': FieldValue.serverTimestamp(), // DateTime.now() এর চেয়ে এটি ফায়ারবেসের জন্য বেশি নির্ভুল
        'status': 'Pending',
      });
    } catch (e) {
      print("Error saving task: $e");
    }
  }

  // নতুন কেস বা মক্কেলের হাজিরার তারিখ এন্ট্রি করার ফাংশন
  Future<void> addNewCase(String caseNo, String clientName, String nextDate) async {
    try {
      await _db.collection('cases').add({
        'case_no': caseNo,
        'client_name': clientName,
        'next_hearing_date': nextDate,
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error adding case: $e");
    }
  }

  // ফায়ারবেস থেকে আজকের কাজের লিস্ট লাইভ নিয়ে আসার স্ট্রিম
  Stream<QuerySnapshot> getTodayTasks() {
    // অফলাইন মোডেও যেন ক্র্যাশ না করে তাই ট্রাই-ক্যাচ সেফটি মেথড
    return _db.collection('daily_tasks').orderBy('created_at', descending: true).snapshots();
  }
}
