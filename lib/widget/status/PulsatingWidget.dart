import 'dart:math' as math;
import 'package:flutter/material.dart';

class PulsatingWidget extends StatefulWidget {
  final Widget child;
  final double maxScale;
  final Duration pulseDuration; // 맥동 지속 시간
  final Duration interval; // 맥동 간격
  final Curve curve;

  const PulsatingWidget({
    super.key,
    required this.child,
    this.maxScale = 1.05, // 최대 확대 스케일
    this.pulseDuration = const Duration(milliseconds: 300), // 맥동 지속 시간
    this.interval = const Duration(seconds: 2), // 맥동 간격
    this.curve = Curves.easeInOut, // 애니메이션 곡선
  });

  @override
  State<PulsatingWidget> createState() => _PulsatingWidgetState();
}

class _PulsatingWidgetState extends State<PulsatingWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    // 전체 애니메이션 주기 설정 (맥동 시간 + 대기 시간)
    _controller = AnimationController(
      vsync: this,
      duration: widget.interval,
    );

    // 맥동 부분의 비율 계산 (전체 주기 중 맥동이 차지하는 비율)
    final pulseRatio = widget.pulseDuration.inMilliseconds / widget.interval.inMilliseconds;

    // 스케일 애니메이션 (처음 pulseRatio 동안만 크기 변화)
    _scaleAnimation = TweenSequence<double>([
      // 처음 pulseRatio/2 동안 확대
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: widget.maxScale)
            .chain(CurveTween(curve: widget.curve)),
        weight: pulseRatio * 50,
      ),
      // 다음 pulseRatio/2 동안 축소
      TweenSequenceItem(
        tween: Tween<double>(begin: widget.maxScale, end: 1.0)
            .chain(CurveTween(curve: widget.curve)),
        weight: pulseRatio * 50,
      ),
      // 나머지 시간 동안 원래 크기 유지
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: 100 - (pulseRatio * 100),
      ),
    ]).animate(_controller);

    // 파동 효과를 위한 투명도 애니메이션
    _opacityAnimation = TweenSequence<double>([
      // 처음 pulseRatio/2 동안 투명도 증가
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 0.8)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: pulseRatio * 50,
      ),
      // 다음 pulseRatio/2 동안 투명도 감소
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.3, end: 0.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: pulseRatio * 50,
      ),
      // 나머지 시간 동안 투명도 0 유지
      TweenSequenceItem(
        tween: ConstantTween<double>(0.0),
        weight: 100 - (pulseRatio * 100),
      ),
    ]).animate(_controller);

    // 애니메이션 반복
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // 파동 효과 (배경)
            Transform.scale(
              scale: math.max(1.0, _scaleAnimation.value * 1.2), // 파동은 메인 위젯보다 더 크게
              child: Opacity(
                opacity: _opacityAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withAlpha(100),
                  ),
                ),
              ),
            ),
            // 크기가 변하는 메인 위젯
            Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            ),
          ],
        );
      },
      child: widget.child,
    );
  }
}