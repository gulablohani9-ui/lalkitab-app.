import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'lalkitab_data.dart';
import 'kundli_painter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(LalKitabApp());
}

class LalKitabApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lal Kitab Kundli & Varshphal',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        scaffoldBackgroundColor: const Color(0xFFF9F9FB),
      ),
      home: InputScreen(),
    );
  }
}

class InputScreen extends StatefulWidget {
  @override
  _InputScreenState createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final _nameController = TextEditingController(text: "rajani");
  final _placeController = TextEditingController(text: "Jalor, Rajasthan, India");
  DateTime selectedDate = DateTime(1983, 5, 24);
  TimeOfDay selectedTime = const TimeOfDay(hour: 14, minute: 45);
  int varshphalAge = 43;

  List<dynamic> _placeSuggestions = [];
  double _latitude = 25.35; // Jalore Default
  double _longitude = 72.62;
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

  // Pure Astronomical Math Engine
  double _rad(double d) => d * pi / 180.0;
  double _deg(double r) => r * 180.0 / pi;
  double _norm(double x) => x - 360.0 * (x / 360.0).floor();

  double _julianDay(int y, int m, int d, double ut) {
    if (m <= 2) {
      y -= 1;
      m += 12;
    }
    int a = y ~/ 100;
    int b = 2 - a + (a ~/ 4);
    return (365.25 * (y + 4716)).floor() +
        (30.6001 * (m + 1)).floor() +
        d +
        b -
        1524.5 +
        (ut / 24.0);
  }

  double _solveKepler(double M, double e) {
    double mRad = _rad(M);
    double e0 = mRad;
    for (int i = 0; i < 15; i++) {
      double delta = (e0 - e * sin(e0) - mRad) / (1.0 - e * cos(e0));
      e0 -= delta;
      if (delta.abs() < 1e-6) break;
    }
    return e0;
  }

