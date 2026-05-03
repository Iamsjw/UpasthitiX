import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../models/session_model.dart';
import '../models/attendance_model.dart';

class SupabaseService {
  static const String _projectUrl = 'https://fgmdixxhzwhgaiajcxal.supabase.co';
  static const String _anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZnbWRpeHhoendoZ2FpYWpjeGFsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzc2NzM1NzQsImV4cCI6MjA5MzI0OTU3NH0.YDXk2lWWlN5SAN1MoXnL0JSVj8c7F_ZI_EOGclb3eas';

  static SupabaseClient get client => Supabase.instance.client;
  static User? get currentAuthUser => client.auth.currentUser;

  static Future<void> initialize() async {
    await Supabase.initialize(url: _projectUrl, anonKey: _anonKey);
  }

  // ─── Auth ──────────────────────────────────────────────────────────────────
  static Future<AuthResponse> signIn(String email, String password) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Future<AuthResponse> signUp(
    String email,
    String password,
    String name,
    String role,
  ) async {
    final response = await client.auth.signUp(
      email: email,
      password: password,
      data: {'name': name, 'role': role},
    );
    if (response.user != null) {
      await client.from('users').upsert({
        'id': response.user!.id,
        'name': name,
        'email': email,
        'role': role,
      });
    }
    return response;
  }

  static Future<void> signOut() async {
    await client.auth.signOut();
  }

  // ─── User Profile ──────────────────────────────────────────────────────────
  static Future<UserModel?> getUserProfile(String userId) async {
    try {
      final data = await client
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();
      if (data == null) return null;
      return UserModel.fromMap(data);
    } catch (_) {
      return null;
    }
  }

  static Future<UserModel?> getCurrentUserProfile() async {
    final user = currentAuthUser;
    if (user == null) return null;
    return getUserProfile(user.id);
  }

