import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/presentation/screens/home_screen/components/contact_selection_dialog.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

class EqubTab extends StatefulWidget {
  const EqubTab({super.key});

  @override
  State<EqubTab> createState() => _EqubTabState();
}

class _EqubTabState extends State<EqubTab> {
  String selectedTerm = 'daily';
  List<Contact> selectedContacts = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.only(top: 50),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TextWidget(
              text: 'Term',
              type: TextType.small,
              weight: FontWeight.w300,
            ),
            DropdownButtonFormField(
              padding: const EdgeInsets.only(left: 10),
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
              value: selectedTerm,
              icon: const Padding(
                padding: EdgeInsets.only(right: 10),
                child: Icon(
                  Icons.keyboard_arrow_down,
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'daily',
                  child: TextWidget(
                    text: 'Daily',
                    type: TextType.small,
                    weight: FontWeight.w400,
                  ),
                ),
                DropdownMenuItem(
                  value: 'weekly',
                  child: TextWidget(
                    text: 'Weekly',
                    type: TextType.small,
                    weight: FontWeight.w400,
                  ),
                ),
                DropdownMenuItem(
                  value: 'bi-weekly',
                  child: TextWidget(
                    text: 'Bi Weekly',
                    type: TextType.small,
                    weight: FontWeight.w400,
                  ),
                ),
                DropdownMenuItem(
                  value: 'monthly',
                  child: TextWidget(
                    text: 'Monthly',
                    type: TextType.small,
                    weight: FontWeight.w400,
                  ),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedTerm = value;
                  });
                }
              },
            ),
            const SizedBox(height: 20),
            TextField(
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: const InputDecoration(
                hintText: 'Amount per Term',
                suffix: Icon(Icons.attach_money),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () async {
                selectedContacts = await showDialog<List<Contact>>(
                      context: context,
                      builder: (BuildContext context) {
                        return ContactSelectionDialog();
                      },
                    ) ??
                    selectedContacts;

                setState(() {
                  selectedContacts = selectedContacts;
                });
              },
              child: const Row(
                children: [
                  Icon(
                    Icons.perm_contact_cal,
                    color: ColorName.primaryColor,
                  ),
                  SizedBox(width: 10),
                  TextWidget(
                    text: 'Add Participants',
                    type: TextType.small,
                    color: ColorName.primaryColor,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: selectedContacts.length,
                itemBuilder: (context, index) => ListTile(
                  title: Row(
                    children: [
                      TextWidget(
                        text: selectedContacts[index].displayName,
                      ),
                    ],
                  ),
                  subtitle: TextWidget(
                    text: selectedContacts[index].phones.first.number,
                    type: TextType.small,
                    weight: FontWeight.w300,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 100.sh,
              height: 50,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: const BorderSide(
                          color: ColorName.primaryColor,
                        ))),
                child: const TextWidget(
                  text: 'Create Equb',
                  color: ColorName.primaryColor,
                ),
                onPressed: () {},
              ),
            )
          ],
        ),
      ),
    );
  }
}
