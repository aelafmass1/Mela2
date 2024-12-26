import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:transaction_mobile_app/core/utils/contact_utils.dart';
import 'package:transaction_mobile_app/core/utils/show_snackbar.dart';
import 'package:transaction_mobile_app/core/utils/ui_helpers.dart';
import 'package:transaction_mobile_app/gen/assets.gen.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/presentation/widgets/button_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/card_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_field_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

import '../../../../bloc/contact/contact_bloc.dart';
import '../../../../data/models/contact_status_model.dart';
import '../../../../data/models/wallet_model.dart';

class SearchReceiverPage extends StatefulWidget {
  final Function(ContactStatusModel selectedContact) onSelected;
  const SearchReceiverPage({super.key, required this.onSelected});

  @override
  State<SearchReceiverPage> createState() => _SearchReceiverPageState();
}

class _SearchReceiverPageState extends State<SearchReceiverPage> {
  final searchController = TextEditingController();

  Timer? _debounce;

  bool isPermissionDenied = false;

  @override
  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    isPermissionDenied = await fetchContacts(context, isWeb: kIsWeb);
    if (mounted) {
      context.read<ContactBloc>().add(RefreshContacts());
      setState(() {});
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            const SizedBox(height: 60),
            _buildSearchField(),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isPermissionDenied)
                    _buildPermissionDeniedWidget()
                  else
                    _buildContactsList(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  _buildPermissionDeniedWidget() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Align(
            alignment: Alignment.center,
            child: Assets.images.contactPageImage.image(
              width: 200,
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 10),
            child: TextWidget(
              text: 'Enable Contact Permission',
              weight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: 80.sw,
            child: const TextWidget(
              text:
                  'This is going to be the settings path on the users device to enable the contact permission for our App.',
              type: TextType.small,
              textAlign: TextAlign.center,
              fontSize: 12,
              weight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 80.sw,
            child: const TextWidget(
              text:
                  'Go to Settings > Apps > Mela Fi > Contact > Select Full Access',
              type: TextType.small,
              textAlign: TextAlign.center,
              fontSize: 12,
              weight: FontWeight.w600,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10, top: 50),
            child: ButtonWidget(
                child: const TextWidget(
                  text: 'Enable Permission',
                  type: TextType.small,
                  color: Colors.white,
                ),
                onPressed: () async {
                  await openAppSettings();
                }),
          )
        ],
      ),
    );
  }

  _buildSearchField() {
    return BlocListener<ContactBloc, ContactState>(
      listener: (context, state) {
        if (state is ContactFail) {
          showSnackbar(
            context,
            description: state.message,
          );
        }
        if (state is ContactFilterFailed) {
          showSnackbar(
            context,
            description: state.message,
          );
        }
      },
      child: CardWidget(
        width: 100.sw,
        child: TextFieldWidget(
          onChanged: (text) {
            if (_debounce?.isActive ?? false) _debounce!.cancel();
            _debounce = Timer(const Duration(milliseconds: 200), () {
              context.read<ContactBloc>().add(SearchContacts(query: text));
            });
          },
          border: InputBorder.none,
          hintText: 'Search by @username, name or phone number',
          hintTextStyle: TextStyle(
            fontSize: 12,
            color: ColorName.grey.shade300,
          ),
          prefix: SvgPicture.asset(
            Assets.images.svgs.search,
            width: 10,
            height: 10,
            fit: BoxFit.scaleDown,
          ),
          borderRadius: BorderRadius.circular(24),
          controller: searchController,
          suffix: SizedBox(
            width: largeMedium,
            child: ButtonWidget(
                elevation: 0,
                color: ColorName.white,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                  topLeft: Radius.zero,
                  bottomLeft: Radius.zero,
                ),
                onPressed: () {
                  if (mounted) {
                    context.pop();
                  }
                },
                child: const TextWidget(
                  text: 'Cancel',
                  fontSize: 14,
                  color: ColorName.primaryColor,
                )),
          ),
        ),
      ),
    );
  }

  _buildContactsList() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: BlocBuilder<ContactBloc, ContactState>(
          builder: (context, state) {
            if (state is ContactFilterSuccess) {
              if (state.filteredContacts.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const TextWidget(
                        text: "No results found",
                        fontSize: 18,
                        weight: FontWeight.bold,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            size: 18,
                          ),
                          horizontalSpaceSmall,
                          Expanded(
                            child: TextWidget(
                              text:
                                  "User tag must start with @ symbol and be at least 4 characters.",
                              fontSize: 14,
                              color: ColorName.grey.shade500,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                      verticalSpaceSmall,
                      Row(
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            size: 18,
                          ),
                          horizontalSpaceSmall,
                          Expanded(
                            child: TextWidget(
                              text:
                                  "If the phone number is not in your contacts, it must be at least 8 digits (excluding country code).",
                              fontSize: 14,
                              color: ColorName.grey.shade500,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }
              return ListView.separated(
                itemBuilder: (context, index) {
                  return _buildContactTile(
                      state.filteredContacts[index],
                      state.filteredContacts[index].contactStatus !=
                          "not_registered",
                      state.filteredContacts[index].wallets);
                },
                separatorBuilder: (context, index) => Divider(
                  color: ColorName.grey.shade100,
                  height: 0.1,
                  thickness: 0.5,
                ),
                itemCount: state.filteredContacts.length,
              );
            } else if (state is ContactLoading ||
                state is ContactFilterLoading) {
              return const Center(child: CircularProgressIndicator());
            } else {
              return Container();
            }
          },
        ),
      ),
    );
  }

  _buildContactTile(ContactStatusModel contact, bool isMelaMember,
      List<WalletModel>? wallets) {
    return ListTile(
      onTap: () {
        try {
          widget.onSelected(contact);
          if (mounted) {
            context.pop();
          }
        } catch (e) {
          log(e.toString());
        }
      },
      leading: Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: Assets.images.profileImage.image(
          color: ColorName.primaryColor.shade200,
          fit: BoxFit.cover,
        ),
      ),
      title: Row(
        children: [
          TextWidget(
            text: contact.contactName ?? '',
            fontSize: 16,
          ),
          const SizedBox(width: 5),
          Visibility(
            visible: isMelaMember,
            child: SvgPicture.asset(
              Assets.images.svgs.checkmarkIcon,
              width: 18,
              height: 18,
            ),
          ),
        ],
      ),
      subtitle: TextWidget(
        text: contact.contactPhoneNumber ?? 'No phone no',
        fontSize: 10,
        color: ColorName.grey.shade500,
        weight: FontWeight.w400,
      ),
    );
  }
}
