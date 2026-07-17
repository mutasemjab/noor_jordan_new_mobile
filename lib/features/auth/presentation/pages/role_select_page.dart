import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';

class RoleSelectPage extends StatefulWidget {
  const RoleSelectPage({super.key});

  @override
  State<RoleSelectPage> createState() => _RoleSelectPageState();
}

class _RoleSelectPageState extends State<RoleSelectPage>
    with TickerProviderStateMixin {
  String? _selectedRole;
  late List<AnimationController> _cardControllers;
  late List<Animation<Offset>> _cardSlides;
  late AnimationController _buttonController;
  late Animation<double> _buttonFade;

  @override
  void initState() {
    super.initState();
    _cardControllers = List.generate(
      2,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      ),
    );
    _cardSlides = List.generate(
      2,
      (i) => Tween<Offset>(
        begin: const Offset(0, 0.5),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _cardControllers[i],
        curve: Curves.easeOutCubic,
      )),
    );
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _buttonFade = CurvedAnimation(parent: _buttonController, curve: Curves.easeIn);

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _cardControllers[0].forward();
    });
    Future.delayed(const Duration(milliseconds: 420), () {
      if (mounted) _cardControllers[1].forward();
    });
  }

  @override
  void dispose() {
    for (final c in _cardControllers) c.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  void _selectRole(String role) {
    setState(() => _selectedRole = role);
    _buttonController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.heroGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Spacer(),
                // Logo + Title
                Container(
                  width: 90,
                  height: 90,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'مدارس نور الأردن الدولية',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'اختر نوع حسابك للمتابعة',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 15,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const Spacer(),
                // Role Cards
                SlideTransition(
                  position: _cardSlides[0],
                  child: _RoleCard(
                    icon: Icons.school_rounded,
                    title: 'طالب',
                    subtitle: 'تابع علاماتك وجدولك وحضورك',
                    isSelected: _selectedRole == 'student',
                    selectedColor: AppColors.accent,
                    onTap: () => _selectRole('student'),
                  ),
                ),
                const SizedBox(height: 16),
                SlideTransition(
                  position: _cardSlides[1],
                  child: _RoleCard(
                    icon: Icons.person_rounded,
                    title: 'معلم',
                    subtitle: 'إدارة صفوفك وعلامات طلابك',
                    isSelected: _selectedRole == 'teacher',
                    selectedColor: Colors.white,
                    onTap: () => _selectRole('teacher'),
                  ),
                ),
                const SizedBox(height: 32),
                // Continue Button
                FadeTransition(
                  opacity: _buttonFade,
                  child: AnimatedOpacity(
                    opacity: _selectedRole != null ? 1.0 : 0.4,
                    duration: const Duration(milliseconds: 200),
                    child: SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _selectedRole == null
                            ? null
                            : () {
                                if (_selectedRole == 'student') {
                                  context.push('/student-login');
                                } else {
                                  context.push('/teacher-login');
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: AppColors.primary,
                          disabledBackgroundColor: AppColors.accent.withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'متابعة',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final Color selectedColor;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.selectedColor,
    required this.onTap,
  });

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = _ctrl;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.reverse(),
      onTapUp: (_) {
        _ctrl.forward();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.forward(),
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? Colors.white.withOpacity(0.15)
                : Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: widget.isSelected
                  ? widget.selectedColor
                  : Colors.white.withOpacity(0.2),
              width: widget.isSelected ? 2.5 : 1,
            ),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? widget.selectedColor.withOpacity(0.2)
                      : Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.icon,
                  color: widget.isSelected ? widget.selectedColor : Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: widget.isSelected ? widget.selectedColor : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.subtitle,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.isSelected)
                Icon(Icons.check_circle_rounded,
                    color: widget.selectedColor, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
