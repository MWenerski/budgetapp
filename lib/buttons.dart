import 'package:flutter/material.dart';
import 'main.dart';
class Buttons {
  static Widget homeButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Home()), 
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF283B41), // Change to your desired button color
      ),
      child: Container(
        height: 72.0,
        width: 112.0,
        decoration: BoxDecoration(
          color: Color(0xFF283B41), // Change to your desired button color
          borderRadius: BorderRadius.circular(8.0), // Optional: Rounded corners
        ),
        child: Center(
          child: Image.asset(
            'assets/house-black-silhouette-without-door.png', // Replace with the actual path to your PNG image
            height: 40.0, // Adjust the image size as needed
            width: 40.0,
          ),
        ),
      ),
    );
  }
}