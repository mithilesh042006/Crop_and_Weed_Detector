import 'package:flutter/material.dart';
import 'package:crop_weed_detector/services/api_service.dart';

class TipsScreen extends StatefulWidget {
  @override
  _TipsScreenState createState() => _TipsScreenState();
}

class _TipsScreenState extends State<TipsScreen> {
  List<dynamic> _tips = [];

  @override
  void initState() {
    super.initState();
    _loadTips();
  }

  Future<void> _loadTips() async {
    try {
      List<dynamic> tips = await ApiService.fetchTips();
      setState(() { _tips = tips; });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to load tips.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Crop Tips")),
      body: GridView.builder(
        padding: EdgeInsets.all(10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // 3 items per row
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: _tips.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(_tips[index]["crop_name"]),
                content: Text(_tips[index]["crop_tips"]),
                actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text("Close"))],
              ),
            ),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 5,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/crops/${_tips[index]['crop_name'].toLowerCase()}.png", height: 50), // Crop Image
                  SizedBox(height: 5),
                  Text(_tips[index]["crop_name"], textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
