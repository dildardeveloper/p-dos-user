import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:p_dos_user/screens/constant.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'home_screen.dart';

class NameSearch extends StatefulWidget {
  @override
  State<NameSearch> createState() => _NameSearchState();
}

class _NameSearchState extends State<NameSearch> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  Future<void> _launchPdfUrl(url) async {
    var uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('excel').snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            if (!snapshot.hasData) {
              return Center(child: Text('Loading...'));
            }
            if (snapshot.data!.size == 0) {
              return Center(child: Text('No data found.'));
            }
            final List<QueryDocumentSnapshot> documents = snapshot.data!.docs;
            final filteredDocuments = documents.where(
              (doc) {
                final data = doc.data() as Map<String, dynamic>;
                final name = (data['Name'] ??
                        data['name'] ??
                        data["Name (våldtäkt mot barn)"] ??
                        "")
                    .toString()
                    .toLowerCase();
                final address =
                    (data['Address'] ?? data['address'] ?? data['Adress'] ?? "")
                        .toString()
                        .toLowerCase();
                final category = (data['Category'] ??
                        data['category'] ??
                        data["Conviction "] ??
                        "")
                    .toString()
                    .toLowerCase();
                final searchText = _searchText.toLowerCase();
                return name.contains(searchText) ||
                    address.contains(searchText) ||
                    category.contains(searchText);
              },
            ).toList();

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
              child: Column(
                children: [
                  Container(
                    height: 43,
                    width: MediaQuery.of(context).size.width,
                    child: TextField(
                      cursorColor: appColor,
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchText = value;
                        });
                      },
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.black,
                          size: 17,
                        ),
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              _searchController.clear();
                              _searchText = '';
                            });
                          },
                          child: Icon(
                            Icons.clear_sharp,
                            color: Colors.black,
                            size: 20,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.black.withOpacity(0.10),
                        hintText: 'Search By Name, Address, or Category',
                        hintStyle: textFieldStyle,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  filteredDocuments.isEmpty
                      ? Center(child: Text('No results found.'))
                      : Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: filteredDocuments.length,
                            scrollDirection: Axis.vertical,
                            itemBuilder: (BuildContext context, int index) {
                              LatLng? latLng;

                              final Map<String, dynamic>? data =
                                  (filteredDocuments[index].data())
                                      as Map<String, dynamic>?;
                              final name = (data?['Name'] ??
                                      data?['name'] ??
                                      data?["Name (våldtäkt mot barn)"] ??
                                      '')
                                  .toString();
                              final address = (data?['Address'] ??
                                      data?['address'] ??
                                      data?['Adress'] ??
                                      '')
                                  .toString();
                              final category =
                                  (data?["Conviction "] ?? '').toString();
                              final phone = (data?["Personnummer: (NY) "] ?? '')
                                  .toString();
                              final isNameMatched = name
                                  .toLowerCase()
                                  .contains(_searchText.toLowerCase());
                              final isAddressMatched = address
                                  .toLowerCase()
                                  .contains(_searchText.toLowerCase());
                              final isCategoryMatched = category
                                  .toLowerCase()
                                  .contains(_searchText.toLowerCase());
                              String? latlngStr = data?['Longitud/Latitud '] ??
                                  data?["Convicted yes/no"];
                              if (latlngStr != null &&
                                  !latlngStr.contains('?') &&
                                  !latlngStr.contains('http')) {
                                List<String> latlngList = latlngStr.split(',');
                                if (latlngList.length == 2) {
                                  double? lat =
                                      double.tryParse(latlngList[0].trim());
                                  double? lng =
                                      double.tryParse(latlngList[1].trim());
                                  if (lat != null && lng != null) {
                                    latLng = LatLng(lat, lng);
                                  }
                                }
                              }
                              String? latlngHttp = data?['Longitud/Latitud '];
                              RegExp exp = RegExp(r'(https?:\/\/[^\s]+)');
                              String? http;
                              if (latlngHttp != null) {
                                Iterable<RegExpMatch> matches =
                                    exp.allMatches(latlngHttp);
                                http = matches
                                    .map((match) => match.group(0))
                                    .firstWhere(
                                        (link) => link!.contains('https'),
                                        orElse: () => null);
                              }

                              return Column(
                                children: [
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Name:',
                                      style: smallText,
                                    ),
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    alignment: Alignment.centerLeft,
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Container(
                                        color: _searchText.isNotEmpty &&
                                                isNameMatched
                                            ? Colors.red.withOpacity(0.08)
                                            : null,
                                        child: Text(
                                          name
                                              .split(' ')
                                              .where((element) =>
                                                  (element).isNotEmpty)
                                              .toList()
                                              .asMap()
                                              .map(
                                                (index, word) => MapEntry(
                                                  index,
                                                  word +
                                                      ((index + 1) % 5 == 0
                                                          ? '\n'
                                                          : ' '),
                                                ),
                                              )
                                              .values
                                              .join(),
                                          maxLines: 2,
                                          style: largText,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Category:',
                                      style: smallText,
                                    ),
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    alignment: Alignment.centerLeft,
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        color: _searchText.isNotEmpty &&
                                                isCategoryMatched
                                            ? Colors.red.withOpacity(0.08)
                                            : null,
                                        child: Text(
                                          category
                                              .split(' ')
                                              .where((element) =>
                                                  (element).isNotEmpty)
                                              .toList()
                                              .asMap()
                                              .map(
                                                (index, word) => MapEntry(
                                                  index,
                                                  word +
                                                      ((index + 1) % 5 == 0
                                                          ? '\n'
                                                          : ' '),
                                                ),
                                              )
                                              .values
                                              .join(),
                                          maxLines: 2,
                                          style: largText,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Personal Number:',
                                      style: smallText,
                                    ),
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    alignment: Alignment.centerLeft,
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        color: _searchText.isNotEmpty &&
                                                isCategoryMatched
                                            ? Colors.red.withOpacity(0.08)
                                            : null,
                                        child: Text(
                                          phone
                                              .split(' ')
                                              .where((element) =>
                                                  (element).isNotEmpty)
                                              .toList()
                                              .asMap()
                                              .map(
                                                (index, word) => MapEntry(
                                                  index,
                                                  word +
                                                      ((index + 1) % 5 == 0
                                                          ? '\n'
                                                          : ' '),
                                                ),
                                              )
                                              .values
                                              .join(),
                                          maxLines: 2,
                                          style: largText,
                                        ),
                                      ),
                                    ),
                                  ),
                                  http != null
                                      ? SizedBox(
                                          height: 10,
                                        )
                                      : SizedBox(
                                          height: 0,
                                        ),
                                  http != null
                                      ? Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            'Weblinks:',
                                            style: smallText,
                                          ),
                                        )
                                      : Container(),
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    alignment: Alignment.centerLeft,
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        color: _searchText.isNotEmpty &&
                                                isCategoryMatched
                                            ? Colors.red.withOpacity(0.08)
                                            : null,
                                        child: GestureDetector(
                                          onTap: () {
                                            _launchPdfUrl(
                                                http);
                                            print("object ................");
                                          },
                                          child: Text(
                                            http ??
                                                ""
                                                    .split(' ')
                                                    .where((element) =>
                                                        (element).isNotEmpty)
                                                    .toList()
                                                    .asMap()
                                                    .map(
                                                      (index, word) => MapEntry(
                                                        index,
                                                        word +
                                                            ((index + 1) % 5 ==
                                                                    0
                                                                ? '\n'
                                                                : ' '),
                                                      ),
                                                    )
                                                    .values
                                                    .join(),
                                            maxLines: 2,
                                            style: GoogleFonts.getFont(
                                              'Nunito',
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xff65B5FF),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  http != null
                                      ? SizedBox(
                                          height: 10,
                                        )
                                      : SizedBox(
                                          height: 0,
                                        ),
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Address:',
                                      style: smallText,
                                    ),
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    alignment: Alignment.centerLeft,
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Container(
                                        color: _searchText.isNotEmpty &&
                                                isAddressMatched
                                            ? Colors.red.withOpacity(0.08)
                                            : null,
                                        child: GestureDetector(
                                          onTap: () {
                                            Get.to(MapPicker(latLng: latLng));
                                          },
                                          child: Text(
                                            address
                                                .split(' ')
                                                .where((element) =>
                                                    (element).isNotEmpty)
                                                .toList()
                                                .asMap()
                                                .map(
                                                  (index, word) => MapEntry(
                                                    index,
                                                    word +
                                                        ((index + 1) % 5 == 0
                                                            ? '\n'
                                                            : ' '),
                                                  ),
                                                )
                                                .values
                                                .join(),
                                            maxLines: 5,
                                            style: largText,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Divider(
                                    thickness: 2,
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
