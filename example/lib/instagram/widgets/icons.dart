import 'package:flutter/material.dart';

class CloseFriendsIcon extends StatelessWidget {
  const CloseFriendsIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24.0,
      height: 24.0,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.green,
      ),
      child: const Icon(
        Icons.star_rounded,
        size: 16.0,
        color: Colors.white,
      ),
    );
  }
}

class UserAvatarIcon extends StatelessWidget {
  const UserAvatarIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24.0,
      height: 24.0,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
      child: const Icon(
        Icons.person_rounded,
        size: 16.0,
        color: Colors.black,
      ),
    );
  }
}
