import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:aplikasispeechtotext/services/dataServices.dart';
import 'package:aplikasispeechtotext/services/dbServices.dart';
import 'package:aplikasispeechtotext/services/messageServices.dart';
import 'package:sizer/sizer.dart';

class userWidget extends StatefulWidget {
  const userWidget({super.key});

  @override
  State<userWidget> createState() => _userWidgetState();
}

class _userWidgetState extends State<userWidget> {
  TextEditingController nama = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController username = TextEditingController();

  String selectedStatus = '';

  String cari = '';
  List<DocumentSnapshot> documents = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.cyan,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(30),
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 5.sp, horizontal: 15.sp),
                child: Text(
                  'Menu Pengguna',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 5.sp),
                      child: TextFormField(
                        onChanged: (value) {
                          setState(() {
                            cari = value;
                          });
                        },
                        obscureText: false,
                        decoration: InputDecoration(
                            labelStyle: TextStyle(color: Colors.cyan, fontSize: 9.sp),
                            labelText: 'Cari',
                            prefixIconColor: Colors.cyan,
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              size: 12.sp,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.orangeAccent,
                                width: 2,
                              ),
                            ),
                            contentPadding: EdgeInsetsDirectional.fromSTEB(8.sp, 8.sp, 8.sp, 8.sp)),
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: StreamBuilder(
                        stream: FirebaseFirestore.instance.collection('pengguna').snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            documents = snapshot.data!.docs;

                            if (cari.length > 0) {
                              documents = snapshot.data!.docs.where((element) {
                                return element.get('nama').toString().toLowerCase().contains(cari.toLowerCase());
                              }).toList();
                            }

                            return ListView.builder(
                              itemCount: documents.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () async {
                                    nama.text = documents[index]['nama'];
                                    password.text = documents[index]['password'];
                                    username.text = documents[index].reference.id;
                                    selectedStatus = documents[index]['status'];

                                    await showModalBottomSheet(
                                      context: context,
                                      builder: (context) {
                                        return Container(
                                          child: ListView(
                                            children: [
                                              SizedBox(
                                                height: 30.sp,
                                              ),
                                              Padding(
                                                padding: EdgeInsets.symmetric(vertical: 5.sp, horizontal: 15.sp),
                                                child: Container(
                                                  width: double.infinity,
                                                  child: TextFormField(
                                                    controller: username,
                                                    enabled: false,
                                                    readOnly: true,
                                                    obscureText: false,
                                                    decoration: InputDecoration(
                                                      labelText: 'Username',
                                                      labelStyle: TextStyle(
                                                        color: Colors.cyan,
                                                        fontSize: 10.sp,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                      enabledBorder: OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: Colors.grey,
                                                          width: 2,
                                                        ),
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                      focusedBorder: OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: Colors.cyan,
                                                          width: 2,
                                                        ),
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                    ),
                                                    style: TextStyle(
                                                      fontSize: 10.sp,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                    keyboardType: TextInputType.text,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.symmetric(vertical: 5.sp, horizontal: 15.sp),
                                                child: Container(
                                                  width: double.infinity,
                                                  child: TextFormField(
                                                    controller: nama,
                                                    obscureText: false,
                                                    decoration: InputDecoration(
                                                      labelText: 'Nama Lengkap',
                                                      labelStyle: TextStyle(
                                                        color: Colors.cyan,
                                                        fontSize: 10.sp,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                      enabledBorder: OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: Colors.grey,
                                                          width: 2,
                                                        ),
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                      focusedBorder: OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: Colors.cyan,
                                                          width: 2,
                                                        ),
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                    ),
                                                    style: TextStyle(
                                                      fontSize: 10.sp,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                    keyboardType: TextInputType.text,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.symmetric(vertical: 5.sp, horizontal: 15.sp),
                                                child: Container(
                                                  width: double.infinity,
                                                  child: TextFormField(
                                                    controller: password,
                                                    obscureText: false,
                                                    decoration: InputDecoration(
                                                      labelText: 'Password',
                                                      labelStyle: TextStyle(
                                                        color: Colors.cyan,
                                                        fontSize: 10.sp,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                      enabledBorder: OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: Colors.grey,
                                                          width: 2,
                                                        ),
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                      focusedBorder: OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: Colors.cyan,
                                                          width: 2,
                                                        ),
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                    ),
                                                    style: TextStyle(
                                                      fontSize: 10.sp,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                    keyboardType: TextInputType.text,
                                                  ),
                                                ),
                                              ),
                                              StatefulBuilder(
                                                builder: (context, setState) {
                                                  return DropdownButton(
                                                    isExpanded: true,
                                                    padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 5.sp),
                                                    value: selectedStatus,
                                                    onChanged: (String? Value) {
                                                      setState(() {
                                                        selectedStatus = Value!;
                                                      });
                                                    },
                                                    items: [
                                                      DropdownMenuItem(
                                                        child: Text(
                                                          'Kasir',
                                                          style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.bold, color: Colors.cyan),
                                                        ),
                                                        value: 'kasir',
                                                      ),
                                                      DropdownMenuItem(
                                                        child: Text(
                                                          'Administrator',
                                                          style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.bold, color: Colors.cyan),
                                                        ),
                                                        value: 'admin',
                                                      ),
                                                    ],
                                                  );
                                                },
                                              ),
                                              Padding(
                                                padding: EdgeInsets.symmetric(vertical: 5.sp, horizontal: 15.sp),
                                                child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan),
                                                  onPressed: () async {
                                                    String docId = documents[index].id;
                                                    Map<String, String> input = {};

                                                    if (nama.text != '' && password.text != '') {
                                                      input['nama'] = nama.text;
                                                      input['password'] = password.text;
                                                      input['status'] = selectedStatus;

                                                      try {
                                                        await DatabaseServices.updateDataWithDocId('pengguna', docId, input);
                                                        Navigator.of(context).pop();
                                                        await MessageService.showSnackBar(context, 'Berhasil diubah');
                                                      } catch (e) {
                                                        print(e);
                                                      }
                                                    } else {
                                                      await MessageService.showSnackBar(context, 'Data tidak boleh kosong');
                                                    }
                                                  },
                                                  child: Text('Ubah Data Pengguna'),
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 15.sp),
                                                child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                                  onPressed: () async {
                                                    String docId = documents[index].id;

                                                    try {
                                                      await DatabaseServices.deleteDataFirestore('pengguna', docId);
                                                      Navigator.of(context).pop();
                                                      await MessageService.showSnackBar(context, 'Berhasil dihapus');
                                                    } catch (e) {
                                                      print(e);
                                                    }
                                                  },
                                                  child: Text('Hapus Data Pengguna'),
                                                ),
                                              ),
                                              SizedBox(
                                                height: MediaQuery.viewInsetsOf(context).bottom,
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: Card(
                                    elevation: 5,
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.white,
                                        child: Image.asset('assets/icons/user.png'),
                                      ),
                                      title: Text('${documents[index]['nama']}'),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('Password'),
                                              Text('(Hidden Text)'),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('Status'),
                                              Text('${documents[index]['status'].toString().toUpperCase()}'),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          } else {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.cyan,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 5,
        child: Icon(Icons.add),
        onPressed: () async {
          nama.text = '';
          password.text = '';
          selectedStatus = 'kasir';
          username.text = '';

          await showModalBottomSheet(
            context: context,
            builder: (context) {
              return Container(
                child: ListView(
                  children: [
                    SizedBox(
                      height: 30.sp,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 5.sp, horizontal: 15.sp),
                      child: Container(
                        width: double.infinity,
                        child: TextFormField(
                          controller: username,
                          obscureText: false,
                          decoration: InputDecoration(
                            labelText: 'Username',
                            labelStyle: TextStyle(
                              color: Colors.cyan,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.cyan,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          keyboardType: TextInputType.text,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 5.sp, horizontal: 15.sp),
                      child: Container(
                        width: double.infinity,
                        child: TextFormField(
                          controller: nama,
                          obscureText: false,
                          decoration: InputDecoration(
                            labelText: 'Nama Pengguna',
                            labelStyle: TextStyle(
                              color: Colors.cyan,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.cyan,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          keyboardType: TextInputType.text,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 5.sp, horizontal: 15.sp),
                      child: Container(
                        width: double.infinity,
                        child: TextFormField(
                          controller: password,
                          obscureText: false,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: TextStyle(
                              color: Colors.cyan,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.cyan,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          keyboardType: TextInputType.text,
                        ),
                      ),
                    ),
                    StatefulBuilder(
                      builder: (context, setState) {
                        return DropdownButton(
                          isExpanded: true,
                          padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 5.sp),
                          value: selectedStatus,
                          onChanged: (String? Value) {
                            setState(() {
                              selectedStatus = Value!;
                            });
                          },
                          items: [
                            DropdownMenuItem(
                              child: Text(
                                'Kasir',
                                style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.bold, color: Colors.cyan),
                              ),
                              value: 'kasir',
                            ),
                            DropdownMenuItem(
                              child: Text(
                                'Administrator',
                                style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.bold, color: Colors.cyan),
                              ),
                              value: 'admin',
                            ),
                          ],
                        );
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 5.sp, horizontal: 15.sp),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan),
                        onPressed: () async {
                          Map<String, String> input = {};

                          if (nama.text != '' && password.text != '') {
                            input['nama'] = nama.text;
                            input['password'] = password.text;
                            input['status'] = selectedStatus;

                            try {
                              await DatabaseServices.createDataWithDocId('pengguna', username.text, input);
                              Navigator.of(context).pop();
                              await MessageService.showSnackBar(context, 'Berhasil ditambah');
                            } catch (e) {
                              print(e);
                            }
                          } else {
                            await MessageService.showSnackBar(context, 'Data tidak boleh kosong');
                          }
                        },
                        child: Text('Tambah Data Pengguna'),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.viewInsetsOf(context).bottom,
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
