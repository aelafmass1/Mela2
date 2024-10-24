import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../gen/colors.gen.dart';
import '../../presentation/widgets/text_widget.dart';

showDetailBottomSheet(BuildContext context) {
  showModalBottomSheet(
      context: context,
      builder: (_) => Wrap(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: Container(
                          width: 35,
                          height: 35,
                          color: ColorName.green,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.person_add,
                            color: ColorName.white,
                            size: 20,
                          ),
                        ),
                      ),
                      title: const TextWidget(
                        text: "Make Co-Admin",
                        type: TextType.small,
                      ),
                      onTap: () => showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const TextWidget(
                              text:
                                  "Are you sure you want to promote to co-admin?"),
                          actions: [
                            MaterialButton(
                              child: const Text("Cancel"),
                              onPressed: () => context.pop(),
                            ),
                            MaterialButton(
                              child: const Text("Promote"),
                              onPressed: () => context.pop(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: Container(
                          width: 35,
                          height: 35,
                          color: ColorName.green,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.person_remove,
                            color: ColorName.white,
                            size: 20,
                          ),
                        ),
                      ),
                      title: const TextWidget(
                        text: "Remove Co-Admin",
                        type: TextType.small,
                      ),
                      onTap: () => showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const TextWidget(
                              text:
                                  "Are you sure you want to remove this co-admin?"),
                          actions: [
                            MaterialButton(
                              child: const Text("Cancel"),
                              onPressed: () => context.pop(),
                            ),
                            MaterialButton(
                              child: const Text("Remove"),
                              onPressed: () => context.pop(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: Container(
                          width: 35,
                          height: 35,
                          color: ColorName.red,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.close,
                            color: ColorName.white,
                            size: 20,
                          ),
                        ),
                      ),
                      title: const TextWidget(
                        text: "Remove from equb",
                        type: TextType.small,
                      ),
                      onTap: () => showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const TextWidget(
                              text:
                                  "Are you sure you want to remove this member?"),
                          actions: [
                            MaterialButton(
                              child: const Text("Cancel"),
                              onPressed: () => context.pop(),
                            ),
                            MaterialButton(
                              child: const Text("Remove"),
                              onPressed: () => context.pop(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ));
}
