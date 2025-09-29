import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'pm2.5/air_quality.dart';
import 'pm2.5/api_service.dart';

// --- โทนสีเดิม ---
const kPrimaryBlue = Color(0xFF1E88E5);
const kBackgroundStart = Color(0xFF1A237E);
const kBackgroundEnd = Color(0xFF42A5F5);
const kCardColor = Color.fromRGBO(255, 255, 255, 0.1);

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AQI Checker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late ApiService api;
  Future<AirQuality>? _airQualityFuture;
  final TextEditingController _searchController = TextEditingController();
  String _currentCity = "Bangkok";

  @override
  void initState() {
    super.initState();
    api = ApiService();
    _fetchData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _fetchData() {
    setState(() {
      _airQualityFuture = api.fetchAirQuality(_currentCity);
    });
  }

  Color _getAqiColor(int? aqi) {
    if (aqi == null) return Colors.grey.shade400;
    if (aqi <= 50) return const Color(0xFF66BB6A);
    if (aqi <= 100) return const Color(0xFFFFEE58);
    if (aqi <= 150) return const Color(0xFFFFA726);
    if (aqi <= 200) return const Color(0xFFEF5350);
    if (aqi <= 300) return const Color(0xFFAB47BC);
    return const Color(0xFF8D6E63);
  }

  String _getAqiLabel(int? aqi) {
    if (aqi == null) return 'Unknown';
    if (aqi <= 50) return 'Good';
    if (aqi <= 100) return 'Moderate';
    if (aqi <= 150) return 'Unhealthy for Sensitive Groups';
    if (aqi <= 200) return 'Unhealthy';
    if (aqi <= 300) return 'Very Unhealthy';
    return 'Hazardous';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [kBackgroundStart, kBackgroundEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async => _fetchData(),
            child: FutureBuilder<AirQuality>(
              future: _airQualityFuture,
              builder: (context, snapshot) {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: _buildContent(snapshot),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(AsyncSnapshot<AirQuality> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(key: ValueKey('loading'), child: CircularProgressIndicator(color: Colors.white));
    }
    if (snapshot.hasError) {
      return _buildErrorState(snapshot.error);
    }
    if (!snapshot.hasData) {
      return const Center(key: ValueKey('no_data'), child: Text('No data available.', style: TextStyle(color: Colors.white)));
    }

    final data = snapshot.data!;
    final aqiColor = _getAqiColor(data.aqi);

    // --- โครงสร้าง Layout หลัก ---
    return SingleChildScrollView(
      key: const ValueKey('data'),
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 20.0),
        child: Column(
          children: [
            _buildSearchBar(),
            const SizedBox(height: 24),
            _buildHeader(data),
            const SizedBox(height: 20),
            // --- วิดเจ็ตใหม่ที่รวมเกจและข้อมูลไว้ในแถวเดียว ---
            _buildMainInfoSection(data, aqiColor),
            const SizedBox(height: 32),
            if (data.pm25Forecast.isNotEmpty) _buildForecastSection(data.pm25Forecast),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(Object? error) {
    return Container(
      key: const ValueKey('error'),
      padding: const EdgeInsets.all(20.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, color: Colors.white70, size: 80),
            const SizedBox(height: 20),
            const Text('Failed to load data', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            Text('$error', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: _fetchData,
                style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('Try Again', style: TextStyle(color: Colors.white))),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search for a city...',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
          border: InputBorder.none,
          suffixIcon: IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              if (_searchController.text.isNotEmpty) {
                setState(() { _currentCity = _searchController.text; });
                _fetchData();
                FocusScope.of(context).unfocus();
              }
            },
          ),
        ),
        onSubmitted: (value) {
          if (value.isNotEmpty) {
            setState(() { _currentCity = value; });
            _fetchData();
          }
        },
      ),
    );
  }

  Widget _buildHeader(AirQuality data) {
    final now = DateFormat('EEEE, hh:mm a').format(DateTime.now());
    return Column(
      children: [
        Text(data.city,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white, shadows: [Shadow(color: Colors.black26, offset: Offset(1,2), blurRadius: 3)])),
        const SizedBox(height: 4),
        Text('Updated on $now', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
      ],
    );
  }

  // --- วิดเจ็ตใหม่: จัดเรียงข้อมูลหลักในแนวนอน ---
  Widget _buildMainInfoSection(AirQuality data, Color aqiColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // --- ส่วนที่ 1: เกจ AQI (ซ้าย) ---
        _buildAqiGauge(data, aqiColor),
        const SizedBox(width: 20),
        // --- ส่วนที่ 2: ข้อมูล PM2.5 และอุณหภูมิ (ขวา) ---
        Expanded(
          child: Column(
            children: [
              _buildInfoTile(
                  icon: Icons.grain,
                  label: 'PM2.5',
                  value: '${data.pm25?.toStringAsFixed(1) ?? '-'} µg/m³',
                  iconColor: aqiColor),
              const SizedBox(height: 16),
              _buildInfoTile(
                  icon: Icons.thermostat,
                  label: 'Temperature',
                  value: '${data.temperature?.toStringAsFixed(1) ?? '-'} °C',
                  iconColor: const Color(0xFF64B5F6)),
            ],
          ),
        ),
      ],
    );
  }


  // --- แก้ไข: ลดขนาดเกจให้เล็กลง ---
  Widget _buildAqiGauge(AirQuality data, Color aqiColor) {
    return Container(
      width: 180, // ลดขนาด
      height: 180, // ลดขนาด
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: kCardColor,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${data.aqi ?? '-'}',
                style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: aqiColor, shadows: const [Shadow(color: Colors.black26, offset: Offset(1,3), blurRadius: 4)])),
            Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: aqiColor.withOpacity(0.25), borderRadius: BorderRadius.circular(12)),
                child: Text(_getAqiLabel(data.aqi), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: aqiColor)))
          ],
        ),
      ),
    );
  }

  Widget _buildForecastSection(List<DailyForecast> forecast) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Weekly Forecast", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 16),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: forecast.length > 7 ? 7 : forecast.length,
            itemBuilder: (context, index) {
              final dayForecast = forecast[index];
              return _buildForecastTile(dayForecast);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildForecastTile(DailyForecast dayForecast) {
    final dayOfWeek = DateFormat('E').format(dayForecast.day).toUpperCase();
    final aqiColor = _getAqiColor(dayForecast.avg);
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(dayOfWeek, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.8))),
          const SizedBox(height: 12),
          Text('${dayForecast.avg}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: aqiColor)),
        ],
      ),
    );
  }

  Widget _buildInfoTile({required IconData icon, required String label, required String value, required Color iconColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(width: 16),
          // --- ใช้ Expanded เพื่อให้ข้อความตัดเมื่อยาวเกินไป ---
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
                Text(
                  value,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  overflow: TextOverflow.ellipsis, // ป้องกันข้อความล้น
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
