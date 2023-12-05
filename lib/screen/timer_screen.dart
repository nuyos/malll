import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:malll/notification/notification_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dietory : 배꼽시계',
      home: TimerScreen(),
    );
  }
}

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  TimerScreenState createState() => TimerScreenState();
}

class TimerScreenState extends State<TimerScreen> {
  int _counter = 0; // 경과 시간(초)
  int _targetHours = 0; // 목표 시간(시)
  int _targetMinutes = 0; // 목표 시간(분)
  int _targetSeconds = 1; // 목표 시간(초)

  Timer? _timer; // 타이머 객체

  @override
  void initState() {
    super.initState();
    _requestNotificationPermissions(); // 알림 권한 요청
  }

  void _requestNotificationPermissions() async {
    final status = await NotificationService().requestNotificationPermissions();
    if (status.isDenied && context.mounted) {
      // 알림 권한이 거부된 경우 다이얼로그 표시
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('알림 권한이 거부되었습니다.'),
          content: Text('알림을 받으려면 앱 설정에서 권한 허용'),
          actions: <Widget>[
            TextButton(
              child: Text('설정'),
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
            ),
            TextButton(
              child: Text('취소'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dietory : 배꼽시계')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('남은 시간: ${_getRemainingTime()}'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('간헐적 단식 시간 입력 : '),
                Row(
                  children: [
                    SizedBox(
                      width: 60,
                      child: TextField(
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            _targetHours = int.parse(value);
                          });
                        },
                      ),
                    ),
                    const Text('시'),
                    SizedBox(
                      width: 60,
                      child: TextField(
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            _targetMinutes = int.parse(value);
                          });
                        },
                      ),
                    ),
                    const Text('분'),
                    SizedBox(
                      width: 60,
                      child: TextField(
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            _targetSeconds = int.parse(value);
                          });
                        },
                      ),
                    ),
                    const Text('초'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _resetCounter,
                  child: const Text('초기화'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _toggleTimer,
                  child: Text(_timer?.isActive == true ? '정지' : '시작'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getRemainingTime() {
    if (_timer?.isActive == true) {
      // 타이머가 활성화된 경우 남은 시간 계산
      int remainingTime = ((_targetHours * 60 * 60) + (_targetMinutes * 60) + _targetSeconds) - _counter;
      int hours = remainingTime ~/ 3600;
      int minutes = (remainingTime % 3600) ~/ 60;
      int seconds = remainingTime % 60;
      return '$hours시간 $minutes분 $seconds초';
    } else {
      return '시작 버튼을 눌러 타이머를 시작하세요.';
    }
  }


  void _resetCounter() {
    setState(() {
      _counter = 0;
    });

    // 초기화 버튼을 눌렀을 때 성공 알림 표시하지 않음
  }

  void _toggleTimer() {
    if (_timer?.isActive == true) {
      _stopTimer();
    } else {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _counter++;
        if (_counter == ((_targetHours * 60 * 60) + (_targetMinutes * 60) + _targetSeconds)) {
          // 타이머가 목표 시간에 도달한 경우 알림 표시 및 타이머 정지
          NotificationService().showNotification(_counter ~/ 60);
          _stopTimer();
          _resetCounter(); // 추가: 카운터 초기화
        }
      });
    });
  }// 백그라운드에서 앱 종료시 알림 안뜨는 문제 해결 해야함

  void _stopTimer() {
    // 타이머 정지
    _timer?.cancel();
  }
}
