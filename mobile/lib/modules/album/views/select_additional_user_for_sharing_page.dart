import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:immich_mobile/modules/album/providers/suggested_shared_users.provider.dart';
import 'package:immich_mobile/shared/models/album.dart';
import 'package:immich_mobile/shared/models/user.dart';
import 'package:immich_mobile/shared/ui/immich_loading_indicator.dart';

class SelectAdditionalUserForSharingPage extends HookConsumerWidget {
  final Album album;

  const SelectAdditionalUserForSharingPage({Key? key, required this.album})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<User>> suggestedShareUsers =
        ref.watch(otherUsersProvider);
    final sharedUsersList = useState<Set<User>>({});

    addNewUsersHandler() {
      AutoRouter.of(context)
          .pop(sharedUsersList.value.map((e) => e.id).toList());
    }

    buildTileIcon(User user) {
      if (sharedUsersList.value.contains(user)) {
        return CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: const Icon(
            Icons.check_rounded,
            size: 25,
          ),
        );
      } else {
        return CircleAvatar(
          backgroundImage:
              const AssetImage('assets/immich-logo-no-outline.png'),
          backgroundColor: Theme.of(context).primaryColor.withAlpha(50),
        );
      }
    }

    buildUserList(List<User> users) {
      List<Widget> usersChip = [];

      for (var user in sharedUsersList.value) {
        usersChip.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Chip(
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.15),
              label: Text(
                user.email,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            children: [...usersChip],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'select_additional_user_for_sharing_page_suggestions'.tr(),
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            itemBuilder: ((context, index) {
              return ListTile(
                leading: buildTileIcon(users[index]),
                title: Text(
                  users[index].email,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  if (sharedUsersList.value.contains(users[index])) {
                    sharedUsersList.value = sharedUsersList.value
                        .where(
                          (selectedUser) => selectedUser.id != users[index].id,
                        )
                        .toSet();
                  } else {
                    sharedUsersList.value = {
                      ...sharedUsersList.value,
                      users[index]
                    };
                  }
                },
              );
            }),
            itemCount: users.length,
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'share_invite',
        ).tr(),
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () {
            AutoRouter.of(context).pop(null);
          },
        ),
        actions: [
          TextButton(
            onPressed:
                sharedUsersList.value.isEmpty ? null : addNewUsersHandler,
            child: const Text(
              "share_add",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ).tr(),
          )
        ],
      ),
      body: suggestedShareUsers.when(
        data: (users) {
          for (var sharedUsers in album.sharedUsers) {
            users.removeWhere(
              (u) => u.id == sharedUsers.id || u.id == album.ownerId,
            );
          }

          return buildUserList(users);
        },
        error: (e, _) => Text("Error loading suggested users $e"),
        loading: () => const Center(
          child: ImmichLoadingIndicator(),
        ),
      ),
    );
  }
}
