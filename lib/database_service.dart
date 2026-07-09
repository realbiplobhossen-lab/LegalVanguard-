import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  // সিনিয়রের ভয়েস নোট এবং আজকের করণীয় কাজ সেভ করার ফাংশন
  Future<void> saveTodayTask(String textNote) async {
    try {
      await _db.collection('daily_tasks').add({
        'task_details': textNote,
        'created_at': FieldValue.serverTimestamp(),
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
    return _db.collection('daily_tasks').orderBy('created_at', descending: true).snapshots();
  }
}
