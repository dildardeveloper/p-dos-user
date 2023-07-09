import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:p_dos_user/screens/constant.dart';

class LayoutBottomSheet extends StatelessWidget {
  final name;
  final address;
  final category;
  final phone;
  final http;
  LayoutBottomSheet(
      {required this.name,
      required this.address,
      required this.category,
      required this.phone,
      required this.http
      });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(20),
      child: Column(
        children: [
          Divider(
            color: Color(0xff767676).withOpacity(0.40),
            // height: 49,
            indent: 130,
            endIndent: 130,
            thickness: 6,
          ),
          Center(
            child: Text(
              'Case Details',
              style: GoogleFonts.getFont(
                "Nunito",
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
          ),
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              'Name:',
              style: smallText,
            ),
          ),
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              name
                  .split(' ')
                  .where((element) => (element as String).isNotEmpty)
                  .toList()
                  .asMap()
                  .map(
                    (index, word) => MapEntry(
                      index,
                      word + ((index + 1) % 5 == 0 ? '\n' : ' '),
                    ),
                  )
                  .values
                  .join(),
              maxLines: 2,
              textAlign: TextAlign.center,
              style: largText,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              'Category:',
              style: smallText,
            ),
          ),
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              category
                  .split(' ')
                  .where((element) => (element as String).isNotEmpty)
                  .toList()
                  .asMap()
                  .map(
                    (index, word) => MapEntry(
                      index,
                      word + ((index + 1) % 5 == 0 ? '\n' : ' '),
                    ),
                  )
                  .values
                  .join(),
              maxLines: 2,
              style: largText,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              'Personal Number:',
              style: smallText,
            ),
          ),
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              phone
                  .split(' ')
                  .where((element) => (element as String).isNotEmpty)
                  .toList()
                  .asMap()
                  .map(
                    (index, word) => MapEntry(
                      index,
                      word + ((index + 1) % 5 == 0 ? '\n' : ' '),
                    ),
                  )
                  .values
                  .join(),
              maxLines: 2,
              style: largText,
            ),
          ),
          SizedBox(
            height: 10,
          ),
         http != null ? Container(
            alignment: Alignment.centerLeft,
            child: Text(
              'Website:',
              style: smallText,
            ),
          ):Container(),
         http != null? Container(
            alignment: Alignment.centerLeft,
            child: Text(
              http ?? "",
              maxLines: 2,
              style: largText,
            ),
          ):Container(),
          http != null ?SizedBox(
            height: 10,
          ): Container(),
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              'Address:',
              style: smallText,
            ),
          ),
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              address
                  .split(' ')
                  .where((element) => (element as String).isNotEmpty)
                  .toList()
                  .asMap()
                  .map(
                    (index, word) => MapEntry(
                      index,
                      word + ((index + 1) % 5 == 0 ? '\n' : ' '),
                    ),
                  )
                  .values
                  .join(),
              maxLines: 4,
              style: largText,
            ),
          ),
        ],
      ),
    );
  }
}
