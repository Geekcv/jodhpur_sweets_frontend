import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:js_order_website/controllers/api_controller.dart';
import '../provider/provider.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(master_Provider).fetchNotification(params: {});
    });
  }

  void _markAsRead(String rowId) async {
    await ApiController.markAsReadNotification(params: {'notification_id': rowId,});
    ref.read(master_Provider).fetchNotification(params: {});
  }

  @override
  Widget build(BuildContext context) {
    final masterProv = ref.watch(master_Provider);
    final notifications = masterProv.allNotifications?.notifications ?? [];
    final isLoading = masterProv.loading;

    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC), // Brighter, cleaner background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          "Notifications",
          style: TextStyle(color: Color(0xff1E293B), fontWeight: FontWeight.w800, fontSize: 20),
        ),
        centerTitle: false,
        actions: [
          if (masterProv.allNotifications?.unread != 0)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(
                  "${masterProv.allNotifications?.unread} New",
                  style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                ),
              ),
            )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blue))
          : notifications.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: notifications.length,
        itemBuilder: (context, index) => _notificationCard(notifications[index]),
      ),
    );
  }

  Widget _notificationCard(dynamic item) {
    bool isRead = item.is_read == true || item.is_read == "true" || item.is_read == 1;
    String type = item.type?.toString().toUpperCase() ?? "GENERAL";
    String priority = item.priority?.toString().toUpperCase() ?? "LOW";

    // Priority wise color coding
    Color priorityColor = priority == "HIGH" ? Colors.red : (priority == "MEDIUM" ? Colors.orange : Colors.blueGrey);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3
      ), // Added margin for card look
      decoration: BoxDecoration(
        color: isRead ? Colors.white : const Color(0xffdbf2ff),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRead ? const Color(0xffF1F5F9) : Colors.blue.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: isRead ? [] : [
          BoxShadow(color: Colors.blue.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          _showCompactDetails(item);
          if (!isRead) _markAsRead(item.row_id.toString());
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center, // Vertically centered for compact look
            children: [
              // Left Icon with subtle glow
              Stack(
                alignment: Alignment.topRight,
                children: [
                  Container(
                    height: 42,
                    width: 42,
                    decoration: BoxDecoration(
                      color: isRead ? const Color(0xffF1F5F9) : Colors.blue.withOpacity(0.08),
                      shape: BoxShape.circle, // Rounded looks more modern
                    ),
                    child: Icon(_getIcon(type), size: 18, color: isRead ? const Color(0xff64748B) : Colors.blue),
                  ),
                  if (!isRead)
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),

              // Content Area
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row 1: Title + Priority
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title ?? "Update",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isRead ? FontWeight.w600 : FontWeight.w800,
                              color: const Color(0xff0F172A),
                            ),
                          ),
                        ),
                        // Compact Priority Badge in Row
                      ],
                    ),

                    const SizedBox(height: 3),

                    // Row 2: Message Snippet
                    Text(
                      item.message ?? "",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: Color(0xff64748B), fontWeight: FontWeight.w400),
                    ),

                    const SizedBox(height: 4),

                    // Row 3: Time Ago
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: priorityColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              priority,
                              style: TextStyle(fontSize: 8, color: priorityColor, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            _timeAgo(item.cr_on.toString()),
                            style: TextStyle(fontSize: 9, color: Colors.blueGrey, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Right Chevron for interactivity
              Icon(Icons.chevron_right_rounded, size: 18, color: Colors.grey.shade500),
            ],
          ),
        ),
      ),
    );
  }



  // --- PROFESSIONAL ALERT DIALOG ---
  void _showCompactDetails(dynamic item) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Center(
          child: Container(
            width: 420,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xffE2E8F0), width: 1),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xff0F172A).withOpacity(0.08),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- HEADER ROW ---
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 16, 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Simple Clean Icon Box
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xffEFF6FF),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xffDBEAFE)),
                        ),
                        child: Icon(
                          _getIcon(item.type ?? ""),
                          color: const Color(0xff2563EB),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Title & Priority Badge
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title ?? "Details",
                              style: const TextStyle(
                                color: Color(0xff0F172A),
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            _simplePriorityBadge(item.priority ?? "NORMAL"),
                          ],
                        ),
                      ),

                      // Close Button (X)
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Color(0xff64748B),
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1, color: Color(0xffF1F5F9)),

                // --- BODY CONTENT ---
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // MESSAGE BOX (Only shows if message exists)
                      if ((item.message ?? "").toString().isNotEmpty) ...[
                        const Text(
                          "Message",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xff64748B),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xffF8FAFC),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xffE2E8F0)),
                          ),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 140),
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: Text(
                                item.message ?? "",
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xff1E293B),
                                  height: 1.5,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // SIMPLE DETAILS TABLE
                      const Text(
                        "Information",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xff64748B),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xffE2E8F0)),
                        ),
                        child: Column(
                          children: [
                            _cleanMetaRow(
                              label: "Type",
                              value: "${item.type ?? 'N/A'}",
                              icon: Icons.category_outlined,
                            ),
                            const Divider(height: 1, color: Color(0xffE2E8F0)),
                            _cleanMetaRow(
                              label: "Date",
                              value: _formatFullDate(item.cr_on),
                              icon: Icons.calendar_today_rounded,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // CLOSE BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 42,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff2563EB),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            "Close",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
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
      ),
    );
  }

// --- EASY TO READ PRIORITY BADGE ---
  Widget _simplePriorityBadge(String priority) {
    Color bg = const Color(0xffF1F5F9);
    Color text = const Color(0xff475569);

    switch (priority.toUpperCase()) {
      case 'HIGH':
      case 'URGENT':
        bg = const Color(0xffFEF2F2);
        text = const Color(0xffDC2626);
        break;
      case 'MEDIUM':
        bg = const Color(0xffFFFBEB);
        text = const Color(0xffD97706);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        priority.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: text,
        ),
      ),
    );
  }

// --- CLEAN TABLE ROW ---
  Widget _cleanMetaRow({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xff64748B)),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xff64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xff0F172A),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
// Helper for Modern Data Rows




  IconData _getIcon(String type) {
    switch (type) {
      case 'REQUEST': return Icons.shopping_cart_outlined;
      case 'ORDER': return Icons.local_shipping_outlined;
      default: return Icons.notifications_none_rounded;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          const Text("No notifications", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  String _formatFullDate(dynamic date) {
    if (date == null) return "N/A";
    return DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(date.toString()));
  }

  String _timeAgo(String dateTime) {
    try {
      DateTime dt = DateTime.parse(dateTime);
      final diff = DateTime.now().difference(dt);
      if (diff.inDays > 0) return "${diff.inDays}d";
      if (diff.inHours > 0) return "${diff.inHours}h";
      if (diff.inMinutes > 0) return "${diff.inMinutes}m";
      return "now";
    } catch (e) { return ""; }
  }
}