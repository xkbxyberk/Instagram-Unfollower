import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/dark_theme_colors.dart';

enum SortOption { none, az, za }

class ResultsContent extends StatefulWidget {
  final List<Map<String, dynamic>> unfollowers;
  final List<Map<String, dynamic>> fans;
  final Set<String> selectedUsers;
  final Function(List<Map<String, dynamic>>) onSelectAll;
  final VoidCallback onCopySelected;
  final VoidCallback onRestartAnalysis;
  final Function(String) onToggleUserSelection;
  final Function(String) onOpenUserProfile;

  // Panel state preservation
  final int initialTabIndex;
  final String initialSearchQuery;
  final String initialSortOption;
  final double initialScrollPosition;
  final Function(int?, String?, String?, double?) onUpdatePanelState;

  const ResultsContent({
    super.key,
    required this.unfollowers,
    required this.fans,
    required this.selectedUsers,
    required this.onSelectAll,
    required this.onCopySelected,
    required this.onRestartAnalysis,
    required this.onToggleUserSelection,
    required this.onOpenUserProfile,
    // Panel state preservation
    this.initialTabIndex = 0,
    this.initialSearchQuery = '',
    this.initialSortOption = 'none',
    this.initialScrollPosition = 0.0,
    required this.onUpdatePanelState,
  });

  @override
  State<ResultsContent> createState() => _ResultsContentState();
}

