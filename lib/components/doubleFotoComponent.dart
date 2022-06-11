import 'package:flutter/material.dart';

class DoublePhotoComponent extends StatelessWidget {
  final String photoUrl;
  final String? secondaryPhotoUrl;

  const DoublePhotoComponent(
      {required this.photoUrl, this.secondaryPhotoUrl, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: FadeInImage.assetNetwork(
            image: photoUrl,
            imageErrorBuilder: (_, __, ___) {
              return CircleAvatar(
                  radius: size.width * 0.35 / 2,
                  child: Icon(
                    Icons.image_not_supported_rounded,
                    size: size.width * 0.35 / 2,
                  ));
            },
            width: size.width,
            height: size.width,
            alignment: Alignment.center,
            fit: BoxFit.cover,
            placeholder: "assets/loader.gif",
          ),
        ),
        // This 'if' wraps all the ClipRRect showing next
        if (secondaryPhotoUrl != null)
          Transform.translate(
            offset: Offset(size.width * 0.2, size.height * 0.07),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: FadeInImage.assetNetwork(
                image: secondaryPhotoUrl!,
                imageErrorBuilder: (_, __, ___) {
                  return CircleAvatar(
                    radius: size.width * 0.15 / 2,
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.grey,
                    child: const Icon(Icons.image_not_supported_rounded),
                  );
                },
                alignment: Alignment.center,
                width: size.width * 0.15,
                height: size.width * 0.15,
                fit: BoxFit.cover,
                placeholder: "assets/loader.gif",
              ),
            ),
          ),
      ],
    );
  }
}
