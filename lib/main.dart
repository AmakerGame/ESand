import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'elements.dart';
import 'sandbox_logic.dart';
import 'sandbox_painter.dart';

void main() => runApp(
    const MaterialApp(home: SandboxGame(), debugShowCheckedModeBanner: false));

class SandboxGame extends StatefulWidget {
  const SandboxGame({super.key});
  @override
  State<SandboxGame> createState() => _SandboxGameState();
}

class _SandboxGameState extends State<SandboxGame> {
  late List<List<int>> grid;
  int selectedId = 1; // Починаємо з Піску
  bool showSettings = false;
  String geminiKey = "";

  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _keyCtrl = TextEditingController();

  String toastText = "Пісок";
  double toastOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    _initGrid();
    _loadSettings();
    // Основний цикл гри (30 FPS для стабільності)
    Timer.periodic(const Duration(milliseconds: 33), (t) {
      if (!showSettings) {
        setState(() => updatePhysics(grid, geminiKey: geminiKey));
      }
    });
  }

  void _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      geminiKey = prefs.getString('gkey') ?? "";
      _keyCtrl.text = geminiKey;
    });
  }

  void _initGrid() => grid = List.generate(100, (_) => List.filled(70, 0));

  // --- ЛОГІКА КЕРУВАННЯ СТРІЛКАМИ ---
  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;

    var all = [...ElementList.systemTools, ...ElementList.gameElements];
    int curIdx = all.indexWhere((e) => e.id == selectedId);

    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      _changeSelection(curIdx + 2, all); // Крок на наступну колонку
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      _changeSelection(curIdx - 2, all); // Крок на попередню колонку
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      if (curIdx % 2 == 0)
        _changeSelection(curIdx + 1, all); // Перейти на нижній ряд
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      if (curIdx % 2 != 0)
        _changeSelection(curIdx - 1, all); // Перейти на верхній ряд
    } else if (event.logicalKey == LogicalKeyboardKey.enter) {
      setState(() => showSettings = !showSettings);
    }
  }

  void _changeSelection(int newIdx, List<ElementModel> all) {
    if (newIdx >= 0 && newIdx < all.length) {
      setState(() => selectedId = all[newIdx].id);
      _autoScroll(newIdx);
      _showToast(all[newIdx].name);
    }
  }

  void _autoScroll(int index) {
    // Кожна колонка займає приблизно 80 пікселів
    double columnOffset = (index / 2).floor() * 80.0;
    _scrollController.animateTo(columnOffset,
        duration: const Duration(milliseconds: 250), curve: Curves.easeInOut);
  }

  void _showToast(String text) {
    setState(() {
      toastText = text;
      toastOpacity = 1.0;
    });
    Timer(const Duration(seconds: 1), () {
      if (mounted) setState(() => toastOpacity = 0.0);
    });
  }

  // --- МАЛЮВАННЯ ---
  void _draw(Offset globalPos) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset localPos = box.globalToLocal(globalPos);

    // Вираховуємо висоту ігрового поля (екран мінус панель меню)
    double gameHeight = MediaQuery.of(context).size.height - 140;

    int c = (localPos.dx / (MediaQuery.of(context).size.width / 70)).floor();
    int r = (localPos.dy / (gameHeight / 100)).floor();

    if (r >= 0 && r < 100 && c >= 0 && c < 70) {
      grid[r][c] = selectedId;
    }
  }

  @override
  Widget build(BuildContext context) {
    var all = [...ElementList.systemTools, ...ElementList.gameElements];
    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            GestureDetector(
              onPanUpdate: (d) => _draw(d.globalPosition),
              onPanDown: (d) => _draw(d.globalPosition),
              child:
                  CustomPaint(painter: SandPainter(grid), size: Size.infinite),
            ),

            // Назва обраного елемента (Toast)
            Positioned(
                bottom: 160,
                left: 0,
                right: 0,
                child: Center(
                  child: AnimatedOpacity(
                    opacity: toastOpacity,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Text(toastText,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                )),

            if (showSettings) _buildSettingsOverlay(),
          ],
        ),
        bottomNavigationBar: _buildBottomBar(all),
      ),
    );
  }

  Widget _buildBottomBar(List<ElementModel> all) {
    return Container(
      height: 140,
      decoration: const BoxDecoration(
        color: Color(0xFF0A0A0A),
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: GridView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
        ),
        itemCount: all.length,
        itemBuilder: (context, i) {
          bool isSel = selectedId == all[i].id;
          return GestureDetector(
            onTap: () {
              if (all[i].isAction) {
                if (all[i].id == 101) _initGrid();
                if (all[i].id == 104) setState(() => showSettings = true);
              } else {
                _changeSelection(i, all);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: isSel
                    ? Colors.white.withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: isSel ? Colors.white : Colors.white10,
                    width: isSel ? 2 : 1),
              ),
              child: Icon(all[i].icon, color: all[i].colors[0], size: 28),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSettingsOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.9), // ВИПРАВЛЕНО Colors.black90
      padding: const EdgeInsets.all(40),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("НАЛАШТУВАННЯ ШІ",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              TextField(
                controller: _keyCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Gemini API Key",
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.amber)),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => setState(() => showSettings = false),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[800]),
                    child: const Text("Назад"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString('gkey', _keyCtrl.text);
                      setState(() {
                        geminiKey = _keyCtrl.text;
                        showSettings = false;
                      });
                      _showToast("Налаштування збережено");
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber[700]),
                    child: const Text("Зберегти"),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
