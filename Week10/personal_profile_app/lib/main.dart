import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Profile',
      themeMode: _themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: ProfilePage(
        isDarkMode: _themeMode == ThemeMode.dark,
        onThemeChanged: _toggleTheme,
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  @override
  Widget build(BuildContext context) {
    final skills = <String>[
      'Flutter',
      'Dart',
      'UI/UX Design',
      'Firebase',
      'REST APIs',
      'Git & GitHub',
    ];

    final socialLinks = <_SocialLink>[
      const _SocialLink(icon: Icons.web, label: 'Website', value: 'phung.dev'),
      const _SocialLink(
        icon: Icons.alternate_email,
        label: 'Email',
        value: 'phunghao2903@gmail.com',
      ),
      const _SocialLink(
        icon: Icons.linked_camera_outlined,
        label: 'Instagram',
        value: '@phung.photos',
      ),
      const _SocialLink(
        icon: Icons.code,
        label: 'GitHub',
        value: 'github.com/phungdev',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Profile'),
        actions: [
          Row(
            children: [
              const Icon(Icons.light_mode_outlined),
              Switch(value: isDarkMode, onChanged: onThemeChanged),
              const Icon(Icons.dark_mode_outlined),
            ],
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 720;

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 960),
                child: isWide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _ProfileCard(isWide: isWide),
                                const SizedBox(height: 24),
                                _ContactCard(),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _AboutCard(),
                                const SizedBox(height: 24),
                                _SkillsCard(skills: skills),
                                const SizedBox(height: 24),
                                _SocialCard(links: socialLinks),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _ProfileCard(isWide: isWide),
                          const SizedBox(height: 24),
                          _AboutCard(),
                          const SizedBox(height: 24),
                          _SkillsCard(skills: skills),
                          const SizedBox(height: 24),
                          _ContactCard(),
                          const SizedBox(height: 24),
                          _SocialCard(links: socialLinks),
                        ],
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.isWide});

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final avatar = CircleAvatar(
      radius: 56,
      backgroundImage: AssetImage('assets/3x4.jpg'),
    );
    

    final details = Column(
      crossAxisAlignment: isWide
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Text(
          'Phung Hao',
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Mobile Developer & Designer',
          style: textTheme.titleMedium?.copyWith(
            color: textTheme.bodySmall?.color,
          ),
          textAlign: isWide ? TextAlign.start : TextAlign.center,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          alignment: isWide ? WrapAlignment.start : WrapAlignment.center,
          children: const [
            Chip(label: Text('Open to collaborate')),
            Chip(label: Text('Remote & On-site')),
          ],
        ),
      ],
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: isWide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  avatar,
                  const SizedBox(width: 24),
                  Expanded(child: details),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [avatar, const SizedBox(height: 16), details],
              ),
      ),
    );
  }
}

class _AboutCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'About',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 12),
            Text(
              'Hi! I am Phung Hao, a fourth-year computer science student with a passion '
              'for crafting delightful mobile experiences. I love working on '
              'immersive UIs, experimenting with animations, and sharing knowledge '
              'with the community.',
            ),
          ],
        ),
      ),
    );
  }
}

class _SkillsCard extends StatelessWidget {
  const _SkillsCard({required this.skills});

  final List<String> skills;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Core Skills',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: skills
                  .map((skill) => Chip(label: Text(skill)))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: const [
            ListTile(
              leading: Icon(Icons.phone),
              title: Text('Phone'),
              subtitle: Text('+84 90 123 4567'),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.email_outlined),
              title: Text('Email'),
              subtitle: Text('hello@phung.dev'),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.location_on_outlined),
              title: Text('Location'),
              subtitle: Text('Da Nang, Vietnam'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialCard extends StatelessWidget {
  const _SocialCard({required this.links});

  final List<_SocialLink> links;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: links
              .map(
                (link) => Column(
                  children: [
                    ListTile(
                      leading: Icon(link.icon),
                      title: Text(link.label),
                      subtitle: Text(link.value),
                    ),
                    if (link != links.last) const Divider(),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _SocialLink {
  const _SocialLink({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}
