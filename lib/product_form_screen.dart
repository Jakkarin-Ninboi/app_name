// product_form_screen.dart
import 'package:flutter/material.dart';
import 'apiPro_service.dart';

class ProductFormScreen extends StatefulWidget {
  final Map<String, dynamic>? product;

  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.product != null;

    _nameController = TextEditingController(text: _isEditMode ? widget.product!['name'] : '');
    _descriptionController = TextEditingController(text: _isEditMode ? widget.product!['description'] : '');
    _priceController = TextEditingController(text: _isEditMode ? widget.product!['price'].toString() : '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _saveProduct() async {
    // Logic การบันทึกข้อมูลยังคงเหมือนเดิม
    if (_formKey.currentState!.validate()) {
      final productData = {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'price': double.tryParse(_priceController.text) ?? 0.0,
      };

      try {
        if (_isEditMode) {
          final productId = widget.product!['id'].toString();
          await ApiService.updateProduct(productId, productData);
        } else {
          await ApiService.createProduct(productData);
        }

        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('บันทึกข้อมูล${_isEditMode ? 'แก้ไข' : 'ใหม่'}สำเร็จ'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('เกิดข้อผิดพลาดในการบันทึก: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // ⭐⭐ จุดที่แก้ไขทั้งหมดจะอยู่ใน Widget build(BuildContext context) ⭐⭐
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // ทำให้ body ขยายไปด้านหลัง AppBar
      appBar: AppBar(
        title: Text(
          _isEditMode ? 'แก้ไขข้อมูลสินค้า' : 'เพิ่มสินค้าใหม่',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent, // AppBar โปร่งใส
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // ⭐ ส่วนที่ 1: พื้นหลังไล่สีและก้อนเมฆ
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
          Positioned(
            bottom: -50,
            left: -50,
            child: Icon(Icons.cloud, size: 200, color: Colors.white.withOpacity(0.15)),
          ),
          Positioned(
            top: 150,
            right: -60,
            child: Icon(Icons.cloud_queue, size: 250, color: Colors.white.withOpacity(0.1)),
          ),

          // ⭐ ส่วนที่ 2: เนื้อหาฟอร์ม
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildTextFormField(
                          controller: _nameController,
                          labelText: 'ชื่อสินค้า',
                          icon: Icons.shopping_bag_outlined,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'กรุณากรอกชื่อสินค้า';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextFormField(
                          controller: _descriptionController,
                          labelText: 'รายละเอียด',
                          icon: Icons.description_outlined,
                           validator: (value) {
                            if (value == null || value.isEmpty) return 'กรุณากรอกรายละเอียดสินค้า';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextFormField(
                          controller: _priceController,
                          labelText: 'ราคา',
                          icon: Icons.price_change_outlined,
                          keyboardType: TextInputType.number,
                           validator: (value) {
                            if (value == null || value.isEmpty) return 'กรุณากรอกราคา';
                            if (double.tryParse(value) == null) return 'กรุณากรอกราคาเป็นตัวเลข';
                            return null;
                          },
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton.icon(
                          onPressed: _saveProduct,
                          icon: const Icon(Icons.save_alt_outlined, color: Colors.white),
                          label: const Text('บันทึกข้อมูล', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ⭐ ฟังก์ชันช่วยสร้าง TextFormField เพื่อให้โค้ดสะอาดและนำกลับมาใช้ใหม่ได้
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon, color: Colors.blue.shade800),
        filled: true,
        fillColor: Colors.blue.shade50.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.blue.shade800, width: 2),
        ),
      ),
    );
  }
}
