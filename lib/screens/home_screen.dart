import 'package:flutter/material.dart';
import 'package:appquanao/screens/product_listscreen.dart';
import 'package:appquanao/screens/profile_screen.dart';
import 'package:appquanao/models/product.dart'; // Đảm bảo import đúng đường dẫn
import 'package:appquanao/screens/product_detail_screen.dart'; // Đảm bảo import đúng đường dẫn
import 'package:appquanao/screens/cart_screen.dart';
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController();
  int _currentBannerIndex = 0;

  List<String> bannerImages = [
    'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?ixlib=rb-4.0.3&auto=format&fit=crop&w=720&q=80',
    'https://images.unsplash.com/photo-1441986300917-64674bd600d8?ixlib=rb-4.0.3&auto=format&fit=crop&w=720&q=80',
    'https://images.unsplash.com/photo-1469334031218-e382a71b716b?ixlib=rb-4.0.3&auto=format&fit=crop|crop&w=720&q=80',
  ];

  // Dữ liệu sản phẩm mẫu (Product objects)
  List<Product> featuredProducts = [
    Product(
      id: 'p1',
      name: 'Áo sơ mi kẻ sọc cao cấp',
      imageUrl: 'https://encrypted-tbn1.gstatic.com/shopping?q=tbn:ANd9GcRXee-0t5n6APPak6cbmC1ctHqJnQWKNUwkAvP737s-UZfyc-yfQvIc9ZOnhCuYzaz_9OP1kWJBKw1a8GES8jqNfEdN9ZYEpygekD6CU57uaU9vA8JWXP7s2JEBOwInt4Tx-2NjXUuF&usqp=CAc',
      price: 450000,
      oldPrice: 500000,
      description: 'Áo sơ mi kẻ sọc với chất liệu cotton cao cấp, mềm mại và thoáng khí, mang lại phong cách lịch lãm và hiện đại. Phù hợp cho cả đi làm và đi chơi.',
      category: 'Áo Sơ mi',
      sizes: ['S', 'M', 'L', 'XL'],
      colors: ['Đen', 'Xanh', 'Đỏ'],
      rating: 4.5,
      reviewCount: 120,
    ),
    Product(
      id: 'p2',
      name: 'Áo Polo Basic Cotton',
      imageUrl: 'https://encrypted-tbn1.gstatic.com/shopping?q=tbn:ANd9GcT47tfmkV-00IOVi0FX6HFJZTQGASpGHXJ4I2pePkbJmTjfbrYnyTcE4GT3GLxIlCClfV2kre02Arb7YVUE7BU9XD75M1cFVjKHM_vA8bnce08n_qRc1RZmRV6wxDPimskvrWVPfVvG&usqp=CAc',
      price: 320000,
      description: 'Áo polo cơ bản được làm từ 100% cotton, thấm hút mồ hôi tốt, co giãn nhẹ, phù hợp cho mọi hoạt động hàng ngày.',
      category: 'Áo Polo',
      sizes: ['M', 'L', 'XL'],
      colors: ['Trắng', 'Đen', 'Xám'],
      rating: 4.2,
      reviewCount: 95, 
    ),
    Product(
      id: 'p3',
      name: 'Áo Thun Cotton Oversize',
      imageUrl: 'https://encrypted-tbn2.gstatic.com/shopping?q=tbn:ANd9GcSyKlFRjS8O7TO4e87wLPWEO_Rb8nfcVUilePcF59Kjl3kaj0S2niS74X6gJka1CtCN4JVI-TwwTAKPecDIplX2br5Pdy6-bnMHRXNGty2Ucou6LHdkoMOJyMk&usqp=CAc',
      price: 250000,
      oldPrice: 300000,
      description: 'Áo thun form rộng thoải mái, chất liệu cotton mềm mịn, mang lại vẻ ngoài năng động và cá tính.',
      category: 'Áo Thun',
      sizes: ['M', 'L', 'XL'],
      colors: ['Vàng', 'Xanh lá', 'Đen'],
      rating: 4.7,
      reviewCount: 150, 
    ),
    Product(
      id: 'p4',
      name: 'Quần Jean Slim Fit Co Giãn',
      imageUrl: 'data:image/jpeg;base64,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',
      price: 680000,
      description: 'Quần jean kiểu dáng slim fit, chất liệu denim co giãn tốt, ôm sát nhưng vẫn thoải mái khi vận động.',
      category: 'Quần Jean',
      sizes: ['28', '30', '32', '34'],
      colors: ['Xanh đậm', 'Xám'],
      rating: 4.3,
      reviewCount: 88, 
    ),
    Product(
      id: 'p5',
      name: 'Áo Hoodie Nỉ Bông',
      imageUrl: 'data:image/jpeg;base64,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',
      price: 520000,
      description: 'Áo hoodie chất liệu nỉ bông dày dặn, giữ ấm tốt, có mũ và túi kangaroo tiện lợi, phong cách đường phố.',
      category: 'Áo Khoác',
      sizes: ['M', 'L', 'XL'],
      colors: ['Đen', 'Xám', 'Đỏ'],
      rating: 4.6,
      reviewCount: 110, 
    ),
    Product(
      id: 'p6',
      name: 'Áo Blazer Kẻ Sọc',
      imageUrl: 'https://images.unsplash.com/photo-1616781498114-1e073c6b2b5a?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTQ4NzZ8MHwxfHNlYXJjaHwyMHx8Y2xvdGhpbmd8ZW58MHx8fHwxNzE4NzQ3ODc3fDA&ixlib=rb-4.0.3&q=80&w=1080',
      price: 890000,
      oldPrice: 1000000,
      description: 'Áo blazer kẻ sọc thời thượng, form dáng ôm vừa, thích hợp cho phong cách công sở hoặc dự tiệc.',
      category: 'Áo Khoác',
      sizes: ['S', 'M', 'L'],
      colors: ['Xám', 'Nâu'],
      rating: 4.8,
      reviewCount: 75, 
    ),
  ];

  List<Product> newArrivalProducts = [
    Product(
      id: 'n1',
      name: 'Áo sơ mi linen thoáng mát',
      imageUrl: 'https://images.unsplash.com/photo-1616781498114-1e073c6b2b5a?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTQ4NzZ8MHwxfHNlYXJjaHwyMHx8Y2xvdGhpbmd8ZW58MHx8fHwxNzE4NzQ3ODc3fDA&ixlib=rb-4.0.3&q=80&w=1080',
      price: 580000,
      description: 'Áo sơ mi làm từ vải linen cao cấp, thoáng khí và nhẹ nhàng, lý tưởng cho mùa hè.',
      category: 'Áo Sơ mi',
      sizes: ['S', 'M', 'L'],
      colors: ['Be', 'Trắng', 'Xám'],
      rating: 4.6,
      reviewCount: 30, 
    ),
    Product(
      id: 'n2',
      name: 'Quần short kaki năng động',
      imageUrl: 'https://images.unsplash.com/photo-1542272605-649377484d0b?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTQ4NzZ8MHwxfHNlYXJjaHwyMHx8Y2xvdGhpbmd8ZW58MHx8fHwxNzE4NzQ3ODc3fDA&ixlib=rb-4.0.3&q=80&w=1080',
      price: 420000,
      description: 'Quần short kaki với thiết kế năng động, chất liệu bền đẹp, phù hợp cho các hoạt động ngoài trời.',
      category: 'Quần',
      sizes: ['28', '30', '32'],
      colors: ['Xám', 'Kem', 'Xanh navy'],
      rating: 4.4,
      reviewCount: 25, 
    ),
    Product(
      id: 'n3',
      name: 'Áo vest slim fit hiện đại',
      imageUrl: 'https://images.unsplash.com/photo-1616781498114-1e073c6b2b5a?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTQ4NzZ8MHwxfHNlYXJjaHwyMHx8Y2xvdGhpbmd8ZW58MHx8fHwxNzE4NzQ3ODc3fDA&ixlib=rb-4.0.3&q=80&w=1080',
      price: 1200000,
      oldPrice: 1500000,
      description: 'Áo vest thiết kế slim fit, mang đến vẻ ngoài sang trọng và chuyên nghiệp. Thích hợp cho các sự kiện quan trọng.',
      category: 'Áo Khoác',
      sizes: ['S', 'M', 'L'],
      colors: ['Đen', 'Xám'],
      rating: 4.9,
      reviewCount: 18, 
    ),
    Product(
      id: 'n4',
      name: 'Áo khoác bomber thời trang',
      imageUrl: 'https://images.unsplash.com/photo-1603252109311-66774a3f12b6?q=80&w=1780&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      price: 750000,
      description: 'Áo khoác bomber cá tính, chất liệu bền đẹp, phong cách đường phố, dễ dàng phối đồ.',
      category: 'Áo Khoác',
      sizes: ['M', 'L', 'XL'],
      colors: ['Đen', 'Xanh rêu'],
      rating: 4.7,
      reviewCount: 40, 
    ),
  ];

  List<Product> flashSaleProducts = [
    Product(
      id: 'fs1',
      name: 'Áo sơ mi caro giảm giá',
      imageUrl: 'https://images.unsplash.com/photo-1616781498114-1e073c6b2b5a?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTQ4NzZ8MHwxfHNlYXJjaHwyMHx8Y2xvdGhpbmd8ZW58MHx8fHwxNzE4NzQ3ODc3fDA&ixlib=rb-4.0.3&q=80&w=1080',
      price: 300000,
      oldPrice: 500000,
      description: 'Áo sơ mi caro phong cách, chất liệu cotton mềm mại, đang có ưu đãi lớn trong Flash Sale!',
      category: 'Áo Sơ mi',
      sizes: ['S', 'M', 'L'],
      colors: ['Đỏ', 'Xanh'],
      rating: 4.0,
      reviewCount: 60, 
    ),
    Product(
      id: 'fs2',
      name: 'Áo polo trắng basic',
      imageUrl: 'https://images.unsplash.com/photo-1603252109311-66774a3f12b6?q=80&w=1780&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      price: 210000,
      oldPrice: 350000,
      description: 'Áo polo trắng tinh khôi, dễ phối đồ, chất vải mềm, thoáng mát. Giá cực sốc!',
      category: 'Áo Polo',
      sizes: ['M', 'L'],
      colors: ['Trắng'],
      rating: 4.1,
      reviewCount: 80, 
    ),
    Product(
      id: 'fs3',
      name: 'Quần jean slim sale',
      imageUrl: 'https://images.unsplash.com/photo-1542272605-649377484d0b?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTQ4NzZ8MHwxfHNlYXJjaHwyMHx8Y2xvdGhpbmd8ZW58MHx8fHwxNzE4NzQ3ODc3fDA&ixlib=rb-4.0.3&q=80&w=1080',
      price: 420000,
      oldPrice: 700000,
      description: 'Quần jean ôm dáng, chất liệu denim cao cấp, giảm giá mạnh chỉ trong Flash Sale.',
      category: 'Quần Jean',
      sizes: ['29', '31', '33'],
      colors: ['Xanh nhạt'],
      rating: 4.4,
      reviewCount: 45, 
    ),
    Product(
      id: 'fs4',
      name: 'Áo hoodie ấm áp',
      imageUrl: 'https://images.unsplash.com/photo-1603252109311-66774a3f12b6?q=80&w=1780&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      price: 360000,
      oldPrice: 600000,
      description: 'Áo hoodie nỉ dày, giữ ấm tốt, có nhiều màu sắc lựa chọn. Ưu đãi số lượng có hạn!',
      category: 'Áo Khoác',
      sizes: ['S', 'M', 'L'],
      colors: ['Đen', 'Xám', 'Xanh'],
      rating: 4.3,
      reviewCount: 70, 
    ),
    Product(
      id: 'fs5',
      name: 'Áo thun basic nhiều màu',
      imageUrl: 'https://images.unsplash.com/photo-1603252109311-66774a3f12b6?q=80&w=1780&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      price: 180000,
      oldPrice: 300000,
      description: 'Áo thun cotton mềm mịn, co giãn, đa dạng màu sắc, dễ phối đồ. Giá rẻ bất ngờ!',
      category: 'Áo Thun',
      sizes: ['S', 'M', 'L'],
      colors: ['Đen', 'Trắng', 'Đỏ', 'Xanh lá'],
      rating: 3.9,
      reviewCount: 100, 
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Auto scroll banner
    Future.delayed(const Duration(seconds: 3), () {
      _autoScrollBanner();
    });
  }

  void _autoScrollBanner() {
    if (mounted) {
      setState(() {
        _currentBannerIndex = (_currentBannerIndex + 1) % bannerImages.length;
      });
      _pageController.animateToPage(
        _currentBannerIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      Future.delayed(const Duration(seconds: 3), () {
        _autoScrollBanner();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'TPShop', // Đổi tiêu đề thành 'TPShop'
          style: TextStyle(
            color: Colors.black87, // Đặt màu cho chữ TPShop
            fontWeight: FontWeight.bold, // Đặt font chữ đậm cho TPShop
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        // Nút "Danh mục sản phẩm" ở góc trái
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.black87),
              onPressed: () {
                Scaffold.of(context).openDrawer(); // Mở Drawer khi nhấn vào
              },
            );
          },
        ),
        actions: [
          // Nút tìm kiếm (di chuyển sang phải)
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black87),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Chức năng tìm kiếm')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black87),
            onPressed: () {
              // Xử lý khi nhấn vào giỏ hàng
              Navigator.push(context, MaterialPageRoute(builder: (_) => CartScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, color: Colors.black87),
            onPressed: () {
              // Xử lý khi nhấn vào tài khoản
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
            },
          ),
        ],
      ),
      // === DRAWER CHO DANH MỤC SẢN PHẨM ===
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blueAccent, // Hoặc một màu sắc phù hợp với thương hiệu của bạn
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Danh mục sản phẩm',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Khám phá bộ sưu tập',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(Icons.accessibility_new, 'Tất cả sản phẩm', () {
              Navigator.pop(context); // Đóng drawer
              Navigator.push(context, MaterialPageRoute(builder: (_) => ProductListScreen()));
            }),
            const Divider(), // Dùng để phân chia các mục
            _buildDrawerItem(Icons.wc, 'Áo Khoác', () {
              Navigator.pop(context); // Đóng drawer
              // Điều hướng đến màn hình danh mục "Áo Khoác"
              Navigator.push(context, MaterialPageRoute(builder: (_) => ProductListScreen(category: 'Áo Khoác')));
            }),
            _buildDrawerItem(Icons.sports_baseball, 'Áo Polo', () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => ProductListScreen(category: 'Áo Polo')));
            }),
            _buildDrawerItem(Icons.checkroom, 'Áo Sơ mi', () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => ProductListScreen(category: 'Áo Sơ mi')));
            }),
            _buildDrawerItem(Icons.shopping_bag, 'Quần Jean', () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => ProductListScreen(category: 'Quần Jean')));
            }),
            _buildDrawerItem(Icons.watch, 'Phụ kiện', () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => ProductListScreen(category: 'Phụ kiện')));
            }),
            // Thêm các danh mục khác nếu cần
            const Divider(),
            _buildDrawerItem(Icons.info_outline, 'Về chúng tôi', () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Về chúng tôi')),
              );
            }),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Banner Section
            _buildHeroBanner(),

            // Flash Sale Section
            _buildFlashSaleSection(),

            // Featured Products
            _buildFeaturedProducts(),

            // New Arrivals
            _buildNewArrivals(),

            // Brand Story
            _buildBrandStory(),

            // Footer
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  // Helper method để xây dựng các mục trong Drawer
  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueGrey[700]),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
    );
  }


  Widget _buildHeroBanner() {
    return SizedBox(
      height: 280,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentBannerIndex = index;
              });
            },
            itemCount: bannerImages.length,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(bannerImages[index]),
                    fit: BoxFit.cover,
                    onError: (exception, stackTrace) {},
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.3),
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '★★★ TPShop',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 3,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Bộ sưu tập mới 2024',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          Positioned(
            bottom: 15,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                bannerImages.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentBannerIndex == index ? 12 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentBannerIndex == index
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlashSaleSection() {
    return Container(
      margin: const EdgeInsets.only(top: 30),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red[50]!, Colors.orange[50]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.flash_on, color: Colors.red, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Flash Sale',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Text(
                  '02:45:30',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: flashSaleProducts.length, // Dùng độ dài của flashSaleProducts
              itemBuilder: (context, index) {
                return _buildFlashSaleItem(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlashSaleItem(int index) {
    final product = flashSaleProducts[index]; // Lấy đối tượng sản phẩm

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    image: DecorationImage( // Hiển thị ảnh từ Product object
                      image: NetworkImage(product.imageUrl),
                      fit: BoxFit.cover,
                      onError: (exception, stackTrace) {
                         // Fallback nếu ảnh không tải được
                      },
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      // Tính phần trăm giảm giá nếu có oldPrice
                      product.oldPrice != null && product.oldPrice! > product.price
                          ? '-${((1 - product.price / product.oldPrice!) * 100).round()}%'
                          : '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name, // Dùng tên từ Product object
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  if (product.oldPrice != null)
                    Text(
                      '${product.oldPrice!.toStringAsFixed(0)}đ', // Dùng giá cũ từ Product object
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  Text(
                    '${product.price.toStringAsFixed(0)}đ', // Dùng giá từ Product object
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedProducts() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Sản phẩm nổi bật',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Xem tất cả sản phẩm nổi bật')),
                  );
                },
                child: const Text('Xem tất cả'),
              ),
            ],
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 260,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: featuredProducts.length, // Dùng độ dài của featuredProducts
              itemBuilder: (context, index) {
                return _buildProductCard(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(int index) {
    final product = featuredProducts[index]; // Lấy đối tượng sản phẩm

    return GestureDetector( // Bọc bằng GestureDetector để có thể nhấn
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    image: DecorationImage( // Hiển thị ảnh từ Product object
                      image: NetworkImage(product.imageUrl),
                      fit: BoxFit.cover,
                      onError: (exception, stackTrace) {
                        // Fallback if image fails to load
                        // debugPrint('Error loading image for ${product.name}: $exception');
                      },
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Thêm vào yêu thích')),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.favorite_border,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name, // Dùng tên từ Product object
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        '${product.rating}', // Dùng rating từ Product object
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${product.reviewCount})', // Dùng reviewCount từ Product object
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${product.price.toStringAsFixed(0)}đ', // Dùng giá từ Product object
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewArrivals() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hàng mới về',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 0.70,
            ),
            itemCount: newArrivalProducts.length, // Dùng độ dài của newArrivalProducts
            itemBuilder: (context, index) {
              return _buildNewArrivalCard(index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNewArrivalCard(int index) {
    final product = newArrivalProducts[index]; // Lấy đối tượng sản phẩm

    return GestureDetector( // Bọc bằng GestureDetector để có thể nhấn
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    image: DecorationImage( // Hiển thị ảnh từ Product object
                      image: NetworkImage(product.imageUrl),
                      fit: BoxFit.cover,
                       onError: (exception, stackTrace) {
                        // Fallback nếu ảnh không tải được
                      },
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'NEW',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name, // Dùng tên từ Product object
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${product.price.toStringAsFixed(0)}đ', // Dùng giá từ Product object
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandStory() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey[900]!, Colors.grey[800]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text(
            '★★★ TPShop',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            'Thương hiệu thời trang trẻ trung, năng động với thiết kế hiện đại và chất lượng cao. Chúng tôi mang đến những sản phẩm thời trang phù hợp với xu hướng và phong cách sống của giới trẻ.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[300],
              height: 1.6,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tìm hiểu thêm về thương hiệu')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text(
              'Tìm hiểu thêm',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.grey[100],
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildFooterItem(Icons.local_shipping, 'Miễn phí\nvận chuyển'),
              _buildFooterItem(Icons.verified_user, 'Bảo hành\nchính hãng'),
              _buildFooterItem(Icons.support_agent, 'Hỗ trợ\n24/7'),
              _buildFooterItem(Icons.payment, 'Thanh toán\nan toàn'),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            '© 2024 Levents Fashion. All rights reserved.',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterItem(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, size: 30, color: Colors.grey[700]),
        const SizedBox(height: 8),
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}