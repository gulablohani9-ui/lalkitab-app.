import 'package:flutter/material.dart';
import 'lalkitab_data.dart';
import 'kundli_painter.dart';

void main() => runApp(LalKitabApp());

class LalKitabApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lal Kitab Kundli & Varshphal',
      theme: ThemeData(primarySwatch: Colors.deepOrange),
      home: InputScreen(),
    );
  }
}

class InputScreen extends StatefulWidget {
  @override
  _InputScreenState createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final _nameController = TextEditingController();
  final _placeController = TextEditingController();
  DateTime selectedDate = DateTime(1995, 5, 15);
  TimeOfDay selectedTime = const TimeOfDay(hour: 10, minute: 30);
  int varshphalAge = 30;

  void _calculateAndNavigate() {
    Map<String, int> birthChart = {
      "Sun": 1,
      "Moon": 4,
      "Mars": 8,
      "Mercury": 3,
      "Jupiter": 2,
      "Venus": 6,
      "Saturn": 10,
      "Rahu": 5,
      "Ketu": 11
    };

    Map<String, int> varshphalChart = LalKitabData.calculateVarshphal(birthChart, varshphalAge);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          name: _nameController.text.isEmpty ? "जातक" : _nameController.text,
          birthChart: birthChart,
          varshphalChart: varshphalChart,
          varshphalAge: varshphalAge,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Lal Kitab Kundli Input")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _nameController, decoration: InputDecoration(labelText: "नाम (Name)")),
            TextField(controller: _placeController, decoration: InputDecoration(labelText: "जन्म स्थान (Birth Place)")),
            SizedBox(height: 15),
            ListTile(
              title: Text("जन्म तिथि: ${selectedDate.toLocal().toString().split(' ')[0]}"),
              trailing: Icon(Icons.calendar_today),
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2100),
                );
                if (picked != null) setState(() => selectedDate = picked);
              },
            ),
            ListTile(
              title: Text("जन्म समय: ${selectedTime.format(context)}"),
              trailing: Icon(Icons.access_time),
              onTap: () async {
                TimeOfDay? picked = await showTimePicker(context: context, initialTime: selectedTime);
                if (picked != null) setState(() => selectedTime = picked);
              },
            ),
            DropdownButtonFormField<int>(
              value: varshphalAge,
              decoration: InputDecoration(labelText: "वर्षफल आयु (Running Year)"),
              items: List.generate(100, (index) => DropdownMenuItem(value: index + 1, child: Text("${index + 1}th Year"))),
              onChanged: (val) => setState(() => varshphalAge = val!),
            ),
            SizedBox(height: 25),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
              onPressed: _calculateAndNavigate,
              child: Text("कुंडली व वर्षफल बनाएं", style: TextStyle(fontSize: 18)),
            )
          ],
        ),
      ),
    );
  }
}

class ResultScreen extends StatelessWidget {
  final String name;
  final Map<String, int> birthChart;
  final Map<String, int> varshphalChart;
  final int varshphalAge;

  ResultScreen({required this.name, required this.birthChart, required this.varshphalChart, required this.varshphalAge});

  @override
  Widget build(BuildContext context) {
    var birthReport = LalKitabData.evaluatePredictions(birthChart, varshphalAge);
    var varshphalReport = LalKitabData.evaluatePredictions(varshphalChart, varshphalAge);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("$name की लाल किताब कुंडली"),
          bottom: TabBar(
            tabs: [
              Tab(text: "जन्म कुंडली"),
              Tab(text: "वर्षफल ($varshphalAgeवां वर्ष)"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildChartTab(birthChart, birthReport["reports"]),
            _buildChartTab(varshphalChart, varshphalReport["reports"]),
          ],
        ),
      ),
    );
  }

  Widget _buildChartTab(Map<String, int> chart, List<Map<String, String>> reports) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(12.0),
      child: Column(
        children: [
          Container(
            height: 220,
            width: double.infinity,
            margin: EdgeInsets.symmetric(vertical: 10),
            child: CustomPaint(painter: KundliPainter(chart)),
          ),
          Divider(),
          Text("PDF सूत्रों के अनुसार फलित एवं उपाय:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          ...reports.map((r) => Card(
                elevation: 3,
                margin: EdgeInsets.symmetric(vertical: 6),
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${r['planet']} (खाना नं. ${r['house']})", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                      SizedBox(height: 4),
                      Text("फलित: ${r['pred']}"),
                      SizedBox(height: 4),
                      Text("उपाय: ${r['remedy']}", style: TextStyle(color: Colors.green[800], fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
