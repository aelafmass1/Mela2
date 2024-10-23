import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:transaction_mobile_app/bloc/equb_member/equb_member_bloc.dart';
import 'package:transaction_mobile_app/core/utils/show_snackbar.dart';
import 'package:transaction_mobile_app/data/models/contact_model.dart';
import 'package:transaction_mobile_app/presentation/widgets/loading_widget.dart';

import '../../bloc/equb/equb_bloc.dart';
import '../../gen/colors.gen.dart';
import '../../presentation/widgets/button_widget.dart';
import '../../presentation/widgets/text_widget.dart';

Future<List<Contact>> showAddMember(BuildContext context, int numberOfMembers,
    List<Contact> contacts, int equbId) async {
  final searchController = TextEditingController();
  bool isSearching = false;
  List<Contact> filteredContacts = [];

  List<Contact> selectedContacts = [];
  await showModalBottomSheet<List<Contact>>(
    context: context,
    isScrollControlled: true,
    builder: (context) => StatefulBuilder(builder: (context, setState) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, top: 40),
              child: SizedBox(
                width: 100.sw,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                        style: IconButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 0,
                          ),
                        ),
                        onPressed: () {
                          context.pop();
                        },
                        icon: const Icon(
                          Icons.close,
                        )),
                    const SizedBox(height: 20),
                    const TextWidget(
                      text: 'Add Members',
                      fontSize: 14,
                      weight: FontWeight.w400,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: searchController,
                      onChanged: (value) {
                        if (value.isEmpty) {
                          setState(() {
                            isSearching = false;
                            filteredContacts = [];
                          });
                        } else {
                          filteredContacts = contacts
                              .where((contact) => contact.displayName
                                  .toLowerCase()
                                  .startsWith(value.toLowerCase()))
                              .toList();
                          setState(() {
                            filteredContacts = filteredContacts;
                            isSearching = true;
                          });
                        }
                      },
                      decoration: InputDecoration(
                        hintText: 'Search name',
                        hintStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                        prefixIcon: const Icon(
                          BoxIcons.bx_search,
                        ),
                        contentPadding: const EdgeInsets.only(left: 20),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextWidget(
                          text: 'All Contact (${contacts.length} Contacts) ',
                          fontSize: 14,
                          weight: FontWeight.w500,
                        ),
                        TextWidget(
                          text: '${selectedContacts.length} / $numberOfMembers',
                          fontSize: 14,
                          weight: FontWeight.w500,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: isSearching
                          ? filteredContacts.isEmpty
                              ? Container(
                                  margin: const EdgeInsets.only(top: 10),
                                  alignment: Alignment.topCenter,
                                  child: TextWidget(
                                    text: '${searchController.text} not Found',
                                    type: TextType.small,
                                    weight: FontWeight.w300,
                                    color: const Color(0xFF6D6D6D),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: filteredContacts.length,
                                  itemBuilder: (context, index) {
                                    final contact = filteredContacts[index];
                                    final isSelected =
                                        selectedContacts.contains(contact);
                                    return CheckboxListTile(
                                      activeColor: ColorName.primaryColor,
                                      contentPadding: EdgeInsets.zero,
                                      value: isSelected,
                                      secondary: contact.photo == null
                                          ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                              child: Container(
                                                width: 50,
                                                height: 50,
                                                color: ColorName.primaryColor,
                                                alignment: Alignment.center,
                                                child: TextWidget(
                                                  text: contact.displayName[0],
                                                  color: Colors.white,
                                                ),
                                              ),
                                            )
                                          : ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                              child: Image.memory(
                                                contact.photo!,
                                                width: 50,
                                                height: 50,
                                                fit: BoxFit.cover,
                                              )),
                                      title: TextWidget(
                                        text: contact.displayName,
                                        fontSize: 16,
                                        weight: FontWeight.w400,
                                      ),
                                      subtitle: TextWidget(
                                        text: contact.phones.first.number,
                                        type: TextType.small,
                                        fontSize: 14,
                                        weight: FontWeight.w300,
                                      ),
                                      onChanged: (bool? selected) {
                                        if (selected == true) {
                                          if (selectedContacts.length <
                                              numberOfMembers) {
                                            selectedContacts.add(contact);
                                          } else {
                                            showSnackbar(
                                              context,
                                              description: 'members are full',
                                            );
                                          }
                                        } else {
                                          selectedContacts.remove(contact);
                                        }
                                        setState(() {
                                          selectedContacts = selectedContacts;
                                        });
                                      },
                                    );
                                  })
                          : ListView.builder(
                              itemCount: contacts.length,
                              itemBuilder: (context, index) {
                                final contact = contacts[index];
                                final isSelected =
                                    selectedContacts.contains(contact);
                                return CheckboxListTile(
                                  activeColor: ColorName.primaryColor,
                                  contentPadding: EdgeInsets.zero,
                                  value: isSelected,
                                  secondary: contact.photo == null
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          child: Container(
                                            width: 50,
                                            height: 50,
                                            color: ColorName.primaryColor,
                                            alignment: Alignment.center,
                                            child: TextWidget(
                                              text: contact.displayName[0],
                                              color: Colors.white,
                                            ),
                                          ),
                                        )
                                      : ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          child: Image.memory(
                                            contact.photo!,
                                            width: 50,
                                            height: 50,
                                            fit: BoxFit.cover,
                                          )),
                                  title: TextWidget(
                                    text: contact.displayName,
                                    fontSize: 16,
                                    weight: FontWeight.w400,
                                  ),
                                  subtitle: TextWidget(
                                    text: contact.phones.first.number,
                                    type: TextType.small,
                                    fontSize: 14,
                                    weight: FontWeight.w300,
                                  ),
                                  onChanged: (bool? selected) {
                                    setState(() {
                                      if (selected == true) {
                                        if (selectedContacts.length <
                                            numberOfMembers) {
                                          selectedContacts.add(contact);
                                        } else {
                                          showSnackbar(
                                            context,
                                            description: 'members are full',
                                          );
                                        }
                                      } else {
                                        selectedContacts.remove(contact);
                                      }
                                    });
                                    setState(() {
                                      selectedContacts = selectedContacts;
                                    });
                                    log(selectedContacts.toString());
                                  },
                                );
                              }),
                    )
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                width: 100.sw,
                color: Colors.white,
                padding: const EdgeInsets.only(
                    bottom: 10, left: 15, right: 15, top: 10),
                child: BlocConsumer<EqubMemberBloc, EqubMemberState>(
                  listener: (context, state) {
                    if (state is EqubMemberInviteFail) {
                      showSnackbar(
                        context,
                        title: 'error',
                        description: state.reason,
                      );
                    } else if (state is EqubMemberInviteSuccess) {
                      context.read<EqubBloc>().add(FetchEqub(equbId: equbId));
                      context.pop();
                    }
                  },
                  builder: (context, state) {
                    return ButtonWidget(
                      onPressed: () {
                        context.read<EqubMemberBloc>().add(
                              InviteEqubMemeber(
                                equbId: equbId,
                                contacts: selectedContacts
                                    .map((c) => ContactModel(
                                        contactId: c.id,
                                        name: c.displayName,
                                        phoneNumber: c.phones.first.number))
                                    .toList(),
                              ),
                            );
                      },
                      child: state is EqubMemberInviteLoading
                          ? const LoadingWidget()
                          : const TextWidget(
                              text: 'Next',
                              type: TextType.small,
                              color: Colors.white,
                            ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      );
    }),
  );
  return selectedContacts;
}
