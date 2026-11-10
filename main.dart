import 'package:flutter/material.dart';

void main() => runApp(const MebelProApp());

class MebelProApp extends StatelessWidget {
  const MebelProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'МебельПро',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF426B58),
        scaffoldBackgroundColor: const Color(0xFFF5F6F4),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selected = 0;
  final pages = const [
    ProjectPage(),
    CabinetPage(),
    MaterialsPage(),
    CuttingPage(),
  ];

  final titles = const ['Проекты', 'Конструктор', 'Материалы', 'Раскрой'];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final wide = constraints.maxWidth >= 760;
      return Scaffold(
        appBar: AppBar(
          title: Row(children: [
            const Icon(Icons.chair_alt_outlined),
            const SizedBox(width: 10),
            Text('МебельПро · ${titles[selected]}',
                style: const TextStyle(fontWeight: FontWeight.w700)),
          ]),
        ),
        body: Row(children: [
          if (wide)
            NavigationRail(
              selectedIndex: selected,
              onDestinationSelected: (v) => setState(() => selected = v),
              labelType: NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(icon: Icon(Icons.folder_outlined), label: Text('Проекты')),
                NavigationRailDestination(icon: Icon(Icons.view_in_ar_outlined), label: Text('Конструктор')),
                NavigationRailDestination(icon: Icon(Icons.tune), label: Text('Материалы')),
                NavigationRailDestination(icon: Icon(Icons.grid_on), label: Text('Раскрой')),
              ],
            ),
          Expanded(child: pages[selected]),
        ]),
        bottomNavigationBar: wide ? null : NavigationBar(
          selectedIndex: selected,
          onDestinationSelected: (v) => setState(() => selected = v),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.folder_outlined), label: 'Проекты'),
            NavigationDestination(icon: Icon(Icons.view_in_ar_outlined), label: 'Конструктор'),
            NavigationDestination(icon: Icon(Icons.tune), label: 'Материалы'),
            NavigationDestination(icon: Icon(Icons.grid_on), label: 'Раскрой'),
          ],
        ),
      );
    });
  }
}

class ProjectPage extends StatelessWidget {
  const ProjectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(20), children: [
      const Text('Рабочее пространство',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      const Text('Создавайте мебельные изделия, рассчитывайте детали и готовьте карты раскроя.'),
      const SizedBox(height: 20),
      Card(child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.add_box_outlined, size: 34),
          const SizedBox(height: 12),
          const Text('Новый проект', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          const Text('Первый прототип: корпусное изделие с параметрическим расчётом деталей.'),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Откройте вкладку «Конструктор», чтобы рассчитать первый корпус.'))),
            icon: const Icon(Icons.add), label: const Text('Начать проект')),
        ]),
      )),
      const SizedBox(height: 14),
      const _InfoCard(icon: Icons.crop_square, title: 'Формат листа по умолчанию', value: '2800 × 2070 мм'),
      const _InfoCard(icon: Icons.layers_outlined, title: 'Материал корпуса', value: 'ЛДСП 16 мм'),
      const _InfoCard(icon: Icons.content_cut, title: 'Ширина пропила', value: '4 мм'),
    ]);
  }
}

class CabinetPage extends StatefulWidget {
  const CabinetPage({super.key});

  @override
  State<CabinetPage> createState() => _CabinetPageState();
}

class _CabinetPageState extends State<CabinetPage> {
  final width = TextEditingController(text: '1200');
  final height = TextEditingController(text: '900');
  final depth = TextEditingController(text: '500');
  final thickness = TextEditingController(text: '16');
  int drawers = 3;
  List<CutPart> parts = [];

  double number(TextEditingController c) => double.tryParse(c.text.replaceAll(',', '.')) ?? 0;

  void calculate() {
    final w = number(width), h = number(height), d = number(depth), t = number(thickness);
    if (w <= 2*t || h <= 2*t || d <= 0 || t <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Проверьте размеры: они должны быть положительными и достаточными для толщины плиты.')));
      return;
    }
    // MVP корпусная схема: две боковины, верх/низ между боковинами,
    // задняя стенка пока не включена в карту деталей.
    final innerWidth = w - 2*t;
    final shelfDepth = d;
    final result = <CutPart>[
      CutPart('Боковина левая', h, d),
      CutPart('Боковина правая', h, d),
      CutPart('Крышка', innerWidth, d),
      CutPart('Дно', innerWidth, d),
    ];
    for (var i = 0; i < drawers; i++) {
      result.add(CutPart('Фасад ящика ${i + 1}', innerWidth / 1, (h - 2*t) / (drawers + 1)));
    }
    setState(() => parts = result);
  }

