import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../teacher_common/domain/entities/teacher_subject.dart';
import '../../../teacher_common/presentation/widgets/subject_picker_field.dart';
import '../cubit/teacher_videos_cubit.dart';

class TeacherVideoFormPage extends StatefulWidget {
  final int classId;
  const TeacherVideoFormPage({super.key, required this.classId});

  @override
  State<TeacherVideoFormPage> createState() => _TeacherVideoFormPageState();
}

class _TeacherVideoFormPageState extends State<TeacherVideoFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _urlCtrl = TextEditingController();
  TeacherSubject? _subject;
  bool _saving = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _urlCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_subject == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اختر المادة أولاً', style: TextStyle(fontFamily: 'Cairo')), backgroundColor: AppColors.error),
      );
      return;
    }
    setState(() => _saving = true);
    final cubit = context.read<TeacherVideosCubit>();
    final error = await cubit.create(subjectId: _subject!.id, title: _titleCtrl.text.trim(), youtubeUrl: _urlCtrl.text.trim());
    if (!mounted) return;
    setState(() => _saving = false);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error, style: const TextStyle(fontFamily: 'Cairo')), backgroundColor: AppColors.error));
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('إضافة فيديو', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 15)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleCtrl,
              style: const TextStyle(fontFamily: 'Cairo'),
              decoration: InputDecoration(
                labelText: 'عنوان الفيديو',
                labelStyle: const TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'الرجاء إدخال العنوان' : null,
            ),
            const SizedBox(height: 14),
            SubjectPickerField(
              classId: widget.classId,
              selectedSubjectId: _subject?.id,
              onChanged: (s) => setState(() => _subject = s),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _urlCtrl,
              style: const TextStyle(fontFamily: 'Cairo'),
              keyboardType: TextInputType.url,
              textDirection: TextDirection.ltr,
              decoration: InputDecoration(
                labelText: 'رابط يوتيوب',
                hintText: 'https://youtube.com/watch?v=...',
                hintStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 12),
                labelStyle: const TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'الرجاء إدخال رابط الفيديو';
                if (YoutubePlayer.convertUrlToId(v.trim()) == null) return 'رابط يوتيوب غير صحيح';
                return null;
              },
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _saving
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('حفظ الفيديو', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}
