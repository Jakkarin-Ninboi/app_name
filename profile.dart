import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8F7CEC),
      body: Center(
        child: Container(
          width: 350,
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 24,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top row: back arrow, heart, menu
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.arrow_back, color: Colors.black54),
                  Row(
                    children: [
                      Icon(Icons.favorite_border, color: Colors.black54),
                      SizedBox(width: 16),
                      Icon(Icons.more_vert, color: Colors.black54),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 16),
              CircleAvatar(
                radius: 48,
                backgroundImage: AssetImage('assets/faceProfile.jpg'),
              ),
              SizedBox(height: 16),
              Text(
                'จักรินทร์ นิลบ่อ',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '660710182 คณะวิทยาศาสตร์ สาขาวิทยาการข้อมูล',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 1.5,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 8),
              Text(
                'ชอบในการเขียนโปรแกรมและชอบเล่นเกมเป็นประจำ',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF8F7CEC),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                ),
                onPressed: () {},
                child: Text('SHOW MORE'),
              ),
              SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSocialStatCircle(Icons.facebook, 'Facebook'),
                  _buildSocialStatCircle(Icons.camera_alt, 'Instagram'),
                  _buildSocialStatCircle(Icons.chat, 'Line'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildSocialStatCircle(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Color(0xFF8F7CEC),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 32),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}