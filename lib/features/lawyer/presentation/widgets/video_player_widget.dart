import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jusconnect/shared/themes/light_theme.dart';

class VideoPlayerWidget extends StatelessWidget {
  final String? videoUrl;

  const VideoPlayerWidget({super.key, this.videoUrl});

  @override
  Widget build(BuildContext context) {
    if (videoUrl == null) {
      return _buildNoVideoPlaceholder();
    }

    return _buildVideoContainer();
  }

  Widget _buildNoVideoPlaceholder() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.videocam_off, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text(
            'Nenhum vídeo disponível',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoContainer() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.play_circle_outline,
                  size: 64,
                  color: AppColors.primaryColor,
                ),
                const SizedBox(height: 8),
                Text(
                  'Clique para reproduzir',
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
