
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

void main() => runApp(TextT());

class TextT extends StatefulWidget {
  TextState createState() => TextState();
}

class TextState extends State<TextT> {
  int count = 10;

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ListView"),
      ),
      body: AnimationLimiter(
        child: ListView.builder(
          itemCount: count,
          itemBuilder: (context, index) {
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation( //滑动动画
                verticalOffset: 50.0,
                child: FadeInAnimation( //渐隐渐现动画
                  child: Container(
                    margin: EdgeInsets.all(5),
                    color: Theme
                        .of(context)
                        .primaryColor,
                    height: 60,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
