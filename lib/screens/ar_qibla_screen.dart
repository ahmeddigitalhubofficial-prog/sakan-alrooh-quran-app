// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:camera/camera.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/theme_manager.dart';
import '../main.dart';
import '../core/helpers/app_lifecycle_helper.dart';
import '../services/world_location_service.dart';
import '../widgets/common/quick_language_button.dart';
import '../core/localization/locale_manager.dart';
import '../core/localization/app_translations.dart';

class ArQiblaScreen extends StatefulWidget {
  final bool isActive;
  const ArQiblaScreen({super.key, this.isActive = true});

  @override
  State<ArQiblaScreen> createState() => _ArQiblaScreenState();
}

class _ArQiblaScreenState extends State<ArQiblaScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  CameraController? _cameraController;
  StreamSubscription? _compassSubscription;
  late AnimationController _pulseController;
  bool _isInitializingCamera = false;
  
  double? _userLatitude;
  double? _userLongitude;
  double _qiblaBearing = 0.0;
  double _deviceHeading = 0.0;
  bool _isCameraInitialized = false;
  bool _isLoadingLocation = true;
  String _statusMessage = 'جاري تحديد القبلة بالواقع المعزز...';

  // Kaaba Coordinates
  static const double kaabaLat = 21.422487;
  static const double kaabaLng = 39.826206;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (AppLifecycleHelper.isForeground) {
      _pulseController.repeat(reverse: true);
    }
    _getLocationAndCalculateQibla();
    if (widget.isActive && AppLifecycleHelper.isForeground) {
      _setupCamera();
      _setupCompass();
    }
  }

  @override
  void didUpdateWidget(ArQiblaScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        if (AppLifecycleHelper.isForeground) {
          _setupCamera();
          _setupCompass();
        }
      } else {
        _stopAndDisposeCamera();
        _compassSubscription?.cancel();
        _compassSubscription = null;
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pulseController.dispose();
    _compassSubscription?.cancel();
    _compassSubscription = null;
    _stopAndDisposeCamera();
    super.dispose();
  }

  Future<void> _stopAndDisposeCamera() async {
    final controller = _cameraController;
    _cameraController = null;
    safeSetState(() {
      _isCameraInitialized = false;
    });
    if (controller != null) {
      try {
        await controller.dispose();
      } catch (e) {
        debugPrint('Camera dispose error: $e');
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
      if (widget.isActive) {
        _setupCompass();
        _setupCamera();
      }
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      _pulseController.stop();
      _compassSubscription?.cancel();
      _compassSubscription = null;
      _stopAndDisposeCamera();
    }
  }

  Future<void> _setupCamera() async {
    if (_isInitializingCamera || _cameraController != null) return;
    if (!widget.isActive || AppLifecycleHelper.isBackground) return;
    _isInitializingCamera = true;

    try {
      final cameras = await availableCameras();
      if (!mounted || !widget.isActive || AppLifecycleHelper.isBackground) return;
      if (cameras.isEmpty) {
        safeSetState(() {
          _statusMessage = 'وضع البوصلة الرقمية (2D) • لم تتوفر كاميرا';
        });
        return;
      }

      final backCamera = cameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        backCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await controller.initialize();
      if (!mounted || !widget.isActive || AppLifecycleHelper.isBackground) {
        await controller.dispose();
        return;
      }

      _cameraController = controller;
      safeSetState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      debugPrint('Camera Init / Pigeon Codec Error: $e');
      // On devices with OEM camera modifications (such as Vivo Android 12 with custom CameraX classes),
      // or if camera permission was denied, fall back gracefully to 2D Digital Compass mode without throwing or crashing.
      safeSetState(() {
        _isCameraInitialized = false;
        _statusMessage = 'وضع البوصلة الرقمية (2D) • جاري التوجيه للقبلة';
      });
    } finally {
      _isInitializingCamera = false;
    }
  }

  Future<void> _getLocationAndCalculateQibla() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLat = prefs.getDouble('saved_lat');
      final savedLng = prefs.getDouble('saved_lng');

      if (savedLat != null && savedLng != null) {
        _userLatitude = savedLat;
        _userLongitude = savedLng;
        _calculateQibla();
        if (mounted) {
          setState(() {
            _isLoadingLocation = false;
          });
        }
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 10),
          ),
        );
        
        _userLatitude = position.latitude;
        _userLongitude = position.longitude;
        
        await prefs.setDouble('saved_lat', position.latitude);
        await prefs.setDouble('saved_lng', position.longitude);

        _calculateQibla();
      } else {
        if (_userLatitude == null) {
          final fallbackCoords = await WorldLocationService.getSavedCoordinates();
          _userLatitude = fallbackCoords.latitude;
          _userLongitude = fallbackCoords.longitude;
          _calculateQibla();
        }
      }
    } catch (e) {
      debugPrint('Location Fetch Error: $e');
      if (_userLatitude == null) {
        final fallbackCoords = await WorldLocationService.getSavedCoordinates();
        _userLatitude = fallbackCoords.latitude;
        _userLongitude = fallbackCoords.longitude;
        _calculateQibla();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }

  void _calculateQibla() {
    if (_userLatitude == null || _userLongitude == null) return;

    final userLatRad = _userLatitude! * (math.pi / 180.0);
    final userLngRad = _userLongitude! * (math.pi / 180.0);
    const kaabaLatRad = kaabaLat * (math.pi / 180.0);
    const kaabaLngRad = kaabaLng * (math.pi / 180.0);

    final dLng = kaabaLngRad - userLngRad;

    final y = math.sin(dLng);
    final x = math.cos(userLatRad) * math.tan(kaabaLatRad) -
        math.sin(userLatRad) * math.cos(dLng);

    double qiblaAngleRad = math.atan2(y, x);
    double qiblaAngleDeg = qiblaAngleRad * (180.0 / math.pi);

    _qiblaBearing = (qiblaAngleDeg + 360.0) % 360.0;
  }

  void _setupCompass() {
    _compassSubscription?.cancel();
    if (AppLifecycleHelper.isBackground) return;

    _compassSubscription = FlutterCompass.events?.listen((CompassEvent event) {
      if (!mounted || AppLifecycleHelper.isBackground) return;
      if (event.heading != null) {
        safeSetState(() {
          _deviceHeading = (event.heading! + 360.0) % 360.0;
        });
      }
    });
  }

  double _getRelativeQiblaAngle() {
    double diff = _qiblaBearing - _deviceHeading;
    return (diff + 360.0) % 360.0;
  }

  double _getDirectionDifference() {
    double diff = _qiblaBearing - _deviceHeading;
    if (diff > 180) diff -= 360;
    if (diff < -180) diff += 360;
    return diff;
  }

  bool _isFacingQibla() {
    return _getDirectionDifference().abs() <= 6.0;
  }

  String _getKaabaDistanceText() {
    if (_userLatitude == null || _userLongitude == null) return '';
    final distanceInMeters = Geolocator.distanceBetween(
      _userLatitude!,
      _userLongitude!,
      kaabaLat,
      kaabaLng,
    );
    final km = (distanceInMeters / 1000).round();
    return '$km كم';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<AppThemeManager>(context).currentTheme;
    final isFacingQibla = _isFacingQibla();
    final relativeQiblaAngle = _getRelativeQiblaAngle();
    final diff = _getDirectionDifference();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Directionality(
        textDirection: Provider.of<LocaleManager>(context).textDirection,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Live Camera Preview Feed
            if (_isCameraInitialized && _cameraController != null)
              CameraPreview(_cameraController!)
            else
              Container(
                color: const Color(0xFF0D1B2A),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: theme.accentColor),
                      SizedBox(height: 16.h),
                      Text(
                        _statusMessage,
                        style: GoogleFonts.cairo(color: Colors.white70, fontSize: 14.sp),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

            // Top Header Bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.55),
                    padding: EdgeInsets.only(top: 48.h, bottom: 16.h, right: 16.w, left: 16.w),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_forward, color: Colors.white),
                          onPressed: () {
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            } else {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
                                (route) => false,
                              );
                            }
                          },
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.tr('nav_qibla'),
                                style: GoogleFonts.cairo(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.sp,
                                ),
                              ),
                              Text(
                                _isLoadingLocation
                                    ? 'جاري تحديد موقعك الجغرافي...'
                                    : 'موقعك: ${_userLatitude?.toStringAsFixed(3)}° ، ${_userLongitude?.toStringAsFixed(3)}°  |  المسافة: ${_getKaabaDistanceText()}',
                                style: GoogleFonts.cairo(
                                  color: Colors.white70,
                                  fontSize: 11.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const QuickLanguageButton(isCompact: true),
                        SizedBox(width: 8.w),
                        Icon(
                          Icons.camera_front_rounded,
                          color: isFacingQibla ? Colors.greenAccent : theme.accentColor,
                          size: 24.sp,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 2. Off-Screen Guidance Banners (Left / Right guidance)
            if (!_isLoadingLocation && !isFacingQibla && diff.abs() > 15)
              _buildOffScreenGuidance(diff, theme),

            // 3. Floating 3D Kaaba in the sky when aligned
            if (!_isLoadingLocation && diff.abs() < 35)
              _buildFloatingKaaba(diff, isFacingQibla),

            // 4. Giant 3D Arrow and Compass HUD in the center/bottom
            if (!_isLoadingLocation)
              Positioned(
                bottom: 30.h,
                left: 0,
                right: 0,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Compass Dial with Giant 3D Arrow
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Container(
                            width: 260.w,
                            height: 260.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: isFacingQibla
                                      ? Colors.greenAccent.withValues(alpha: 0.2 + (_pulseController.value * 0.2))
                                      : theme.accentColor.withValues(alpha: 0.1 + (_pulseController.value * 0.1)),
                                  blurRadius: 30,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Outer Ring
                                Container(
                                  width: 240.w,
                                  height: 240.w,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black.withValues(alpha: 0.45),
                                    border: Border.all(
                                      color: isFacingQibla ? Colors.greenAccent : theme.accentColor.withValues(alpha: 0.4),
                                      width: isFacingQibla ? 3.0 : 2.0,
                                    ),
                                  ),
                                ),

                                // Rotating Giant 3D Glowing Arrow
                                Transform.rotate(
                                  angle: relativeQiblaAngle * math.pi / 180.0,
                                  child: CustomPaint(
                                    size: Size(230.w, 230.w),
                                    painter: GiantQiblaArrow3DPainter(
                                      color: isFacingQibla ? const Color(0xFF00E676) : theme.accentColor,
                                      isFacingQibla: isFacingQibla,
                                      pulseValue: _pulseController.value,
                                    ),
                                  ),
                                ),

                                // Center Kaaba Icon Badge
                                Container(
                                  width: 60.w,
                                  height: 60.w,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFF101010),
                                    border: Border.all(
                                      color: isFacingQibla ? Colors.greenAccent : const Color(0xFFFFD700),
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: isFacingQibla ? Colors.greenAccent.withValues(alpha: 0.4) : const Color(0xFFFFD700).withValues(alpha: 0.2),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      '🕋',
                                      style: TextStyle(fontSize: 28.sp),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 16.h),

                      // Status Info Card
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.78),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: isFacingQibla ? Colors.greenAccent : Colors.white24,
                            width: 1.5,
                          ),
                          boxShadow: [
                            if (isFacingQibla)
                              BoxShadow(
                                color: Colors.greenAccent.withValues(alpha: 0.25),
                                blurRadius: 15,
                              ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isFacingQibla ? 'أنت تواجه الكعبة المشرفة الآن! 🕋' : 'قم بتدوير الهاتف نحو السهم الذهبي',
                              style: GoogleFonts.cairo(
                                color: isFacingQibla ? const Color(0xFF69F0AE) : Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15.sp,
                              ),
                            ),
                            SizedBox(height: 3.h),
                            Text(
                              'زاوية القبلة: ${_qiblaBearing.toStringAsFixed(1)}°  |  اتجاه الهاتف: ${_deviceHeading.toStringAsFixed(1)}°  |  الفارق: ${diff.abs().toStringAsFixed(1)}°',
                              style: GoogleFonts.cairo(
                                color: Colors.white70,
                                fontSize: 11.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Haptic trigger on alignment
            if (isFacingQibla)
              const Positioned(
                bottom: 80,
                left: 0,
                right: 0,
                child: _HapticFeedbackWrapper(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOffScreenGuidance(double diff, AppTheme theme) {
    final bool isTurnRight = diff > 0;
    return Positioned(
      top: MediaQuery.of(context).size.height * 0.42,
      right: isTurnRight ? 16.w : null,
      left: !isTurnRight ? 16.w : null,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: theme.accentColor.withValues(alpha: 0.8),
                width: 1.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.accentColor.withValues(alpha: 0.3 + (_pulseController.value * 0.3)),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isTurnRight) ...[
                  Icon(Icons.arrow_back_rounded, color: theme.accentColor, size: 22.sp),
                  SizedBox(width: 6.w),
                ],
                Text(
                  isTurnRight ? 'استدر يميناً ⬅️ (${diff.round()}°)' : '(${diff.abs().round()}°) ➡️ استدر يساراً',
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13.sp,
                  ),
                ),
                if (isTurnRight) ...[
                  SizedBox(width: 6.w),
                  Icon(Icons.arrow_forward_rounded, color: theme.accentColor, size: 22.sp),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFloatingKaaba(double diff, bool isFacingQibla) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final horizontalOffset = (diff / 35.0) * (screenWidth * 0.35);

    return Positioned(
      left: (screenWidth / 2 - 80.w) + horizontalOffset,
      top: screenHeight * 0.18,
      width: 160.w,
      height: 160.w,
      child: Center(
        child: Kaaba3DWidget(
          size: 130.w,
          yawAngle: (-diff * math.pi / 180.0) + 0.45,
          pitchAngle: 0.32,
          isMini: false,
          glowColor: isFacingQibla ? Colors.greenAccent : Colors.transparent,
        ),
      ),
    );
  }
}

/// رسم السهم ثلاثي الأبعاد العملاق المتوهج (Giant Neon 3D Arrow)
class GiantQiblaArrow3DPainter extends CustomPainter {
  final Color color;
  final bool isFacingQibla;
  final double pulseValue;

  GiantQiblaArrow3DPainter({
    required this.color,
    required this.isFacingQibla,
    required this.pulseValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    final baseColor = isFacingQibla ? const Color(0xFF00E676) : color;
    final lightColor = isFacingQibla ? const Color(0xFFB9F6CA) : const Color(0xFFFFE082);
    final darkColor = isFacingQibla ? const Color(0xFF00A844) : const Color(0xFFC49000);

    // 1. Draw glowing outer aura
    final glowPaint = Paint()
      ..color = baseColor.withValues(alpha: 0.35 + (pulseValue * 0.25))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);

    final glowPath = Path();
    glowPath.moveTo(centerX, 8);
    glowPath.lineTo(centerX - 36, 85);
    glowPath.lineTo(centerX - 16, 75);
    glowPath.lineTo(centerX - 16, centerY - 20);
    glowPath.lineTo(centerX + 16, centerY - 20);
    glowPath.lineTo(centerX + 16, 75);
    glowPath.lineTo(centerX + 36, 85);
    glowPath.close();
    canvas.drawPath(glowPath, glowPaint);

    // 2. Draw Left Half (Light Facet)
    final leftPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [lightColor, baseColor],
      ).createShader(Rect.fromLTWH(centerX - 36, 8, 36, centerY));

    final leftPath = Path();
    leftPath.moveTo(centerX, 12);
    leftPath.lineTo(centerX - 32, 80);
    leftPath.lineTo(centerX - 14, 72);
    leftPath.lineTo(centerX - 14, centerY - 24);
    leftPath.lineTo(centerX, centerY - 24);
    leftPath.close();
    canvas.drawPath(leftPath, leftPaint);

    // 3. Draw Right Half (Shadow Facet)
    final rightPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [baseColor, darkColor],
      ).createShader(Rect.fromLTWH(centerX, 8, 36, centerY));

    final rightPath = Path();
    rightPath.moveTo(centerX, 12);
    rightPath.lineTo(centerX + 32, 80);
    rightPath.lineTo(centerX + 14, 72);
    rightPath.lineTo(centerX + 14, centerY - 24);
    rightPath.lineTo(centerX, centerY - 24);
    rightPath.close();
    canvas.drawPath(rightPath, rightPaint);

    // 4. Center Spine Highlight
    final spinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(centerX, 14), Offset(centerX, centerY - 24), spinePaint);

    // 5. Arrowhead Tip Crystal
    final tipPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(centerX, 14), 4.5, tipPaint);
  }

  @override
  bool shouldRepaint(covariant GiantQiblaArrow3DPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.isFacingQibla != isFacingQibla ||
        oldDelegate.pulseValue != pulseValue;
  }
}

class _HapticFeedbackWrapper extends StatefulWidget {
  const _HapticFeedbackWrapper();

  @override
  State<_HapticFeedbackWrapper> createState() => _HapticFeedbackWrapperState();
}

class _HapticFeedbackWrapperState extends State<_HapticFeedbackWrapper> {
  @override
  void initState() {
    super.initState();
    HapticFeedback.vibrate();
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

// Vector3 structure for 3D math operations
class Vector3 {
  final double x;
  final double y;
  final double z;

  const Vector3(this.x, this.y, this.z);

  Vector3 rotateX(double angle) {
    final cosA = math.cos(angle);
    final sinA = math.sin(angle);
    return Vector3(x, y * cosA - z * sinA, y * sinA + z * cosA);
  }

  Vector3 rotateY(double angle) {
    final cosA = math.cos(angle);
    final sinA = math.sin(angle);
    return Vector3(x * cosA + z * sinA, y, -x * sinA + z * cosA);
  }

  Vector3 rotateZ(double angle) {
    final cosA = math.cos(angle);
    final sinA = math.sin(angle);
    return Vector3(x * cosA - y * sinA, x * sinA + y * cosA, z);
  }
}

// 3D Kaaba Widget
class Kaaba3DWidget extends StatelessWidget {
  final double size;
  final double yawAngle;
  final double pitchAngle;
  final bool isMini;
  final Color glowColor;

  const Kaaba3DWidget({
    super.key,
    required this.size,
    required this.yawAngle,
    required this.pitchAngle,
    this.isMini = false,
    this.glowColor = Colors.transparent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: glowColor != Colors.transparent
          ? BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: glowColor.withValues(alpha: 0.35),
                  blurRadius: 35,
                  spreadRadius: 6,
                ),
              ],
            )
          : null,
      child: CustomPaint(
        size: Size(size, size),
        painter: Kaaba3DPainter(
          yaw: yawAngle,
          pitch: pitchAngle,
          isMini: isMini,
        ),
      ),
    );
  }
}

// 3D Kaaba Painter using Painter's Algorithm and Dynamic Diffuse Shading
class Kaaba3DPainter extends CustomPainter {
  final double yaw;
  final double pitch;
  final bool isMini;

  Kaaba3DPainter({
    required this.yaw,
    required this.pitch,
    required this.isMini,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    final double s = size.width * (isMini ? 0.32 : 0.34);
    final vertices = [
      Vector3(-s, -s, -s), // 0: Top Back Left
      Vector3(s, -s, -s),  // 1: Top Back Right
      Vector3(s, s, -s),   // 2: Bottom Back Right
      Vector3(-s, s, -s),  // 3: Bottom Back Left
      Vector3(-s, -s, s),  // 4: Top Front Left
      Vector3(s, -s, s),   // 5: Top Front Right
      Vector3(s, s, s),    // 6: Bottom Front Right
      Vector3(-s, s, s),   // 7: Bottom Front Left
    ];

    final rotated = vertices.map((v) {
      var r = v.rotateY(yaw);
      r = r.rotateX(pitch);
      return r;
    }).toList();

    final projected = rotated.map((v) {
      const cameraDist = 400.0;
      final factor = cameraDist / (cameraDist + v.z);
      return Offset(centerX + v.x * factor, centerY + v.y * factor);
    }).toList();

    final faces = [
      {'indices': [4, 5, 6, 7], 'name': 'front'},
      {'indices': [1, 0, 3, 2], 'name': 'back'},
      {'indices': [0, 4, 7, 3], 'name': 'left'},
      {'indices': [5, 1, 2, 6], 'name': 'right'},
      {'indices': [0, 1, 5, 4], 'name': 'top'},
      {'indices': [7, 6, 2, 3], 'name': 'bottom'},
    ];

    faces.sort((a, b) {
      final aIdx = a['indices'] as List<int>;
      final bIdx = b['indices'] as List<int>;
      final aZ = aIdx.map((i) => rotated[i].z).reduce((x, y) => x + y) / 4;
      final bZ = bIdx.map((i) => rotated[i].z).reduce((x, y) => x + y) / 4;
      return bZ.compareTo(aZ);
    });

    final goldPaint = Paint()..color = const Color(0xFFFFD700);
    final borderPaint = Paint()
      ..color = const Color(0xFFD4AF37).withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (final face in faces) {
      final idx = face['indices'] as List<int>;
      final name = face['name'] as String;

      final p0 = projected[idx[0]];
      final p1 = projected[idx[1]];
      final p2 = projected[idx[2]];
      final p3 = projected[idx[3]];

      final edge1 = p1 - p0;
      final edge2 = p2 - p0;
      final crossProduct = (edge1.dx * edge2.dy) - (edge1.dy * edge2.dx);

      if (crossProduct > 0) continue; // Back-face culling

      Color faceColor;
      switch (name) {
        case 'top':
          faceColor = const Color(0xFF1E1E1E);
          break;
        case 'front':
          faceColor = const Color(0xFF0F0F0F);
          break;
        case 'right':
          faceColor = const Color(0xFF151515);
          break;
        case 'left':
          faceColor = const Color(0xFF0A0A0A);
          break;
        case 'back':
          faceColor = const Color(0xFF050505);
          break;
        default:
          faceColor = const Color(0xFF121212);
      }

      final facePath = Path()
        ..moveTo(p0.dx, p0.dy)
        ..lineTo(p1.dx, p1.dy)
        ..lineTo(p2.dx, p2.dy)
        ..lineTo(p3.dx, p3.dy)
        ..close();

      canvas.drawPath(facePath, Paint()..color = faceColor);
      canvas.drawPath(facePath, borderPaint);

      // Gold Belt on walls (Kiswah Belt)
      if (name == 'front' || name == 'right' || name == 'left' || name == 'back') {
        final bTop0 = Offset.lerp(p0, p3, 0.18)!;
        final bTop1 = Offset.lerp(p1, p2, 0.18)!;
        final bBot1 = Offset.lerp(p1, p2, 0.28)!;
        final bBot0 = Offset.lerp(p0, p3, 0.28)!;

        final beltPath = Path()
          ..moveTo(bTop0.dx, bTop0.dy)
          ..lineTo(bTop1.dx, bTop1.dy)
          ..lineTo(bBot1.dx, bBot1.dy)
          ..lineTo(bBot0.dx, bBot0.dy)
          ..close();

        canvas.drawPath(beltPath, goldPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant Kaaba3DPainter oldDelegate) {
    return oldDelegate.yaw != yaw || oldDelegate.pitch != pitch;
  }
}
