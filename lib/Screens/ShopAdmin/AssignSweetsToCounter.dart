import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/api_controller.dart';
import '../../models/FetchCounterModel.dart';
import '../../models/FetchSweetsModel.dart';
import '../../provider/provider.dart';

class AssignSweetsToCounter extends ConsumerStatefulWidget {
  const AssignSweetsToCounter({super.key});

  @override
  ConsumerState<AssignSweetsToCounter> createState() => _AssignSweetsToCounterState();
}

class _AssignSweetsToCounterState extends ConsumerState<AssignSweetsToCounter> {
  String? _selectedSweetId;
  final Set<String> _selectedCounterIds = {};

  String _sweetsViewMode = 'card';
  String _sweetSearch = '';
  String _counterSearch = '';
  bool _isSubmitting = false;

  static const Color primaryNavy = Color(0xFF0F172A);
  static const Color accentBlue = Color(0xFF2563EB);
  static const Color borderColor = Color(0xFFE2E8F0);
  static const Color textMuted = Color(0xFF64748B);
  static const Color cardBg = Color(0xFFF8FAFC);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(master_Provider).fetchSweets();
        ref.read(master_Provider).fetchCounter();
      }
    });
  }

  void _selectSweet(String id) {
    setState(() {
      _selectedSweetId = (_selectedSweetId == id) ? null : id;
    });
  }

  void _toggleCounterSelection(String id) {
    setState(() {
      if (_selectedCounterIds.contains(id)) {
        _selectedCounterIds.remove(id);
      } else {
        _selectedCounterIds.add(id);
      }
    });
  }

  void _resetSelection() {
    setState(() {
      _selectedSweetId = null;
      _selectedCounterIds.clear();
    });
  }

  Future<void> _submitAssignment() async {
    if (_selectedSweetId == null || _selectedCounterIds.isEmpty) return;

    setState(() => _isSubmitting = true);

    try {
      var params = {
        "sweet_id": _selectedSweetId,
        "counter_ids": _selectedCounterIds.toList(),
      };

      var response = await ApiController.assignSweetToCounters(context: context,params: params);

      if (response != null && response['status'] == 0) {
        _showSnackBar("Sweet assigned successfully!", const Color(0xFF10B981));
        _resetSelection();
      } else {
        _showSnackBar(response?['msg'] ?? "Assignment failed. Try again.", Colors.redAccent);
      }
    } catch (e) {
      _showSnackBar("Error: $e", Colors.redAccent);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _confirmAndSubmit(FetchSweetsModel selectedSweet, List<FetchCounterModel> countersList) {
    final selectedCounters = countersList.where((c) => _selectedCounterIds.contains(c.row_id.toString())).toList();

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        backgroundColor: Colors.white,
        elevation: 6,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 440,
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Light Blue Accent Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: const BoxDecoration(
                  color: Color(0xFFEFF6FF),
                  border: Border(bottom: BorderSide(color: Color(0xFFDBEAFE))),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Confirm Counter Mapping",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: accentBlue,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            "Review assignment before submitting",
                            style: TextStyle(
                              fontSize: 11,
                              color: textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close_rounded, color: textMuted, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

              // Dialog Body
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "SELECTED ITEM",
                        style: TextStyle(
                          fontSize: 10,
                          color: textMuted,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: borderColor),
                        ),
                        child: Text(
                          selectedSweet.sweet_name ?? "Unnamed Sweet",
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: primaryNavy,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "ASSIGNED COUNTERS",
                            style: TextStyle(
                              fontSize: 10,
                              color: textMuted,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: accentBlue.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "${selectedCounters.length} Selected",
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: accentBlue,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      Container(
                        constraints: const BoxConstraints(maxHeight: 220),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: borderColor),
                        ),
                        child: selectedCounters.isEmpty
                            ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: Text(
                              "No counters selected",
                              style: TextStyle(fontSize: 12, color: textMuted),
                            ),
                          ),
                        )
                            : ListView.separated(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          itemCount: selectedCounters.length,
                          separatorBuilder: (_, __) => const Divider(height: 1, color: borderColor),
                          itemBuilder: (context, idx) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              child: Text(
                                selectedCounters[idx].counter_name ?? "Counter",
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: primaryNavy,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Actions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: borderColor)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: borderColor),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(color: textMuted, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _submitAssignment();
                        },
                        icon: const Icon(Icons.send_rounded, size: 14),
                        label: const Text(
                          "Confirm & Assign",
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentBlue,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color(0xFF94A3B8),
                          disabledForegroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnackBar(String message, Color bg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        backgroundColor: bg,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final masterProv = ref.watch(master_Provider);
    final List<FetchSweetsModel> sweetsList = masterProv.allSweets ?? [];
    final List<FetchCounterModel> countersList = masterProv.allCounters ?? [];

    final filteredSweets = sweetsList.where((sweet) {
      final name = (sweet.sweet_name ?? '').toLowerCase();
      return name.contains(_sweetSearch.toLowerCase());
    }).toList();

    final filteredCounters = countersList.where((counter) {
      final name = (counter.counter_name ?? '').toLowerCase();
      return name.contains(_counterSearch.toLowerCase());
    }).toList();

    FetchSweetsModel? selectedSweetObj;
    if (_selectedSweetId != null) {
      selectedSweetObj = sweetsList.firstWhere(
            (s) => s.row_id.toString() == _selectedSweetId,
        orElse: () => FetchSweetsModel(),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: _buildTopHeader(selectedSweetObj, countersList),
      ),
      body: masterProv.loading
          ? const Center(child: CircularProgressIndicator(color: accentBlue))
          : LayoutBuilder(
        builder: (context, constraints) {
          final bool isDesktop = constraints.maxWidth > 900;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                if (isDesktop)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 6,
                        child: _buildSweetsPanel(filteredSweets),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        flex: 5,
                        child: _buildCountersPanel(filteredCounters),
                      ),
                    ],
                  )
                else ...[
                  _buildSweetsPanel(filteredSweets),
                  const SizedBox(height: 20),
                  _buildCountersPanel(filteredCounters),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopHeader(FetchSweetsModel? selectedSweet, List<FetchCounterModel> countersList) {
    final bool canSubmit = _selectedSweetId != null && _selectedCounterIds.isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            const Text(
              "Sweet Counter Mapping",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryNavy),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: canSubmit && !_isSubmitting ? () => _confirmAndSubmit(selectedSweet!, countersList) : null,
              icon: _isSubmitting ? const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
                  : const Icon(Icons.send_rounded, size: 14),
              label: Text(
                _isSubmitting ? "ASSIGNING..." : "Assign Sweets (${_selectedCounterIds.length})",
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentBlue,
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFF94A3B8),
                disabledForegroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width < 600 ? 12 : 18, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSweetsPanel(List<FetchSweetsModel> filteredSweets) {
    return Container(
      height: 640,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text("Select Sweet", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: primaryNavy)),
              const Spacer(),
              _buildViewSwitch(_sweetsViewMode, (mode) => setState(() => _sweetsViewMode = mode)),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 38,
            child: TextField(
              onChanged: (v) => setState(() => _sweetSearch = v),
              style: const TextStyle(fontSize: 12),
              decoration: InputDecoration(
                hintText: "Search sweet...",
                prefixIcon: const Icon(Icons.search, size: 16, color: textMuted),
                contentPadding: EdgeInsets.zero,
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: borderColor)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: accentBlue)),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: _sweetsViewMode == 'card'
                ? GridView.builder(
              itemCount: filteredSweets.length,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 240,
                mainAxisExtent: 72,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (context, index) {
                final sweet = filteredSweets[index];
                final isSelected = _selectedSweetId == sweet.row_id.toString();

                return InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => _selectSweet(sweet.row_id.toString()),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? accentBlue : borderColor,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [BoxShadow(color: accentBlue.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2))]
                          : [],
                    ),
                    child: Row(
                      children: [
                        Radio<String>(
                          value: sweet.row_id.toString(),
                          groupValue: _selectedSweetId,
                          activeColor: accentBlue,
                          visualDensity: VisualDensity.compact,
                          onChanged: (val) {
                            if (val != null) _selectSweet(val);
                          },
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                sweet.sweet_name ?? "",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primaryNavy),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                sweet.department_name ?? sweet.category_name ?? "-",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 10, color: textMuted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
                : _buildSweetsListTable(filteredSweets),
          ),
        ],
      ),
    );
  }

  Widget _buildCountersPanel(List<FetchCounterModel> filteredCounters) {
    return Container(
      height: 640,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text("Select Counters", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: primaryNavy)),
              const Spacer(),
              if (_selectedCounterIds.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: accentBlue.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "${_selectedCounterIds.length} Selected",
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: accentBlue),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 38,
            child: TextField(
              onChanged: (v) => setState(() => _counterSearch = v),
              style: const TextStyle(fontSize: 12),
              decoration: InputDecoration(
                hintText: "Search counter...",
                prefixIcon: const Icon(Icons.search, size: 16, color: textMuted),
                contentPadding: EdgeInsets.zero,
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: borderColor)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: accentBlue)),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: ListView.separated(
              itemCount: filteredCounters.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final counter = filteredCounters[index];
                final isChecked = _selectedCounterIds.contains(counter.row_id.toString());

                return InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => _toggleCounterSelection(counter.row_id.toString()),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isChecked ? accentBlue : borderColor,
                        width: isChecked ? 1.5 : 1,
                      ),
                      boxShadow: isChecked
                          ? [BoxShadow(color: accentBlue.withOpacity(0.06), blurRadius: 6, offset: const Offset(0, 2))]
                          : [],
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: Checkbox(
                            value: isChecked,
                            activeColor: accentBlue,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            onChanged: (_) => _toggleCounterSelection(counter.row_id.toString()),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            counter.counter_name ?? "Counter",
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primaryNavy),
                          ),
                        ),
                        if (isChecked)
                          const Icon(Icons.check_circle_rounded, size: 16, color: accentBlue),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSweetsListTable(List<FetchSweetsModel> sweets) {
    return ListView.separated(
      itemCount: sweets.length,
      separatorBuilder: (_, __) => const Divider(height: 1, color: borderColor),
      itemBuilder: (context, index) {
        final sweet = sweets[index];

        return ListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          leading: Radio<String>(
            value: sweet.row_id.toString(),
            groupValue: _selectedSweetId,
            activeColor: accentBlue,
            onChanged: (val) {
              if (val != null) _selectSweet(val);
            },
          ),
          title: Text(sweet.sweet_name ?? "", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primaryNavy)),
          subtitle: Text(
            sweet.department_name ?? sweet.category_name ?? '',
            style: const TextStyle(fontSize: 11, color: textMuted),
          ),
          onTap: () => _selectSweet(sweet.row_id.toString()),
        );
      },
    );
  }

  Widget _buildViewSwitch(String current, Function(String) onChange) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: borderColor)),
      padding: const EdgeInsets.all(2),
      child: Row(
        children: [
          _buildIconButton(Icons.grid_view_rounded, current == 'card', () => onChange('card')),
          _buildIconButton(Icons.view_list_rounded, current == 'list', () => onChange('list')),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, bool active, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: active ? cardBg : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 16, color: active ? primaryNavy : textMuted),
      ),
    );
  }
}