  // ─── Classes & Subjects ───────────────────────────────────────────────────
  static Future<List<ClassModel>> getClasses() async {
    try {
      final data = await client.from('classes').select().order('name');
      return (data as List)
          .map((e) => ClassModel.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<List<SubjectModel>> getSubjects() async {
    try {
      final data = await client.from('subjects').select().order('name');
      return (data as List)
          .map((e) => SubjectModel.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ─── Teacher Assignments ──────────────────────────────────────────────────
  static Future<List<AssignmentModel>> getTeacherAssignments(
    String teacherId,
  ) async {
    try {
      final data = await client
          .from('teacher_assignments')
          .select('*, classes(name), subjects(name)')
          .eq('teacher_id', teacherId);
      return (data as List).map((e) {
        final map = e as Map<String, dynamic>;
        return AssignmentModel.fromMap({
          ...map,
          'class_name': (map['classes'] as Map?)?['name'],
          'subject_name': (map['subjects'] as Map?)?['name'],
        });
      }).toList();
    } catch (_) {
      return [];
    }
  }

  // ─── Sessions ─────────────────────────────────────────────────────────────
  static Future<SessionModel?> createSession({
    required String teacherId,
    required String classId,
    required String subjectId,
    required String code,
    required String securityLevel,
    required int rssiThreshold,
    required int durationSeconds,
  }) async {
    try {
      final now = DateTime.now().toUtc();
      final endTime = now.add(Duration(seconds: durationSeconds));
      final data = await client
          .from('sessions')
          .insert({
            'teacher_id': teacherId,
            'class_id': classId,
            'subject_id': subjectId,
            'code': code,
            'security_level': securityLevel,
            'rssi_threshold': rssiThreshold,
            'start_time': now.toIso8601String(),
            'end_time': endTime.toIso8601String(),
            'is_active': true,
          })
          .select()
          .single();
      return SessionModel.fromMap(data);
    } catch (_) {
      return null;
    }
  }

  static Future<bool> endSession(String sessionId) async {
    try {
      await client
          .from('sessions')
          .update({
            'is_active': false,
            'end_time': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', sessionId);
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<SessionModel?> getActiveSessionByCode(String code) async {
    try {
      final data = await client
          .from('sessions')
          .select()
          .eq('code', code)
          .eq('is_active', true)
          .maybeSingle();
      if (data == null) return null;
      return SessionModel.fromMap(data);
    } catch (_) {
      return null;
    }
  }

  static Future<SessionModel?> getActiveSessionForTeacher(
    String teacherId,
  ) async {
    try {
      final data = await client
          .from('sessions')
          .select()
          .eq('teacher_id', teacherId)
          .eq('is_active', true)
          .maybeSingle();
      if (data == null) return null;
      return SessionModel.fromMap(data);
    } catch (_) {
      return null;
    }
  }

  // ─── Attendance ───────────────────────────────────────────────────────────
  static Future<bool> markAttendance({
    required String studentId,
    required String sessionId,
  }) async {
    try {
      // Check for duplicate
      final existing = await client
          .from('attendance')
          .select()
          .eq('student_id', studentId)
          .eq('session_id', sessionId)
          .eq('status', 'present')
          .maybeSingle();
      if (existing != null) return false; // already marked

      await client.from('attendance').insert({
        'student_id': studentId,
        'session_id': sessionId,
        'timestamp': DateTime.now().toIso8601String(),
        'status': 'present',
      });

      // Log the action
      await client.from('attendance_logs').insert({
        'action': 'marked',
        'performed_by': studentId,
        'student_id': studentId,
        'session_id': sessionId,
        'timestamp': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> revokeAttendance({
    required String attendanceId,
    required String teacherId,
    required String studentId,
    required String sessionId,
    String? reason,
  }) async {
    try {
      await client
          .from('attendance')
          .update({'status': 'revoked'})
          .eq('id', attendanceId);

      await client.from('attendance_logs').insert({
        'action': 'revoked',
        'performed_by': teacherId,
        'student_id': studentId,
        'session_id': sessionId,
        'timestamp': DateTime.now().toIso8601String(),
        'reason': reason ?? '',
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<List<AttendanceModel>> getSessionAttendance(
    String sessionId,
  ) async {
    try {
      final data = await client
          .from('attendance')
          .select('*, users(name, email)')
          .eq('session_id', sessionId)
          .order('timestamp');
      return (data as List).map((e) {
        final map = e as Map<String, dynamic>;
        return AttendanceModel.fromMap({
          ...map,
          'student_name': (map['users'] as Map?)?['name'],
          'student_email': (map['users'] as Map?)?['email'],
        });
      }).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<List<AttendanceModel>> getStudentAttendanceHistory(
    String studentId,
  ) async {
    try {
      final data = await client
          .from('attendance')
          .select('*, sessions(*, subjects(name))')
          .eq('student_id', studentId)
          .order('timestamp', ascending: false);
      return (data as List)
          .map((e) => AttendanceModel.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<bool> hasStudentMarkedAttendance({
    required String studentId,
    required String sessionId,
  }) async {
    try {
      final data = await client
          .from('attendance')
          .select()
          .eq('student_id', studentId)
          .eq('session_id', sessionId)
          .eq('status', 'present')
          .maybeSingle();
      return data != null;
    } catch (_) {
      return false;
    }
  }

  // ─── Realtime ─────────────────────────────────────────────────────────────
  static RealtimeChannel subscribeToSessionAttendance(
    String sessionId,
    void Function(List<Map<String, dynamic>>) onUpdate,
  ) {
    debugPrint('[Realtime] Subscribing to attendance for session: $sessionId');
    return client
        .channel('attendance_$sessionId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'attendance',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'session_id',
            value: sessionId,
          ),
          callback: (payload) {
            debugPrint('[Realtime] Attendance change detected: ${payload.toString()}');
            // Fetch latest attendance and push to UI
            getSessionAttendance(sessionId).then((records) {
              debugPrint(
                '[Realtime] Fetched ${records.length} records, pushing to UI',
              );
              onUpdate(records.map((e) => e.toMap()).toList());
            }).catchError((e) {
              debugPrint('[Realtime] Error fetching attendance: $e');
            });
          },
        )
        .subscribe();
  }
}
