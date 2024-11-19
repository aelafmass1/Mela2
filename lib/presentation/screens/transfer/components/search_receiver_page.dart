// ignore_for_file: use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:transaction_mobile_app/core/utils/show_snackbar.dart';
import 'package:transaction_mobile_app/gen/assets.gen.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/presentation/widgets/button_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/card_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/loading_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_field_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

import '../../../../bloc/contact/contact_bloc.dart';
import '../../../../data/models/contact_status_model.dart';

class SearchReceiverPage extends StatefulWidget {
  final Function(ContactStatusModel selectedContact) onSelected;
  const SearchReceiverPage({super.key, required this.onSelected});

  @override
  State<SearchReceiverPage> createState() => _SearchReceiverPageState();
}

class _SearchReceiverPageState extends State<SearchReceiverPage> {
  final searchController = TextEditingController();

  List<Contact> contacts = [];
  List<Contact> filteredContacts = [];

  List<String> melaMemberContacts = [];

  bool isPermissionDenied = false;
  bool isSearching = false;

  Future<void> _fetchContacts() async {
    if (kIsWeb) return;

    if (await FlutterContacts.requestPermission(readonly: true)) {
      List<Contact> c = await FlutterContacts.getContacts(withProperties: true);
      setState(() {
        contacts = c;
      });
      // if (searchFocusNode.hasFocus == false) {
      //   searchFocusNode.requestFocus();
      // }
      final contactState = context.read<ContactBloc>().state;
      if (contactState is! ContactSuccess) {
        context.read<ContactBloc>().add(CheckMyContacts(contacts: contacts));
      } else if (contactState.contacts.isNotEmpty) {
        setState(() {
          melaMemberContacts =
              contactState.contacts.map((c) => c.contactId).toList();
        });
      }
    } else {
      setState(() {
        isPermissionDenied = true;
      });
    }
  }

  @override
  void initState() {
    _fetchContacts();
    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();
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
        if (state is ContactSuccess) {
          if (state.contacts.isNotEmpty) {
            setState(() {
              melaMemberContacts =
                  state.contacts.map((c) => c.contactId).toList();
            });
          }
        } else if (state is ContactFail) {
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
            if (text.isEmpty) {
              setState(() {
                isSearching = false;
              });
            } else {
              filteredContacts = contacts.where((contact) {
                final name = contact.displayName.toLowerCase();
                final phoneNumber = contact.phones.first.number.toLowerCase();
                final searchTextLower = text.toLowerCase();
                return name.contains(searchTextLower) ||
                    phoneNumber.contains(searchTextLower);
              }).toList();
              setState(() {
                isSearching = true;
                filteredContacts = filteredContacts;
              });
            }
          },
          border: InputBorder.none,
          hintText: '',
          prefix: SvgPicture.asset(
            Assets.images.svgs.search,
            width: 10,
            height: 10,
            fit: BoxFit.scaleDown,
          ),
          borderRadius: BorderRadius.circular(24),
          controller: searchController,
          suffix: SizedBox(
            width: 68,
            child: CardWidget(
              width: 68,
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
                    context.pop();
                  },
                  child: const TextWidget(
                    text: 'Cancel',
                    fontSize: 14,
                    color: ColorName.primaryColor,
                  )),
            ),
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
            if (isSearching) {
              return ListView.separated(
                itemBuilder: (context, index) {
                  return _buildContactTile(
                    filteredContacts[index],
                  );
                },
                separatorBuilder: (context, index) => Divider(
                  color: ColorName.grey.shade100,
                  height: 0.1,
                  thickness: 0.5,
                ),
                itemCount: filteredContacts.length,
              );
            } else {
              return ListView.separated(
                itemBuilder: (context, index) {
                  return _buildContactTile(
                    contacts[index],
                  );
                },
                separatorBuilder: (context, index) => Divider(
                  color: ColorName.grey.shade100,
                  height: 0.1,
                  thickness: 0.5,
                ),
                itemCount: contacts.length,
              );
            }
          },
        ),
      ),
    );
  }

  _buildContactTile(Contact contact) {
    return ListTile(
      onTap: () {
        if (melaMemberContacts.contains(contact.id)) {
          final state = context.read<ContactBloc>().state;
          if (state is ContactSuccess) {
            final selectedContact =
                state.contacts.firstWhere((c) => c.contactId == contact.id);
            widget.onSelected(selectedContact.copyWith(
              contactName: contact.displayName,
              contactPhoneNumber: contact.phones.first.number,
            ));
          }
        } else {
          widget.onSelected(
            ContactStatusModel(
                contactId: contact.id,
                contactStatus: 'Selected',
                userId: -1,
                contactName: contact.displayName,
                contactPhoneNumber: contact.phones.first.number,
                wallets: []),
          );
        }
        context.pop();
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
            text: contact.displayName,
            fontSize: 16,
          ),
          const SizedBox(width: 5),
          Visibility(
            visible: melaMemberContacts.contains(contact.id),
            child: SvgPicture.asset(
              Assets.images.svgs.checkmarkIcon,
              width: 18,
              height: 18,
            ),
          ),
        ],
      ),
      subtitle: TextWidget(
        text: contact.phones.first.number,
        fontSize: 10,
        color: ColorName.grey.shade500,
        weight: FontWeight.w400,
      ),
    );
  }
}
