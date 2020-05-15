import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutter_text/api/pear_video.dart';
import 'package:flutter_text/model/pear_video.dart';
import 'package:flutter_text/utils/utils.dart';
import 'package:flutter_text/widget/video_widget.dart';

void main() => runApp(PearVideoFirstPage());

class PearVideoFirstPage extends StatefulWidget {
  PearVideoFirstPageState createState() => PearVideoFirstPageState();
}

class PearVideoFirstPageState extends State<PearVideoFirstPage>
    with SingleTickerProviderStateMixin {
  SwiperController swperController = SwiperController(); //swiper组件
  ScrollController scroController = new ScrollController(); //自动滑动title控制器
  Timer timer;  //自动滑动title
  int currentIndex = 0; //当前index
  int page = 1; //数据页数
  bool isShow = false; //是否显示页面
  List<Category> tabs = []; //底部栏
  List<HotList> hot = []; //swipe数据

  //title自动滚动
  void startTimer() {
    int time = 10000;
    timer = Timer.periodic(new Duration(milliseconds: time), (timer) {
      if (scroController.positions.isNotEmpty == false) {
        print('界面被销毁');
        return;
      }
      double maxScrollExtent = scroController.position.maxScrollExtent;
      if (maxScrollExtent > 0) {
        scroController.animateTo(maxScrollExtent,
            duration: new Duration(milliseconds: (time * 0.5).toInt()),
            curve: Curves.linear);
        Future.delayed(Duration(milliseconds: (time * 0.5).toInt()), () {
          if (scroController.positions.isNotEmpty == true) {
            scroController.animateTo(0,
                duration: new Duration(milliseconds: (time * 0.5).toInt()),
                curve: Curves.linear);
          }
        });
      } else {
        print('不需要移动');
        timer.cancel();
      }
    });
  }

  //获取列表
  void getCategoryList() async {
    final result = await PearVideoApi().getCategoryList();
    setState(() {
      tabs = result;
    });
    getVideoList();
  }

  //获取视频信息
  void getVideoList({bool isLoadMore = false}) async {
    String id = ArrayUtil.get(tabs, currentIndex).categoryId;
    final result = await PearVideoApi().getCategoryDataList(page, id);
    setState(() {
      page += 1;
      if (isLoadMore == false) {
        hot.clear();
        page = 1;
      }
      hot.addAll(result);
      isShow = true;
    });
    print(hot[0].videos.url);
  }

  void initState() {
    super.initState();
    this.startTimer();
    getCategoryList();
  }

  //页面销毁
  void dispose() {
    this.scroController.dispose();
    this.timer.cancel();

    super.dispose();
  }

  Widget build(BuildContext context) {
    return isShow
        ? Scaffold(
            body: SingleChildScrollView(
              child: Container(
                child: componentView(context),
              ),
            ),
            bottomSheet: Container(
              height: 45,
              color: Colors.black,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: tabs?.length ?? 0,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        currentIndex = index;
                      });
                      getVideoList();
                    },
                    child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.only(left: 20, right: 20),
                      child: Text(
                        '${ArrayUtil.get(tabs, index).name ?? ''}',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                },
              ),
            ),
          )
        : Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
  }

  Widget componentView(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: Swiper(
        loop: false,
        itemCount: hot?.length ?? 0,
        onIndexChanged: (val) {
          if (val == hot.length - 1) {
            getVideoList(isLoadMore: true);
          }
        },
        controller: swperController,
        scrollDirection: Axis.vertical,
        itemBuilder: (BuildContext context, int index) {
          return ArrayUtil.get(hot, index).videos.url != null
              ? Stack(
                  children: <Widget>[
                    VideoPlayerText(
                      url: ArrayUtil.get(hot, index)
                          .videos
                          .url
                          .replaceAll('http:', 'https:'),
                      title: '示例视频',
                      width: MediaQuery.of(context).size.width,
                    ),
                    Positioned(
                        bottom: 80,
                        left: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                CircleAvatar(
                                  radius: 20,
                                  backgroundImage: NetworkImage(
                                      ArrayUtil.get(hot, index).nodeInfo?.logoImg),
                                ),
                                Container(
                                  padding: EdgeInsets.only(left: 13),
                                  child: Text(
                                    '${ArrayUtil.get(hot, index).nodeInfo?.name ?? ''}',
                                    style: TextStyle(color: Colors.white, fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                                padding: EdgeInsets.only(top: 10),
                                width: 150,
                                height: 30,
                                child: ListView(
                                  controller: scroController,
                                  physics: new NeverScrollableScrollPhysics(),
                                  scrollDirection: Axis.horizontal,
                                  children: <Widget>[
                                    Text(
                                      '${ArrayUtil.get(hot, index).name ?? ''}',
                                      maxLines: 1,
                                      style: TextStyle(color: Colors.white, fontSize: 16),
                                    ),
                                  ],
                                )
                            ),
                          ],
                        ),),
                  ],
                )
              : Container();
        },
      ),
    );
  }
}
