import 'package:flutter/material.dart';

/// Maps a human colour name (as entered by the admin, e.g. "Navy", "Maroon")
/// to a display [Color] for swatches on the product and cart screens.
/// Unknown names fall back to a neutral grey.
Color colorFromName(String name) {
  switch (name.trim().toLowerCase()) {
    case 'white':
      return Colors.white;
    case 'black':
      return const Color(0xFF111827);
    case 'navy':
      return const Color(0xFF1B2B3A);
    case 'blue':
      return const Color(0xFF2563EB);
    case 'teal':
      return const Color(0xFF1B6B61);
    case 'green':
      return const Color(0xFF16A34A);
    case 'red':
      return const Color(0xFFDC2626);
    case 'maroon':
      return const Color(0xFF7F1D1D);
    case 'brown':
      return const Color(0xFFA0522D);
    case 'beige':
      return const Color(0xFFE8DCC4);
    case 'cream':
      return const Color(0xFFF5EFE0);
    case 'natural':
      return const Color(0xFFEADDCA);
    case 'grey':
    case 'gray':
      return const Color(0xFF9CA3AF);
    case 'gold':
      return const Color(0xFFD4AF37);
    case 'orange':
      return const Color(0xFFF59E0B);
    case 'yellow':
      return const Color(0xFFEAB308);
    case 'pink':
      return const Color(0xFFEC4899);
    case 'purple':
      return const Color(0xFF7C3AED);
    default:
      return const Color(0xFFD1D5DB);
  }
}

/// A light colour needs a border so a white/cream swatch is visible on white.
bool isLightColor(Color c) => c.computeLuminance() > 0.8;
