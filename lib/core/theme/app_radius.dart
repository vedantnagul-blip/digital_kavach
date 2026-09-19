import 'package:flutter/material.dart';

class AppRadius {
  const AppRadius._();

  static const double s8 = 8;
  static const double m12 = 12;
  static const double l16 = 16;
  static const double xl24 = 24;
  static const double xxl32 = 32; // Added for the large modern cards
  static const double pill999 = 999;

  static const BorderRadius rS = BorderRadius.all(Radius.circular(s8));
  static const BorderRadius rM = BorderRadius.all(Radius.circular(m12));
  static const BorderRadius rL = BorderRadius.all(Radius.circular(l16));
  static const BorderRadius rXl = BorderRadius.all(Radius.circular(xl24));
  static const BorderRadius rXxl = BorderRadius.all(Radius.circular(xxl32));
  static const BorderRadius rPill = BorderRadius.all(Radius.circular(pill999));
}