class _ResultsContentState extends State<ResultsContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _searchQuery = '';
  SortOption _sortOption = SortOption.none;

  @override
  void initState() {
    super.initState();

    // Initial values'ları restore et
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
    _searchController.text = widget.initialSearchQuery;
    _searchQuery = widget.initialSearchQuery;

    // Sort option'ı restore et
    switch (widget.initialSortOption) {
      case 'az':
        _sortOption = SortOption.az;
        break;
      case 'za':
        _sortOption = SortOption.za;
        break;
      default:
        _sortOption = SortOption.none;
    }

    // Listeners
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase().trim();
      });
      widget.onUpdatePanelState(null, _searchQuery, null, null);
    });

    _tabController.addListener(() {
      widget.onUpdatePanelState(_tabController.index, null, null, null);
    });

    _scrollController.addListener(() {
      widget.onUpdatePanelState(null, null, null, _scrollController.offset);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialScrollPosition > 0 && _scrollController.hasClients) {
        _scrollController.jumpTo(widget.initialScrollPosition);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getFilteredAndSortedList(
      List<Map<String, dynamic>> originalList) {
    List<Map<String, dynamic>> filteredList = originalList;

    if (_searchQuery.isNotEmpty) {
      filteredList = originalList.where((user) {
        final username = (user['username'] as String).toLowerCase();
        return username.contains(_searchQuery);
      }).toList();
    }

    switch (_sortOption) {
      case SortOption.az:
        filteredList.sort((a, b) => (a['username'] as String)
            .toLowerCase()
            .compareTo((b['username'] as String).toLowerCase()));
        break;
      case SortOption.za:
        filteredList.sort((a, b) => (b['username'] as String)
            .toLowerCase()
            .compareTo((a['username'] as String).toLowerCase()));
        break;
      case SortOption.none:
        break;
    }

    return filteredList;
  }

  Future<void> _openInInstagramApp(String username) async {
    final instagramAppUrl = 'instagram://user?username=$username';
    final instagramWebUrl = 'https://www.instagram.com/$username/';

    try {
      if (await canLaunchUrl(Uri.parse(instagramAppUrl))) {
        await launchUrl(
          Uri.parse(instagramAppUrl),
          mode: LaunchMode.externalApplication,
        );
      } else {
        await launchUrl(
          Uri.parse(instagramWebUrl),
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      try {
        await launchUrl(
          Uri.parse(instagramWebUrl),
          mode: LaunchMode.externalApplication,
        );
      } catch (e) {
        widget.onOpenUserProfile(username);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        _buildHeaderStats(isDark),
        _buildTabBar(isDark),
        _buildSearchAndSort(isDark),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildUserList(
                  _getFilteredAndSortedList(widget.unfollowers), false, isDark),
              _buildUserList(
                  _getFilteredAndSortedList(widget.fans), true, isDark),
            ],
          ),
        ),
        _buildBottomActions(isDark),
      ],
    );
  }

  Widget _buildHeaderStats(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.fromLTRB(20, 15, 20, 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  Colors.blue.shade900.withValues(alpha: 0.3),
                  Colors.purple.shade900.withValues(alpha: 0.3),
                ]
              : [
                  Colors.blue.shade50,
                  Colors.purple.shade50,
                ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.blue.shade200.withValues(alpha: isDark ? 0.3 : 1.0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: ThemeColors.instagramGradient(context).take(2).toList(),
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'analysis_completed'.tr(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ThemeColors.primaryText(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${widget.unfollowers.length + widget.fans.length} sonuç',
                  style: TextStyle(
                    fontSize: 12,
                    color: ThemeColors.secondaryText(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(bool isDark) {
    final gradientColors = ThemeColors.instagramGradient(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: ThemeColors.surface(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.white,
        unselectedLabelColor: ThemeColors.secondaryText(context),
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              gradientColors[0],
              gradientColors[2],
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        dividerColor: Colors.transparent,
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.person_remove, size: 16),
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${widget.unfollowers.length}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.favorite, size: 16),
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${widget.fans.length}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndSort(bool isDark) {
    final gradientColors = ThemeColors.instagramGradient(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: ThemeColors.card(context),
                borderRadius: BorderRadius.circular(10),
                boxShadow: ThemeColors.cardShadow(context),
              ),
              child: TextField(
                controller: _searchController,
                style: TextStyle(color: ThemeColors.primaryText(context)),
                decoration: InputDecoration(
                  hintText: 'search_user'.tr(),
                  hintStyle: TextStyle(
                    color: ThemeColors.secondaryText(context),
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: ThemeColors.secondaryText(context),
                    size: 20,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: ThemeColors.card(context),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  gradientColors[0],
                  gradientColors[2],
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: PopupMenuButton<SortOption>(
              onSelected: (SortOption option) {
                setState(() {
                  _sortOption = option;
                });
                String sortValue = 'none';
                switch (option) {
                  case SortOption.az:
                    sortValue = 'az';
                    break;
                  case SortOption.za:
                    sortValue = 'za';
                    break;
                  case SortOption.none:
                    sortValue = 'none';
                    break;
                }
                widget.onUpdatePanelState(null, null, sortValue, null);
              },
              icon: const Icon(Icons.sort, color: Colors.white, size: 20),
              color: ThemeColors.card(context),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              itemBuilder: (BuildContext context) => [
                PopupMenuItem(
                  value: SortOption.none,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.clear,
                          size: 16, color: ThemeColors.secondaryText(context)),
                      const SizedBox(width: 8),
                      Text('Varsayılan',
                          style: TextStyle(
                              fontSize: 14,
                              color: ThemeColors.primaryText(context))),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: SortOption.az,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.sort_by_alpha,
                          size: 16, color: ThemeColors.secondaryText(context)),
                      const SizedBox(width: 8),
                      Text('sort_az'.tr(),
                          style: TextStyle(
                              fontSize: 14,
                              color: ThemeColors.primaryText(context))),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: SortOption.za,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.sort_by_alpha,
                          size: 16, color: ThemeColors.secondaryText(context)),
                      const SizedBox(width: 8),
                      Text('sort_za'.tr(),
                          style: TextStyle(
                              fontSize: 14,
                              color: ThemeColors.primaryText(context))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList(
      List<Map<String, dynamic>> users, bool isFansTab, bool isDark) {
    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isFansTab ? Icons.favorite_outline : Icons.person_remove_outlined,
              size: 64,
              color: ThemeColors.secondaryText(context),
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Arama sonucu bulunamadı'
                  : (isFansTab
                      ? 'Henüz fan bulunmuyor'
                      : 'Henüz takipten çıkan bulunmuyor'),
              style: TextStyle(
                fontSize: 16,
                color: ThemeColors.secondaryText(context),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    final gradientColors = ThemeColors.instagramGradient(context);

    return Column(
      children: [
        if (users.isNotEmpty)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [gradientColors[0], gradientColors[2]],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => widget.onSelectAll(users),
                    child: Row(
                      children: [
                        Icon(
                          _areAllUsersSelected(users)
                              ? Icons.check_box
                              : _areSomeUsersSelected(users)
                                  ? Icons.indeterminate_check_box
                                  : Icons.check_box_outline_blank,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            _areAllUsersSelected(users)
                                ? 'clear_all'.tr()
                                : _areSomeUsersSelected(users)
                                    ? '${_getSelectedCount(users)} seçili'
                                    : 'select_all'.tr(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_areSomeUsersSelected(users))
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      onPressed: widget.onCopySelected,
                      padding: const EdgeInsets.all(6),
                      constraints:
                          const BoxConstraints(minWidth: 32, minHeight: 32),
                      icon: const Icon(
                        Icons.copy,
                        color: Colors.white,
                        size: 16,
                      ),
                      tooltip: 'copy_selected'.tr(),
                    ),
                  ),
              ],
            ),
          ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final username = user['username'] as String;
              final profilePicUrl = user['profilePicUrl'] as String;
              final isSelected = widget.selectedUsers.contains(username);

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? gradientColors[0].withValues(alpha: 0.1)
                      : ThemeColors.card(context),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? gradientColors[0] : Colors.transparent,
                    width: 1,
                  ),
                  boxShadow: ThemeColors.cardShadow(context),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 4,
                  ),
                  leading: GestureDetector(
                    onTap: () => widget.onToggleUserSelection(username),
                    child: Stack(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? gradientColors[0]
                                  : ThemeColors.border(context),
                              width: 2,
                            ),
                          ),
                          child: ClipOval(
                            child: profilePicUrl.isNotEmpty
                                ? Image.network(
                                    profilePicUrl,
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return _buildDefaultAvatar(
                                          username, isFansTab);
                                    },
                                  )
                                : _buildDefaultAvatar(username, isFansTab),
                          ),
                        ),
                        if (isSelected)
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: gradientColors[0],
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 1.5),
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 8,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  title: Text(
                    '@$username',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: isSelected
                          ? gradientColors[3]
                          : ThemeColors.primaryText(context),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    isFansTab ? 'follows_you'.tr() : 'not_following'.tr(),
                    style: TextStyle(
                      color: isFansTab
                          ? Colors.green.shade600
                          : Colors.red.shade600,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.shade500,
                              Colors.blue.shade700,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.language_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                          padding: EdgeInsets.zero,
                          onPressed: () => widget.onOpenUserProfile(username),
                          tooltip: 'Web\'de aç',
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              gradientColors[2],
                              gradientColors[4],
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.launch_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                          padding: EdgeInsets.zero,
                          onPressed: () => _openInInstagramApp(username),
                          tooltip: 'Instagram uygulamasında aç',
                        ),
                      ),
                    ],
                  ),
                  onTap: () => widget.onToggleUserSelection(username),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultAvatar(String username, bool isFansTab) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isFansTab
              ? [Colors.green.shade100, Colors.green.shade200]
              : [Colors.red.shade100, Colors.red.shade200],
        ),
        shape: BoxShape.circle,
      ),
      child: Icon(
        isFansTab ? Icons.favorite : Icons.person_outline,
        color: isFansTab ? Colors.green.shade700 : Colors.red.shade700,
        size: 20,
      ),
    );
  }

  bool _areAllUsersSelected(List<Map<String, dynamic>> users) {
    if (users.isEmpty) return false;
    return users
        .every((user) => widget.selectedUsers.contains(user['username']));
  }

  bool _areSomeUsersSelected(List<Map<String, dynamic>> users) {
    return users.any((user) => widget.selectedUsers.contains(user['username']));
  }

  int _getSelectedCount(List<Map<String, dynamic>> users) {
    return users
        .where((user) => widget.selectedUsers.contains(user['username']))
        .length;
  }

  Widget _buildBottomActions(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey.shade600, Colors.grey.shade700],
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: widget.onRestartAnalysis,
          icon:
              const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
          label: Text(
            'restart_analysis'.tr(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
