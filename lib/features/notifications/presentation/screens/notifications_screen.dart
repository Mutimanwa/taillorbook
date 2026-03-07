import 'package:flutter/material.dart';
import 'package:taillorbook/core/theme/app_colors.dart';
import 'package:taillorbook/core/theme/app_typography.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<Map<String, dynamic>> _notifications = [
    {
      'title': 'Nouvelle Collection !',
      'body': 'Découvrez "Éclat d\'Hiver", notre nouvelle collection capsule.',
      'time': 'Il y a 2h',
      'isRead': false,
      'type': Icons.auto_awesome,
    },
    {
      'title': 'Rendez-vous confirmé',
      'body': 'Votre essayage pour demain à 14h30 est bien confirmé.',
      'time': 'Hier',
      'isRead': true,
      'type': Icons.calendar_today,
    },
    {
      'title': 'Mise à jour Chris Couture',
      'body':
          'Découvrez les coulisses de notre atelier dans notre nouveau post.',
      'time': '2 jours',
      'isRead': true,
      'type': Icons.history_edu,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: const Text('NOTIFICATIONS'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                for (var n in _notifications) {
                  n['isRead'] = true;
                }
              });
            },
            child: const Text('TOUT LIRE'),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: _notifications.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final n = _notifications[index];
          return _buildNotificationItem(n, index);
        },
      ),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> n, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _notifications[index]['isRead'] = true;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: n['isRead']
              ? Border.all(color: AppColors.greySubtle)
              : Border.all(color: AppColors.gold, width: 1),
          boxShadow: [
            if (!n['isRead'])
              BoxShadow(
                color: AppColors.gold.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.offWhite,
                shape: BoxShape.circle,
              ),
              child: Icon(n['type'], color: AppColors.black, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(n['title'], style: AppTypography.labelLarge),
                      if (!n['isRead'])
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.gold,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(n['body'], style: AppTypography.bodyMedium),
                  const SizedBox(height: 8),
                  Text(
                    n['time'],
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.black.withOpacity(0.4),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
