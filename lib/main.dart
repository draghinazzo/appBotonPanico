import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shutter Volume Listener',
      debugShowCheckedModeBanner: false,
      home: const VolumePage(),
    );
  }
}

class VolumePage extends StatefulWidget {
  const VolumePage({super.key});

  @override
  State<VolumePage> createState() => _VolumePageState();
}

class _VolumePageState extends State<VolumePage> {
  static const MethodChannel _channel = MethodChannel('volume_channel');
  String status = 'Alarma activa';
  String? currentImagePath;
  int countdown = 0;
  Timer? countdownTimer;

  @override
  void initState() {
    super.initState();
    _channel.setMethodCallHandler(_handleNativeCall);
  }

  Future<void> _handleNativeCall(MethodCall call) async {
    if (call.method == 'volumeUp') {
      await _startCountdown('assets/images/saludar.png');
    } else if (call.method == 'volumeDown') {
      await _startCountdown('assets/images/caminar.png');
    }
  }

  Future<void> _startCountdown(String imagePath) async {
    setState(() {
      currentImagePath = imagePath;
      countdown = 3;
      status = 'Activando en $countdown...';
    });

    countdownTimer?.cancel();
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown > 1) {
        setState(() {
          countdown--;
          status = 'Activando en $countdown...';
        });
      } else {
        timer.cancel();
        _triggerAlert(imagePath);
      }
    });
  }

  Future<void> _triggerAlert(String imagePath) async {
    setState(() {
      status = 'Enviando alerta...';
    });

    try {
      final response = await http.get(Uri.parse(
        'http://mipolicia.ssp.cdmx.gob.mx/mpn/rest/alertas/activar/51bee05eb1542083672ea13ff3d69059f55cbf82',
      ));

      setState(() {
        status = 'Respuesta: ${response.body}';
      });
    } catch (e) {
      setState(() {
        status = 'Error al enviar alerta: $e';
      });
    }

    await Future.delayed(const Duration(seconds: 3));
    setState(() {
      currentImagePath = null;
      status = 'Alarma activa';
    });
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alarma MPN')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(status, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            if (currentImagePath != null)
              Image.asset(currentImagePath!, height: 200),
          ],
        ),
      ),
    );
  }
}
