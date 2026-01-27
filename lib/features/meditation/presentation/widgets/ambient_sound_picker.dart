import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../data/ambient_sound_service.dart';
import '../../data/binaural_audio_service.dart';
import 'brainwave_selector.dart';

class AmbientSoundPicker extends StatefulWidget {
  final Function(AmbientSoundType)? onSoundChanged;
  final double volume;
  final Function(double)? onVolumeChanged;
  final bool showBrainwaves;
  final Function(BrainwaveType)? onBrainwaveChanged;

  const AmbientSoundPicker({
    super.key,
    this.onSoundChanged,
    this.volume = 0.5,
    this.onVolumeChanged,
    this.showBrainwaves = true,
    this.onBrainwaveChanged,
  });

  @override
  State<AmbientSoundPicker> createState() => _AmbientSoundPickerState();
}

class _AmbientSoundPickerState extends State<AmbientSoundPicker> {
  final AmbientSoundService _soundService = AmbientSoundService();
  AmbientSoundType _selectedSound = AmbientSoundType.none;
  late double _volume;
  bool _showVolumeSlider = false;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _volume = widget.volume;
    _selectedSound = _soundService.currentSound;
  }

  void _selectSound(AmbientSoundType soundType) async {
    setState(() {
      _selectedSound = soundType;
      _showVolumeSlider = soundType != AmbientSoundType.none;
    });
    
    await _soundService.play(soundType);
    widget.onSoundChanged?.call(soundType);
  }

  void _updateVolume(double newVolume) {
    setState(() {
      _volume = newVolume;
    });
    _soundService.setVolume(newVolume);
    widget.onVolumeChanged?.call(newVolume);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showBrainwaves) ...[
          Row(
            children: [
              _TabButton(
                label: 'Ambient',
                icon: Icons.water_drop_outlined,
                isSelected: _selectedTab == 0,
                onTap: () => setState(() => _selectedTab = 0),
              ),
              const SizedBox(width: 8),
              _TabButton(
                label: 'Brainwaves',
                icon: Icons.waves_rounded,
                isSelected: _selectedTab == 1,
                onTap: () => setState(() => _selectedTab = 1),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spacing16),
        ],
        if (!widget.showBrainwaves || _selectedTab == 0)
          _buildAmbientSection()
        else
          BrainwaveSelector(
            onBrainwaveChanged: widget.onBrainwaveChanged,
          ),
      ],
    );
  }

  Widget _buildAmbientSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!widget.showBrainwaves)
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'Ambient Sounds',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.jobsObsidian.withOpacity(0.6),
              ),
            ),
          ),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: AmbientSoundService.availableSounds.length,
            itemBuilder: (context, index) {
              final sound = AmbientSoundService.availableSounds[index];
              final isSelected = _selectedSound == sound.type;
              
              return Padding(
                padding: EdgeInsets.only(
                  right: index < AmbientSoundService.availableSounds.length - 1 
                      ? AppSpacing.spacing12 
                      : 0,
                ),
                child: GestureDetector(
                  onTap: () => _selectSound(sound.type),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 70,
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? AppColors.jobsSage.withOpacity(0.2) 
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected 
                            ? AppColors.jobsSage 
                            : Colors.transparent,
                        width: 2,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.jobsSage.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          sound.icon,
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          sound.name,
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 11,
                            fontWeight: isSelected 
                                ? FontWeight.w600 
                                : FontWeight.w500,
                            color: isSelected
                                ? AppColors.jobsSage
                                : AppColors.jobsObsidian.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (_showVolumeSlider) ...[
          const SizedBox(height: AppSpacing.spacing16),
          Row(
            children: [
              Icon(
                Icons.volume_down_rounded,
                color: AppColors.jobsObsidian.withOpacity(0.5),
                size: 20,
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: AppColors.jobsSage,
                    inactiveTrackColor: AppColors.jobsSage.withOpacity(0.2),
                    thumbColor: AppColors.jobsSage,
                    overlayColor: AppColors.jobsSage.withOpacity(0.1),
                    trackHeight: 4,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 8,
                    ),
                  ),
                  child: Slider(
                    value: _volume,
                    onChanged: _updateVolume,
                    min: 0.0,
                    max: 1.0,
                  ),
                ),
              ),
              Icon(
                Icons.volume_up_rounded,
                color: AppColors.jobsObsidian.withOpacity(0.5),
                size: 20,
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.jobsSage.withOpacity(0.15) 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? AppColors.jobsSage 
                : AppColors.jobsObsidian.withOpacity(0.15),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? AppColors.jobsSage
                  : AppColors.jobsObsidian.withOpacity(0.5),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? AppColors.jobsSage
                    : AppColors.jobsObsidian.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
