import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';

class DatabaseServices {
  //Collection

  //Metode Read
  static Future<Map?> readData(String CollectionName) async {
    try {
      List data = [];
      List id = [];
      Map mapData = {};
      await FirebaseFirestore.instance.collection(CollectionName).get().then(
        (QuerySnapshot) {
          for (var element in QuerySnapshot.docs) {
            data.add(element.data());
            id.add(element.id);
          }

          mapData['data'] = data;
          mapData['id'] = id;
        },
      );
      return mapData;
    } catch (e) {
      print(e);
      return null;
    }
  }

  static Future<Map?> readDataWithCondition(String CollectionName, String key, String value) async {
    try {
      List data = [];
      List id = [];
      Map mapData = {};
      await FirebaseFirestore.instance.collection(CollectionName).where(key, isEqualTo: value).get().then((QuerySnapshot) {
        for (var element in QuerySnapshot.docs) {
          data.add(element.data());
          id.add(element.id);
        }
        mapData['data'] = data;
        mapData['id'] = id;
      });
      return mapData;
    } catch (e) {
      print(e);
      return null;
    }
  }

  static Future<Map?> readDataWithDateRange(String CollectionName, DateTime date) async {
    try {
      List data = [];
      List id = [];
      Map mapData = {};
      await FirebaseFirestore.instance.collection(CollectionName).where('transactionDate', isGreaterThanOrEqualTo: DateFormat('yyyy-MM-dd').format(date.subtract(Duration(days: 6)))).where('transactionDate', isLessThanOrEqualTo: DateFormat('yyyy-MM-dd').format(date)).get().then((QuerySnapshot) {
        for (var element in QuerySnapshot.docs) {
          data.add(element.data());
          id.add(element.id);
        }
        mapData['data'] = data;
        mapData['id'] = id;
      });
      return mapData;
    } catch (e) {
      print(e);
      return null;
    }
  }

  static Future<Map?> readDataWithTwoDateRange(String CollectionName, String key1, var value1, String key2, var value2) async {
    try {
      List data = [];
      List id = [];
      Map mapData = {};
      await FirebaseFirestore.instance.collection(CollectionName).where(key1, isLessThanOrEqualTo: value1).where(key2, isGreaterThanOrEqualTo: value2).get().then((QuerySnapshot) {
        for (var element in QuerySnapshot.docs) {
          data.add(element.data());
          id.add(element.id);
        }
        mapData['data'] = data;
        mapData['id'] = id;
      });
      return mapData;
    } catch (e) {
      print(e);
      return null;
    }
  }

  // static Future<Map?> readDataWithTwoDateRangeAndOneCond(String CollectionName, String key1, var value1, String key2, var value2, String key3, var value3) async {
  //   try {
  //     List data = [];
  //     List id = [];
  //     Map mapData = {};
  //     await FirebaseFirestore.instance.collection(CollectionName).where(key1, isLessThanOrEqualTo: value1).where(key2, isGreaterThanOrEqualTo: value2).where(key3, isEqualTo: value3).get().then((QuerySnapshot) {
  //       for (var element in QuerySnapshot.docs) {
  //         data.add(element.data());
  //         id.add(element.id);
  //       }
  //       mapData['data'] = data;
  //       mapData['id'] = id;
  //     });
  //     return mapData;
  //   } catch (e) {
  //     print(e);
  //     return null;
  //   }
  // }

  static Future<List<String>?> readDataOnceShowWithTwoCondDateTime(String collectionName, String columnName, String key1, var value1, String key2, var value2) async {
    try {
      Set<String> data = {};
      List<String> listData = [];

      await FirebaseFirestore.instance.collection(collectionName).where(key1, isLessThanOrEqualTo: value1).where(key2, isGreaterThanOrEqualTo: value2).get().then(
        (querySnapshot) {
          for (var element in querySnapshot.docs) {
            print(element);
            data.add((element.data()[columnName]).toString());
          }
          data.forEach((element) {
            listData.add(element);
          });
        },
      );
      return listData;
    } catch (e) {
      print(e);
      return null;
    }
  }

  static Future<Map?> readOneData(String collectionName, String docId) async {
    try {
      Map mapData = {};

      await FirebaseFirestore.instance.collection(collectionName).doc(docId).get().then((QuerySnapshot) {
        mapData['data'] = QuerySnapshot.data();
        mapData['id'] = QuerySnapshot.id;
      });
      return mapData;
    } catch (e) {
      return null;
    }
  }

  static Future<List<String>?> readDataOnceShowWithOneCond(String collectionName, String columnName, String key, String value) async {
    try {
      Set<String> data = {};
      List<String> listData = [];
      await FirebaseFirestore.instance.collection(collectionName).where(key, isEqualTo: value).get().then(
        (querySnapshot) {
          for (var element in querySnapshot.docs) {
            data.add((element.data()[columnName]).toString());
          }
          data.forEach((element) {
            listData.add(element);
          });
        },
      );
      return listData;
    } catch (e) {
      print(e);
      return null;
    }
  }

  static Future<List<String>?> readDataOnceShowWithTwoCond(String collectionName, String columnName, String key1, String value1, String key2, String value2) async {
    try {
      Set<String> data = {};
      List<String> listData = [];
      await FirebaseFirestore.instance.collection(collectionName).where(key1, isEqualTo: value1).where(key2, isEqualTo: value2).get().then(
        (querySnapshot) {
          for (var element in querySnapshot.docs) {
            data.add((element.data()[columnName]).toString());
          }
          data.forEach((element) {
            listData.add(element);
          });
        },
      );
      return listData;
    } catch (e) {
      print(e);
      return null;
    }
  }

  static Future<Map?> uploadImage(File imageFile, String location, String uuid) async {
    try {
      Map img = {};
      String url = '';
      String lokasi = '$location/$uuid';
      Reference ref = FirebaseStorage.instance.ref().child(lokasi);
      UploadTask task = ref.putFile(imageFile);

      await task.whenComplete(
        () async {
          url = await ref.getDownloadURL();
        },
      );
      img['uuid'] = uuid;
      img['url'] = url;

      return img;
    } catch (e) {
      return null;
    }
  }

  static Future<void> createDataWithDocId(String collectionName, String docId, Map<String, String> input) async {
    await FirebaseFirestore.instance.collection(collectionName).doc(docId).set(input);
  }

  static Future<void> updateDataWithDocId(String collectionName, String docId, Map<String, String> input) async {
    await FirebaseFirestore.instance.collection(collectionName).doc(docId).update(input);
  }

  // static Future<void> updateDataWithCondition(String collectionName, String key, String value ,Map<String, String> input) async {
  //   await FirebaseFirestore.instance.collection(collectionName).where(key, isEqualTo: value).update(input);
  // }

  static Future<void> deleteDataFirestore(String collectionName, String docId) async {
    await FirebaseFirestore.instance.collection(collectionName).doc(docId).delete();
  }

  static Future<void> deleteDataFirestoreWithCond(String collectionName, String docId) async {
    await FirebaseFirestore.instance.collection(collectionName).doc(docId).delete();
  }

  static Future<void> deleteDataStorage(String lokasi, String uuid) async {
    await FirebaseStorage.instance.ref().child("$lokasi/$uuid").delete();
  }

  // static Future<void> deleteDataTemp() async {
  //   await FirebaseStorage.instance.ref().child("temp/").delete();
  // }
}
