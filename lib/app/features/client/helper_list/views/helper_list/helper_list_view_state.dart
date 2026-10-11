part of 'helper_list_view.dart';

class _HelperListViewState extends State<HelperListView> {
  final HelperListController controller = Get.find<HelperListController>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      controller.loadMoreHelpers();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _openChat(HelperListModel helper) async {
    try {
      if (!Get.isRegistered<MessageController>()) {
        if (!Get.isRegistered<AvailabilityRepository>()) {
          Get.put(AvailabilityRepository(Get.find()));
        }
        Get.put(
          MessageController(
            Get.find<ChatRepository>(),
            Get.find<OrderRepository>(),
            Get.find<AvailabilityRepository>(),
          ),
        );
      }
      final msgCtrl = Get.find<MessageController>();

      final chatRepo = Get.find<ChatRepository>();
      final room = await chatRepo.startChat(helper.id);
      chatRepo.rememberRoomCompany(
        room.uuid,
        name: helper.companyName ?? '',
        logo: helper.avatarUrl,
      );

      await msgCtrl.loadRooms();
      ChatModel chat;
      try {
        chat = msgCtrl.chats.firstWhere((c) => c.roomUuid == room.uuid);
      } catch (_) {
        chat = ChatModel(
          name: helper.name,
          avatar: helper.avatarUrl,
          lastMessage: '',
          timeAgo: 'Just now'.tr,
          roomUuid: room.uuid,
          roomId: room.id,
        );
        msgCtrl.chats.add(chat);
      }

      Get.to(() => ChatView(chat: chat));
    } catch (e) {
      Get.snackbar('Error'.tr, 'Could not start chat. Please try again.'.tr);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: controller.categoryName.value),
      body: Column(
        children: [
          HelperListFilterSection(),
          HelperListSortSection(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.loadHelpers,
              color: Color(0xFF6CA34D),
              child: Obx(() {
                final loading = controller.isLoading.value;
                if (loading && controller.displayedHelpers.isEmpty) {
                  return const HelperListShimmer();
                }
                if (controller.displayedHelpers.isEmpty) {
                  return Center(
                    child: Text(
                      "No helpers match your filter criteria.".tr,
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }
                return ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 10.h,
                  ),
                  itemCount: controller.displayedHelpers.length + 1,
                  itemBuilder: (context, index) {
                    if (index == controller.displayedHelpers.length) {
                      return Obx(() {
                        if (controller.isLoadingMore.value) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 20.h),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF6CA34D),
                              ),
                            ),
                          );
                        }
                        return SizedBox.shrink();
                      });
                    }
                    final helper = controller.displayedHelpers[index];
                    return HelperListHelperCard(
                      helper: helper,
                      onChat: _openChat,
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
