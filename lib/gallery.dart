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
          pageController.previousPage(duration: Duration(milliseconds: 100), curve: Curves.easeIn);
        }
        if(keyEvent is KeyDownEvent && keyEvent.logicalKey == LogicalKeyboardKey.arrowRight){
          pageController.nextPage(duration: Duration(milliseconds: 100), curve: Curves.easeIn);
        }

        if(keyEvent is KeyDownEvent && keyEvent.logicalKey == LogicalKeyboardKey.escape){
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.amber.shade100,           
        body: Container(
          color: Colors.black,
          child: Stack(
            children: [
                PageView(
                controller: pageController,
                children: [
                  ...images.map((e) => FittedBox(
                    child: Image.network(e))
                    )
                ],
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 88,
                  color: Colors.pink,
                  height: MediaQuery.of(context).size.height,
                  child: Icon(Icons.chevron_left, size: 52,),
                ),
              ),

            
              
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  width: 88,
                  color: Colors.pink,
                  height: MediaQuery.of(context).size.height,
                  child: OutlinedButton(
                    style: const ButtonStyle(
                      iconColor: MaterialStatePropertyAll(Colors.black),
                    ),
                    onPressed: (){},
                    child: Icon(Icons.chevron_right, size: 52,)),
                ),
              ),

              
            ],
          ),
        )
      ),
    );
  }
}