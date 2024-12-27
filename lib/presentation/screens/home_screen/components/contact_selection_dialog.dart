import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/presentation/widgets/back_button.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

class ContactSelectionDialog extends StatefulWidget {
  const ContactSelectionDialog({super.key});

  @override
  _ContactSelectionDialogState createState() => _ContactSelectionDialogState();
}

class _ContactSelectionDialogState extends State<ContactSelectionDialog> {
  List<Contact> _contacts = [];
  List<Contact> _selectedContacts = [];

  @override
  void initState() {
    _fetchContacts();
    super.initState();
  }

  Future<void> _fetchContacts() async {
    if (await FlutterContacts.requestPermission(readonly: true)) {
      List<Contact> contacts =
          await FlutterContacts.getContacts(withProperties: true);
      setState(() {
        _contacts = contacts;
      });
      log(_contacts.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        insetPadding: EdgeInsets.zero,
        shape: const ContinuousRectangleBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    BackButtonWidget(
                      padding: EdgeInsets.zero,
                    ),
                    SizedBox(width: 20),
                    TextWidget(text: 'Select Contacts'),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  width: double.maxFinite,
                  padding: const EdgeInsets.only(top: 30),
                  child: _contacts.isEmpty
                      ? const Center(
                          child: TextWidget(
                            text: 'No Contact found',
                            type: TextType.small,
                            weight: FontWeight.w300,
                          ),
                        )
                      : ListView.builder(
                          itemCount: _contacts.length,
                          itemBuilder: (context, index) {
                            final contact = _contacts[index];
                            final isSelected =
                                _selectedContacts.contains(contact);
                            return CheckboxListTile(
                              value: isSelected,
                              title: TextWidget(
                                text: contact.displayName,
                                weight: FontWeight.w400,
                              ),
                              subtitle: TextWidget(
                                text: contact.phones.first.number,
                                type: TextType.small,
                                weight: FontWeight.w300,
                              ),
                              onChanged: (bool? selected) {
                                setState(() {
                                  if (selected == true) {
                                    _selectedContacts.add(contact);
                                  } else {
                                    _selectedContacts.remove(contact);
                                  }
                                });
                                setState(() {
                                  _selectedContacts = _selectedContacts;
                                });
                                log(_selectedContacts.toString());
                              },
                            );
                          },
                        ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context)
                          .pop(); // Close the dialog without returning contacts
                    },
                    child: const TextWidget(
                      text: 'Cancel',
                      type: TextType.small,
                      color: ColorName.primaryColor,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context)
                          .pop(_selectedContacts); // Return selected contacts
                    },
                    child: const TextWidget(
                      text: 'OK',
                      type: TextType.small,
                      color: ColorName.primaryColor,
                    ),
                  ),
                ],
              )
            ],
          ),
        ));
  }
}
