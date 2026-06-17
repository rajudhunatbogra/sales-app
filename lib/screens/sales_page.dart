import 'package:flutter/material.dart';
import 'package:sales_app/models/jewelry_item.dart';
import 'package:sales_app/models/memo_model.dart';
import 'package:sales_app/database/database_helper.dart';
import 'package:sales_app/services/storage_service.dart';
import 'package:sales_app/services/calculator_service.dart';

class SalesPage extends StatefulWidget {
  const SalesPage({super.key});

  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  final _formKey = GlobalKey<FormState>();
  final _memoNoController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _discountController = TextEditingController();
  final _paidController = TextEditingController();

  final List<JewelryItem> _items = [];
  double _subTotal = 0.0;
  double _grandTotal = 0.0;
  double _dueAmount = 0.0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _memoNoController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _discountController.dispose();
    _paidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sales Page')),
      body: const Center(child: Text('Sales App Content')),
    );
  }
}

