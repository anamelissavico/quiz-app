import 'package:flutter/material.dart';

class QuizziaBottomNav extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTabChange;

  const QuizziaBottomNav({
    Key? key,
    required this.currentIndex,
    required this.onTabChange,
  }) : super(key: key);

  @override
  State<QuizziaBottomNav> createState() => _QuizziaBottomNavState();
}

class _QuizziaBottomNavState extends State<QuizziaBottomNav> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFF7E22CE), width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              /// 🔥 INÍCIO = index 0
              _buildNavItem(
                index: 0,
                icon: Icons.home_rounded,
                label: 'Início',
                isActive: widget.currentIndex == 0,
              ),

              /// 🔥 CRIAR = index 1
              _buildAddButton(),

              /// 🔥 PERFIL = index 2
              _buildNavItem(
                index: 2,
                icon: Icons.person_rounded,
                label: 'Perfil',
                isActive: widget.currentIndex == 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required bool isActive,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () => widget.onTabChange(index),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? Color(0xFFF3E8FF) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 2,
                width: isActive ? 8 : 0,
                decoration: BoxDecoration(
                  color: Color(0xFF7E22CE),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              SizedBox(height: 4),
              Icon(
                icon,
                color: isActive ? Color(0xFF7E22CE) : Color(0xFF9CA3AF),
                size: 24,
              ),
              SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? Color(0xFF7E22CE) : Color(0xFF9CA3AF),
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔥 CRIAR = index 1
  Widget _buildAddButton() {
    return Container(
      width: 60,
      child: GestureDetector(
        onTap: () => widget.onTabChange(1),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              margin: EdgeInsets.only(bottom: 4, top: 8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFBBF24),
                    Color(0xFFF59E0B),
                    Color(0xFFF97316),
                  ],
                ),
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFFFBBF24).withOpacity(0.5),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: -1.0, end: 1.0),
                      duration: Duration(milliseconds: 2000),
                      builder: (context, value, child) {
                        return ClipOval(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment(value - 0.3, 0),
                                end: Alignment(value + 0.3, 0),
                                colors: [
                                  Colors.transparent,
                                  Colors.white.withOpacity(0.3),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      onEnd: () => setState(() {}),
                    ),
                  ),
                  Center(
                    child: Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              'Criar',
              style: TextStyle(
                color: Color(0xFFD97706),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
