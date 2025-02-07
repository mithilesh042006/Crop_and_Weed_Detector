import 'package:flutter/material.dart';
import 'package:crop_weed_detector/services/api_service.dart';

class DiseasesScreen extends StatefulWidget {
  @override
  _DiseasesScreenState createState() => _DiseasesScreenState();
}

class _DiseasesScreenState extends State<DiseasesScreen> {
  List<dynamic> _diseases = [];

  @override
  void initState() {
    super.initState();
    _loadDiseases();
  }

  Future<void> _loadDiseases() async {
    try {
      List<dynamic> diseases = await ApiService.fetchDiseases();
      setState(() { _diseases = diseases; });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to load diseases.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Crop Diseases")),
      body: GridView.builder(
        padding: EdgeInsets.all(10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10,
        ),
        itemCount: _diseases.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(_diseases[index]["disease_name"]),
                content: Text("Cure: ${_diseases[index]["cure"]}"),
                actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text("Close"))],
              ),
            ),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 5,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/diseases/${_diseases[index]['disease_name'].toLowerCase()}.png", height: 50), 
                  SizedBox(height: 5),
                  Text(_diseases[index]["disease_name"], textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
