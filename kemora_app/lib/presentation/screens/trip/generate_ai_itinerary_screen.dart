import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/entities/trip_plan_request.dart';
import '../../viewmodels/trip_view_model.dart';
import '../../viewmodels/auth_view_model.dart';
import 'ai_itinerary_result_screen.dart';

// Egyptian governorates with their coordinates
const List<Map<String, dynamic>> _kEgyptGovernorates = [
  {'name': 'Cairo', 'lat': 30.0444, 'lng': 31.2357},
  {'name': 'Alexandria', 'lat': 31.2001, 'lng': 29.9187},
  {'name': 'Luxor', 'lat': 25.6872, 'lng': 32.6396},
  {'name': 'Aswan', 'lat': 24.0889, 'lng': 32.8998},
  {'name': 'Sharm El-Sheikh', 'lat': 27.9158, 'lng': 34.3300},
  {'name': 'Hurghada', 'lat': 27.2574, 'lng': 33.8129},
  {'name': 'Giza', 'lat': 30.0131, 'lng': 31.2089},
  {'name': 'Dahab', 'lat': 28.5094, 'lng': 34.5198},
  {'name': 'Siwa Oasis', 'lat': 29.2031, 'lng': 25.5192},
  {'name': 'El-Gouna', 'lat': 27.3995, 'lng': 33.6780},
  {'name': 'Port Said', 'lat': 31.2565, 'lng': 32.2841},
  {'name': 'Marsa Matrouh', 'lat': 31.3543, 'lng': 27.2373},
];

class GenerateAIItineraryScreen extends StatefulWidget {
  final String? preSelectedPlaceId;
  final String? preSelectedPlaceName;
  final double? preSelectedLat;
  final double? preSelectedLng;

  const GenerateAIItineraryScreen({
    super.key,
    this.preSelectedPlaceId,
    this.preSelectedPlaceName,
    this.preSelectedLat,
    this.preSelectedLng,
  });

  @override
  State<GenerateAIItineraryScreen> createState() => _GenerateAIItineraryScreenState();
}

class _GenerateAIItineraryScreenState extends State<GenerateAIItineraryScreen> {
  int _durationDays = 3;
  String? _selectedBudget;
  String? _preferences;
  final List<String> _selectedTourismTypes = [];
  Map<String, dynamic>? _selectedGov; // Selected governorate

  final List<Map<String, dynamic>> _tourismOptions = [
    {'name': 'CulturalHeritage', 'label': 'Historical', 'icon': Icons.account_balance},
    {'name': 'Leisure', 'label': 'Leisure', 'icon': Icons.beach_access},
    {'name': 'Adventure', 'label': 'Adventure', 'icon': Icons.terrain},
    {'name': 'ReligiousPilgrimage', 'label': 'Religious', 'icon': Icons.church},
    {'name': 'Sports', 'label': 'Sports', 'icon': Icons.sports_soccer},
    {'name': 'Culinary', 'label': 'Culinary', 'icon': Icons.restaurant},
    {'name': 'EcoTourism', 'label': 'Nature', 'icon': Icons.nature_people},
    {'name': 'MedicalWellness', 'label': 'Wellness', 'icon': Icons.spa},
    {'name': 'Business', 'label': 'Business', 'icon': Icons.business_center},
  ];

  @override
  void initState() {
    super.initState();
    final authVM = context.read<AuthViewModel>();
    _selectedBudget = authVM.user?.preferences?.budget ?? 'Mid-Range';
    // Default to Cairo if no place pre-selected
    _selectedGov = _kEgyptGovernorates.first;
  }

  void _onGenerate() async {
    final tripVM = context.read<TripViewModel>();

    // Use pre-selected place coords if provided, otherwise use picked governorate
    final double lat = widget.preSelectedLat ?? (_selectedGov?['lat'] as double? ?? 30.0444);
    final double lng = widget.preSelectedLng ?? (_selectedGov?['lng'] as double? ?? 31.2357);
    final String location = widget.preSelectedPlaceName != null
        ? widget.preSelectedPlaceName!
        : (_selectedGov?['name'] as String? ?? 'Cairo');

    if (widget.preSelectedLat == null && _selectedGov == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a destination city first.')),
      );
      return;
    }

