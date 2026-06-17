import 'package:flutter/material.dart';
import 'sales_page.dart';
import 'inventory_page.dart';
import 'memo_history_page.dart'; // নতুন মেমো ইতিহাস পেজ ইমপোর্ট করা হলো

class DashboardPage extends StatelessWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('জুয়েলারি POS ড্যাশবোর্ড', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.amber.shade900,
        centerTitle: true,
        elevation: 2,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.amber.shade50, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ওয়েলকাম ব্যানার
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.amber.shade800,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(color: Colors.amber.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4)),
                  ],
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('স্বাগতম, রাজু!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                    SizedBox(height: 5),
                    Text('আপনার জুয়েলারি ব্যবসার হিসাব এখন আরও সহজ ও নিখুঁত।', style: TextStyle(fontSize: 14, color: Colors.white90)),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              const Text('প্রধান মেনু:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 15),
              
              // মেনু গ্রিড ভিউ (এখন ৩টি বাটন করা হলো)
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildMenuCard(
                    context,
                    title: 'সেলস কাউন্টার\n(বিল/মেমো)',
                    icon: Icons.point_of_sale,
                    color: Colors.green.shade600,
                    page: const SalesPage(),
                  ),
                  _buildMenuCard(
                    context,
                    title: 'ইনভেন্টরি\n(স্টক এন্ট্রি)',
                    icon: Icons.inventory,
                    color: Colors.blue.shade700,
                    page: const InventoryPage(),
                  ),
                  _buildMenuCard(
                    context,
                    title: 'মেমো সার্চ\n(ইতিহাস ও খোঁজ)',
                    icon: Icons.manage_search,
                    color: Colors.purple.shade700,
                    page: const MemoHistoryPage(), // ৩ নম্বর বাটন কানেক্ট হলো
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, {required String title, required IconData icon, required Color color, required Widget page}) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.white,
            border: Border.all(color: color.withOpacity(0.2), width: 1.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: color.withOpacity(0.1),
                child: Icon(icon, size: 28, color: color),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87, height: 1.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
