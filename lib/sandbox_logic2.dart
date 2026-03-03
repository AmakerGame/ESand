import 'dart:math';
import 'human_logic.dart';

bool processAdvancedPhysics(List<List<int>> grid, int r, int c, int type,
    Random rng, List<List<bool>> moved) {
  int rows = grid.length;
  int cols = grid[0].length;

  bool inBounds(int r, int c) => r >= 0 && r < rows && c >= 0 && c < cols;

  void swap(int r1, int c1, int r2, int c2) {
    int temp = grid[r1][c1];
    grid[r1][c1] = grid[r2][c2];
    grid[r2][c2] = temp;
    moved[r1][c1] = true;
    moved[r2][c2] = true;
  }

  // --- 21. ЛЮДИНА ---
  if (type == 21) {
    updateHumanAI(grid, r, c, rng, moved);
    return true;
  }

  // --- 19. БЛИСКАВКА ---
  if (type == 19) {
    if (rng.nextInt(100) > 70) {
      grid[r][c] = 0;
    } else {
      for (int i = -1; i <= 1; i++) {
        for (int j = -1; j <= 1; j++) {
          if (inBounds(r + i, c + j)) {
            int target = grid[r + i][c + j];
            if (target == 16 || target == 2) {
              grid[r + i][c + j] = 19;
              moved[r + i][c + j] = true;
            }
          }
        }
      }
    }
    return true;
  }

  // --- 20. НАСІННЯ ---
  if (type == 20) {
    if (inBounds(r + 1, c) && grid[r + 1][c] == 0) {
      swap(r, c, r + 1, c);
    }
    for (int i = -1; i <= 1; i++) {
      for (int j = -1; j <= 1; j++) {
        if (inBounds(r + i, c + j) && grid[r + i][c + j] == 2) {
          grid[r][c] = 15; // Стає рослиною
        }
      }
    }
    return true;
  }

  return false;
}
