import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;

// ======= ТИПИ =======
const int TILE_EMPTY = 0;
const int TILE_WALL = 3;
const int TILE_FIRE = 4;
const int TILE_LAVA = 7;
const int TILE_TRAP = 8;
const int TILE_ORE = 6;
const int TILE_HUMAN = 21;
const int TILE_AI_HUMAN = 25;
const int TILE_ENEMY = 18;

const int SCAN_RADIUS = 2;

// ======= ЕМОЦІЇ =======
class HumanEmotion {
  final String emoji;
  final int r, c;
  final DateTime expires;

  const HumanEmotion(this.emoji, this.r, this.c, this.expires);

  bool get isAlive => DateTime.now().isBefore(expires);
}

final List<HumanEmotion> activeEmotions = [];

void _addEmotion(String emoji, int r, int c) {
  activeEmotions
    ..removeWhere((e) => !e.isAlive)
    ..add(HumanEmotion(
      emoji, r, c,
      DateTime.now().add(const Duration(seconds: 2)),
    ));
}

// ======= GEMINI AI =======
const String _geminiEndpoint =
    'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';

const String _geminiPrompt =
    'You are a sandbox game AI. Context: {context}. '
    'Answer only 1 word: move_left, move_right, build, attack, flee.';

const Set<String> _validActions = {
  'move_left', 'move_right', 'build', 'attack', 'flee',
};

Future<String> getGeminiDecision(String apiKey, String context) async {
  if (apiKey.isEmpty) return 'stay';

  try {
    final response = await http.post(
      Uri.parse('$_geminiEndpoint?key=$apiKey'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': _geminiPrompt.replaceFirst('{context}', context)},
            ],
          },
        ],
      }),
    );

    if (response.statusCode != 200) return 'stay';

    final text = (jsonDecode(response.body) as Map<String, dynamic>)
        .let((d) => d['candidates'][0]['content']['parts'][0]['text'])
        ?.toString()
        .toLowerCase()
        .trim() ?? '';

    return _validActions.contains(text) ? text : 'stay';
  } catch (_) {
    return 'stay';
  }
}

// ======= РОЗШИРЕННЯ =======
extension _Let<T> on T {
  R let<R>(R Function(T) block) => block(this);
}

// ======= СКАНУВАННЯ НАВКОЛИШНЬОГО СЕРЕДОВИЩА =======
typedef _ScanResult = ({bool danger, int enemyR, int enemyC});

_ScanResult _scanEnvironment(List<List<int>> grid, int r, int c) {
  final rows = grid.length;
  final cols = grid[0].length;

  bool danger = false;
  int enemyR = -1, enemyC = -1;

  for (int i = -SCAN_RADIUS; i <= SCAN_RADIUS; i++) {
    for (int j = -SCAN_RADIUS; j <= SCAN_RADIUS; j++) {
      final nr = r + i, nc = c + j;
      if (nr < 0 || nr >= rows || nc < 0 || nc >= cols) continue;

      final tile = grid[nr][nc];
      if (tile == TILE_FIRE || tile == TILE_LAVA || tile == TILE_TRAP) {
        danger = true;
      }
      if (tile == TILE_ENEMY) {
        enemyR = nr;
        enemyC = nc;
      }
    }
  }

  return (danger: danger, enemyR: enemyR, enemyC: enemyC);
}

// ======= ВИБІР ДІЇ (ЗВИЧАЙНИЙ ЛЮДИН) =======
String _decideHumanAction(_ScanResult scan, List<List<int>> grid, int r, int c, Random rng) {
  if (scan.danger) return 'flee';
  if (scan.enemyR != -1) return 'attack';

  final cols = grid[0].length;
  if (c + 1 < cols && grid[r][c + 1] == TILE_ORE) return 'mine';
  if (rng.nextInt(100) > 98) return 'build';
  return 'walk';
}

// ======= ВИКОНАННЯ ДІЇ =======
void _executeAction({
  required String action,
  required List<List<int>> grid,
  required int r,
  required int c,
  required Random rng,
  required bool isAI,
  required _ScanResult scan,
}) {
  final rows = grid.length;
  final cols = grid[0].length;
  bool inBounds(int r, int c) => r >= 0 && r < rows && c >= 0 && c < cols;

  final selfTile = isAI ? TILE_AI_HUMAN : TILE_HUMAN;

  void tryMove(int dir) {
    final nc = c + dir;
    if (inBounds(r, nc) && grid[r][nc] == TILE_EMPTY) {
      grid[r][nc] = selfTile;
      grid[r][c] = TILE_EMPTY;
    }
  }

  switch (action) {
    case 'flee':
      _addEmotion('🏃', r, c);
      tryMove(rng.nextBool() ? 1 : -1);

    case 'attack':
      if (scan.enemyR != -1) {
        grid[scan.enemyR][scan.enemyC] = TILE_EMPTY;
        _addEmotion('⚔️', r, c);
      }

    case 'mine':
      if (inBounds(r, c + 1)) {
        grid[r][c + 1] = TILE_EMPTY;
        _addEmotion('🪓', r, c);
      }

    case 'build':
      if (inBounds(r - 1, c) && grid[r - 1][c] == TILE_EMPTY) {
        grid[r - 1][c] = TILE_WALL;
        _addEmotion('🧱', r, c);
      }

    case 'walk':
    case 'move_left':
    case 'move_right':
      tryMove(action == 'move_left' ? -1 : (action == 'move_right' ? 1 : (rng.nextBool() ? 1 : -1)));
  }
}

// ======= ГОЛОВНА ФУНКЦІЯ =======
Future<void> updateHumanAI(
  List<List<int>> grid,
  int r,
  int c,
  Random rng,
  List<List<bool>> moved, {
  String? geminiKey,
  bool isAI = false,
}) async {
  if (isAI && (geminiKey == null || geminiKey.isEmpty)) return;

  final scan = _scanEnvironment(grid, r, c);

  final String action;
  if (isAI) {
    // AI викликає Gemini лише в 3% випадків — зберігаємо API квоту
    if (rng.nextInt(100) <= 96) return;
    final context = 'Danger:${scan.danger},Enemy:${scan.enemyR != -1}';
    action = await getGeminiDecision(geminiKey!, context);
  } else {
    action = _decideHumanAction(scan, grid, r, c, rng);
  }

  _executeAction(
    action: action,
    grid: grid,
    r: r,
    c: c,
    rng: rng,
    isAI: isAI,
    scan: scan,
  );
}