    final request = TripPlanRequest(
      latitude: lat,
      longitude: lng,
      maxRadiusKm: 25,
      durationDays: _durationDays,
      budget: _selectedBudget,
      location: location,
      centerPlaceId: widget.preSelectedPlaceId != null ? int.tryParse(widget.preSelectedPlaceId!) : null,
      preferences: _preferences,
      tourismTypes: _selectedTourismTypes,
    );

    await tripVM.generateAiItinerary(request);

    if (!mounted) return;

    if (tripVM.state == TripState.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tripVM.errorMessage ?? 'Failed to generate itinerary. Please try again.'),
          backgroundColor: Colors.red[700],
          duration: const Duration(seconds: 5),
          action: SnackBarAction(label: 'OK', textColor: Colors.white, onPressed: () {}),
        ),
      );
      return;
    }

    if (tripVM.state == TripState.loaded && tripVM.currentPlan != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AIItineraryResultScreen(
            itinerary: tripVM.currentPlan!,
            request: request,
          ),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final tripVM = context.watch<TripViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('AI Trip Planner', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.preSelectedPlaceName != null)
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFC5A358).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFC5A358).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Color(0xFFC5A358)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Planning around: ${widget.preSelectedPlaceName}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              const Text('Where do you want to go?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.grey[50],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButton<Map<String, dynamic>>(
                  value: _selectedGov,
                  isExpanded: true,
                  underline: const SizedBox(),
                  borderRadius: BorderRadius.circular(16),
                  icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFFC5A358)),
                  onChanged: (val) => setState(() => _selectedGov = val),
                  items: _kEgyptGovernorates.map((gov) {
                    return DropdownMenuItem<Map<String, dynamic>>(
                      value: gov,
                      child: Row(
                        children: [
                          const Icon(Icons.location_city, size: 18, color: Color(0xFFC5A358)),
                          const SizedBox(width: 10),
                          Text(gov['name'] as String,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),
            ],

            const Text('How many days is your trip?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [1, 2, 3, 5, 7].map((d) => _buildDayButton(d)).toList(),
            ),
            const SizedBox(height: 32),
            const Text('What is your daily budget?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            _buildBudgetSelector(),
            const SizedBox(height: 32),
            const Text('Your Interests', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            _buildTourismTypesGrid(),
            const SizedBox(height: 32),
            const Text('Additional Preferences', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            TextField(
              onChanged: (val) => _preferences = val,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'e.g. traveling with kids, vegetarian...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey[300]!)),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 40),
            if (tripVM.state == TripState.loading)
              const Center(child: CircularProgressIndicator(color: Color(0xFFC5A358)))
            else
              ElevatedButton(
                onPressed: _onGenerate,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  backgroundColor: const Color(0xFF1A1A1A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text('Generate My Journey', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTourismTypesGrid() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _tourismOptions.map((opt) {
        final isSelected = _selectedTourismTypes.contains(opt['name']);
        return FilterChip(
          avatar: Icon(opt['icon'], size: 16, color: isSelected ? Colors.white : Colors.black87),
          label: Text(opt['label']),
          selected: isSelected,
          onSelected: (val) {
            setState(() {
              if (val) {
                _selectedTourismTypes.add(opt['name']);
              } else {
                _selectedTourismTypes.remove(opt['name']);
              }
            });
          },
          selectedColor: const Color(0xFFC5A358),
          labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          showCheckmark: false,
        );
      }).toList(),
    );
  }

  Widget _buildDayButton(int days) {
    final isSelected = _durationDays == days;
    return GestureDetector(
      onTap: () => setState(() => _durationDays = days),
      child: Container(
        width: 60,
        height: 50,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFC5A358) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? const Color(0xFFC5A358) : Colors.grey[300]!),
        ),
        child: Center(
          child: Text(
            '$days',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetSelector() {
    return Row(
      children: ['Budget', 'Mid-Range', 'Luxury'].map((b) {
        final isSelected = _selectedBudget == b;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(b),
              selected: isSelected,
              onSelected: (val) {
                if (val) setState(() => _selectedBudget = b);
              },
              padding: const EdgeInsets.symmetric(vertical: 8),
              selectedColor: const Color(0xFFC5A358),
              labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              showCheckmark: false,
            ),
          ),
        );
      }).toList(),
    );
  }
}