  Map<String, int> _calculateAccurateLalKitabKundli(
      DateTime date, TimeOfDay time, double lat, double lon) {
    double decimalTime = time.hour + (time.minute / 60.0);
    double ut = decimalTime - 5.5; // IST to UTC
    double jd = _julianDay(date.year, date.month, date.day, ut);
    double d = jd - 2451545.0;
    double t = d / 36525.0;

    // Authentic Lahiri Ayanamsha (Chitra Paksha)
    double ayanamsha = 23.85833 + (1.396042 * t) + (0.000308 * t * t);

    // Sun & Earth
    double mSun = _norm(357.5291 + 35999.0503 * t);
    double cSun = (1.9146 - 0.0048 * t) * sin(_rad(mSun)) +
        (0.019993 - 0.000101 * t) * sin(_rad(2 * mSun)) +
        0.000289 * sin(_rad(3 * mSun));
    double lSunTrop = _norm(280.4665 + 36000.7698 * t + cSun);

    double rSun = 1.00014 - 0.01671 * cos(_rad(mSun));
    double xEarth = -rSun * cos(_rad(lSunTrop));
    double yEarth = -rSun * sin(_rad(lSunTrop));

    // Moon Longitude (Brown/Chapront Series)
    double l0Moon = 218.3165 + 481267.8813 * t;
    double lMoonM = 134.9634 + 477198.8676 * t;
    double dMoon = 297.8502 + 445267.1115 * t;
    double fMoon = 93.2721 + 483202.0175 * t;

    double lMoonTrop = _norm(l0Moon +
        6.2888 * sin(_rad(lMoonM)) +
        1.2740 * sin(_rad(2 * dMoon - lMoonM)) +
        0.6583 * sin(_rad(2 * dMoon)) +
        0.2136 * sin(_rad(2 * lMoonM)) -
        0.1851 * sin(_rad(mSun)) -
        0.1143 * sin(_rad(2 * fMoon)));

    // Rahu & Ketu (Mean Lunar Nodes)
    double lRahuTrop = _norm(125.0445 - 1934.1363 * t + 0.002075 * t * t);
    double lKetuTrop = _norm(lRahuTrop + 180.0);

    // Heliocentric Keplerian Elements for Planets
    List<Map<String, dynamic>> planetElements = [
      // Mercury
      {
        "name": "Mercury",
        "a": 0.387098,
        "e": 0.205630,
        "I": 7.005,
        "L": _norm(252.2509 + 149472.6746 * t),
        "peri": _norm(77.4561 + 1.5565 * t),
        "node": _norm(48.3309 + 1.2536 * t),
      },
      // Venus
      {
        "name": "Venus",
        "a": 0.723332,
        "e": 0.006772,
        "I": 3.3946,
        "L": _norm(181.9798 + 58517.8156 * t),
        "peri": _norm(131.5637 + 1.4022 * t),
        "node": _norm(76.6799 + 0.9011 * t),
      },
      // Mars
      {
        "name": "Mars",
        "a": 1.523679,
        "e": 0.093400,
        "I": 1.8497,
        "L": _norm(355.4330 + 19140.2993 * t),
        "peri": _norm(336.0602 + 1.8410 * t),
        "node": _norm(49.5581 + 0.7721 * t),
      },
      // Jupiter
      {
        "name": "Jupiter",
        "a": 5.20260,
        "e": 0.04849,
        "I": 1.303,
        "L": _norm(34.3515 + 3034.9057 * t),
        "peri": _norm(14.3312 + 1.6126 * t),
        "node": _norm(100.4644 + 1.0210 * t),
      },
      // Saturn
      {
        "name": "Saturn",
        "a": 9.5549,
        "e": 0.05551,
        "I": 2.489,
        "L": _norm(50.0774 + 1222.1138 * t),
        "peri": _norm(93.0568 + 1.9638 * t),
        "node": _norm(113.6655 + 0.8771 * t),
      },
    ];

    Map<String, double> tropLongitudes = {
      "Sun": lSunTrop,
      "Moon": lMoonTrop,
      "Rahu": lRahuTrop,
      "Ketu": lKetuTrop,
    };

    for (var p in planetElements) {
      double a = p["a"];
      double e = p["e"];
      double M = _norm(p["L"] - p["peri"]);
      double E = _solveKepler(M, e);
      double xv = a * (cos(E) - e);
      double yv = a * sqrt(1.0 - e * e) * sin(E);

      double v = _norm(_deg(atan2(yv, xv)));
      double r = sqrt(xv * xv + yv * yv);

      double lHelioc = _norm(v + p["peri"]);
      double xh = r * cos(_rad(lHelioc));
      double yh = r * sin(_rad(lHelioc));

      // Geocentric Longitude
      double xg = xh - xEarth;
      double yg = yh - yEarth;
      double lGeoc = _norm(_deg(atan2(yg, xg)));

      tropLongitudes[p["name"]] = lGeoc;
    }

    // Ascendant (Lagna) Calculation
    double gmst0 = _norm(280.46061837 + 360.98564736629 * d + 0.000387933 * t * t);
    double lst = _norm(gmst0 + lon);
    double eps = 23.439291 - 0.0130042 * t;

    double ascRad = atan2(cos(_rad(lst)), -sin(_rad(lst)) * cos(_rad(eps)) - tan(_rad(lat)) * sin(_rad(eps)));
    double ascTrop = _norm(_deg(ascRad));
    double ascSidereal = _norm(ascTrop - ayanamsha);
    int ascSign = (ascSidereal ~/ 30) + 1;

    // Convert Sidereal Longitude to Lal Kitab House relative to Lagna
    int getHouse(double tropDeg) {
      double sidereal = _norm(tropDeg - ayanamsha);
      int planetSign = (sidereal ~/ 30) + 1;
      int house = (planetSign - ascSign + 1);
      if (house <= 0) house += 12;
      return house;
    }

    Map<String, int> finalChart = {};
    tropLongitudes.forEach((name, deg) {
      finalChart[name] = getHouse(deg);
    });

    return finalChart;
  }

