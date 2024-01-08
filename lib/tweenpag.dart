import 'package:flutter/material.dart';

import 'home.dart';
import 'values/colors.dart';
import 'values/dimens.dart';
import 'values/styles.dart';

class tweenPage extends StatefulWidget {
  final minutes,seconds,list,index;
  const tweenPage({super.key,this.minutes,this.seconds,this.index,this.list});

  @override
  State<tweenPage> createState() => _tweenPageState();
}

class _tweenPageState extends State<tweenPage> {

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
        duration: Duration(
            minutes: widget.minutes,
            seconds: widget.seconds),
        tween: Tween(
            begin: Duration(
                minutes: widget.minutes,
                seconds: widget.seconds),
            end: Duration.zero),
        onEnd: () {

        },
        builder: (BuildContext context, Duration value,
            Widget? child) {
          final minutes = value.inMinutes;
          final seconds = value.inSeconds % 60;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Text(
              "0$minutes:$seconds",
              textAlign: TextAlign.center,
              style: Sty().smallText.copyWith(
                  color: Clr().white,
                  fontWeight: FontWeight.w600,
                  fontFamily: "MulshiSemi",
                  fontSize: Dim().d28),
            ),
          );
        });
  }
}
