import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AdaptiveIconData {
  const AdaptiveIconData({
    required this.material,
    required this.cupertino,
  });

  final IconData material;
  final IconData cupertino;

  IconData get value {
    return switch (defaultTargetPlatform) {
      TargetPlatform.iOS || TargetPlatform.macOS => cupertino,
      _ => material,
    };
  }
}

class AppIcons {
  const AppIcons._();

  static const home = AdaptiveIconData(
    material: Icons.home_outlined,
    cupertino: CupertinoIcons.house,
  );

  static const homeFilled = AdaptiveIconData(
    material: Icons.home,
    cupertino: CupertinoIcons.house_fill,
  );

  static const labs = AdaptiveIconData(
    material: Icons.monitor_heart_outlined,
    cupertino: CupertinoIcons.waveform_path_ecg,
  );

  static const labsFilled = AdaptiveIconData(
    material: Icons.monitor_heart,
    cupertino: CupertinoIcons.waveform_path_ecg,
  );

  static const medication = AdaptiveIconData(
    material: Icons.medication_outlined,
    cupertino: CupertinoIcons.bandage,
  );

  static const medicationFilled = AdaptiveIconData(
    material: Icons.medication,
    cupertino: CupertinoIcons.bandage_fill,
  );

  static const more = AdaptiveIconData(
    material: Icons.grid_view_outlined,
    cupertino: CupertinoIcons.square_grid_2x2,
  );

  static const moreFilled = AdaptiveIconData(
    material: Icons.grid_view,
    cupertino: CupertinoIcons.square_grid_2x2_fill,
  );
}
