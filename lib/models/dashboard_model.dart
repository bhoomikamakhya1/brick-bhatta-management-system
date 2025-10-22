import 'package:flutter/material.dart';

class DashboardStats {
  final int labourEntries;
  final double salesToday;
  final double payables;
  final double receivables;

  DashboardStats({
    required this.labourEntries,
    required this.salesToday,
    required this.payables,
    required this.receivables,
  });

  factory DashboardStats.sample() {
    return DashboardStats(
      labourEntries: 24,
      salesToday: 45000.0,
      payables: 12500.0,
      receivables: 8200.0,
    );
  }
}

class QuickAction {
  final String title;
  final String titleHindi;
  final IconData icon;
  final VoidCallback? onTap;

  QuickAction({
    required this.title,
    required this.titleHindi,
    required this.icon,
    this.onTap,
  });
}

