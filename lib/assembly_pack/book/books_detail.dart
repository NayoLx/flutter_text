import 'package:flutter/material.dart';
import 'package:flutter_text/api/book.dart';
import 'package:flutter_text/assembly_pack/book/chapters_detail.dart';
import 'package:flutter_text/model/book.dart';

void main() => runApp(BooksDetail());

class BooksDetail extends StatefulWidget {
  final String id;

  BooksDetail({this.id});

  BooksDetailState createState() => BooksDetailState();
}

class BooksDetailState extends State<BooksDetail> {
  Books _books;
  ChapterResult _chapterResult;
  bool isShowPage = false;
  bool isShowChapter = false;

  //获取详情
  void getBooksDetail() async {
    final result = await BookApi().getBookDetail(widget.id);
    if (result != null) {
      setState(() {
        _books = result;
        isShowPage = true;
      });
      getBooksChapters();
    } else {
      Navigator.of(context).pop();
    }
  }

  //获取章节
  void getBooksChapters() async {
    final result = await BookApi().getBookBtoc(widget.id);
    if (result != null) {
      setState(() {
        _chapterResult = result;
        isShowChapter = true;
      });
      print(_chapterResult.name);
    }
  }

  @override
  void initState() {
    getBooksDetail();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isShowPage
        ? Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text(_books.title,
                  style: const TextStyle(fontSize: 15, color: Colors.black)),
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () {
                    Navigator.of(context).pop();
                  }),
            ),
            body: Container(
              child: Column(
                children: <Widget>[
                  Container(
                    height: 200,
                    child: Row(
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          alignment: Alignment.topCenter,
                          child: Image.network(
                            _books.cover,
                            width: 115,
                            height: 200,
                          ),
                        ),
                        Expanded(
                          child: Container(
                            child: Column(
                              children: <Widget>[
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                                  alignment: Alignment.topLeft,
                                  child: Text('作者： ${_books.author}'),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                                  alignment: Alignment.topLeft,
                                  child: Text('标签： ${_books.cat}'),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                                  alignment: Alignment.topLeft,
                                  child: Text('简介： ${_books.longIntro}',
                                      maxLines: 2),
                                ),
                                Expanded(
                                  child: Container(
                                    alignment: Alignment.bottomCenter,
                                    padding: const EdgeInsets.only(bottom: 20),
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ChaptersDetail(
                                                    link: _chapterResult
                                                        ?.chapters[0].link),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        child: const Text('开始阅读'),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  isShowChapter
                      ? Expanded(
                          child: ListView.builder(
                            itemBuilder: (_, index) {
                              return InkWell(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => ChaptersDetail(
                                          link: _chapterResult
                                              ?.chapters[index].link,
                                          chapters: _chapterResult.chapters,
                                          index: index)));
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 15.0),
                                  child: Text(
                                      _chapterResult?.chapters[index].title),
                                ),
                              );
                            },
                            itemCount: _chapterResult.chapters.length,
                          ),
                        )
                      : const Center(
                          child: CircularProgressIndicator(),
                        ),
                ],
              ),
            ))
        : const Center(
            child: CircularProgressIndicator(),
          );
  }
}
