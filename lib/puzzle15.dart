import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Tile{
  int r = 0, c = 0;
  int value = 0;
  Color color = Colors.red.shade300;
}

class Puzzle15 extends StatefulWidget {
  const Puzzle15({super.key});

  @override
  State<Puzzle15> createState() => _Puzzle15State();
}

class _Puzzle15State extends State<Puzzle15> {
  List<int> field = List.generate(16, (index) => index);  
  List<Tile> tiles = List.generate(16, (index) => Tile());

  int emptyPos = 0;
  int fieldWidth = 4;

  double tileWidth = 120;

  FocusNode fieldFocusNode = FocusNode();
 
  @override
  void initState(){
    super.initState();

    field.shuffle();

    for(int i = 0; i < field.length; ++i){
      tiles[field[i]].r = i ~/ fieldWidth;
      tiles[field[i]].c = i % fieldWidth;
      tiles[field[i]].value = field[i];
            
      tiles[field[i]].color = field[i] == i + 1 ? Colors.green.shade200 : Colors.red.shade300;
    }

    emptyPos = field.indexOf(0);
  }

  List<Widget> buildField(){
    List<Widget> tileWidgets = [];

    for(int i = 0; i < 16; ++ i){
      if(tiles[i].value > 0){
        tileWidgets.add(
          AnimatedPositioned(
            left: (MediaQuery.of(context).size.width - tileWidth * 4) / 2 + tiles[i].c * (tileWidth + 5),
            top:  (MediaQuery.of(context).size.height - tileWidth * 4) / 2 + tiles[i].r * (tileWidth + 5),
            duration: const Duration(milliseconds: 75),
            child: AnimatedContainer(            
              width: tileWidth,
              height: tileWidth,
              color: tiles[i].color,
              duration: const Duration(milliseconds: 120),            
              child: Center(child: Text(tiles[i].value.toString(), style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold
              ),)),
            )
          )
        );
      }
    }  

    return tileWidgets;
  }

  void swapValues(int direction){
    if(emptyPos + direction > fieldWidth * fieldWidth || emptyPos + direction < 0) return;

    Tile swapValue = tiles[field[emptyPos + direction]];
    Tile emptyTile = tiles[field[emptyPos]];

    if((swapValue.r - emptyTile.r).abs() <= 1 && (swapValue.c - emptyTile.c).abs() <= 1){
      setState(() {
        final temp = field[emptyPos];
        field[emptyPos] = field[emptyPos + direction];
        field[emptyPos + direction] = temp;

        emptyPos = emptyPos + direction;

        for(int i = 0; i < field.length; ++i){
          tiles[field[i]].r = i ~/ fieldWidth;
          tiles[field[i]].c = i % fieldWidth;
          tiles[field[i]].value = field[i];

          tiles[field[i]].color = field[i] == i + 1 ? Colors.green.shade200 : Colors.red.shade300;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber.shade100,           
      body: KeyboardListener(
        focusNode: fieldFocusNode,
        autofocus: true,
        onKeyEvent: (keyEvent){          
          if(keyEvent is KeyDownEvent && keyEvent.logicalKey == LogicalKeyboardKey.arrowUp){
            swapValues(fieldWidth);
          }
          if(keyEvent is KeyDownEvent && keyEvent.logicalKey == LogicalKeyboardKey.arrowDown){
            swapValues(-fieldWidth);
          }
          if(keyEvent is KeyDownEvent && keyEvent.logicalKey == LogicalKeyboardKey.arrowLeft){
            swapValues(1);
          }
          if(keyEvent is KeyDownEvent && keyEvent.logicalKey == LogicalKeyboardKey.arrowRight){
            swapValues(-1);
          }
          if(keyEvent is KeyDownEvent && keyEvent.logicalKey == LogicalKeyboardKey.escape){
            Navigator.of(context).pop();
          }
        },

        child: Stack(
          children: [...buildField()],
        ),
      )
    );
  }
}