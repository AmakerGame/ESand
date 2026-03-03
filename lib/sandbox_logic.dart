import 'dart:math';
import 'human_logic.dart';

void updatePhysics(List<List<int>> grid, {String? geminiKey}) {
  int rows = grid.length;
  int cols = grid[0].length;
  Random rng = Random();
  List<List<bool>> moved = List.generate(rows, (_) => List.filled(cols, false));

  bool inBounds(int r, int c) => r >= 0 && r < rows && c >= 0 && c < cols;
  bool isEmpty(int r, int c) => inBounds(r, c) && grid[r][c] == 0;

  void swap(int r1, int c1, int r2, int c2) {
    int temp = grid[r1][c1];
    grid[r1][c1] = grid[r2][c2];
    grid[r2][c2] = temp;
    moved[r1][c1] = true;
    moved[r2][c2] = true;
  }

  for (int r = rows - 1; r >= 0; r--) {
    for (int c = 0; c < cols; c++) {
      int type = grid[r][c];
      if (type == 0 || moved[r][c]) continue;

      // --- ФІЗИКА ЛЮДЕЙ ---
      if (type == 21 || type == 25) {
        // 1. ПЕРЕВІРКА НА СМЕРТЬ (Засипання піском/золотом або Вогонь)
        bool suffocated = inBounds(r - 1, c) &&
            (grid[r - 1][c] == 1 ||
                grid[r - 1][c] == 22 ||
                grid[r - 1][c] == 24);
        bool burnt = (inBounds(r + 1, c) &&
                (grid[r + 1][c] == 7 || grid[r + 1][c] == 4)) ||
            (inBounds(r, c + 1) && grid[r][c + 1] == 7) ||
            (inBounds(r, c - 1) && grid[r][c - 1] == 7);

        if (suffocated || burnt) {
          grid[r][c] =
              (burnt) ? 7 : 0; // Перетворюється на вогонь або просто зникає
          continue;
        }

        // 2. ГРАВІТАЦІЯ ТА ДІЇ
        if (isEmpty(r + 1, c)) {
          swap(r, c, r + 1, c);
        } else {
          updateHumanAI(grid, r, c, rng, moved,
              geminiKey: geminiKey, isAI: type == 25);
        }
        continue;
      }

      // --- ТНТ ТА БЛИСКАВКА ---
      if (type == 11) {
        if (inBounds(r + 1, c) && grid[r + 1][c] == 19 ||
            inBounds(r - 1, c) && grid[r - 1][c] == 19) {
          // Вибух
          for (int i = -3; i <= 3; i++)
            for (int j = -3; j <= 3; j++)
              if (inBounds(r + i, c + j)) grid[r + i][c + j] = 0;
          continue;
        }
      }

      // --- ПІСОК / ЗОЛОТО ---
      if (type == 1 || type == 22 || type == 24) {
        if (isEmpty(r + 1, c))
          swap(r, c, r + 1, c);
        else if (isEmpty(r + 1, c - 1))
          swap(r, c, r + 1, c - 1);
        else if (isEmpty(r + 1, c + 1)) swap(r, c, r + 1, c + 1);
      }
      // --- РІДИНИ ---
      else if (type == 2 || type == 4 || type == 8) {
        if (isEmpty(r + 1, c))
          swap(r, c, r + 1, c);
        else if (isEmpty(r, c - 1))
          swap(r, c, r, c - 1);
        else if (isEmpty(r, c + 1)) swap(r, c, r, c + 1);
      }
    }
  }
}
