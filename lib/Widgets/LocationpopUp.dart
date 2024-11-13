import 'package:flutter/material.dart';

class LocationPopup extends StatelessWidget {
  final String title;
  

  const LocationPopup(
      {Key? key, required this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
    
      
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(7.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 13,fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            
          ],
        ),
      ),
    );
  }
}
