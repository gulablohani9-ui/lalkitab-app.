import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sweph/sweph.dart';
import 'lalkitab_data.dart';
import 'kundli_painter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Sweph.init();
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
  final _nameController = TextEditingController(text: "Ghanshyam");
  final _placeController = TextEditingController(text: "Jodhpur, Rajasthan, India");
  DateTime selectedDate = DateTime(1983, 6, 30);
  TimeOfDay selectedTime = const TimeOfDay(hour: 1, minute: 16);
  int varshphalAge = 44;

  List<dynamic> _placeSuggestions = [];
  double _latitude = 26.29;
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

  double _getLahiriAyanamsha(double tjdUt) {
    double t = (tjdUt - 2451545.0) / 36525.0;
    return 23.85833 + (1.396042 * t);
  }

  Map<String, dynamic> _calculateSwissLalKitab(
      DateTime date, TimeOfDay time, double lat, double lon) {
    double decimalTime = time.hour + (time.minute / 60.0);
    double utHour = decimalTime - 5.5; // IST to UTC
    int day = date.day;
    int month = date.month;
    int year = date.year;

    if (utHour < 0) {
      utHour += 24.0;
      DateTime prevDay = date.subtract(const Duration(days: 1));
      day = prevDay.day;
      month = prevDay.month;
      year = prevDay.year;
    }

    double tjdUt = Sweph.swe_julday(
        year, month, day, utHour, CalendarType.SE_GREG_CAL);
    double lahiri = _getLahiriAyanamsha(tjdUt);

    final housesData = Sweph.swe_houses(tjdUt, lat, lon, Hsys.P);
    double ascendantTrop = housesData.ascmc[0];
    double ascendantSid = ascendantTrop - lahiri;
    while (ascendantSid < 0) ascendantSid += 360.0;
    ascendantSid %= 360.0;
    int ascSign = (ascendantSid ~/ 30) + 1;

    Map<String, HeavenlyBody> bodies = {
      "Sun": HeavenlyBody.SE_SUN,
      "Moon": HeavenlyBody.SE_MOON,
      "Mars": HeavenlyBody.SE_MARS,
      "Mercury": HeavenlyBody.SE_MERCURY,
      "Jupiter": HeavenlyBody.SE_JUPITER,
      "Venus": HeavenlyBody.SE_VENUS,
      "Saturn": HeavenlyBody.SE_SATURN,
      "Rahu": HeavenlyBody.SE_TRUE_NODE,
    };

    Map<String, int> chart = {};
    double birthSunLon = 0.0;

    bodies.forEach((name, body) {
      final coords = Sweph.swe_calc_ut(tjdUt, body, SwephFlag.SEFLG_SWIEPH);
      double tropLon = coords.longitude;
      if (name == "Sun") birthSunLon = tropLon;

      double sidLon = tropLon - lahiri;
      while (sidLon < 0) sidLon += 360.0;
      sidLon %= 360.0;

      int planetSign = (sidLon ~/ 30) + 1;
      int house = (planetSign - ascSign + 1);
      if (house <= 0) house += 12;
      chart[name] = house;
    });

    int rahuHouse = chart["Rahu"]!;
    chart["Ketu"] = ((rahuHouse - 1 + 6) % 12) + 1;

    return {
      "chart": chart,
      "birthSunLon": birthSunLon,
      "tjdUt": tjdUt,
      "ascSign": ascSign,
    };
  }

  // Pure Live Solar Return Engine for ANY Year
  Map<String, int> _calculateLiveVarshphal(
      double birthSunLon, DateTime birthDate, int age, double lat, double lon, Map<String, int> birthChart) {
    int targetYear = birthDate.year + (age - 1);
    
    // Approximate JD for target year birth date
    double approxJd = Sweph.swe_julday(
        targetYear, birthDate.month, birthDate.day, 12.0, CalendarType.SE_GREG_CAL);

    // Iterative convergence to find exact solar return second
    double returnJd = approxJd;
    for (int i = 0; i < 6; i++) {
      final sunPos = Sweph.swe_calc_ut(returnJd, HeavenlyBody.SE_SUN, SwephFlag.SEFLG_SWIEPH);
      double diff = birthSunLon - sunPos.longitude;
      while (diff > 180.0) diff -= 360.0;
      while (diff < -180.0) diff += 360.0;
      returnJd += diff / 0.9856473; // Sun daily motion
    }

    double lahiri = _getLahiriAyanamsha(returnJd);

    // Varsh Pravesh Ascendant
    final returnHouses = Sweph.swe_houses(returnJd, lat, lon, Hsys.P);
    double returnAscTrop = returnHouses.ascmc[0];
    double returnAscSid = returnAscTrop - lahiri;
    while (returnAscSid < 0) returnAscSid += 360.0;
    returnAscSid %= 360.0;
    int varshLagna = (returnAscSid ~/ 30) + 1;

    // Delegate to Lal Kitab Farman house shift logic
    return LalKitabEngine.calculateDynamicVarshphal(birthChart, age, varshLagna);
  }

  void _calculateAndNavigate() {
    var birthResult = _calculateSwissLalKitab(
        selectedDate, selectedTime, _latitude, _longitude);
    Map<String, int> birthChart = birthResult["chart"];
    double birthSunLon = birthResult["birthSunLon"];

    Map<String, int> varshphalChart = _calculateLiveVarshphal(
        birthSunLon, selectedDate, varshphalAge, _latitude, _longitude, birthChart);

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
                                  _latitude = double.tryParse(item['lat']) ?? 26.29;
                                  _longitude = double.tryParse(item['lon']) ?? 73.02;
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
