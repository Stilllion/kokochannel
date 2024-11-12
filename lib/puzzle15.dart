import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Tile15{
  int r = 0;
  int c= 0;
  Color color = Colors.red;

  int value = 0;
}

class Pair<T1,T2> {
    final int r;
    final int c;
    Pair(this.r, this.c);
}


class Puzzle15 extends StatefulWidget {
  const Puzzle15({super.key});

  @override
  State<Puzzle15> createState() => _Puzzle15State();
}

class _Puzzle15State extends State<Puzzle15> {

  List<List<int>> field = [
    [2,  4,  6,  1 ],
    [9, 11, 13, 12 ],
    [8, 15, 7,  10 ],
    [3,  5, 14,  0 ],
  ];

  List<Pair> tilesPos = [];

  Pair emptySlot = Pair(3, 3);

  Pair up = Pair(1, 0);
  Pair down = Pair(-1, 0);
  Pair right = Pair(0, -1);
  Pair left = Pair(0, 1);

  FocusNode fieldFocusNode = FocusNode();
 
  @override
  void initState(){
    super.initState();

    for(int r = 0; r < 4; ++r){
      for(int c = 0; c < 4; ++c){
        tilesPos.add(Pair(r, c));
      }
    }        
  }

  List<Widget> buildField(){
    List<Widget> tiles = [];

    for(int i = 1; i < 16; ++ i){
      tiles.add(        
        AnimatedPositioned(
          left: (MediaQuery.of(context).size.width - 55 * 4) / 2 + tilesPos[i].c * 55,
          top:  (MediaQuery.of(context).size.height - 55 * 4) / 2 + tilesPos[i].r * 55,
          child: Container(            
            width: 50,
            height: 50,
            color: Colors.red.shade200,
            child: Center(child: Text(field[tilesPos[i].r][tilesPos[i].c].toString())),
          ),
          duration: Duration(milliseconds: 50)
        )
      );
    }  

    return tiles;
  }

  void swapValues(Pair direction){
    int? swapValue = field[emptySlot.r + direction.r][emptySlot.c + direction.c];
    
    if(swapValue != null){
      setState(() {
        field[emptySlot.r][emptySlot.c] = swapValue;
        field[emptySlot.r + direction.r][emptySlot.c + direction.c] = 0;
        emptySlot = Pair(emptySlot.r + direction.r, emptySlot.c + direction.c);
        
        for(int r = 0; r < 4; ++r){
          for(int c = 0; c < 4; ++c){
            tilesPos[field[r][c]] = Pair(r, c);
          }
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
            swapValues(up);
          }
          if(keyEvent is KeyDownEvent && keyEvent.logicalKey == LogicalKeyboardKey.arrowDown){
            swapValues(down);
          }
          if(keyEvent is KeyDownEvent && keyEvent.logicalKey == LogicalKeyboardKey.arrowLeft){
            swapValues(left);
          }
          if(keyEvent is KeyDownEvent && keyEvent.logicalKey == LogicalKeyboardKey.arrowRight){
            swapValues(right);
          }      
        },

        child: Stack(
          children: [
            ...buildField()
          ],
        ),
      )
    );
  }
}