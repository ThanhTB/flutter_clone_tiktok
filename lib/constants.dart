import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:tiktok_clone/controllers/auth_controller.dart';
import 'package:tiktok_clone/views/screen/add_vide_screen.dart';
import 'package:tiktok_clone/views/screen/profile_screen.dart';
import 'package:tiktok_clone/views/screen/search_screen.dart';
import 'package:tiktok_clone/views/screen/video_screen.dart';

// PAGES
List pages = [
  VideoScreen(),
  SearchScreen(),
  const AddVideoScreen(),
  Text('Messages Screen'),
  ProfileScreen(uid: authController.user.uid),
];

// COLOR
const backgroundColor = Colors.black;
const buttonColor = Colors.red;
const borderColor = Colors.grey;

// FIREBASE
var firebaseAuth = FirebaseAuth.instance;
var firebaseStorage = FirebaseStorage.instance;
var firestore = FirebaseFirestore.instance;

// CONTROLLERS
var authController = AuthController.instance;
