import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
  final _nameController = TextEditingController(text: "Ghanshyam");
  final _placeController = TextEditingController(text: "Jodhpur, Rajasthan, India");
  DateTime selectedDate = DateTime(1983, 6, 30);
  TimeOfDay selectedTime = const TimeOfDay(hour: 1, minute: 16);
  int varshphalAge = 43;

  List<dynamic> _placeSuggestions = [];
  double _latitude = 26.29; // Jodhpur Default
  double _longitude = 73.02;
  bool _isLoadingPlaces = false;

  Future<void> _fetchPlaces(String query) async {
    if (query.trim().length < 3) {
      setState(() => _placeSuggestions = []);
      return;
    }
    setState(() => _isLoadingPlaces = true);

    try {
      final url = Uri.parse(
          'https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1&limit=5');
      final response = await http.get(url, headers: {'User-Agent': 'LalKitabApp'});

      if (response.statusCode == 200) {
        setState(() {
          _placeSuggestions = json.decode(response.body);
          _isLoadingPlaces = false;
        });
      }
    } catch (_) {
      setState(() => _isLoadingPlaces = false);
    }
  }

  // --- ASTRONOMICAL CALCULATION ENGINE ---
  double _julianDay(int year, int month, int day, double ut) {
    if (month <= 2) {
      year -= 1;
      month += 12;
    }
    int a = year ~/ 100;
    int b = 2 - a + (a ~/ 4);
    return (365.25 * (year + 4716)).floor() +
        (30.6001 * (month + 1)).floor() +
        day +
        b -
        1524.5 +
        (ut / 24.0);
  }

  Map<String, int> _calculateRealKundli(DateTime date, TimeOfDay time, double lat, double lon) {
    // Timezone for India is +5.5
    double decimalTime = time.hour + (time.minute / 60.0);
    double ut = decimalTime - 5.5; // Universal Time (UTC)
    double jd = _julianDay(date.year, date.month, date.day, ut);
    double d = jd - 2451545.0; // Days since J2000.0

    // Lahiri Ayanamsha (approximate)
    double ayanamsha = 23.85 + (d * 0.000038);

    // Mean Longitude Formulas (Astronomical Ephemeris Math)
    double lSun = (280.460 + 0.9856474 * d) % 360;
    double lMoon = (218.316 + 13.176396 * d) % 360;
    double lMars = (355.433 + 0.5240330 * d) % 360;
    double lMercury = (3.444 + 4.0923344 * d) % 360;
    double lJupiter = (34.351 + 0.0830853 * d) % 360;
    double lVenus = (181.980 + 1.6021305 * d) % 360;
    double lSaturn = (50.077 + 0.0334442 * d) % 360;
    double lRahu = (125.044 - 0.0529538 * d) % 360;
    if (lRahu < 0) lRahu += 360;
    double lKetu = (lRahu + 180) % 360;

    // Local Sidereal Time & Ascendant
    double gmst = (18.697374558 + 24.06570982441908 * d) % 24;
    double lst = (gmst + (lon / 15.0)) % 24;
    double ramc = lst * 15.0;
    double ascendant = (ramc + 90 - ayanamsha) % 360;
    if (ascendant < 0) ascendant += 360;
    int ascSign = (ascendant ~/ 30) + 1;

    // Lal Kitab maps planets into houses relative to Ascendant (Equal 30 deg house)
    int getHouse(double longDeg) {
      double nirayana = (longDeg - ayanamsha) % 360;
      if (nirayana < 0) nirayana += 360;
      int sign = (nirayana ~/ 30) + 1;
      int house = (sign - ascSign + 1);
      if (house <= 0) house += 12;
      return house;
    }

    return {
      "Sun": getHouse(lSun),
      "Moon": getHouse(lMoon),
      "Mars": getHouse(lMars),
      "Mercury": getHouse(lMercury),
      "Jupiter": getHouse(lJupiter),
      "Venus": getHouse(lVenus),
      "Saturn": getHouse(lSaturn),
      "Rahu": getHouse(lRahu),
      "Ketu": getHouse(lKetu),
    };
  }

  void _calculateAndNavigate() {
    // 1. Calculate Real Birth Chart from DOB, Time & Place
    Map<String, int> birthChart = _calculateRealKundli(selectedDate, selectedTime, _latitude, _longitude);

    // 2. Calculate Lal Kitab Varshphal Progression Chart
    Map<String, int> varshphalChart =
        LalKitabData.calculateVarshphal(birthChart, varshphalAge);

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
            TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: "नाम (Name)")),
            SizedBox(height: 10),
            TextField(
              controller: _placeController,
              decoration: InputDecoration(
                labelText: "जन्म स्थान (e.g. Jodhpur)",
                suffixIcon: _isLoadingPlaces
                    ? Transform.scale(
                        scale: 0.5, child: CircularProgressIndicator())
                    : Icon(Icons.location_on),
              ),
              onChanged: _fetchPlaces,
            ),
            if (_placeSuggestions.isNotEmpty)
              Container(
                decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8)),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _placeSuggestions.length,
                  itemBuilder: (context, index) {
                    final item = _placeSuggestions[index];
                    return ListTile(
                      leading: Icon(Icons.place, color: Colors.deepOrange),
                      title: Text(item['display_name'] ?? ''),
                      onTap: () {
                        setState(() {
                          _placeController.text = item['display_name'];
                          _latitude = double.tryParse(item['lat']) ?? 26.29;
                          _longitude = double.tryParse(item['lon']) ?? 73.02;
                          _placeSuggestions = [];
                        });
                      },
                    );
                  },
                ),
              ),
            SizedBox(height: 15),
            ListTile(
              title: Text(
                  "जन्म तिथि: ${selectedDate.toLocal().toString().split(' ')[0]}"),
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
                TimeOfDay? picked = await showTimePicker(
                    context: context, initialTime: selectedTime);
                if (picked != null) setState(() => selectedTime = picked);
              },
            ),
            DropdownButtonFormField<int>(
              value: varshphalAge,
              decoration:
                  InputDecoration(labelText: "वर्षफल आयु (Running Year)"),
              items: List.generate(
                  100,
                  (index) => DropdownMenuItem(
                      value: index + 1, child: Text("${index + 1}th Year"))),
              onChanged: (val) => setState(() => varshphalAge = val!),
            ),
            SizedBox(height: 25),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50)),
              onPressed: _calculateAndNavigate,
              child: Text("कुंडली व वर्षफल बनाएं",
                  style: TextStyle(fontSize: 18)),
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

  ResultScreen(
      {required this.name,
      required this.birthChart,
      required this.varshphalChart,
      required this.varshphalAge});

  @override
  Widget build(BuildContext context) {
    var birthReport =
        LalKitabData.evaluatePredictions(birthChart, varshphalAge);
    var varshphalReport =
        LalKitabData.evaluatePredictions(varshphalChart, varshphalAge);

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

  Widget _buildChartTab(
      Map<String, int> chart, List<Map<String, String>> reports) {
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
          Text("PDF सूत्रों के अनुसार फलित एवं उपाय:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          ...reports.map((r) => Card(
                elevation: 3,
                margin: EdgeInsets.symmetric(vertical: 6),
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${r['planet']} (खाना नं. ${r['house']})",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrange)),
                      SizedBox(height: 4),
                      Text("फलित: ${r['pred']}"),
                      SizedBox(height: 4),
                      Text("उपाय: ${r['remedy']}",
                          style: TextStyle(
                              color: Colors.green[800],
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
