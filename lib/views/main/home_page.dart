import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:real_estate/controllers/bottom_navigation_bar_controller.dart';
import 'package:real_estate/controllers/chat_controller.dart';
import 'package:real_estate/controllers/profile_controller.dart';
import 'package:real_estate/controllers/property_controller.dart';
import 'package:real_estate/controllers/property_details_controller.dart';
import 'package:real_estate/controllers/theme_controller.dart';
import 'package:real_estate/models/paginated_conversation.dart';
import 'package:real_estate/models/paginated_property.dart';
import 'package:real_estate/models/profile_info.dart';
import 'package:real_estate/models/property.dart';
import 'package:real_estate/services/auth_apis/auth_apis.dart';
import 'package:real_estate/services/chat_apis/chat_apis.dart';
import 'package:real_estate/services/properties_apis/properties_apis.dart';
import 'package:real_estate/textstyles/text_colors.dart';
import 'package:real_estate/textstyles/text_styles.dart';
import 'package:real_estate/widgets/my_bottom_navigation_bar.dart';
import 'package:real_estate/widgets/my_floating_action_button.dart';
import 'package:real_estate/widgets/property_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final PropertyController propertyController = Get.find<PropertyController>();

  final List<String> tabs = ['All', 'House', 'Flat', 'Villa'];
  final BottomNavigationBarController bottomController =
      Get.find<BottomNavigationBarController>();
  final ProfileController profileController = Get.find<ProfileController>();
  final PropertyDetailsController pdController =
      Get.find<PropertyDetailsController>();

  final ThemeController themeController = Get.find<ThemeController>();
  final ChatController chatController = Get.find<ChatController>();
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.wait([
        if (!chatController.isConnected) _fetchFirstConversation(),
        _fetchProperties(),
        if (profileController.isInitialLoading) _fetchUserInfo(),
        if (pdController.isFavoriteSet.isEmpty) _fetchFavorites(),
      ]);
    });
  }

  Future<void> _fetchFirstConversation() async {
    chatController.chats.clear();
    PaginatedConversation pConversation = await ChatApis.getConversations();
    if (pConversation.conversations.isNotEmpty) {
      chatController.add(pConversation.conversations[0]);
    }
  }

  Future<void> _fetchUserInfo() async {
    profileController.changeIsInitialLoading(true);

    print("trying to fetch user info from home page");

    ProfileInfo? profileInfo = await AuthApis.getProfile();
    if (profileInfo == null) {
      print("!!!! returned profileInfo is null");
      return;
    }
    profileController.changeCurrentUserInfo(profileInfo);
    profileController.changeIsInitialLoading(false);
  }

  Future<void> _fetchProperties() async {
    propertyController.clearProperties();
    propertyController.changeIsLoading(true);
    PaginatedProperty pProperty =
        PaginatedProperty(nextPageUrl: null, properties: []);
    do {
      pProperty =
          await PropertiesApis.getProperties(url: pProperty.nextPageUrl);

      for (var property in pProperty.properties) {
        propertyController.addProperty(property);
      }
    } while (pProperty.nextPageUrl != null);
    propertyController.changeIsLoading(false);
  }

  Future<void> _fetchFavorites() async {
    pdController.clear();
    PaginatedProperty pProperty =
        PaginatedProperty(nextPageUrl: null, properties: []);
    do {
      pProperty = await PropertiesApis.getFavorites(url: pProperty.nextPageUrl);
      for (var property in pProperty.properties) {
        pdController.initFavorites(property);
      }
    } while (pProperty.nextPageUrl != null);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: const Color.fromARGB(255, 245, 243, 243),
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: GetBuilder<ProfileController>(
            id: "profilePhoto",
            init: profileController,
            builder: (controller) => CircleAvatar(
              radius: 25,
              backgroundImage: profileController.isInitialLoading
                  ? const AssetImage("assets/images/person.jpg")
                  : NetworkImage(
                      profileController.currentUserInfo!.profilePhoto,
                    ),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Welcome",
            ),
            GetBuilder<ProfileController>(
              init: profileController,
              id: 'fullName',
              builder: (controller) => Text(
                profileController.isInitialLoading
                    ? "To our app"
                    : "${profileController.currentUserInfo?.firstName} ${profileController.currentUserInfo?.lastName}",
              ),
            ),
          ],
        ),
      ),
      body: Container(
        padding: const EdgeInsets.only(left: 15, right: 15, top: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            searchBarWidget(),
            TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: tabs.map((tab) => Tab(text: tab)).toList(),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: getPropertiesTypesLists(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: const MyFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: GetBuilder<BottomNavigationBarController>(
        init: bottomController,
        builder: (controller) {
          return MyBottomNavigationBar(
            bottomController: bottomController,
          );
        },
      ),
    );
  }

  List<GetBuilder<PropertyController>> getPropertiesTypesLists() {
    return [
      tabElement(builderId: 'all'),
      tabElement(builderId: 'house'),
      tabElement(builderId: 'flat'),
      tabElement(builderId: 'villa'),
    ];
  }

  GetBuilder<PropertyController> tabElement({
    required String builderId,
  }) {
    List<Property> wantedList = [];
    if (builderId == 'all') {
      wantedList = propertyController.getAll;
    } else if (builderId == 'house')
      // ignore: curly_braces_in_flow_control_structures
      wantedList = propertyController.getHouses;
    else if (builderId == 'flat')
      // ignore: curly_braces_in_flow_control_structures
      wantedList = propertyController.getFlats;
    else
      // ignore: curly_braces_in_flow_control_structures
      wantedList = propertyController.getVillas;
    return GetBuilder<PropertyController>(
      init: propertyController,
      id: builderId,
      builder: (contorller) {
        if (propertyController.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              _fetchProperties(),
              _fetchUserInfo(),
            ]);
          },
          child: AnimationLimiter(
            child: GridView.builder(
              padding: const EdgeInsets.only(top: 20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Two items per row
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.8, // Height to width ratio
              ),
              itemCount:
                  wantedList.length, // For example, 10 items for each tab
              itemBuilder: (context, index) {
                return AnimationConfiguration.staggeredGrid(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  columnCount: 2,
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: ScaleAnimation(
                      scale: 0.8,
                      child: FadeInAnimation(
                        child: GetBuilder<PropertyController>(
                          init: propertyController,
                          id: "propertyCard$index",
                          builder: (controller) => AnimatedScale(
                            scale: controller.cardAnimationScale[index],
                            duration: const Duration(milliseconds: 150),
                            child: PropertyCard(
                              property: wantedList[index],
                              scaleController: propertyController,
                              index: index,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Container searchBarWidget() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(50, 79, 76, 76),
            offset: Offset(2, 2),
            blurRadius: 10,
          ),
          BoxShadow(
            color: Color.fromARGB(50, 79, 76, 76),
            offset: Offset(-2, 2),
            blurRadius: 10,
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          filled: true,
          // fillColor: Colors.white,
          hintText: "Search",
          hintStyle: h4TitleStyleGrey,
          contentPadding: const EdgeInsets.all(18),
          enabledBorder: UnderlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          focusedBorder: UnderlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          prefixIcon: IconButton(
            onPressed: () {
              Get.toNamed("/searchResultPage");
            },
            icon: const Icon(Icons.search, color: greyText),
          ),
          suffixIcon: IconButton(
            onPressed: () {
              Get.toNamed("/filterSearchPage");
            },
            icon: const Icon(Icons.filter_alt_outlined, color: greyText),
          ),
        ),
      ),
    );
  }
}
