import 'package:flutter/material.dart';

class ElementModel {
  final int id;
  final String name;
  final List<Color> colors;
  final IconData icon;
  final bool isAction;
  ElementModel(
      {required this.id,
      required this.name,
      required this.colors,
      required this.icon,
      this.isAction = false});
}

class ElementList {
  static final List<ElementModel> gameElements = [
    ElementModel(
        id: 1, name: 'Пісок', colors: [Colors.orangeAccent], icon: Icons.grain),
    ElementModel(
        id: 2, name: 'Вода', colors: [Colors.blue], icon: Icons.water_drop),
    ElementModel(
        id: 3, name: 'Стіна', colors: [Colors.grey], icon: Icons.grid_view),
    ElementModel(
        id: 4, name: 'Лава', colors: [Colors.redAccent], icon: Icons.volcano),
    ElementModel(
        id: 6, name: 'Дерево', colors: [Colors.brown], icon: Icons.forest),
    ElementModel(
        id: 7,
        name: 'Вогонь',
        colors: [Colors.orange],
        icon: Icons.local_fire_department),
    ElementModel(
        id: 8,
        name: 'Кислота',
        colors: [Colors.greenAccent],
        icon: Icons.science),
    ElementModel(
        id: 11, name: 'ТНТ', colors: [Colors.red], icon: Icons.whatshot),
    ElementModel(
        id: 19,
        name: 'Блискавка',
        colors: [Colors.yellowAccent],
        icon: Icons.bolt),
    ElementModel(
        id: 14, name: 'Дим', colors: [Colors.white38], icon: Icons.cloud),
    ElementModel(
        id: 21, name: 'Людина', colors: [Colors.yellow], icon: Icons.person),
    ElementModel(
        id: 25,
        name: 'ШІ Людина',
        colors: [Colors.cyanAccent],
        icon: Icons.psychology),
    ElementModel(
        id: 22,
        name: 'Золото',
        colors: [Color(0xFFFFD700)],
        icon: Icons.savings),
    ElementModel(
        id: 24, name: 'Алмаз', colors: [Colors.cyan], icon: Icons.diamond),
  ];

  static final List<ElementModel> systemTools = [
    ElementModel(
        id: 0,
        name: 'Стерти',
        colors: [Colors.black],
        icon: Icons.auto_fix_normal),
    ElementModel(
        id: 101,
        name: 'Смітник',
        colors: [Colors.red],
        icon: Icons.delete_forever,
        isAction: true),
    ElementModel(
        id: 104,
        name: 'Налаштування',
        colors: [Colors.white],
        icon: Icons.settings,
        isAction: true),
  ];

  static ElementModel getById(int id) {
    return [...systemTools, ...gameElements]
        .firstWhere((e) => e.id == id, orElse: () => gameElements[0]);
  }
}
