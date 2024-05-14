import 'package:flutter/material.dart';

class EmptyChatTile extends StatelessWidget {
  const EmptyChatTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      width: double.infinity,
      height: 90,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                margin: EdgeInsets.only(left: 12),
                child: CircleAvatar(
                  backgroundColor:
                      Theme.of(context).colorScheme.primary.withOpacity(0.5),
                  radius: 28,
                ),
              ),
              SizedBox(
                width: 20,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(bottom: 10, left: 10),
                    width: 100,
                    height: 20,
                    decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 10, bottom: 10),
                    width: 60,
                    height: 15,
                    decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20)),
                  ),
                ],
              ),
            ],
          ),
          // Row(
          //   children: [
          //     Container(
          //       width: 40,
          //       height: 25,
          //       margin: EdgeInsets.only(right: 20),
          //       decoration: BoxDecoration(
          //           borderRadius: BorderRadius.circular(20),
          //           color:
          //               Theme.of(context).colorScheme.primary.withOpacity(0.5)),
          //     )
          //   ],
          // )
        ],
      ),
    );
  }
}
