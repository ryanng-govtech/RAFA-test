import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';

import 'contants.dart';

class MyUploadPage extends StatefulWidget {
  MyUploadPage({Key? key}) : super(key: key);

  @override
  MyUploadPageState createState() => MyUploadPageState();
}

class MyUploadPageState extends State<MyUploadPage> {
  List<XFile> imageFileList = [];

  dynamic _pickImageError;
  bool isVideo = false;
  bool isReachLimit10 = false;
  bool isFailedFileCheck = false;

  String? _retrieveDataError;

  final ImagePicker _picker = ImagePicker();
  final int fiveMb = 5 * 1024 * 1024;

  //Instantiate empty MimeTypeResolver, initialise in init  method
  MimeTypeResolver mimeTypeResolver = MimeTypeResolver.empty();

  void _onImageButtonPressed(ImageSource source,
      {BuildContext? context}) async {
    if (source == ImageSource.camera) {
      try {
        XFile? pickedFile = await _picker.pickImage(
          source: source,
          maxWidth: 500,
          maxHeight: 300,
        );
        if (pickedFile != null && await pickedFile.length() <= fiveMb) {
          Stream<Uint8List> fileBytes =
              pickedFile.openRead(0, mimeTypeResolver.magicNumbersMaxLength);
          List<int> headerBytes = await fileBytes.single;
          if (mimeTypeResolver.lookup(pickedFile.path,
                  headerBytes: headerBytes) !=
              null) {
            // print("Passed file check.");
            setState(() {
              isFailedFileCheck = false;
              imageFileList.add(pickedFile);
            });
          } else {
            setState(() {
              isFailedFileCheck = true;
            });
          }
        }
      } catch (e) {
        print(e);
        setState(() {
          _pickImageError = e;
        });
      }
    } else {
      try {
        final pickedFileList = await _picker.pickMultiImage(
          maxWidth: 500,
          maxHeight: 300,
          //imageQuality: quality,
        );
        isFailedFileCheck = false;
        if (pickedFileList != null) {
          int count = imageFileList.length;
          for (int i = 0; i < 10 - count; i++) {
            if (await pickedFileList[i].length() <= fiveMb) {
              Stream<Uint8List> fileBytes = pickedFileList[i]
                  .openRead(0, mimeTypeResolver.magicNumbersMaxLength);
              List<int> headerBytes = await fileBytes.single;
              if (mimeTypeResolver.lookup(pickedFileList[i].path,
                      headerBytes: headerBytes) !=
                  null) {
                isFailedFileCheck = false;
                imageFileList.add(pickedFileList[i]);
              } else {
                isFailedFileCheck = true;
              }
            }
          }
          setState(() {
            imageFileList;
            isFailedFileCheck;
            if ((pickedFileList.length + count) > 10) {
              isReachLimit10 = true;
            }
          });
        }
      } catch (e) {
        setState(() {
          _pickImageError = e;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();

    //initialise MimeTypeResolver magic bytes to be checked
    mimeTypeResolver.addMagicNumber([0xFF, 0xD8], 'image/jpg');
    mimeTypeResolver.addMagicNumber([0xFF, 0xD8], 'image/jpeg');
    mimeTypeResolver
        .addMagicNumber([0x47, 0x49, 0x46, 0x38, 0x37, 0x61], 'image/gif');
    mimeTypeResolver
        .addMagicNumber([0x47, 0x49, 0x46, 0x38, 0x39, 0x61], 'image/gif');
    mimeTypeResolver.addMagicNumber(
        [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A], 'image/png');
    mimeTypeResolver.addMagicNumber([0x42, 0x4D], 'image/bmp');
    // mimeTypeResolver.addMagicNumber([0x00, 0x00, 0x00], 'image/heic');
  }

  Widget previewImages() {
    ScrollController imageScrollController = ScrollController();
    return Column(
      children: [
        Text(
            "Please upload images. Maximum file size for each file is 5MB. Allowed file types: JPEG, GIF, PNG, BMP."),
        Visibility(
          child: Align(
            alignment: Alignment.center,
            child: Text(
              "Maximum of 10 images allowed.",
              style: TextStyle(color: kRed),
            ),
          ),
          visible: isReachLimit10,
        ),
        Visibility(
          child: Align(
            alignment: Alignment.center,
            child: Text(
              "Invalid file type.",
              style: TextStyle(color: kRed),
            ),
          ),
          visible: isFailedFileCheck,
        ),
        SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: OverflowBar(
            spacing: 8,
            overflowSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  isVideo = false;
                  if (imageFileList.length < 10) {
                    _onImageButtonPressed(ImageSource.camera, context: context);
                  } else {
                    setState(() {
                      isReachLimit10 = true;
                    });
                  }
                },
                icon: Icon(Icons.camera_alt),
                label: Text("Capture Image"),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: kElectricBlue),
                  padding: EdgeInsets.all(20),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  if (imageFileList.length < 10) {
                    _onImageButtonPressed(
                      ImageSource.gallery,
                      context: context,
                    );
                  } else {
                    setState(() {
                      isReachLimit10 = true;
                    });
                  }
                },
                icon: Icon(Icons.file_upload),
                label: Text("Upload Image"),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: kElectricBlue),
                  padding: EdgeInsets.all(20),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        Container(
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(color: Colors.grey[200]),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Scrollbar(
              controller: imageScrollController,
              child: GridView.builder(
                controller: imageScrollController,
                physics: ScrollPhysics(),
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  crossAxisSpacing: 20,
                  maxCrossAxisExtent: 150,
                ),
                itemCount: imageFileList.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (_) {
                            return _buildImageDialog(context, index);
                          });
                    },
                    child: Center(
                        child: DottedBorder(
                            child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      child: Stack(
                          alignment: AlignmentDirectional.center,
                          children: [
                            Image.file(File(imageFileList[index].path)),
                            Positioned(
                              top: -7,
                              right: -7,
                              child: IconButton(
                                splashRadius: 5,
                                icon: Icon(Icons.close),
                                onPressed: () {
                                  setState(() {
                                    imageFileList.removeAt(index);
                                    isReachLimit10 = false;
                                  });
                                },
                              ),
                            )
                          ]),
                    ))),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget handlePreview() {
    return previewImages();
  }

  @override
  Widget build(BuildContext context) {
    //final test1 = ModalRoute.of(context)!.settings.arguments as List;
    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          handlePreview(),
        ]);
  }

  Text? _getRetrieveErrorWidget() {
    if (_retrieveDataError != null) {
      final Text result = Text(_retrieveDataError!);
      _retrieveDataError = null;
      return result;
    }
    return null;
  }

  Widget _buildImageDialog(BuildContext context, int index) {
    return Dialog(
        child: Stack(
      children: [
        Image.file(File(imageFileList[index].path)),
        Positioned(
            child: IconButton(
                splashRadius: 5,
                icon: Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
            top: -7,
            right: -7),
      ],
    ));
  }
}
