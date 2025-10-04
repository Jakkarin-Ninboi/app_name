// product_list_screen.dart
import 'dart:ui'; // Import สำหรับ ImageFilter
import 'package:flutter/material.dart';
import 'apiPro_service.dart';
import 'product_form_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late Future<List<dynamic>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _refreshProducts();
  }

  void _refreshProducts() {
    setState(() {
      _productsFuture = ApiService.fetchProducts();
    });
  }

  // โค้ดส่วน _navigateToAddScreen, _navigateToEditScreen, _deleteProduct
  // ยังคงเหมือนเดิมทุกประการ ไม่มีการเปลี่ยนแปลง
  void _navigateToAddScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProductFormScreen()),
    );
    _refreshProducts();
  }

  void _navigateToEditScreen(Map<String, dynamic> product) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ProductFormScreen(product: product)),
    );
    _refreshProducts();
  }

  void _deleteProduct(String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ยืนยันการลบ'),
          content: const Text('คุณต้องการลบสินค้านี้ใช่หรือไม่?'),
          actions: <Widget>[
            TextButton(
              child: const Text('ยกเลิก'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('ลบ', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                try {
                  Navigator.of(context).pop();
                  await ApiService.deleteProduct(id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('ลบสินค้าสำเร็จ'),
                        backgroundColor: Colors.green),
                  );
                  _refreshProducts();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('เกิดข้อผิดพลาด: $e'),
                        backgroundColor: Colors.red),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ทำให้ AppBar โปร่งใสเพื่อให้เห็นพื้นหลัง
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent, // โปร่งใส
        elevation: 0, // ไม่มีเงา
      ),
      body: Stack(
        children: [
          // ⭐ ส่วนที่ 1: พื้นหลังไล่สี (อยู่ชั้นล่างสุด)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue.shade800,
                  Colors.lightBlue.shade300,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // ⭐ ส่วนที่ 2: ก้อนเมฆตกแต่ง (อยู่ชั้นกลาง)
          Positioned(
            top: 100,
            left: -40,
            child: Icon(Icons.cloud, size: 120, color: Colors.white.withOpacity(0.2)),
          ),
          Positioned(
            top: 250,
            right: -30,
            child: Icon(Icons.cloud_queue, size: 150, color: Colors.white.withOpacity(0.15)),
          ),
          Positioned(
            bottom: 50,
            left: 20,
            child: Icon(Icons.cloud_circle, size: 80, color: Colors.white.withOpacity(0.25)),
          ),

          // ⭐ ส่วนที่ 3: เนื้อหาหลัก (อยู่ชั้นบนสุด)
          SafeArea(
            child: Column(
              children: [
                // ⭐ กรอบหัวข้อ "รายการสินค้า" ที่ตกแต่งแล้ว
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                  margin: const EdgeInsets.only(top: 16, bottom: 16, left: 20, right: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Text(
                    'รายการสินค้า',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                ),

                // ⭐ ใช้ Expanded เพื่อให้ ListView ขยายเต็มพื้นที่ที่เหลือ
                Expanded(
                  child: FutureBuilder<List<dynamic>>(
                    future: _productsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: Colors.white));
                      }
                      // ... (โค้ดใน FutureBuilder เหมือนเดิม) ...
                      if (snapshot.hasError) {
                        return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}', style: const TextStyle(color: Colors.white, fontSize: 16)));
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('ไม่มีข้อมูลสินค้า', style: TextStyle(color: Colors.white, fontSize: 16)));
                      }

                      final products = snapshot.data!;
                      return RefreshIndicator(
                        onRefresh: () async => _refreshProducts(),
                        child: ListView.builder(
                          padding: const EdgeInsets.only(top: 8), // เพิ่มช่องว่างด้านบน
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            final product = products[index];
                            final productId = product['id']?.toString() ?? '';
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              elevation: 5,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                title: Text(product['name'] ?? 'ไม่มีชื่อ', style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('ราคา: ${product['price'] ?? 'N/A'} บาท'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blueAccent),
                                      onPressed: () => _navigateToEditScreen(product),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                                      onPressed: () => _deleteProduct(productId),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
       floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddScreen,
        backgroundColor: Colors.white,
        child: Icon(Icons.add, color: Colors.blue.shade800),
      ),
    );
  }
}
