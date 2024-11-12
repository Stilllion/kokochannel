import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:html/parser.dart';
import 'package:html/dom.dart' as DOM;
import 'package:flutter/material.dart';
import 'package:kokochannel/TGPost.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:kokochannel/gallery.dart';
import 'package:kokochannel/puzzle15.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;
  
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Map<String, List<TGPost>> postsByChannel = {};
  
  Set<int> postsIDs = {};
  List<String> imagesHTML = [];
  
  List<TGPost> feed = [];

  PageController pageController = PageController();
  TextEditingController newSubTextFieldController = TextEditingController();
  
  int maxPosts = 10;

  // Keeps both channel url and the last seen post for the channel
  Map<String, dynamic> subs = {};

  List<String> combo = [];
  List<String> code = ["up", "up", "down", "down", "left", "right", "left", "right"];

  ScrollController feedScrollController = ScrollController();
  
  void loadSubs() async{
    var subsFile = File("subs.json");
    
    try{
      var data = await subsFile.readAsString();
      
      setState((){      
        subs = json.decode(data);
        
        if(subs.isNotEmpty){
          requestPosts();
        }
      });
    } catch (E){
      print(E);
    }
  }

  @override
  void initState(){
    super.initState();

    loadSubs();

    feedScrollController.addListener(() {
      if(feedScrollController.position.maxScrollExtent - feedScrollController.offset < 200){

      }      
    });
  }

  void updateSubs(){
    var subsFile = File("subs.json");
    print(subs);
    subsFile.writeAsString(json.encode(subs));
  }

  void initSub(String channelURL) async {
    var resp = await get(Uri.parse("$channelURL"));

    final DOM.Document document = parse(resp.body);
    
    String lastID = "1";

    for(var el in document.querySelectorAll('.tgme_widget_message_wrap')){
      String? id = el.querySelector("div")?.attributes["data-post"]?.split('/')[1];

      if(id != null){
        lastID = id;
      }
    }

    subs.putIfAbsent(channelURL, () => lastID);

    setState(() {
      updateSubs();
    });
  }

  void requestPosts() async {    
    subs.forEach((key, value) async {
      bool noNewPosts = false;
      String channelTitle = "";

      int afterId = int.parse(value);
      String lastId = "-1";

      postsIDs.add(afterId);
      
      while(!noNewPosts){
        var resp = await get(Uri.parse("$key?after=$afterId"), headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/85.0.4183.121 Safari/537.36'
        });

        final DOM.Document document = parse(resp.body);
        
        noNewPosts = document.querySelector(".tme_no_messages_found") != null;

        if(channelTitle == ""){
          channelTitle = document.querySelector(".tgme_channel_info_header_title > span")?.text ?? "";
        }

        for(var el in document.querySelectorAll('.tgme_widget_message_wrap')){
          List<String> imgs = [];

          el.querySelectorAll("div > div > div > div > div > div > a")
            .map((e) {
              if(e.attributes['style'] != null){
                if(e.attributes['style']!.contains('.jpg') || e.attributes['style']!.contains('.png')){
                  imgs.add(e.attributes['style']!.split("(\'")[1].replaceAll("\')", ''));
                }
              }
            }).toList();

          if(imgs.isEmpty){
            el.querySelectorAll("div > div > div > a")
              .map((e) {
                if(e.attributes['style'] != null){
                  imgs.add(e.attributes['style']!.split("(\'")[1].replaceAll("\')", ''));
                }
              }).toList();
          }

          String? id = el.querySelector("div")?.attributes["data-post"]?.split('/')[1];
          String? date = el.querySelector("div > div > div > div > div> span > a > time")?.attributes['datetime'];
          if(date != null){
            date = date.replaceAll('T', ' ');
          }


          if(id != null){
            if(postsIDs.add(int.parse(id))){
              feed.add(
                TGPost(              
                  id,
                  channelTitle,
                  date ?? "",
                  el.querySelector(".js-message_text")?.innerHtml ?? "",
                  imgs              
                )
              );              
            }
            
            lastId = id;
          }
        }

        afterId += 8;
      }

      if(lastId != "-1"){
        subs[key] = lastId;
      }
      
      setState(() {
        updateSubs();
      });
    });    
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: (keyEvent){          
        if(keyEvent is KeyDownEvent && keyEvent.logicalKey == LogicalKeyboardKey.arrowUp){
          combo.add("up");
        }
        if(keyEvent is KeyDownEvent && keyEvent.logicalKey == LogicalKeyboardKey.arrowDown){
          combo.add("down");
        }
        if(keyEvent is KeyDownEvent && keyEvent.logicalKey == LogicalKeyboardKey.arrowLeft){
          combo.add("left");
        }
        if(keyEvent is KeyDownEvent && keyEvent.logicalKey == LogicalKeyboardKey.arrowRight){
          combo.add("right");
        }

        // if(combo.contains(code)){
        if(combo.join().contains(code.join())){
          Navigator.push(context, MaterialPageRoute(builder: (context) => Puzzle15()));
        }
      },
      child: Scaffold(
        backgroundColor: Colors.amber.shade100,
        appBar: AppBar(
          backgroundColor: Colors.amber.shade200,
          title: const Text("KOKO CHANNEL"),
          actions: [
            IconButton(
              focusNode: FocusNode(),
            
              onPressed: (){
                requestPosts();
              },
              icon: const Icon(Icons.refresh)
            ),
            
            const SizedBox(
              width: 25,
            ),
      
            IconButton(
              focusNode: FocusNode(),
              onPressed: (){
                pageController.nextPage(duration: const Duration(milliseconds: 10), curve: Curves.bounceIn);
              },
              icon: const Icon(Icons.add)
            ),
            
            const SizedBox(
              width: 16,
            )
          ],
        ),
        
        body: PageView(
          controller: pageController,      
          children: [       
            subs.isNotEmpty && feed.isNotEmpty ? Padding(
              padding: const EdgeInsets.all(32.0),
              child: Center(
                child: ListView.builder(
                  itemCount: feed.length,
                  physics: const AlwaysScrollableScrollPhysics(),
                  cacheExtent: 10000,
                  // controller: feedScrollController,
                  itemBuilder: (context, index){
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        color: Colors.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("${feed[index].channelName}: ", style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold
                              ),),
                            ),
                            
                            GestureDetector(
                              onTap: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context) => Gallery(images: feed[index].imgURLs)));
                              },
                              child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width / 2,
                                  child: Row(
                                    children: [
                                      ...feed[index].imgURLs.map((e) {
                                        if(e.isEmpty){
                                          return const SizedBox.shrink();
                                        } else {
                                          return Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Container(
                                                // width: 200,
                                                child: Image.network(e)),
                                            ),
                                          );
                                        }
                                      })
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Html(
                              data: feed[index].text,
                              style: {
                                "*": Style(fontSize: FontSize.xLarge, fontFamily: "Noto Sans")
                              },
                            ),
        
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("id: ${feed[index].id}    ${feed[index].date}", style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal
                                ),),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                )
              ),
            ) : const Center(child: Text("NO NEW POSTS", style: TextStyle(
              fontSize: 20
            ),)),
              
            Row(
              children: [
                SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...subs.keys.map((e) => (Text(e))).toList()
                    ],
                  ),
                ),
                Expanded(
                  child: Center(              
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 132),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextField(
                            controller: newSubTextFieldController,
                            onSubmitted: (value){
                              initSub("https://t.me/s/${value.substring(13)}");
                              newSubTextFieldController.clear();
                            }
                          ),
                          
                          const SizedBox(height: 64,),
                          
                          ElevatedButton(
                            onPressed: (){
                              pageController.jumpTo(0);
                            }, child: const Text("BACK")
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}