import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationManager {
  static final LocalizationManager _instance = LocalizationManager._internal();
  factory LocalizationManager() => _instance;
  LocalizationManager._internal();

  final ValueNotifier<String> currentLocale = ValueNotifier('zh'); // Default to Chinese
  final ValueNotifier<bool> hapticEnabled = ValueNotifier(true); // Default ON
  static const String _prefKey = 'geo_journey_locale';
  static const String _hapticKey = 'geo_journey_haptic';

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(_prefKey)) {
      currentLocale.value = prefs.getString(_prefKey)!;
    }
    if (prefs.containsKey(_hapticKey)) {
      hapticEnabled.value = prefs.getBool(_hapticKey)!;
    }
  }

  Future<void> toggleHaptic(bool enabled) async {
    hapticEnabled.value = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hapticKey, enabled);
  }

  Future<void> setLocale(String code) async {
    currentLocale.value = code;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, code);
  }

  String get(String key) {
    final map = _localizedValues[currentLocale.value] ?? _localizedValues['en']!;
    return map[key] ?? key;
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'game_title': 'GEO JOURNEY',
      'game_subtitle': 'THE CORE PROTOCOL',
      'btn_continue': 'CONTINUE',
      'btn_new_game': 'NEW GAME',
      'btn_settings': 'SETTINGS',
      'btn_help': 'HELP',
      'btn_about': 'ABOUT',
      'btn_exit': 'EXIT',
      'dialog_confirm_title': 'Confirm New Game',
      'dialog_confirm_content': 'Starting a new game will overwrite your current progress. Are you sure?',
      'yes': 'YES',
      'no': 'NO',
      'dialog_help_title': 'How to Play',
      'dialog_help_content': '1. Use D-Pad to Move.\n2. Tap Attack to break blocks.\n3. Collect colored crystals.\n4. Match 4 blocks of same color to clear them.\n5. Don\'t get crushed!',
      'dialog_about_title': 'About',
      'dialog_about_content': 'Geo Journey v1.0\nCreated with Flutter & Flame.',
      'bag_label': 'Bag',
      'cheat_label': 'Cheat',
      'intro_skip': 'SKIP ANIMATION >>',
      'intro_briefing': 'MISSION BRIEFING',
      'intro_init': 'INITIALIZE SYSTEM',
      'intro_text': "In 21XX, the surface has been devastated by solar storms, forcing humanity underground.\n\n"
                    "As an elite explorer of the 'Deep Geology Bureau', you pilot the 'Mole' nano-mining armor.\n\n"
                    "Your mission is to delve deep into the crust to find the only energy source sustaining the underground city—Core Crystals.\n\n"
                    "However, your armor's 'Quantum Compression Pack' is a civilian prototype with poor stability, initially holding only 8 ore units. Overloading fails the spatial fold.\n\n"
                    "As you collect high-purity samples (Score), HQ will send upgrade patches to stabilize the field, expanding capacity and letting you reach deeper into the core.",
      'bag_full': 'Bag Full!',
      'level_complete': 'Level Complete!',
      'next_level_loading': 'Entering Level ',
      'game_over': 'GAME OVER',
      'final_score': 'Final Score: ',
      'btn_main_menu': 'MAIN MENU',
      'settings_title': 'Settings',
      'settings_language': 'Language',
      'challenge_africa': 'Sahara Shards',
      'challenge_europe': 'Alpine Crystal',
      'challenge_asia': 'Jade Empire',
      'challenge_australia': 'Outback Opal',
      'challenge_americas': 'Andes Gold',
      'challenge_antarctica': 'Polar Core',
      'challenge_target': 'Target: ',
      'challenge_reward': 'Reward: ',
      'challenge_bag': ' Bag Slots',
      'btn_challenge': 'START CHALLENGE',
      'map_locked': 'Locked',
      'map_unlocked': 'Completed',
      'setting_haptic': 'Vibration',
      'btn_revive': 'REVIVE (AD)',
    },
    'zh': {
      'game_title': '地心之旅',
      'game_subtitle': '核心协议',
      'btn_continue': '继续游戏',
      'btn_new_game': '开始游戏',
      'btn_settings': '设置',
      'btn_help': '帮助',
      'btn_about': '关于',
      'btn_exit': '退出',
      'dialog_confirm_title': '确认开始新游戏',
      'dialog_confirm_content': '开始新游戏将覆盖当前的存档进度。确定吗？',
      'yes': '确定',
      'no': '取消',
      'dialog_help_title': '游戏说明',
      'dialog_help_content': '1. 使用方向键移动。\n2. 点击攻击按钮打破方块。\n3. 收集彩色水晶。\n4. 将4个同色方块连在一起消除。\n5. 小心不要被压扁！',
      'dialog_about_title': '关于',
      'dialog_about_content': 'Geo Journey v1.0\n使用 Flutter & Flame 制作。',
      'bag_label': '背包',
      'cheat_label': '作弊',
      'intro_skip': '跳过动画 >>',
      'intro_briefing': '任务简报',
      'intro_init': '系统初始化',
      'intro_text': "在21XX年，地表因持续的太阳风暴而变得荒芜，人类被迫迁入地下避难所。\n\n"
                    "作为“深层地质勘探局”的精英探险家，你驾驶着代号为“地鼠”的纳米挖掘装甲。\n\n"
                    "你的任务是深入地壳，寻找维持地下城运转的唯一能源——源核水晶 (Core Crystals)。\n\n"
                    "然而，你的装甲最初搭载的“量子压缩背包”还是民用原型机，能量稳定性很差，最初只能容纳 8 个单位的矿石水晶。一旦超载，空间折叠场就会失效，导致无法继续采集。\n\n"
                    "随着你在挖掘过程中收集更多的高纯度样本（积分积累），总部会远程传输固件升级补丁，增强你背包的力场稳定性，从而逐步扩充容量，解锁更多携带空间，让你能向着更深的地心进发。",
      'bag_full': '背包已满!',
      'level_complete': '关卡完成!',
      'next_level_loading': '正在进入第 ',
      'game_over': '游戏结束',
      'final_score': '最终得分: ',
      'btn_restart': '重试',
      'btn_main_menu': '主菜单',
      'settings_title': '设置',
      'settings_language': '语言',
      'challenge_africa': '撒哈拉碎片',
      'challenge_europe': '阿尔卑斯水晶',
      'challenge_asia': '翡翠帝国',
      'challenge_australia': '蛋白石荒野',
      'challenge_americas': '安第斯黄金',
      'challenge_antarctica': '极地核心',
      'challenge_target': '目标积分: ',
      'challenge_reward': '奖励: ',
      'challenge_bag': ' 格背包',
      'btn_challenge': '开始挑战',
      'map_locked': '未解锁',
      'map_unlocked': '已完成',
      'setting_haptic': '震动',
      'btn_revive': '复活 (广告)',
    }
  };
}
