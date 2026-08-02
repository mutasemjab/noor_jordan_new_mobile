import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../teacher_attendance/domain/entities/teacher_attendance.dart';
import '../../../teacher_attendance/presentation/pages/teacher_attendance_page.dart';
import '../../../teacher_exams/presentation/pages/teacher_exams_list_page.dart';
import '../../../teacher_grades/presentation/pages/teacher_grades_page.dart';
import '../../../teacher_notes/presentation/pages/teacher_notes_page.dart';
import '../../../teacher_files/presentation/pages/teacher_files_hub_page.dart';
import '../../../teacher_videos/presentation/pages/teacher_videos_page.dart';
import '../../domain/entities/school_class.dart';
import 'class_roster_page.dart';

/// Landing page after a teacher opens a class from "فصولي" — a hub of
/// actions (roster, attendance, grades, notes, files, exams) scoped to
/// that one class.
class ClassHubPage extends StatelessWidget {
  final SchoolClass schoolClass;
  const ClassHubPage({super.key, required this.schoolClass});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(schoolClass.name, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 16)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _ClassHeaderCard(schoolClass: schoolClass),
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.all(16),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: [
                _HubTile(
                  icon: Icons.people_rounded,
                  label: 'الطلاب',
                  color: AppColors.primary,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => ClassRosterPage(schoolClass: schoolClass)),
                  ),
                ),
                _HubTile(
                  icon: Icons.fact_check_rounded,
                  label: 'الحضور والغياب',
                  color: AppColors.present,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => TeacherAttendancePage(
                        initialClass: TeacherAttendanceClass(
                          classId: schoolClass.id,
                          className: schoolClass.name,
                          subject: schoolClass.subject,
                          periodNumber: 0,
                        ),
                      ),
                    ),
                  ),
                ),
                _HubTile(
                  icon: Icons.grading_rounded,
                  label: 'العلامات',
                  color: AppColors.accentDark,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => TeacherGradesPage(classId: schoolClass.id, className: schoolClass.name),
                    ),
                  ),
                ),
                _HubTile(
                  icon: Icons.sticky_note_2_rounded,
                  label: 'مفكرتي',
                  color: AppColors.excused,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => TeacherNotesPage(classId: schoolClass.id, className: schoolClass.name),
                    ),
                  ),
                ),
                _HubTile(
                  icon: Icons.folder_rounded,
                  label: 'الملفات',
                  color: AppColors.late,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => TeacherFilesHubPage(classId: schoolClass.id, className: schoolClass.name),
                    ),
                  ),
                ),
                _HubTile(
                  icon: Icons.smart_display_rounded,
                  label: 'الفيديوهات',
                  color: AppColors.accent,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => TeacherVideosPage(classId: schoolClass.id, className: schoolClass.name),
                    ),
                  ),
                ),
                _HubTile(
                  icon: Icons.quiz_rounded,
                  label: 'الامتحانات',
                  color: AppColors.error,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => TeacherExamsListPage(classId: schoolClass.id, className: schoolClass.name),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ClassHeaderCard extends StatelessWidget {
  final SchoolClass schoolClass;
  const _ClassHeaderCard({required this.schoolClass});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withOpacity(0.25), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
            child: const Icon(Icons.class_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(schoolClass.name,
                    style: const TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 2),
                Text('${schoolClass.subject} • ${schoolClass.studentCount} طالب',
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.white.withOpacity(0.85))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HubTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _HubTile({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
            boxShadow: [
              BoxShadow(color: color.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 3)),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(height: 10),
              Text(label, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            ],
          ),
        ),
      ),
    );
  }
}
