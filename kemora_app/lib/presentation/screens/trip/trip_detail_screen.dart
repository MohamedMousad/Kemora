import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../widgets/kemora_app_bar.dart';
import '../../../data/local/trip_mock_data.dart';
import '../../../data/local/place_data.dart';
import '../explore/place_detail_screen.dart';
import '../../../domain/entities/ai_itinerary.dart' as ai;
import '../../../domain/entities/trip_plan_request.dart';
import '../../viewmodels/trip_view_model.dart';
import '../../viewmodels/auth_view_model.dart';

enum _SaveState { idle, loading, saved, error }

class TripDetailScreen extends StatefulWidget {
  final LocalTrip? trip;
  final ai.AIItinerary? aiItinerary;
  final TripPlanRequest? request;

  const TripDetailScreen({super.key, this.trip, this.aiItinerary, this.request});

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  _SaveState _saveState = _SaveState.idle;

  bool get isAi => widget.aiItinerary != null;

  ai.AIItinerary get currentAiItinerary {
    if (!isAi) throw Exception('Not AI itinerary');
    final tripVM = context.watch<TripViewModel>();
    return tripVM.currentPlan ?? widget.aiItinerary!;
  }

  Future<void> _onSaveTrip() async {
    final authVM = context.read<AuthViewModel>();
    if (authVM.state != AuthState.authenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please sign in to save your trip.'),
          action: SnackBarAction(
            label: 'Sign In',
            onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil('/login', (r) => false),
          ),
        ),
      );
      return;
    }

    setState(() => _saveState = _SaveState.loading);

    final DateTime? startDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'When does your journey start?',
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppColors.primaryContainer,
            onPrimary: AppColors.onPrimary,
            onSurface: AppColors.onSurface,
          ),
        ),
        child: child!,
      ),
    );

    if (startDate == null) {
      setState(() => _saveState = _SaveState.idle);
      return;
    }

    final endDate = startDate.add(Duration(days: currentAiItinerary.days.length - 1));

    if (!mounted) return;

    final tripVM = context.read<TripViewModel>();
    final success = await tripVM.savePlan(startDate, endDate);

    if (!mounted) return;

    if (success) {
      setState(() => _saveState = _SaveState.saved);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your trip has been saved! dYZ%'),
          backgroundColor: AppColors.primaryContainer,
        ),
      );
    } else {
      setState(() => _saveState = _SaveState.error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tripVM.errorMessage ?? 'Could not save trip. Try again.'),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: _onSaveTrip,
          ),
        ),
      );
    }
  }

  void _onSwapPlace(String currentPlaceName) async {
    final preferences = await showDialog<String>(
      context: context,
      builder: (context) {
        String input = '';
        return AlertDialog(
          title: const Text('Swap Place'),
          content: TextField(
            decoration: const InputDecoration(hintText: 'Any specific preferences? (e.g. food)'),
            onChanged: (val) => input = val,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.pop(context, input), child: const Text('Swap')),
          ],
        );
      },
    );

    if (preferences != null) {
      if (!mounted) return;
      context.read<TripViewModel>().swapPlace(currentPlaceName, preferences);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = isAi ? currentAiItinerary.title : widget.trip!.title;
    final duration = isAi ? '${currentAiItinerary.days.length} Days' : '${widget.trip!.durationDays} Days • ${widget.trip!.governorate}';

    return Scaffold(
      appBar: KemoraAppBar(
        showBack: true,
        trailing: isAi && _saveState != _SaveState.saved
            ? GestureDetector(
                onTap: _saveState == _SaveState.loading ? null : _onSaveTrip,
                child: _saveState == _SaveState.loading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text('Save Trip', style: AppTypography.titleMedium.copyWith(color: AppColors.primaryContainer)),
              )
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('YOUR EXPEDITION', style: AppTypography.labelSmall.copyWith(color: AppColors.primaryContainer)),
            const SizedBox(height: 8),
            Text(title, style: AppTypography.displaySmall),
            const SizedBox(height: 4),
            Text(duration, style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 32),
            if (isAi)
              ...currentAiItinerary.days.map((day) => _buildAiDaySection(context, day))
            else
              ...widget.trip!.days.map((day) => _buildDaySection(context, day)),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildDaySection(BuildContext context, TripDay day) {
    return _buildDayBase(
      context,
      day.dayNumber,
      day.title,
      day.stops.length,
      (index, isLast) => _buildTimelineStop(context, day.stops[index], isLast),
    );
  }

  Widget _buildAiDaySection(BuildContext context, ai.TripDay day) {
    return _buildDayBase(
      context,
      day.dayNumber,
      day.dailySummary ?? 'Day ${day.dayNumber}',
      day.activities.length,
      (index, isLast) => _buildAiTimelineStop(context, day.activities[index], isLast),
    );
  }

  Widget _buildDayBase(BuildContext context, int dayNumber, String title, int count, Widget Function(int, bool) stopBuilder) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.primaryContainer.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text('$dayNumber',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text('Day $dayNumber — $title', style: AppTypography.titleLarge, maxLines: 2, overflow: TextOverflow.ellipsis)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ...List.generate(count, (index) {
          final isLast = index == count - 1;
          return stopBuilder(index, isLast);
        }),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildTimelineStop(BuildContext context, TripStop stop, bool isLast) {
    final place = placesData.where((p) => p.id == stop.placeId).firstOrNull;
    final categoryIcon = _categoryIcon(stop.category);

    return _buildStopBase(
      context: context,
      isLast: isLast,
      isCompleted: stop.isCompleted,
      name: stop.name,
      time: stop.time,
      icon: categoryIcon,
      imageUrl: place?.imageAsset,
      isNetworkImage: false,
      onTap: () {
        if (place != null) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => PlaceDetailScreen(place: place)));
        }
      },
      onLongPress: () => _showStopInfo(context, stop),
    );
  }

  Widget _buildAiTimelineStop(BuildContext context, ai.ItineraryItem stop, bool isLast) {
    final categoryIcon = _categoryIcon(stop.category ?? 'Others');
    return _buildStopBase(
      context: context,
      isLast: isLast,
      isCompleted: false,
      name: stop.name,
      time: stop.timeOfDay,
      icon: categoryIcon,
      imageUrl: stop.imageUrl,
      isNetworkImage: true,
      onTap: null,
      trailing: PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert, color: AppColors.outlineVariant),
        onSelected: (val) {
          if (val == 'swap') _onSwapPlace(stop.name);
        },
        itemBuilder: (context) => [
          const PopupMenuItem(value: 'swap', child: Text('Swap Place')),
        ],
      ),
    );
  }

  Widget _buildStopBase({
    required BuildContext context,
    required bool isLast,
    required bool isCompleted,
    required String name,
    required String time,
    required IconData icon,
    String? imageUrl,
    bool isNetworkImage = false,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    Widget? trailing,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted ? AppColors.primaryContainer : AppColors.surfaceContainerHigh,
                    border: Border.all(
                      color: isCompleted ? AppColors.primaryContainer : AppColors.outlineVariant,
                      width: 2,
                    ),
                  ),
                  child: isCompleted ? const Icon(Icons.check, size: 8, color: Colors.white) : null,
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: isCompleted ? AppColors.primaryContainer : AppColors.outlineVariant.withValues(alpha: 0.4),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: GestureDetector(
                onTap: onTap,
                onLongPress: onLongPress,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: imageUrl != null && imageUrl.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: isNetworkImage
                                    ? Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(icon, color: AppColors.outlineVariant))
                                    : Image.asset(imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(icon, color: AppColors.outlineVariant)),
                              )
                            : Icon(icon, color: AppColors.outlineVariant),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name, style: AppTypography.titleMedium),
                            const SizedBox(height: 2),
                            Text(time, style: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceVariant)),
                          ],
                        ),
                      ),
                      if (trailing != null)
                        trailing
                      else if (isCompleted)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('Done', style: AppTypography.labelSmall.copyWith(color: AppColors.primaryContainer)),
                        )
                      else
                        const Icon(Icons.chevron_right, color: AppColors.outline, size: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showStopInfo(BuildContext context, TripStop stop) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(stop.name, style: AppTypography.headlineSmall),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.star, color: AppColors.tertiary, size: 20),
                const SizedBox(width: 8),
                Text('${stop.reviewScore}/5.0', style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Text('Review Score', style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant)),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: stop.tags.map((tag) => Chip(
                    label: Text(tag, style: AppTypography.labelMedium),
                    backgroundColor: AppColors.surfaceContainer,
                    side: BorderSide.none,
                  )).toList(),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Ancient Places': return Icons.account_balance;
      case 'Museums': return Icons.museum;
      case 'Hotels': return Icons.hotel;
      case 'Restaurants': return Icons.restaurant;
      default: return Icons.place;
    }
  }
}
