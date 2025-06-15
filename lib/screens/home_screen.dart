import 'package:flutter/material.dart';
import 'package:appquanao/screens/product_listscreen.dart';
import 'package:appquanao/screens/profile_screen.dart';
import 'package:appquanao/models/product.dart'; // Đảm bảo import đúng đường dẫn
import 'package:appquanao/screens/cart_screen.dart';
import 'package:appquanao/screens/product_detail_screen.dart'; // Đảm bảo import đúng đường dẫn
import 'package:http/http.dart' as http; // Import thư viện http
import 'dart:convert'; // Import để làm việc với JSON

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

  // Khai báo các list sản phẩm để lưu dữ liệu từ API
  List<Product> featuredProducts = [];
  List<Product> newArrivalProducts = [];
  List<Product> flashSaleProducts = [];

  // Trạng thái tải dữ liệu
  bool _isLoading = true;
  String _errorMessage = '';

  final String _apiUrl = 'http://10.0.2.2/apiAppQuanAo/api/sanpham/danhsachsanpham.php'; // API lấy tất cả sản phẩm
  // Nếu bạn có các endpoint riêng cho Featured, New Arrivals, Flash Sale, hãy định nghĩa chúng ở đây
  // Ví dụ:
  // final String _featuredApiUrl = 'http://10.0.2.2/apiAppQuanAo/api/featured_products';
  // final String _newArrivalsApiUrl = 'http://10.0.2.2/apiAppQuanAo/api/new_arrivals';
  // final String _flashSaleApiUrl = 'http://10.0.2.2/apiAppQuanAo/api/flash_sale';


  @override
  void initState() {
    super.initState();
    // Gọi API để tải dữ liệu khi khởi tạo màn hình
    _fetchProducts();
    // Auto scroll banner
    Future.delayed(const Duration(seconds: 3), () {
      _autoScrollBanner();
    });
  }

  // Hàm để gọi API và lấy dữ liệu sản phẩm
  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await http.get(Uri.parse(_apiUrl));

      if (response.statusCode == 200) {
        // Phân tích cú pháp JSON
         List<dynamic> jsonList = json.decode(response.body);
         debugPrint('FULL API Response Body for Products: ${json.encode(jsonList)}'); // THÊM DÒNG NÀY
        List<Product> fetchedProducts = jsonList.map((json) => Product.fromJson(json)).toList();

        // Giả lập phân loại sản phẩm cho mục đích demo
        // Trong thực tế, API của bạn nên cung cấp các endpoint riêng cho từng loại
        // hoặc thêm trường 'type' vào Product model và lọc ở đây
        setState(() {
          featuredProducts = fetchedProducts.where((p) => p.rating >= 4.5).toList();
        //  newArrivalProducts = fetchedProducts.where((p) => p.category == 'Áo Sơ mi' || p.category == 'Quần').toList(); // Ví dụ lọc
          flashSaleProducts = fetchedProducts.where((p) => p.oldPrice != null && p.oldPrice! > p.price).toList();

          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load products: ${response.statusCode}';
          _isLoading = false;
        });
        debugPrint('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
      debugPrint('Exception fetching products: $e');
    }
  }


  void _autoScrollBanner() {
    if (mounted) {
      if (_pageController.hasClients) { // THÊM DÒNG NÀY
        setState(() {
          _currentBannerIndex = (_currentBannerIndex + 1) % bannerImages.length;
        });
        _pageController.animateToPage(
          _currentBannerIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
      // Luôn đặt Future.delayed bên ngoài if để đảm bảo nó vẫn cố gắng scroll lại sau 3s
      // ngay cả khi lúc đầu chưa có client, nhưng chỉ animate nếu có client.
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
          'TPShop',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.black87),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: [
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
              Navigator.push(context, MaterialPageRoute(builder: (_) => CartScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, color: Colors.black87),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blueAccent,
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
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => ProductListScreen()));
            }),
            const Divider(),
            _buildDrawerItem(Icons.wc, 'Áo Khoác', () {
              Navigator.pop(context);
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Hiển thị vòng tròn tải
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_errorMessage),
                      ElevatedButton(
                        onPressed: _fetchProducts, // Thử tải lại
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView( // Hiển thị nội dung khi tải thành công
                  child: Column(
                    children: [
                      _buildHeroBanner(),
                      _buildFlashSaleSection(),
                      _buildFeaturedProducts(),
                      _buildNewArrivals(),
                      _buildBrandStory(),
                      _buildFooter(),
                    ],
                  ),
                ),
    );
  }

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
    if (flashSaleProducts.isEmpty) {
      return const SizedBox.shrink(); // Không hiển thị nếu không có sản phẩm
    }
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
                  '02:45:30', // Thời gian này sẽ cần được cập nhật động trong ứng dụng thực tế
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
              itemCount: flashSaleProducts.length,
              itemBuilder: (context, index) {
                return _buildFlashSaleItem(flashSaleProducts[index]); // Truyền trực tiếp Product object
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlashSaleItem(Product product) { // Nhận Product object
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(productId: product.id.toString()),
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
                    image: DecorationImage(
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
                    product.name,
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
                      '${product.oldPrice!.toStringAsFixed(0)}đ',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  Text(
                    '${product.price.toStringAsFixed(0)}đ',
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
    if (featuredProducts.isEmpty) {
      return const SizedBox.shrink(); // Không hiển thị nếu không có sản phẩm
    }
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
              
            ],
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 260,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: featuredProducts.length,
              itemBuilder: (context, index) {
                return _buildProductCard(featuredProducts[index]); // Truyền trực tiếp Product object
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product) { // Nhận Product object
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(productId: product.id.toString()),
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
                    image: DecorationImage(
                      image: NetworkImage(product.imageUrl),
                      fit: BoxFit.cover,
                       onError: (exception, stackTrace) {
                        // Fallback if image fails to load
                      },
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
                    product.name,
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
                        '${product.rating}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${product.reviewCount})',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${product.price.toStringAsFixed(0)}đ',
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
    if (newArrivalProducts.isEmpty) {
      return const SizedBox.shrink(); // Không hiển thị nếu không có sản phẩm
    }
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
            itemCount: newArrivalProducts.length,
            itemBuilder: (context, index) {
              return _buildNewArrivalCard(newArrivalProducts[index]); // Truyền trực tiếp Product object
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNewArrivalCard(Product product) { // Nhận Product object
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(productId: product.id.toString()),
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
                    image: DecorationImage(
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
                    product.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${product.price.toStringAsFixed(0)}đ',
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