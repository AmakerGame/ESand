import 'package:flutter/material.dart';
import 'elements.dart';

class SandPainter extends CustomPainter {
  final List<List<int>> grid;
  SandPainter(this.grid);

  @override
  void paint(Canvas canvas, Size size) {
    int rows = grid.length;
    int cols = grid[0].length;
    double cellW = size.width / cols;
    double cellH = size.height / rows;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (grid[r][c] != 0) {
          final element = ElementList.getById(grid[r][c]);
          final paint = Paint()..color = element.colors[0];
          canvas.drawRect(
              Rect.fromLTWH(c * cellW, r * cellH, cellW, cellH), paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
