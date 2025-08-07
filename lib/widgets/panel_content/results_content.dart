import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../utils/instagram_colors.dart';

class ResultsContent extends StatelessWidget {
  final List<String> unfollowers;
  final Set<String> selectedUsers;
  final VoidCallback onSelectAll;
  final VoidCallback onCopySelected;
  final VoidCallback onRestartAnalysis;
  final Function(String) onToggleUserSelection;
  final Function(String) onOpenUserProfile;

  const ResultsContent({
    super.key,
    required this.unfollowers,
    required this.selectedUsers,
    required this.onSelectAll,
    required this.onCopySelected,
    required this.onRestartAnalysis,
    required this.onToggleUserSelection,
    required this.onOpenUserProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.fromLTRB(20, 15, 20, 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.red.shade50,
                Colors.red.shade100.withValues(alpha: 0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.red.shade200, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red.shade100, Colors.red.shade200],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_remove_outlined,
                  color: Colors.red.shade700,
                  size: 24,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'people_found'.tr(args: [unfollowers.length.toString()]),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'not_following_back'.tr(),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (unfollowers.isNotEmpty)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  InstagramColors.gradientColors[0],
                  InstagramColors.gradientColors[2]
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: onSelectAll,
                    child: Row(
                      children: [
                        Icon(
                          selectedUsers.length == unfollowers.length
                              ? Icons.check_box
                              : selectedUsers.isEmpty
                                  ? Icons.check_box_outline_blank
                                  : Icons.indeterminate_check_box,
                          color: Colors.white,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          selectedUsers.isEmpty
                              ? 'select_all'.tr()
                              : selectedUsers.length == unfollowers.length
                                  ? 'clear_all'.tr()
                                  : 'selected_count'.tr(
                                      args: [selectedUsers.length.toString()]),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (selectedUsers.isNotEmpty)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: onCopySelected,
                      icon: const Icon(
                        Icons.copy,
                        color: Colors.white,
                        size: 18,
                      ),
                      tooltip: 'copy_selected'.tr(),
                    ),
                  ),
              ],
            ),
          ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: unfollowers.length,
            itemBuilder: (context, index) {
              final user = unfollowers[index];
              final isSelected = selectedUsers.contains(user);

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? InstagramColors.gradientColors[0].withValues(alpha: 0.1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? InstagramColors.gradientColors[0]
                        : Colors.transparent,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  leading: GestureDetector(
                    onTap: () => onToggleUserSelection(user),
                    child: Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isSelected
                              ? [
                                  InstagramColors.gradientColors[0],
                                  InstagramColors.gradientColors[2]
                                ]
                              : [Colors.red.shade100, Colors.red.shade200],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isSelected ? Icons.check : Icons.person_outline,
                        color: isSelected ? Colors.white : Colors.red.shade700,
                        size: 22,
                      ),
                    ),
                  ),
                  title: Text(
                    '@$user',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: isSelected
                          ? InstagramColors.gradientColors[3]
                          : Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    'not_following'.tr(),
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  trailing: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          InstagramColors.gradientColors[0],
                          InstagramColors.gradientColors[2]
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.open_in_new_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      onPressed: () => onOpenUserProfile(user),
                    ),
                  ),
                  onTap: () => onToggleUserSelection(user),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.grey.shade600, Colors.grey.shade700],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: onRestartAnalysis,
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              label: Text(
                'restart_analysis'.tr(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
