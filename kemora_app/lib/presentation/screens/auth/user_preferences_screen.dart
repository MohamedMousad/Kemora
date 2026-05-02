import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_view_model.dart';
import '../home/home_screen.dart';

import '../../../domain/entities/user_preferences.dart';

class UserPreferencesScreen extends StatefulWidget {
  final bool fromSettings;
  const UserPreferencesScreen({super.key, this.fromSettings = false});

  @override
  State<UserPreferencesScreen> createState() => _UserPreferencesScreenState();
}

class _UserPreferencesScreenState extends State<UserPreferencesScreen> {
  String _selectedBudget = 'Mid-Range';
  String _selectedPace = 'Moderate';
  final List<String> _selectedVibes = [];

  final List<String> _budgetOptions = ['Budget', 'Mid-Range', 'Luxury'];
  final List<String> _paceOptions = ['Relaxed', 'Moderate', 'Fast-Paced'];
  final List<String> _vibeOptions = [
    'Historical Sites',
    'Nile Cruises',
    'Desert Safaris',
    'Local Culinary',
    'Beach Relaxation',
    'Oasis Exploring',
    'Shopping & Souqs',
    'Adventure Sports',
    'Luxurious Stays'
  ];

  @override
  void initState() {
    super.initState();
    final prefs = context.read<AuthViewModel>().user?.preferences;
    if (prefs != null) {
      if (_budgetOptions.contains(prefs.budget)) _selectedBudget = prefs.budget;
      if (_paceOptions.contains(prefs.pace)) _selectedPace = prefs.pace;
      if (prefs.interests.isNotEmpty) {
        _selectedVibes.clear();
        _selectedVibes.addAll(prefs.interests.where((v) => _vibeOptions.contains(v)));
      }
    }
  }

  void _onSave() async {
    final authVM = context.read<AuthViewModel>();
    
    final prefs = UserPreferences(
      budget: _selectedBudget,
      pace: _selectedPace,
      interests: _selectedVibes,
    );

    await authVM.updatePreferences(prefs);

    if (authVM.state == AuthState.authenticated || authVM.errorMessage == null) {
      if (!mounted) return;
      
      if (widget.fromSettings) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Preferences updated successfully!'), backgroundColor: Colors.green)
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Your Travel Style', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Personalize your Kemora experience.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            
            _buildSectionTitle('Daily Budget'),
            const SizedBox(height: 12),
            _buildChoiceChips(_budgetOptions, _selectedBudget, (val) {
              setState(() => _selectedBudget = val);
            }),
            
            const SizedBox(height: 32),
            _buildSectionTitle('Trip Pace'),
            const SizedBox(height: 12),
            _buildChoiceChips(_paceOptions, _selectedPace, (val) {
              setState(() => _selectedPace = val);
            }),
            
            const SizedBox(height: 32),
            _buildSectionTitle('Interests & Vibe'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: _vibeOptions.map((vibe) {
                final isSelected = _selectedVibes.contains(vibe);
                return FilterChip(
                  label: Text(vibe),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedVibes.add(vibe);
                      } else {
                        _selectedVibes.remove(vibe);
                      }
                    });
                  },
                  selectedColor: const Color(0xFFC5A358).withValues(alpha: 0.2),
                  checkmarkColor: const Color(0xFFC5A358),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 48),
            if (authVM.state == AuthState.loading)
              const Center(child: CircularProgressIndicator())
            else
              ElevatedButton(
                onPressed: _onSave,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  backgroundColor: const Color(0xFF1A1A1A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Start Exploring Egypt', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            if (authVM.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(authVM.errorMessage!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A)),
    );
  }

  Widget _buildChoiceChips(List<String> options, String selectedValue, Function(String) onSelected) {
    return Wrap(
      spacing: 8,
      children: options.map((opt) {
        final isSelected = opt == selectedValue;
        return ChoiceChip(
          label: Text(opt),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) onSelected(opt);
          },
          selectedColor: const Color(0xFFC5A358),
          labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        );
      }).toList(),
    );
  }
}
