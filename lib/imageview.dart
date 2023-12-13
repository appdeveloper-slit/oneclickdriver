import 'dart:io';

import 'package:flutter/material.dart';
import 'package:oneclick_driver/values/dimens.dart';

class Imageview extends StatefulWidget {
  final fileimage, urlimage;

  const Imageview({super.key, this.fileimage, this.urlimage});

  @override
  State<Imageview> createState() => _ImageviewState();
}

class _ImageviewState extends State<Imageview> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: Dim().d350,
        width: double.infinity,
        child: widget.fileimage == null
            ? Image.network(widget.urlimage, fit: BoxFit.cover)
            : Image.file(File(widget.fileimage), fit: BoxFit.cover),
      ),
    );
  }
}
