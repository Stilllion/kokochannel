import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Gallery extends StatelessWidget {
  Gallery({super.key, required this.images});

  final List<String> images;
  PageController pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKeyEvent: (keyEvent){        
        if(keyEvent is KeyDownEvent && keyEvent.logicalKey == LogicalKeyboardKey.arrowLeft){
          pageController.previousPage(duration: const Duration(milliseconds: 100), curve: Curves.easeIn);
        }
        if(keyEvent is KeyDownEvent && keyEvent.logicalKey == LogicalKeyboardKey.arrowRight){
          pageController.nextPage(duration: const Duration(milliseconds: 100), curve: Curves.easeIn);
        }

        if(keyEvent is KeyDownEvent && keyEvent.logicalKey == LogicalKeyboardKey.escape){
          Navigator.of(context).pop();
        }
      },
      child: Listener(
         onPointerSignal: (event) {
          if (event is PointerScrollEvent) {
            final offset = event.scrollDelta.dy;
            if(offset > 0){
              pageController.nextPage(duration: const Duration(milliseconds: 100), curve: Curves.easeIn);
            } else {
              pageController.previousPage(duration: const Duration(milliseconds: 100), curve: Curves.easeIn);
            }
          }
        },
        child: GestureDetector(
          onTap: (){
            Navigator.of(context).pop();
          },
          child: Scaffold(
            backgroundColor: const Color(0xFFEBDBB2),           
            body: Container(
              color: Colors.black,
              child: PageView(
              controller: pageController,
              children: [
                ...images.map((e) => FittedBox(
                  child: Image.network(e))
                  )
              ],),
            )
          ),
        ),
      ),
    );
  }
}