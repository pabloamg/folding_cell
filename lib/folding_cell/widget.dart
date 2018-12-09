import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Simple Folding Cell Widget by FaoB
class SimpleFoldingCell extends StatefulWidget {
  SimpleFoldingCell({Key key,
    @required this.frontWidget,
    @required this.innerTopWidget,
    @required this.innerBottomWidget,
    this.cellSize = const Size(150.0, 50.0),
    this.unfoldCell = false,
    this.skipAnimation = false,
    this.padding = const EdgeInsets.only(left: 20, right: 20, bottom: 5, top: 10)})
      : assert(frontWidget != null),
        assert(innerTopWidget != null),
        assert(innerBottomWidget != null),
        assert(cellSize != null),
        assert(unfoldCell != null),
        assert(skipAnimation != null),
        assert(padding != null),
        super(key: key);

  // Front widget in folded cell
  final Widget frontWidget;

  /// Top Widget in unfolded cell
  final Widget innerTopWidget;

  /// Bottom Widget in unfolded cell
  final Widget innerBottomWidget;

  /// Size of cell
  final Size cellSize;

  /// If true cell will be unfolded when created, if false cell will be folded when created
  final bool unfoldCell;

  /// If true cell will fold and unfold without animation, if false cell folding and unfolding will be animated
  final bool skipAnimation;

  /// Padding around cell
  final EdgeInsetsGeometry padding;

  @override
  _SimpleFoldingCellState createState() => _SimpleFoldingCellState();
}

class _SimpleFoldingCellState extends State<SimpleFoldingCell> with SingleTickerProviderStateMixin{
  bool _isExpanded = false;
  double _animVal;
  AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animVal = 0;

    if(widget.unfoldCell) {
      _animVal = 1;
      _isExpanded = true;
    }

    if(!widget.skipAnimation) {
      _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 500));

      _animationController.value = 0;
      if(widget.unfoldCell)
        _animationController.value = 1;

      _animationController.addListener((){
        setState(() {
          _animVal =  _animationController.value;
        });
      });
    }
  }

  @override
  void dispose() {
    if(_animationController != null)
      _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final angle = _animVal * math.pi;
    return Padding(
        padding: widget.padding,
        child: Container(
          color: Colors.transparent,
          height: widget.cellSize.height + (widget.cellSize.height * _animVal),
          width: widget.cellSize.width,
          child: Stack(
            children: <Widget>[
            GestureDetector(
            onTap: _handleTap,
              child:Container(
                height: widget.cellSize.height,
                width: widget.cellSize.width,
                child: widget.innerTopWidget,
              ),),
              Transform(
                alignment: Alignment.bottomCenter,
                transform: (Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateX(angle)),
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationX(math.pi),
                  child: Container(
                    height: widget.cellSize.height,
                    width: widget.cellSize.width,
                    child:_animVal<1 ? IgnorePointer(
                      child: Opacity(opacity: 1.0 * _animVal,
                      child: widget.innerBottomWidget,),
                    ) : widget.innerBottomWidget
                  ),
                ),
              ),
      GestureDetector(
        onTap: _handleTap,
        child:Transform(
                alignment: Alignment.bottomCenter,
                transform: (Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateX(angle)),
                child: Opacity(
                  opacity: angle >= 1.5708 ? 0.0 : 1.0,
                  child: Container(
                    height: angle >= 1.5708 ? 0.0 : widget.cellSize.height,
                    width: angle >= 1.5708 ? 0.0 : widget.cellSize.width,
                    child: widget.frontWidget,
                  ),
                ),
              ),)
            ],
          ),
        ),
    );
  }

  void _handleTap(){
    if(_isExpanded){
      if(widget.skipAnimation){
        setState(() {
          _animVal = 0;
        });
      }else{
        _animationController.reverse();
      }
    }else{
      if(widget.skipAnimation){
        setState(() {
          _animVal = 1;
        });
      }else{
        _animationController.forward();
      }
    }
    _isExpanded = !_isExpanded;
  }
}