  @override
  void dispose() {
    width.dispose(); height.dispose(); depth.dispose(); thickness.dispose();
    super.dispose();
  }

  Widget field(String label, TextEditingController c) => SizedBox(
    width: 150,
    child: TextField(controller: c, keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label, suffixText: 'мм', border: const OutlineInputBorder())),
  );

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(20), children: [
      const Text('Параметрический конструктор', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      const SizedBox(height: 6),
      const Text('Введите габариты корпуса. Расчёт ниже — стартовая схема для проверки логики, не производственный чертёж.'),
      const SizedBox(height: 18),
      Wrap(spacing: 12, runSpacing: 12, children: [
        field('Ширина', width), field('Высота', height),
        field('Глубина', depth), field('Толщина ЛДСП', thickness),
      ]),
      const SizedBox(height: 18),
      Row(children: [
        const Expanded(child: Text('Количество фасадов ящиков')),
        IconButton(onPressed: drawers > 0 ? () => setState(() => drawers--) : null, icon: const Icon(Icons.remove_circle_outline)),
        Text('$drawers', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        IconButton(onPressed: drawers < 12 ? () => setState(() => drawers++) : null, icon: const Icon(Icons.add_circle_outline)),
      ]),
      const SizedBox(height: 12),
      FilledButton.icon(onPressed: calculate, icon: const Icon(Icons.calculate_outlined), label: const Text('Рассчитать детали')),
      if (parts.isNotEmpty) ...[
        const SizedBox(height: 24),
        const Text('Предварительный список деталей', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...parts.map((p) => Card(child: ListTile(
          title: Text(p.name),
          subtitle: Text('${p.length.toStringAsFixed(1)} × ${p.width.toStringAsFixed(1)} мм'),
          trailing: Text('${(p.length*p.width/1000000).toStringAsFixed(3)} м²'),
        ))),
        const Text('Важно: размеры ящиков, зазоры фасадов, конструкция задней стенки, присадка и кромление будут добавлены в следующих этапах.', style: TextStyle(color: Colors.deepOrange)),
      ],
    ]);
  }
}

class MaterialsPage extends StatelessWidget {
  const MaterialsPage({super.key});
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(20), children: const [
    Text('Материалы и настройки', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
    SizedBox(height: 16),
    _InfoCard(icon: Icons.crop, title: 'Лист ЛДСП', value: '2800 × 2070 мм'),
    _InfoCard(icon: Icons.layers, title: 'Толщина ЛДСП', value: '16 мм'),
    _InfoCard(icon: Icons.content_cut, title: 'Пропил', value: '4 мм'),
    _InfoCard(icon: Icons.border_style, title: 'Кромка', value: '0,4 мм и 2 мм'),
    SizedBox(height: 12),
    Text('В следующей итерации эти значения станут редактируемыми и будут сохраняться в профилях материалов.'),
  ]);
}

class CuttingPage extends StatelessWidget {
  const CuttingPage({super.key});
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(20), children: const [
    Text('Оптимизация раскроя', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
    SizedBox(height: 12),
    _InfoCard(icon: Icons.dashboard_outlined, title: 'Исходный лист', value: '2800 × 2070 мм'),
    _InfoCard(icon: Icons.swap_horiz, title: 'Учитываемые ограничения', value: 'Пропил 4 мм · направление текстуры'),
    SizedBox(height: 12),
    Text('Модуль раскроя пока подготовлен как следующий этап. Он будет размещать детали на листах, учитывать поворот, обрезку кромок, пропил и остатки. До внедрения оптимизатора эта вкладка не выдаёт производственную карту.'),
  ]);
}

class CutPart {
  final String name;
  final double length;
  final double width;
  const CutPart(this.name, this.length, this.width);
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  const _InfoCard({required this.icon, required this.title, required this.value});

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: Icon(icon, size: 28),
      title: Text(title),
      subtitle: Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
    ),
  );
}
