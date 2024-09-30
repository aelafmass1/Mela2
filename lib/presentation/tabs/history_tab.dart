import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:transaction_mobile_app/bloc/transaction/transaction_bloc.dart';
import 'package:transaction_mobile_app/config/routing.dart';
import 'package:transaction_mobile_app/core/utils/show_snackbar.dart';
import 'package:transaction_mobile_app/data/models/receiver_info_model.dart';
import 'package:transaction_mobile_app/gen/assets.gen.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/presentation/widgets/loading_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

class HistoryTab extends StatefulWidget {
  const HistoryTab({super.key});

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  String selectedFilter = 'all';
  @override
  void initState() {
    context.read<TransactionBloc>().add(FetchTrasaction());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        toolbarHeight: 50,
        title: const TextWidget(
          text: 'Transaction History',
        ),
        actions: [
          // IconButton(
          //   onPressed: () {
          //     //
          //   },
          //   icon: const Icon(Icons.print_outlined),
          // ),
          IconButton(
            onPressed: () {
              //
            },
            icon: SvgPicture.asset(Assets.images.svgs.filterIcon),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 65,
                    height: 30,
                    child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          backgroundColor: selectedFilter == 'all'
                              ? ColorName.primaryColor
                              : null,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                            side: selectedFilter == 'all'
                                ? BorderSide.none
                                : const BorderSide(),
                          ),
                        ),
                        child: TextWidget(
                          text: 'All',
                          fontSize: 12,
                          color: selectedFilter == 'all' ? Colors.white : null,
                        ),
                        onPressed: () {
                          setState(() {
                            selectedFilter = 'all';
                          });
                        }),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 80,
                    height: 30,
                    child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          backgroundColor: selectedFilter == 'remittance'
                              ? ColorName.primaryColor
                              : null,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                            side: selectedFilter == 'remittance'
                                ? BorderSide.none
                                : const BorderSide(),
                          ),
                        ),
                        child: TextWidget(
                          text: 'Remittance',
                          fontSize: 12,
                          color: selectedFilter == 'remittance'
                              ? Colors.white
                              : null,
                        ),
                        onPressed: () {
                          setState(() {
                            selectedFilter = 'remittance';
                          });
                        }),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 75,
                    height: 30,
                    child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          backgroundColor: selectedFilter == 'equb'
                              ? ColorName.primaryColor
                              : null,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                            side: selectedFilter == 'equb'
                                ? BorderSide.none
                                : const BorderSide(),
                          ),
                        ),
                        child: TextWidget(
                          text: 'Equb',
                          fontSize: 12,
                          color: selectedFilter == 'equb' ? Colors.white : null,
                        ),
                        onPressed: () {
                          setState(() {
                            selectedFilter = 'equb';
                          });
                        }),
                  )
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(
                color: ColorName.borderColor,
              ),
            ),
            Expanded(
              child: BlocConsumer<TransactionBloc, TransactionState>(
                listener: (context, state) {
                  if (state is TransactionFail) {
                    showSnackbar(
                      context,
                      title: 'Error',
                      description: state.reason,
                    );
                  }
                },
                builder: (context, state) {
                  if (state is TransactionLoading) {
                    return const Center(
                      child: LoadingWidget(
                        color: ColorName.primaryColor,
                      ),
                    );
                  } else if (state is TransactionSuccess) {
                    if (state.data.isNotEmpty) {
                      return Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async {
                            context
                                .read<TransactionBloc>()
                                .add(FetchTrasaction());
                          },
                          child: ListView.separated(
                            separatorBuilder: (context, index) => const Divider(
                              color: ColorName.borderColor,
                            ),
                            itemCount: state.data.length,
                            itemBuilder: (context, index) => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextWidget(
                                  text: DateFormat('yyyy-MM-dd')
                                              .format(DateTime.now()) ==
                                          state.data.keys.elementAt(index)
                                      ? 'Today'
                                      : (DateTime.parse(state.data.keys
                                                          .elementAt(index))
                                                      .day -
                                                  1) ==
                                              DateTime.now().day
                                          ? 'Yesterday'
                                          : DateFormat('d-MMMM yyyy').format(
                                              DateTime.parse(state.data.keys
                                                  .elementAt(index))),
                                  color: ColorName.primaryColor,
                                  fontSize: 14,
                                  weight: FontWeight.w600,
                                ),
                                for (var transaction
                                    in state.data.values.elementAt(index))
                                  _buildTrasactionTile(transaction),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                    return const Center(
                      child: TextWidget(
                        text: 'Transaction history is empty',
                        type: TextType.small,
                        weight: FontWeight.w300,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  _buildTrasactionTile(ReceiverInfo receiverInfo) {
    return ListTile(
      onTap: () {
        context.pushNamed(
          RouteName.receipt,
          extra: receiverInfo,
        );
      },
      leading: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: const Color(0xFFA000C8).withOpacity(0.1),
        ),
        child: Center(
          child: SvgPicture.asset(
            Assets.images.svgs.transactionIcon,
            width: 24,
            height: 24,
          ),
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextWidget(
            text: '\$${receiverInfo.amount}',
            fontSize: 14,
            weight: FontWeight.w600,
          ),
          TextWidget(
            text: DateFormat('hh:mm a').format(receiverInfo.transactionDate!),
            fontSize: 10,
            weight: FontWeight.w400,
          )
        ],
      ),
      title: TextWidget(
        text: receiverInfo.receiverName,
        fontSize: 14,
        weight: FontWeight.w400,
      ),
      subtitle: TextWidget(
        text: receiverInfo.receiverPhoneNumber,
        fontSize: 10,
        weight: FontWeight.w400,
      ),
    );
  }
}
