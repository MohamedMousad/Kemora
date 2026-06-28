import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../widgets/kemora_app_bar.dart';
import '../../../domain/entities/trip.dart';
import '../explore/place_detail_screen.dart';
import '../../../domain/entities/ai_itinerary.dart' as ai;
import '../../../domain/entities/trip_plan_request.dart';
import '../../viewmodels/trip_view_model.dart';
import '../../viewmodels/auth_view_model.dart';

enum _SaveState { idle, loading, saved, error }

class TripDetailScreen extends StatefulWidget {
  final Trip? trip;
  final ai.AIItinerary? aiItinerary;
  final TripPlanRequest? request;

  const TripDetailScreen({super.key, this.trip, this.aiItinerary, this.request});

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  _SaveState _saveState = _SaveState.idle;
  bool _isLoadingDetails = false;
  Trip? _fullTrip;

  Trip? get activeTrip => _fullTrip ?? widget.trip;

  @override
  void initState() {
    super.initState();
    if (widget.trip != null && widget.trip!.savedItinerary == null) {
      _isLoadingDetails = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final fullTrip = await context.read<TripViewModel>().loadTripDetails(widget.trip!.id);
        if (mounted && fullTrip != null) {
          setState(() {
            _fullTrip = fullTrip;
            _isLoadingDetails = false;
          });
          if (fullTrip.savedItinerary != null) {
            context.read<TripViewModel>().setCurrentPlan(fullTrip.savedItinerary!);
          }
        } else if (mounted) {
          setState(() => _isLoadingDetails = false);
        }
      });
    } else {
      _fullTrip = widget.trip;
      if (_fullTrip?.savedItinerary != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.read<TripViewModel>().setCurrentPlan(_fullTrip!.savedItinerary!);
        });
      }
    }
  }

  bool get isAi => widget.aiItinerary != null || activeTrip?.savedItinerary != null;

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<TripViewModel>().setCurrentPlan(null);
    });
    super.dispose();
  }

  ai.AIItinerary _getCurrentAiItinerary(BuildContext context, {bool listen = true}) {
    if (!isAi) throw Exception('Not AI itinerary');
    final tripVM = listen ? context.watch<TripViewModel>() : context.read<TripViewModel>();
    return tripVM.currentPlan ?? widget.aiItinerary ?? activeTrip!.savedItinerary!;
  }

  Future<void> _onSaveTrip() async {
    final authVM = context.read<AuthViewModel>();
    if (authVM.state != AuthState.authenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to save your trip.')),
      );
      return;
    }

    setState(() => _saveState = _SaveState.loading);

    final currentItinerary = _getCurrentAiItinerary(context, listen: false);
    // Use today as start date, compute end from itinerary length (no date picker)
    final startDate = DateTime.now();
    final endDate = startDate.add(Duration(days: currentItinerary.days.length > 0 ? currentItinerary.days.length - 1 : 0));

    final tripVM = context.read<TripViewModel>();
    final success = await tripVM.savePlan(startDate, endDate);

    if (!mounted) return;

    if (success) {
      setState(() => _saveState = _SaveState.saved);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Trip saved successfully! ✓'),
          backgroundColor: AppColors.primaryContainer,
        ),
      );
    } else {
      setState(() => _saveState = _SaveState.error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tripVM.errorMessage ?? 'Could not save trip. Try again.'),
          action: SnackBarAction(label: 'Retry', onPressed: _onSaveTrip),
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
    if (_isLoadingDetails) {
      return Scaffold(
        appBar: KemoraAppBar(showBack: true),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final currentItinerary = isAi ? _getCurrentAiItinerary(context) : null;
    final title = isAi ? currentItinerary!.title : activeTrip!.title;
    final durationDays = !isAi ? activeTrip!.endDate.difference(activeTrip!.startDate).inDays + 1 : 0;
    final duration = isAi ? '${currentItinerary!.days.length} Days' : '${durationDays > 0 ? durationDays : 1} Days • ${activeTrip!.location}';

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
              ..._getCurrentAiItinerary(context).days.asMap().entries.map((entry) => _buildAiDaySection(context, entry.key, entry.value))
            else
              _buildTripPlacesSection(context, activeTrip!.plannedPlaces),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildTripPlacesSection(BuildContext context, List<dynamic> places) {
    if (places.isEmpty) return const Text('No places planned yet.');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Planned Places', style: AppTypography.titleLarge),
        const SizedBox(height: 16),
        ...List.generate(places.length, (index) {
          final place = places[index];
          final isLast = index == places.length - 1;
          return _buildTimelineStop(context, place, isLast);
        }),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildAiDaySection(BuildContext context, int dayIndex, ai.TripDay day) {
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
                  child: Text('${day.dayNumber}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text('Day ${day.dayNumber} — ${day.dailySummary ?? "Day ${day.dayNumber}"}', style: AppTypography.titleLarge, maxLines: 2, overflow: TextOverflow.ellipsis)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: day.activities.length,
          onReorder: (oldIndex, newIndex) {
            context.read<TripViewModel>().reorderPlace(dayIndex, oldIndex, newIndex);
          },
          itemBuilder: (context, index) {
            final isLast = index == day.activities.length - 1;
            return Container(
              key: ValueKey(day.activities[index].name + index.toString()),
              child: _buildAiTimelineStop(context, dayIndex, index, day.activities[index], isLast),
            );
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildTimelineStop(BuildContext context, dynamic place, bool isLast) {
    final categoryIcon = _categoryIcon('Others');

    return _buildStopBase(
      context: context,
      isLast: isLast,
      isCompleted: false,
      name: place.name,
      time: '',
      icon: categoryIcon,
      imageUrl: place.imageUrl ?? place.mainImageUrl,
      isNetworkImage: true,
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => PlaceDetailScreen(placeId: place.id.toString())));
      },
    );
  }

  Widget _buildAiTimelineStop(BuildContext context, int dayIndex, int activityIndex, ai.ItineraryItem stop, bool isLast) {
    final categoryIcon = _categoryIcon(stop.category ?? 'Others');
    return _buildStopBase(
      context: context,
      isLast: isLast,
      isCompleted: stop.isVisited,
      onCircleTap: () => context.read<TripViewModel>().toggleVisitedStatus(widget.trip?.id ?? '', dayIndex, activityIndex),
      name: stop.name,
      time: stop.timeOfDay,
      icon: categoryIcon,
      imageUrl: stop.imageUrl,
      isNetworkImage: true,
      onTap: null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.drag_handle, color: AppColors.outlineVariant),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.outlineVariant),
            onSelected: (val) {
              if (val == 'swap') _onSwapPlace(stop.name);
              if (val == 'remove') context.read<TripViewModel>().removePlace(dayIndex, activityIndex);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'swap', child: Text('Swap Place')),
              const PopupMenuItem(value: 'remove', child: Text('Remove', style: TextStyle(color: Colors.red))),
            ],
          ),
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
    VoidCallback? onCircleTap,
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
                GestureDetector(
                  onTap: onCircleTap,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted ? AppColors.primaryContainer : AppColors.surfaceContainerHigh,
                      border: Border.all(
                        color: isCompleted ? AppColors.primaryContainer : AppColors.outlineVariant,
                        width: 2,
                      ),
                    ),
                    child: isCompleted ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
                  ),
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
