import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class MapDirectionScreen extends StatefulWidget {
  const MapDirectionScreen({super.key});

  @override
  State<MapDirectionScreen> createState() => _MapDirectionScreenState();
}

class _MapDirectionScreenState extends State<MapDirectionScreen> {
  final MapController _mapController = MapController(); // 
  LatLng? _currentPosition; // 
  LatLng? _destinationPosition; // 
  bool _isLoading = false; // 
  bool _hasError = false; // 
  String _errorMessage = ''; // 
  bool _isMapReady = false; // 

  String _destinationName = ''; // 
  List<LatLng> _routePoints = []; // 
  double _routeDistance = 0; // 
  double _routeDuration = 0; // 

  // Titik default awal jika GPS belum aktif (Jakarta) 
  final LatLng _defaultCenter = const LatLng(-6.2088, 106.8456); // 

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _getCurrentLocation(); // 
      }
    });
  }

  @override
  void dispose() {
    _mapController.dispose(); // 
    super.dispose();
  }

  bool _isValidLatLng(LatLng? point) {
    if (point == null) return false; // 
    return point.latitude.isFinite &&
        point.longitude.isFinite &&
        point.latitude >= -90 &&
        point.latitude <= 90 &&
        point.longitude >= -180 &&
        point.longitude <= 180; // 
  }

  LatLng? _sanitizeLatLng(double lat, double lng) {
    if (!lat.isFinite || !lng.isFinite) return null; // 
    if (lat.isNaN || lng.isNaN) return null; // 
    if (lat < -90 || lat > 90) return null; // 
    return LatLng(lat, lng); // 
  }

  Future<void> _getCurrentLocation() async {
    if (!mounted) return; // [cite: 202]

    setState(() {
      _isLoading = true; // [cite: 202]
      _hasError = false; // [cite: 202]
      _errorMessage = ''; // [cite: 202]
    });

    try {
      final hasPermission = await _handleLocationPermission(); // [cite: 202]
      if (!hasPermission) {
        if (!mounted) return; // [cite: 202]
        setState(() {
          _hasError = true; // [cite: 202]
          _errorMessage = 'Tidak dapat mengakses lokasi'; // [cite: 202]
          _isLoading = false; // [cite: 202]
        });
        return; // [cite: 202]
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      final currentPos = _sanitizeLatLng(position.latitude, position.longitude); // [cite: 202]
      if (currentPos == null) {
        throw Exception('Koordinat lokasi tidak valid'); // [cite: 202]
      }

      if (!mounted) return; // [cite: 202]
      setState(() {
        _currentPosition = currentPos; // [cite: 202]
        _hasError = false; // [cite: 202]
      });

      if (_isValidLatLng(_destinationPosition)) {
        await _getRoute(); // [cite: 202]
      }

      if (_isMapReady && _isValidLatLng(_currentPosition) && mounted) {
        _mapController.move(_currentPosition!, 15); // [cite: 202]
      }
    } catch (e) {
      if (!mounted) return; // [cite: 202]
      setState(() {
        _hasError = true; // [cite: 202]
        _errorMessage = 'Gagal mendapatkan lokasi: ${e.toString()}'; // [cite: 202]
      });
      _showSnackBar(_errorMessage); // [cite: 202]
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; // [cite: 203]
        });
      }
    }
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled(); // [cite: 203]
    if (!serviceEnabled) {
      _showSnackBar('Layanan lokasi tidak aktif. Silakan aktifkan.'); // [cite: 203]
      await Geolocator.openLocationSettings(); // [cite: 203]
      return false; // [cite: 203]
    }

    LocationPermission permission = await Geolocator.checkPermission(); // [cite: 203]
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission(); // [cite: 203]
      if (permission == LocationPermission.denied) {
        _showSnackBar('Izin lokasi ditolak.'); // [cite: 203]
        return false; // [cite: 203]
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showSnackBar('Izin lokasi ditolak permanen. Silakan aktifkan di pengaturan.'); // [cite: 203]
      await Geolocator.openAppSettings(); // [cite: 203]
      return false; // [cite: 203]
    }

    return true; // [cite: 203]
  }

  Future<void> _getRoute() async {
    if (_currentPosition == null || _destinationPosition == null) return; // [cite: 203]
    if (!_isValidLatLng(_currentPosition) || !_isValidLatLng(_destinationPosition)) return; // [cite: 203]

    try {
      final start = '${_currentPosition!.longitude},${_currentPosition!.latitude}'; // [cite: 203]
      final end = '${_destinationPosition!.longitude},${_destinationPosition!.latitude}'; // [cite: 203]

      final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/$start;$end' // [cite: 203]
        '?overview=full&geometries=geojson&steps=false&alternatives=false'
      );

      final response = await http.get(
        url,
        headers: {'User-Agent': 'FlutterMapApp/1.0'}, // [cite: 203]
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Waktu permintaan habis'), // [cite: 203]
      );

      if (!mounted) return; // [cite: 204]

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body); // [cite: 204]

        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final route = data['routes'][0]; // [cite: 204]
          final geometry = route['geometry']; // [cite: 204]

          if (geometry != null && geometry['coordinates'] != null) {
            final coordinates = geometry['coordinates'] as List; // [cite: 204]
            final points = coordinates.map((coord) {
              return LatLng(coord[1], coord[0]); // [cite: 204]
            }).toList();

            final distance = route['distance'] ?? 0; // [cite: 204]
            final duration = route['duration'] ?? 0; // [cite: 204]

            setState(() {
              _routePoints = points; // [cite: 204]
              _routeDistance = distance.toDouble(); // [cite: 204]
              _routeDuration = duration.toDouble(); // [cite: 204]
            });
          }
        } else {
          throw Exception('Rute tidak ditemukan'); // [cite: 204]
        }
      } else {
        throw Exception('Gagal mendapatkan rute (HTTP ${response.statusCode})'); // [cite: 204]
      }
    } catch (e) {
      setState(() {
        _routePoints = [_currentPosition!, _destinationPosition!]; // [cite: 204]
        _routeDistance = _calculateDistance(_currentPosition!, _destinationPosition!); // [cite: 204]
        _routeDuration = _routeDistance / 11.11; // [cite: 204]
      });
      _showSnackBar('Menggunakan rute garis lurus (OSRM tidak tersedia)'); // [cite: 204]
    }
  }

  void _zoomToRoute() {
    if (_routePoints.isEmpty || !_isMapReady) return; // [cite: 204]

    try {
      double sumLat = 0; // [cite: 204]
      double sumLng = 0; // [cite: 204]
      for (var point in _routePoints) {
        sumLat += point.latitude; // [cite: 204]
        sumLng += point.longitude; // [cite: 204]
      }

      final centerLat = sumLat / _routePoints.length; // [cite: 204]
      final centerLng = sumLng / _routePoints.length; // [cite: 204]
      final center = LatLng(centerLat, centerLng); // [cite: 205]

      double maxDistance = 0; // [cite: 205]
      for (var point in _routePoints) {
        final distance = _calculateDistance(center, point); // [cite: 205]
        if (distance > maxDistance) {
          maxDistance = distance; // [cite: 205]
        }
      }

      double zoomLevel; // [cite: 205]
      if (maxDistance < 100) { zoomLevel = 18; } // [cite: 205]
      else if (maxDistance < 500) { zoomLevel = 16; } // [cite: 205]
      else if (maxDistance < 2000) { zoomLevel = 14; } // [cite: 205]
      else if (maxDistance < 5000) { zoomLevel = 13; } // [cite: 205]
      else if (maxDistance < 10000) { zoomLevel = 12; } // [cite: 205]
      else if (maxDistance < 20000) { zoomLevel = 11; } // [cite: 205]
      else if (maxDistance < 50000) { zoomLevel = 10; } // [cite: 205]
      else { zoomLevel = 8; } // [cite: 205]

      _mapController.move(center, zoomLevel); // [cite: 205]
    } catch (e) {
      if (_isValidLatLng(_destinationPosition)) {
        _mapController.move(_destinationPosition!, 14); // [cite: 205]
      }
    }
  }

  double _calculateDistance(LatLng point1, LatLng point2) {
    if (!_isValidLatLng(point1) || !_isValidLatLng(point2)) return 0; // [cite: 205]

    const double R = 6371000; // [cite: 205]
    final double lat1 = point1.latitude * pi / 180; // [cite: 205]
    final double lat2 = point2.latitude * pi / 180; // [cite: 205]
    final double dLat = (point2.latitude - point1.latitude) * pi / 180; // [cite: 205]
    final double dLng = (point2.longitude - point1.longitude) * pi / 180; // [cite: 205]

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLng / 2) * sin(dLng / 2); // [cite: 205]
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a)); // [cite: 205]

    final double distance = R * c; // [cite: 205]
    return distance.isFinite ? distance : 0; // [cite: 205]
  }

  Future<void> _searchPlace(String query) async {
    if (query.isEmpty) {
      _showSnackBar('Masukkan nama tempat'); // [cite: 206]
      return; // [cite: 206]
    }

    if (!mounted) return; // [cite: 206]
    setState(() {
      _isLoading = true; // [cite: 206]
      _hasError = false; // [cite: 206]
    });

    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?' // [cite: 206]
        'q=${Uri.encodeComponent(query)}&format=json&limit=5&countrycodes=id'
      );

      final response = await http.get(
        url,
        headers: {'User-Agent': 'FlutterMapApp/1.0'}, // [cite: 206]
      ).timeout(const Duration(seconds: 10)); // [cite: 206]

      if (!mounted) return; // [cite: 206]

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List; // [cite: 206]

        if (data.isEmpty) {
          _showSnackBar('Tempat tidak ditemukan'); // [cite: 206]
          return; // [cite: 206]
        }

        if (data.length == 1) {
          final lat = double.parse(data[0]['lat']); // [cite: 206]
          final lng = double.parse(data[0]['lon']); // [cite: 206]
          final name = data[0]['display_name']; // [cite: 206]

          final newDest = _sanitizeLatLng(lat, lng); // [cite: 206]
          if (newDest == null) {
            _showSnackBar('Koordinat tidak valid'); // [cite: 206]
            return; // [cite: 206]
          }

          if (!mounted) return; // [cite: 206]
          setState(() {
            _destinationPosition = newDest; // [cite: 206]
            _destinationName = name; // [cite: 207]
          });

          await _getRoute(); // [cite: 207]

          if (_isMapReady && mounted) {
            _zoomToRoute(); // [cite: 207]
          }
          _showSnackBar('Tujuan: $name'); // [cite: 207]
        } else {
          if (mounted) {
            _showSearchResultDialog(data); // [cite: 207]
          }
        }
      } else {
        throw Exception('Gagal mencari tempat (HTTP ${response.statusCode})'); // [cite: 207]
      }
    } catch (e) {
      setState(() {
        _hasError = true; // [cite: 207]
        _errorMessage = e.toString(); // [cite: 207]
      });
      _showSnackBar('Error: ${e.toString()}'); // [cite: 207]
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; // [cite: 207]
        });
      }
    }
  }

  void _showSearchResultDialog(List<dynamic> results) {
    if (!mounted) return; // [cite: 207]

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Pilih Tujuan'), // [cite: 207]
          content: SizedBox(
            width: double.maxFinite, // [cite: 207]
            height: 300, // [cite: 207]
            child: ListView.builder(
              itemCount: results.length, // [cite: 207]
              itemBuilder: (context, index) {
                final item = results[index]; // [cite: 207]
                final name = item['display_name']; // [cite: 207]
                final lat = double.parse(item['lat']); // [cite: 207]
                final lng = double.parse(item['lon']); // [cite: 207]

                return ListTile(
                  title: Text(name, maxLines: 2, overflow: TextOverflow.ellipsis), // [cite: 207]
                  subtitle: Text(
                    '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}', // [cite: 208]
                    style: const TextStyle(fontSize: 12), // [cite: 208]
                  ),
                  onTap: () async {
                    final newDest = _sanitizeLatLng(lat, lng); // [cite: 208]
                    if (newDest != null) {
                      if (!mounted) return; // [cite: 208]
                      setState(() {
                        _destinationPosition = newDest; // [cite: 208]
                        _destinationName = name; // [cite: 208]
                      });

                      final messenger = ScaffoldMessenger.of(context);
                      await _getRoute(); // [cite: 208]

                      if (_isMapReady && mounted) {
                        _zoomToRoute(); // [cite: 208]
                      }
                      if (mounted) {
                        _showSnackBar('Tujuan: $name', messenger: messenger); // [cite: 208]
                      }
                    }
                    Navigator.pop(context); // [cite: 208]
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // [cite: 208]
              child: const Text('Tutup'),
            )
          ],
        );
      },
    );
  }

  String _formatDistance(double meters) {
    if (meters >= 1000) {
      return '${(meters / 1000).toStringAsFixed(1)} km'; // [cite: 208]
    } else {
      return '${meters.toStringAsFixed(0)} m'; // [cite: 208]
    }
  }

  String _formatDuration(double seconds) {
    if (seconds <= 0) return '0 menit'; // [cite: 208]
    if (seconds >= 3600) {
      final int hours = (seconds / 3600).floor(); // [cite: 208]
      final int minutes = ((seconds % 3600) / 60).round(); // [cite: 208]
      return '$hours jam $minutes menit'; // [cite: 208]
    } else if (seconds >= 60) {
      return '${(seconds / 60).round()} menit'; // [cite: 208]
    } else {
      return '< 1 menit'; // [cite: 208]
    }
  }

  void _showSnackBar(String message, {ScaffoldMessengerState? messenger}) {
    if (!mounted) return; // [cite: 209]
    final snackBarMessenger = messenger ?? ScaffoldMessenger.maybeOf(context);
    if (snackBarMessenger == null) return;

    snackBarMessenger.showSnackBar(
      SnackBar(
        content: Text(message), // [cite: 209]
        duration: const Duration(seconds: 3), // [cite: 209]
        action: SnackBarAction(
          label: 'OK', // [cite: 209]
          onPressed: () {
            if (mounted) {
              snackBarMessenger.hideCurrentSnackBar(); // [cite: 209]
            }
          },
        ),
      ),
    );
  }

  Widget _buildMarker(bool isDestination) {
    return Container(
      width: 30, // [cite: 209]
      height: 30, // [cite: 209]
      decoration: BoxDecoration(
        color: isDestination ? Colors.red : Colors.blue, // [cite: 209]
        shape: BoxShape.circle, // [cite: 209]
        border: Border.all(color: Colors.white, width: 2), // [cite: 209]
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3), // [cite: 209]
            blurRadius: 5, // [cite: 209]
            offset: const Offset(0, 2), // [cite: 209]
          )
        ],
      ),
      child: Icon(
        isDestination ? Icons.flag : Icons.my_location, // [cite: 209]
        color: Colors.white, // [cite: 209]
        size: 16, // [cite: 209]
      ),
    );
  }

  Widget _buildInfoCard() {
    if (_currentPosition == null || _destinationPosition == null) {
      return const SizedBox.shrink(); // [cite: 209]
    }

    final distance = _routeDistance > 0 ? _routeDistance : _calculateDistance(_currentPosition!, _destinationPosition!); // [cite: 209]
    final duration = _routeDuration > 0 ? _routeDuration : distance / 11.11; // [cite: 209]

    return Container(
      padding: const EdgeInsets.all(16), // [cite: 209]
      decoration: const BoxDecoration(
        color: Colors.white, // [cite: 209]
        boxShadow: [
          BoxShadow(
            color: Colors.grey, // [cite: 210]
            blurRadius: 4, // [cite: 210]
            offset: Offset(0, 2), // [cite: 210]
          )
        ],
      ),
      child: Column(
        children: [
          if (_destinationName.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8), // [cite: 210]
              child: Text(
                'Tujuan: $_destinationName', // [cite: 210]
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), // [cite: 210]
                textAlign: TextAlign.center, // [cite: 210]
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly, // [cite: 210]
            children: [
              _buildInfoItem(icon: Icons.route, label: 'Jarak', value: _formatDistance(distance)), // [cite: 210]
              Container(width: 1, height: 40, color: Colors.grey[300]), // [cite: 210]
              _buildInfoItem(icon: Icons.timer, label: 'Estimasi Waktu', value: _formatDuration(duration)), // [cite: 210]
              Container(width: 1, height: 40, color: Colors.grey[300]), // [cite: 210]
              _buildInfoItem(icon: Icons.directions_car, label: 'Kecepatan', value: '40 km/jam'), // [cite: 210]
            ],
          ),
          if (_routePoints.isNotEmpty && _routePoints.length > 2)
            Padding(
              padding: const EdgeInsets.only(top: 4), // [cite: 210]
              child: Text(
                '🗺️ Rute via jalan (${_routePoints.length} titik)', // [cite: 210]
                style: const TextStyle(fontSize: 11, color: Colors.green, fontStyle: FontStyle.italic), // [cite: 211]
              ),
            )
        ],
      ),
    );
  }

  Widget _buildInfoItem({required IconData icon, required String label, required String value}) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.green), // [cite: 211]
        const SizedBox(height: 4), // [cite: 211]
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), // [cite: 211]
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])), // [cite: 211]
      ],
    );
  }

  Future<void> _showCoordinateDialog() async {
    if (!mounted) return; // [cite: 211]

    final TextEditingController latController = TextEditingController(); // [cite: 211]
    final TextEditingController lngController = TextEditingController(); // [cite: 211]

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Masukkan Koordinat'), // [cite: 211]
          content: Column(
            mainAxisSize: MainAxisSize.min, // [cite: 211]
            children: [
              TextField(
                controller: latController, // [cite: 211]
                decoration: const InputDecoration(labelText: 'Latitude', hintText: 'Contoh: -6.1754'), // [cite: 211]
                keyboardType: const TextInputType.numberWithOptions(decimal: true), // [cite: 212]
              ),
              const SizedBox(height: 8), // [cite: 212]
              TextField(
                controller: lngController, // [cite: 212]
                decoration: const InputDecoration(labelText: 'Longitude', hintText: 'Contoh: 106.8272'), // [cite: 212]
                keyboardType: const TextInputType.numberWithOptions(decimal: true), // [cite: 212]
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')), // [cite: 212]
            TextButton(
              onPressed: () async {
                final lat = double.tryParse(latController.text); // [cite: 212]
                final lng = double.tryParse(lngController.text); // [cite: 212]

                if (lat != null && lng != null) {
                  final newDest = _sanitizeLatLng(lat, lng); // [cite: 212]
                  if (newDest == null) {
                    _showSnackBar('Koordinat tidak valid'); // [cite: 212]
                    return; // [cite: 212]
                  }

                  if (!mounted) return; // [cite: 212]
                  setState(() {
                    _destinationPosition = newDest; // [cite: 212]
                    _destinationName = 'Koordinat: $lat, $lng'; // [cite: 212]
                  });

                  final messenger = ScaffoldMessenger.of(context);
                  await _getRoute(); // [cite: 212]

                  if (_isMapReady && mounted) {
                    _zoomToRoute(); // [cite: 212]
                  }
                  if (mounted) {
                    _showSnackBar('Koordinat tersimpan', messenger: messenger);
                  }
                  Navigator.pop(context); // [cite: 212]
                } else {
                  _showSnackBar('Format koordinat tidak valid'); // [cite: 212]
                }
              },
              child: const Text('Simpan'), // [cite: 212]
            ),
          ],
        );
      },
    );
  }

  Future<void> _showSearchDialog() async {
    if (!mounted) return; // [cite: 212]
    final TextEditingController searchController = TextEditingController(); // [cite: 212]

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cari Tempat'), // [cite: 213]
          content: Column(
            mainAxisSize: MainAxisSize.min, // [cite: 213]
            children: [
              const Text('Masukkan nama tempat:'), // [cite: 213]
              const SizedBox(height: 8), // [cite: 213]
              TextField(
                controller: searchController, // [cite: 213]
                decoration: const InputDecoration(
                  hintText: 'Contoh: Monas, Jakarta', // [cite: 213]
                  prefixIcon: Icon(Icons.search), // [cite: 213]
                  border: OutlineInputBorder(), // [cite: 213]
                ),
                onSubmitted: (value) {
                  Navigator.pop(context, value); // [cite: 213]
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')), // [cite: 213]
            TextButton(
              onPressed: () => Navigator.pop(context, searchController.text), // [cite: 213]
              child: const Text('Cari'), // [cite: 213]
            ),
          ],
        );
      },
    ).then((result) {
      if (mounted && result != null && result.isNotEmpty) {
        _searchPlace(result); // [cite: 213]
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Navigasi OpenStreetMap'), // [cite: 213]
        backgroundColor: Colors.green, // [cite: 213]
        foregroundColor: Colors.white, // [cite: 213]
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location), // [cite: 213]
            onPressed: _getCurrentLocation, // [cite: 213]
            tooltip: 'Lokasi Saya', // [cite: 213]
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // [cite: 213]
          : Stack(
              children: [
                Column(
                  children: [
                    _buildInfoCard(), // [cite: 214]
                    Expanded(
                      child: Stack(
                        children: [
                          FlutterMap(
                            mapController: _mapController, // [cite: 214]
                            options: MapOptions(
                              initialCenter: _currentPosition ?? _defaultCenter, // [cite: 214]
                              initialZoom: 15, // [cite: 214]
                              onTap: (tapPosition, point) async {
                                if (_isMapReady && _isValidLatLng(point) && mounted) {
                                  setState(() {
                                    _destinationPosition = point; // [cite: 214]
                                    _destinationName =
                                        'Lat: ${point.latitude.toStringAsFixed(6)}, Lng: ${point.longitude.toStringAsFixed(6)}'; // [cite: 214]
                                  });
                                  await _getRoute(); // [cite: 214]
                                  _showSnackBar('Tujuan diubah'); // [cite: 214]
                                }
                              },
                              onMapReady: () {
                                if (!mounted) return; // [cite: 214]
                                setState(() {
                                  _isMapReady = true; // [cite: 214]
                                });
                                if (_isValidLatLng(_currentPosition)) {
                                  _mapController.move(_currentPosition!, 15); // [cite: 214]
                                }
                              },
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', // [cite: 214]
                                userAgentPackageName: 'com.example.flutter_application_1', // [cite: 214]
                                tileProvider: NetworkTileProvider(), // [cite: 214]
                              ),
                              if (_routePoints.isNotEmpty && _routePoints.length > 1)
                                PolylineLayer(
                                  polylines: [
                                    Polyline(
                                      points: _routePoints, // [cite: 214]
                                      color: Colors.blue, // [cite: 214]
                                      strokeWidth: 5, // [cite: 214]
                                      borderColor: Colors.blue, // [cite: 214]
                                      borderStrokeWidth: 7, // [cite: 214]
                                    ),
                                  ],
                                ),
                              if (_isValidLatLng(_currentPosition))
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      point: _currentPosition!, // [cite: 214]
                                      width: 40, // [cite: 215]
                                      height: 40, // [cite: 215]
                                      child: _buildMarker(false), // [cite: 215]
                                    ),
                                  ],
                                ),
                              if (_isValidLatLng(_destinationPosition))
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      point: _destinationPosition!, // [cite: 215]
                                      width: 40, // [cite: 215]
                                      height: 40, // [cite: 215]
                                      child: _buildMarker(true), // [cite: 215]
                                    ),
                                  ],
                                ),
                              const Align(
                                alignment: Alignment.bottomRight, // [cite: 215]
                                child: Padding(
                                  padding: EdgeInsets.all(8.0), // [cite: 215]
                                  child: Text(
                                    '© OpenStreetMap contributors | OSRM', // [cite: 215]
                                    style: TextStyle(
                                      fontSize: 10, // [cite: 215]
                                      color: Colors.grey, // [cite: 215]
                                      shadows: [Shadow(color: Colors.white, blurRadius: 4)], // [cite: 215]
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (_hasError)
                            Positioned(
                              top: 16, // [cite: 215]
                              left: 16, // [cite: 215]
                              right: 16, // [cite: 215]
                              child: Container(
                                padding: const EdgeInsets.all(12), // [cite: 215]
                                decoration: BoxDecoration(
                                  color: Colors.red[100], // [cite: 215]
                                  borderRadius: BorderRadius.circular(8), // [cite: 215]
                                  border: Border.all(color: Colors.red), // [cite: 215]
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.error, color: Colors.red), // [cite: 215]
                                    const SizedBox(width: 8), // [cite: 215]
                                    Expanded(
                                      child: Text(_errorMessage, style: const TextStyle(color: Colors.red)), // [cite: 216]
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          Positioned(
                            right: 16, // [cite: 216]
                            bottom: 100, // [cite: 216]
                            child: FloatingActionButton.small(
                              onPressed: () async {
                                if (_isValidLatLng(_currentPosition) && _isMapReady && mounted) {
                                  _mapController.move(_currentPosition!, 16); // [cite: 216]
                                } else {
                                  await _getCurrentLocation(); // [cite: 216]
                                }
                              },
                              backgroundColor: Colors.white, // [cite: 216]
                              foregroundColor: Colors.green, // [cite: 216]
                              child: const Icon(Icons.my_location), // [cite: 216]
                            ),
                          ),
                          if (_routePoints.isNotEmpty)
                            Positioned(
                              left: 16, // [cite: 216]
                              bottom: 100, // [cite: 216]
                              child: FloatingActionButton.small(
                                onPressed: () {
                                  if (_isMapReady) {
                                    _zoomToRoute(); // [cite: 216]
                                  }
                                },
                                backgroundColor: Colors.white, // [cite: 216]
                                foregroundColor: Colors.blue, // [cite: 216]
                                child: const Icon(Icons.zoom_out_map), // [cite: 216]
                              ),
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0), // [cite: 216]
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _showSearchDialog, // [cite: 216]
                              icon: const Icon(Icons.search), // [cite: 216]
                              label: const Text('Cari Tempat'), // [cite: 216]
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange, // [cite: 216]
                                foregroundColor: Colors.white, // [cite: 216]
                              ),
                            ),
                          ),
                          const SizedBox(width: 8), // [cite: 217]
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _showCoordinateDialog, // [cite: 217]
                              icon: const Icon(Icons.edit_location), // [cite: 217]
                              label: const Text('Koordinat'), // [cite: 217]
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue, // [cite: 217]
                                foregroundColor: Colors.white, // [cite: 217]
                              ),
                            ),
                          ),
                          const SizedBox(width: 8), // [cite: 217]
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                if (!mounted) return; // [cite: 217]
                                setState(() {
                                  _destinationPosition = null; // [cite: 217]
                                  _destinationName = ''; // [cite: 217]
                                  _routePoints = []; // [cite: 217]
                                  _routeDistance = 0; // [cite: 217]
                                  _routeDuration = 0; // [cite: 217]
                                });
                                _showSnackBar('Tujuan dihapus'); // [cite: 217]
                              },
                              icon: const Icon(Icons.clear), // [cite: 217]
                              label: const Text('Hapus'), // [cite: 217]
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red, // [cite: 217]
                                foregroundColor: Colors.white, // [cite: 217]
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}