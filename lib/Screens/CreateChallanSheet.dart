import 'package:flutter/material.dart';

class CreateChallanSheet extends StatefulWidget {
  final String orderId;
  const CreateChallanSheet({super.key, required this.orderId});

  @override
  State<CreateChallanSheet> createState() => _CreateChallanSheetState();
}

class _CreateChallanSheetState extends State<CreateChallanSheet> {
  final TextEditingController dateController = TextEditingController(text: "2026-03-30");
  final TextEditingController transportController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Generate Challan", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text("Order ID: ${widget.orderId}", style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),

          const Text("Dispatch Date", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 8),
          TextField(
            controller: dateController,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.calendar_today, size: 18),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              hintText: "YYYY-MM-DD",
            ),
          ),

          const SizedBox(height: 20),

          const Text("Transport Details", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 8),
          TextField(
            controller: transportController,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: "e.g. Truck RJ14 AB 1234, Driver: Rajesh",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),

          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Challan Created & Dispatched! ✅"),
                  backgroundColor: Colors.green,
                ));
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff108548)),
              child: const Text("GENERATE & DISPATCH", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}