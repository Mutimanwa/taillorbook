import 'package:flutter/material.dart';

/// Ombres standardisées de l'interface (profondeur douce et discrète).
class AppShadows {
  AppShadows._();

  /// Ombre des cartes et blocs de contenu.
  static const List<BoxShadow> card = <BoxShadow>[
    BoxShadow(color: Color(0x14101828), offset: Offset(0, 4), blurRadius: 16),
  ];

  /// Ombre des éléments flottants (barres, résumés collants, dialogs).
  static const List<BoxShadow> floating = <BoxShadow>[
    BoxShadow(color: Color(0x1F101828), offset: Offset(0, 8), blurRadius: 24),
  ];

  /// Ombre légère (survol, cartes secondaires).
  static const List<BoxShadow> subtle = <BoxShadow>[
    BoxShadow(color: Color(0x0A101828), offset: Offset(0, 2), blurRadius: 8),
  ];
}
