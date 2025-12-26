import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/language_provider.dart';
import '../../providers/bull_provider.dart';
import '../../providers/owner_provider.dart';
import 'champions_list_view.dart';
import 'owners_list_view.dart';

class BullsScreen extends StatefulWidget {
  const BullsScreen({super.key});

  @override
  State<BullsScreen> createState() => _BullsScreenState();
}

class _BullsScreenState extends State<BullsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleRefresh() {
    if (_tabController.index == 0) {
      // Champions tab - refresh bulls
      context.read<BullProvider>().loadBulls();
    } else {
      // Owners tab - refresh owners
      context.read<OwnerProvider>().loadOwners();
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 120.0,
              floating: true,
              pinned: true,
              backgroundColor: AppTheme.primaryOrange,
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: _handleRefresh,
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                titlePadding: const EdgeInsets.only(bottom: 56),
                title: Text(
                  lang.getText('nav_community'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(color: AppTheme.primaryOrange),
                    Positioned(
                      right: -30,
                      bottom: -50,
                      child: Icon(Icons.groups, size: 150, color: Colors.white.withOpacity(0.1)),
                    ),
                  ],
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(56),
                child: Container(
                  color: AppTheme.primaryOrange,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        color: Colors.white,
                      ),
                      labelColor: AppTheme.primaryOrange,
                      unselectedLabelColor: Colors.white,
                      labelStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      dividerColor: Colors.transparent,
                      indicatorSize: TabBarIndicatorSize.tab,
                      tabs: [
                        Tab(text: lang.getText('champions')),
                        Tab(text: lang.getText('owners')),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: const [
            ChampionsListView(),
            OwnersListView(),
          ],
        ),
      ),
    );
  }
}
