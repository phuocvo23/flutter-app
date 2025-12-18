import 'package:cloud_firestore/cloud_firestore.dart';

/// Service để thêm 24 sản phẩm mẫu vào Firestore
class SeedingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Thêm 24 sản phẩm mẫu từ danh sách
  /// Chỉ chạy nếu chưa có sản phẩm nào trong database
  Future<void> seedProducts() async {
    final collection = _firestore.collection('products');

    // Kiểm tra đã có sản phẩm chưa
    final existing = await collection.limit(1).get();
    if (existing.docs.isNotEmpty) {
      print('⚠️ Products already exist, skipping seeding.');
      return;
    }

    print('🌱 Seeding 24 products...');

    final products = _getProductsData();

    int count = 0;
    for (final productData in products) {
      await collection.add({
        ...productData,
        'createdAt': FieldValue.serverTimestamp(),
      });
      count++;
    }

    print('✅ Seeded $count products successfully!');
  }

  /// Xóa tất cả sản phẩm (dùng để reset)
  Future<void> deleteAllProducts() async {
    final collection = _firestore.collection('products');
    final docs = await collection.get();

    print('🗑️ Deleting ${docs.docs.length} products...');

    final batch = _firestore.batch();
    for (final doc in docs.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();

    print('✅ All products deleted.');
  }

  /// Xóa và seed lại
  Future<void> resetAndSeed() async {
    await deleteAllProducts();
    await seedProducts();
  }

  /// Dữ liệu 24 sản phẩm
  List<Map<String, dynamic>> _getProductsData() {
    return [
      {
        'name': 'Mũ Fullface AGV K1 S',
        'description': 'Mũ bảo hiểm thể thao, thiết kế khí động học.',
        'imageUrl':
            'https://agvvietnam.vn/wp-content/uploads/2024/05/k1-s-lap-matt-black-grey-red-motorbike-full-face-helmet-e2206.webp',
        'category': 'Mũ Bảo Hiểm',
        'price': 5500000.0,
        'originalPrice': 6200000.0,
        'stock': 10,
        'isFeatured': true,
        'isNew': true,
        'rating': 4.8,
        'reviewCount': 24,
        'sizes': ['M', 'L', 'XL'],
        'colors': ['Đen', 'Đỏ'],
      },
      {
        'name': 'Mũ 3/4 Cổ Điển Royal',
        'description': 'Mũ 3/4 phong cách classic, kèm kính phi công.',
        'imageUrl':
            'https://hifa.vn/wp-content/uploads/2018/10/Royal-M20C-Xam-Xuoc-3.jpg',
        'category': 'Mũ Bảo Hiểm',
        'price': 850000.0,
        'originalPrice': 1200000.0,
        'stock': 25,
        'isFeatured': false,
        'isNew': false,
        'rating': 4.5,
        'reviewCount': 45,
        'sizes': ['M', 'L', 'XL'],
        'colors': ['Xám', 'Đen', 'Nâu'],
      },
      {
        'name': 'Mũ Cào Cào Fox Racing',
        'description': 'Mũ off-road chuyên dụng, thoáng khí tối đa.',
        'imageUrl':
            'https://product.hstatic.net/200000349543/product/1280_gyhigaxya445ky3a_ac351ef158ef4fe08ff9d2b9cd1bfad5_master.png',
        'category': 'Mũ Bảo Hiểm',
        'price': 3800000.0,
        'originalPrice': 4500000.0,
        'stock': 5,
        'isFeatured': true,
        'isNew': false,
        'rating': 4.9,
        'reviewCount': 12,
        'sizes': ['M', 'L', 'XL'],
        'colors': ['Đen', 'Cam'],
      },
      {
        'name': 'Áo Khoác Da Alpinestars',
        'description': 'Áo khoác da thật bảo hộ, chống mài mòn cao.',
        'imageUrl':
            'https://www.jokerhelmets.com/wp-content/uploads/2016/02/gpr_leather_jacket_black_white_photoshopped.jpg',
        'category': 'Áo Khoác',
        'price': 9500000.0,
        'originalPrice': 11000000.0,
        'stock': 8,
        'isFeatured': true,
        'isNew': true,
        'rating': 4.7,
        'reviewCount': 18,
        'sizes': ['M', 'L', 'XL', 'XXL'],
        'colors': ['Đen', 'Trắng'],
      },
      {
        'name': 'Áo Giáp Lưới Mùa Hè',
        'description': 'Áo khoác vải lưới thoáng mát, có giáp vai và tay.',
        'imageUrl':
            'https://www.jokerhelmets.com/wp-content/uploads/2023/06/sulaite-mesh-jacket.jpg',
        'category': 'Áo Khoác',
        'price': 1200000.0,
        'originalPrice': 1500000.0,
        'stock': 30,
        'isFeatured': false,
        'isNew': false,
        'rating': 4.3,
        'reviewCount': 67,
        'sizes': ['M', 'L', 'XL'],
        'colors': ['Đen'],
      },
      {
        'name': 'Áo Mưa Bộ Givi',
        'description': 'Bộ quần áo mưa chống nước tuyệt đối, phản quang.',
        'imageUrl':
            'https://gsports.vn/wp-content/uploads/2022/08/givi-crs01.jpg',
        'category': 'Áo Khoác',
        'price': 950000.0,
        'originalPrice': 1000000.0,
        'stock': 50,
        'isFeatured': false,
        'isNew': true,
        'rating': 4.6,
        'reviewCount': 89,
        'sizes': ['M', 'L', 'XL', 'XXL'],
        'colors': ['Đen', 'Vàng'],
      },
      {
        'name': 'Găng Tay Da Classic',
        'description': 'Găng tay da bò màu nâu, phong cách vintage.',
        'imageUrl':
            'https://pos.nvncdn.com/ac78b1-122712/ps/20230331_mOIRabcxJc.jpeg?v=1680277025',
        'category': 'Găng Tay',
        'price': 850000.0,
        'originalPrice': 1000000.0,
        'stock': 20,
        'isFeatured': true,
        'isNew': false,
        'rating': 4.4,
        'reviewCount': 34,
        'sizes': ['M', 'L', 'XL'],
        'colors': ['Nâu', 'Đen'],
      },
      {
        'name': 'Găng Tay Gù Carbon',
        'description': 'Găng tay vải pha da, có gù carbon bảo vệ khớp.',
        'imageUrl':
            'https://bizweb.dktcdn.net/thumb/grande/100/345/516/products/gang-tay-motowolf-carbon-2.png?v=1721290193463',
        'category': 'Găng Tay',
        'price': 450000.0,
        'originalPrice': 600000.0,
        'stock': 40,
        'isFeatured': false,
        'isNew': true,
        'rating': 4.5,
        'reviewCount': 56,
        'sizes': ['M', 'L', 'XL'],
        'colors': ['Đen', 'Đỏ'],
      },
      {
        'name': 'Găng Tay Cụt Ngón',
        'description': 'Găng tay hở ngón tiện lợi cho đi phố.',
        'imageUrl':
            'https://xeomshop.vn/wp-content/uploads/2022/09/XOS00264.jpg',
        'category': 'Găng Tay',
        'price': 150000.0,
        'originalPrice': 200000.0,
        'stock': 100,
        'isFeatured': false,
        'isNew': false,
        'rating': 4.2,
        'reviewCount': 123,
        'sizes': ['M', 'L', 'XL'],
        'colors': ['Đen'],
      },
      {
        'name': 'Giày Boot Cổ Cao TCX',
        'description': 'Giày bảo hộ cổ cao, chống nước Gore-tex.',
        'imageUrl':
            'https://mainguyen.sgp1.digitaloceanspaces.com/276716/conversions/giay-bao-ho-moto-tcx-tourstep-wp--11-optimize.jpg',
        'category': 'Giày Touring',
        'price': 4500000.0,
        'originalPrice': 5000000.0,
        'stock': 6,
        'isFeatured': true,
        'isNew': true,
        'rating': 4.9,
        'reviewCount': 15,
        'sizes': ['40', '41', '42', '43', '44'],
        'colors': ['Đen'],
      },
      {
        'name': 'Giày Sneaker Moto',
        'description': 'Giày dáng thể thao có lót mũi số và bảo vệ mắt cá.',
        'imageUrl':
            'https://product.hstatic.net/200000751979/product/xpd_moto-1_s105_011_092eb91212b44fdb9b65b918012e0523_master.jpg',
        'category': 'Giày Touring',
        'price': 2200000.0,
        'originalPrice': 2800000.0,
        'stock': 15,
        'isFeatured': false,
        'isNew': true,
        'rating': 4.6,
        'reviewCount': 28,
        'sizes': ['40', '41', '42', '43', '44'],
        'colors': ['Đen', 'Trắng'],
      },
      {
        'name': 'Giày Adventure Forma',
        'description': 'Giày địa hình đế gai lớn, khóa cài chắc chắn.',
        'imageUrl':
            'https://bizweb.dktcdn.net/100/504/473/products/z4853833559079-9b52f2b9d23c3ee85d6ad3e49b2e2b17.jpg?v=1705748244690',
        'category': 'Giày Touring',
        'price': 6800000.0,
        'originalPrice': 7500000.0,
        'stock': 4,
        'isFeatured': true,
        'isNew': false,
        'rating': 4.8,
        'reviewCount': 9,
        'sizes': ['41', '42', '43', '44'],
        'colors': ['Nâu', 'Đen'],
      },
      {
        'name': 'Balo Chống Nước 30L',
        'description': 'Balo cuộn miệng chống nước 100%, có phản quang.',
        'imageUrl':
            'https://bikersaigon.net/wp-content/uploads/2023/10/balo-chong-nuoc-motowolf-mdl0714-30l-den-cam.jpg',
        'category': 'Túi & Balo',
        'price': 1200000.0,
        'originalPrice': 1600000.0,
        'stock': 20,
        'isFeatured': true,
        'isNew': false,
        'rating': 4.7,
        'reviewCount': 42,
        'sizes': [],
        'colors': ['Đen', 'Cam'],
      },
      {
        'name': 'Túi Hít Bình Xăng',
        'description': 'Túi nam châm gắn bình xăng, có ngăn đựng điện thoại.',
        'imageUrl':
            'https://mubaohiemdochanoi.com/wp-content/uploads/2024/04/tui-hit-binh-xang-givi-ea130b-26l-da-nang-13.jpg',
        'category': 'Túi & Balo',
        'price': 800000.0,
        'originalPrice': 950000.0,
        'stock': 12,
        'isFeatured': false,
        'isNew': true,
        'rating': 4.5,
        'reviewCount': 31,
        'sizes': [],
        'colors': ['Đen'],
      },
      {
        'name': 'Túi Treo Hông Đôi',
        'description': 'Bộ túi vải treo hai bên hông xe cho các chuyến đi xa.',
        'imageUrl':
            'https://gsports.vn/wp-content/uploads/2023/05/tui-hong-givi-ea101b.jpg',
        'category': 'Túi & Balo',
        'price': 2500000.0,
        'originalPrice': 3000000.0,
        'stock': 8,
        'isFeatured': true,
        'isNew': true,
        'rating': 4.8,
        'reviewCount': 19,
        'sizes': [],
        'colors': ['Đen'],
      },
      {
        'name': 'Giáp Gối Inox Pro',
        'description': 'Bộ bọc gối và ống chân, vỏ inox chịu va đập mạnh.',
        'imageUrl': 'https://xeomshop.vn/wp-content/uploads/2020/12/0.jpg',
        'category': 'Giáp Bảo Hộ',
        'price': 450000.0,
        'originalPrice': 550000.0,
        'stock': 35,
        'isFeatured': false,
        'isNew': false,
        'rating': 4.3,
        'reviewCount': 78,
        'sizes': [],
        'colors': ['Đen'],
      },
      {
        'name': 'Áo Giáp Ngực Rời',
        'description': 'Giáp bảo vệ ngực và lưng dạng áo ghi-lê nhựa cứng.',
        'imageUrl':
            'https://pos.nvncdn.com/37cd6c-96997/ps/20211228_VivBGDn9EFgmfg3Wyvhoh4M2.jpg?v=1673657083',
        'category': 'Giáp Bảo Hộ',
        'price': 1800000.0,
        'originalPrice': 2200000.0,
        'stock': 10,
        'isFeatured': true,
        'isNew': false,
        'rating': 4.6,
        'reviewCount': 23,
        'sizes': ['M', 'L', 'XL'],
        'colors': ['Đen'],
      },
      {
        'name': 'Đai Lưng Bảo Vệ',
        'description': 'Đai siết lưng hỗ trợ cột sống khi đi đường dài.',
        'imageUrl':
            'https://motowolf.vn/wp-content/uploads/2024/02/dai-lung-chong-moi-motowolf-mdl-1028-den-do-600x600.jpg',
        'category': 'Giáp Bảo Hộ',
        'price': 650000.0,
        'originalPrice': 800000.0,
        'stock': 15,
        'isFeatured': false,
        'isNew': true,
        'rating': 4.4,
        'reviewCount': 45,
        'sizes': ['M', 'L', 'XL'],
        'colors': ['Đen', 'Đỏ'],
      },
      {
        'name': 'Quần Jean Riding Kevlar',
        'description': 'Quần bò thời trang lót sợi Kevlar chống mài mòn.',
        'imageUrl':
            'https://bizweb.dktcdn.net/100/504/473/products/z5218443829207-c65097080d97b9045de558dfb8c21df6-1709634923248.jpg?v=1709634957367',
        'category': 'Quần Riding',
        'price': 2100000.0,
        'originalPrice': 2600000.0,
        'stock': 18,
        'isFeatured': true,
        'isNew': true,
        'rating': 4.7,
        'reviewCount': 56,
        'sizes': ['30', '31', '32', '33', '34'],
        'colors': ['Xanh', 'Đen'],
      },
      {
        'name': 'Quần Giáp Touring Vải',
        'description': 'Quần vải dù nhiều túi, chống nước nhẹ, có giáp gối.',
        'imageUrl':
            'https://mainguyen.sgp1.digitaloceanspaces.com/223309/conversions/quan-giap-vai-chong-nuoc-dainese-tempest-d-dry-1-optimize.jpg',
        'category': 'Quần Riding',
        'price': 3200000.0,
        'originalPrice': 3800000.0,
        'stock': 7,
        'isFeatured': true,
        'isNew': false,
        'rating': 4.5,
        'reviewCount': 21,
        'sizes': ['M', 'L', 'XL'],
        'colors': ['Đen'],
      },
      {
        'name': 'Quần Da Racing',
        'description': 'Quần da bò ôm sát, có slide chà gối (puck).',
        'imageUrl':
            'https://product.hstatic.net/1000357687/product/mat_truoc_quan_di_rung_ver_3_e8638e9797734be58099717fcf9c857c_master.jpg',
        'category': 'Quần Riding',
        'price': 6500000.0,
        'originalPrice': 8000000.0,
        'stock': 3,
        'isFeatured': false,
        'isNew': true,
        'rating': 4.9,
        'reviewCount': 8,
        'sizes': ['M', 'L', 'XL'],
        'colors': ['Đen'],
      },
      {
        'name': 'Giá Đỡ Điện Thoại Nhôm',
        'description': 'Kẹp điện thoại hợp kim nhôm gắn ghi đông chắc chắn.',
        'imageUrl':
            'https://bikersaigon.net/wp-content/uploads/2023/10/gia-do-dien-thoai-motowolf-mdl-2827D-den-1.jpg',
        'category': 'Phụ Kiện',
        'price': 250000.0,
        'originalPrice': 350000.0,
        'stock': 80,
        'isFeatured': true,
        'isNew': false,
        'rating': 4.6,
        'reviewCount': 134,
        'sizes': [],
        'colors': ['Đen', 'Bạc'],
      },
      {
        'name': 'Tai Nghe Bluetooth Intercom',
        'description': 'Thiết bị liên lạc gắn mũ bảo hiểm kết nối nhóm.',
        'imageUrl':
            'https://hifa.vn/wp-content/uploads/2024/06/tai-nghe-bluetooth-intercom-scs-s9-3.jpg',
        'category': 'Phụ Kiện',
        'price': 1500000.0,
        'originalPrice': 2000000.0,
        'stock': 22,
        'isFeatured': true,
        'isNew': true,
        'rating': 4.7,
        'reviewCount': 67,
        'sizes': [],
        'colors': ['Đen'],
      },
      {
        'name': 'Khóa Đĩa Báo Động',
        'description': 'Khóa phanh đĩa tích hợp còi hú chống trộm.',
        'imageUrl':
            'https://bizweb.dktcdn.net/100/414/235/products/alarm-01.jpg?v=1624694224813',
        'category': 'Phụ Kiện',
        'price': 450000.0,
        'originalPrice': 600000.0,
        'stock': 45,
        'isFeatured': false,
        'isNew': false,
        'rating': 4.4,
        'reviewCount': 89,
        'sizes': [],
        'colors': ['Đen', 'Vàng'],
      },
    ];
  }
}