  void _calculateAndNavigate() {
    Map<String, int> birthChart = _calculateAccurateLalKitabKundli(
        selectedDate, selectedTime, _latitude, _longitude);
    Map<String, int> varshphalChart =
        LalKitabEngine.calculateVarshphal(birthChart, varshphalAge);

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
      appBar: AppBar(
        title: const Text("लाल किताब कुंडली व वर्षफल",
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: "नाम (Name)",
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _placeController,
                      decoration: InputDecoration(
                        labelText: "जन्म स्थान (e.g. Jodhpur)",
                        prefixIcon: const Icon(Icons.location_city),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        suffixIcon: _isLoadingPlaces
                            ? Transform.scale(
                                scale: 0.5,
                                child: const CircularProgressIndicator())
                            : const Icon(Icons.search),
                      ),
                      onChanged: _fetchPlaces,
                    ),
                    if (_placeSuggestions.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _placeSuggestions.length,
                          separatorBuilder: (ctx, i) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final item = _placeSuggestions[index];
                            return ListTile(
                              leading: const Icon(Icons.place,
                                  color: Colors.deepOrange),
                              title: Text(item['display_name'] ?? '',
                                  style: const TextStyle(fontSize: 13)),
                              onTap: () {
                                setState(() {
                                  _placeController.text = item['display_name'];
                                  _latitude = double.tryParse(item['lat']) ?? 25.35;
                                  _longitude = double.tryParse(item['lon']) ?? 72.62;
                                  _placeSuggestions = [];
                                });
                              },
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14)),
                            icon: const Icon(Icons.calendar_today, size: 18),
                            label: Text(
                                selectedDate.toLocal().toString().split(' ')[0]),
                            onPressed: () async {
                              DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime(1900),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null)
                                setState(() => selectedDate = picked);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14)),
                            icon: const Icon(Icons.access_time, size: 18),
                            label: Text(selectedTime.format(context)),
                            onPressed: () async {
                              TimeOfDay? picked = await showTimePicker(
                                  context: context, initialTime: selectedTime);
                              if (picked != null)
                                setState(() => selectedTime = picked);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      value: varshphalAge,
                      decoration: InputDecoration(
                        labelText: "वर्षफल आयु (Running Year)",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        prefixIcon: const Icon(Icons.timeline),
                      ),
                      items: List.generate(
                        100,
                        (index) => DropdownMenuItem(
                            value: index + 1,
                            child: Text(
                                "${index + 1}वां वर्षफल (Age ${index + 1})")),
                      ),
                      onChanged: (val) => setState(() => varshphalAge = val!),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                backgroundColor: Colors.deepOrange,
              ),
              onPressed: _calculateAndNavigate,
              child: const Text("विस्तृत कुंडली व वर्षफल देखें",
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
            ),
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

  ResultScreen({
    required this.name,
    required this.birthChart,
    required this.varshphalChart,
    required this.varshphalAge,
  });

  @override
  Widget build(BuildContext context) {
    var birthReport =
        LalKitabEngine.generateFullReport(birthChart, varshphalAge);
    var varshphalReport =
        LalKitabEngine.generateFullReport(varshphalChart, varshphalAge);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("$name की लाल किताब कुंडली"),
          bottom: TabBar(
            indicatorColor: Colors.white,
            tabs: const [
              Tab(icon: Icon(Icons.auto_awesome), text: "जन्म कुंडली"),
              Tab(icon: Icon(Icons.update), text: "वर्षफल"),
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
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 240,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: CustomPaint(painter: KundliPainter(chart)),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              "PDF मूल सूत्रों के अनुसार सम्पूर्ण फलित, शर्तें एवं उपाय:",
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange.shade900),
            ),
          ),
          const SizedBox(height: 10),
          ...reports.map((r) => Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${r['planet']} (खाना नं. ${r['house']})",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.deepOrange.shade800),
                          ),
                          Chip(
                            label: Text("भाव ${r['house']}",
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12)),
                            backgroundColor: Colors.deepOrange,
                            visualDensity: VisualDensity.compact,
                          )
                        ],
                      ),
                      if (r['shlok']!.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.amber.shade200),
                          ),
                          child: Text(
                            r['shlok']!,
                            style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.brown.shade900,
                                height: 1.4,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                      const Text("विस्तृत फलित एवं स्वभाव:",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.black87)),
                      const SizedBox(height: 4),
                      Text(r['swabhav']!,
                          style: const TextStyle(
                              fontSize: 14, height: 1.45, color: Colors.black87)),
                      if (r['vishesh_shartein']!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text("विशेष शर्तें व स्थितियां:",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.indigo.shade900)),
                        const SizedBox(height: 4),
                        Text(r['vishesh_shartein']!,
                            style: TextStyle(
                                fontSize: 14,
                                height: 1.4,
                                color: Colors.indigo.shade900)),
                      ],
                      if (r['upaay']!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text("लाल किताब सटीक उपाय:",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.green.shade900)),
                        const SizedBox(height: 4),
                        Text(r['upaay']!,
                            style: TextStyle(
                                fontSize: 14,
                                height: 1.4,
                                color: Colors.green.shade900,
                                fontWeight: FontWeight.w600)),
                      ],
                      if (r['savdhani']!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text("सावधानी व वर्जनाएं:",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.red.shade900)),
                        const SizedBox(height: 4),
                        Text(r['savdhani']!,
                            style: TextStyle(
                                fontSize: 14,
                                height: 1.4,
                                color: Colors.red.shade900)),
                      ],
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
