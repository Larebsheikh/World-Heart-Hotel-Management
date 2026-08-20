import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const ProviderScope(child: WorldHeartApp()));
}

class WorldHeartApp extends StatelessWidget {
  const WorldHeartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'World Heart Hotel & Resort',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F172A),
          primary: const Color(0xFF0F172A),
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF0F172A),
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
        ),
      ),
      home: const IntroWelcomeScreen(),
    );
  }
}

// ============================================================================
// DOMAIN MODELS & ENUMS
// ============================================================================
enum RoomStatus { available, occupied, cleaning, maintenance }
enum BookingStatus { booked, checkedIn, checkedOut, cancelled }

class Room {
  final int id;
  final String roomNumber;
  final String name;
  final String category;
  final int rateUsd;
  final int capacity;
  final List<String> amenities;
  final IconData icon;
  RoomStatus status;

  Room({
    required this.id,
    required this.roomNumber,
    required this.name,
    required this.category,
    required this.rateUsd,
    required this.capacity,
    required this.amenities,
    required this.icon,
    this.status = RoomStatus.available,
  });

  Room copyWith({RoomStatus? status}) {
    return Room(
      id: id,
      roomNumber: roomNumber,
      name: name,
      category: category,
      rateUsd: rateUsd,
      capacity: capacity,
      amenities: amenities,
      icon: icon,
      status: status ?? this.status,
    );
  }
}

class Booking {
  final String id;
  final String guestName;
  final String guestEmail;
  final String roomNumber;
  final String roomName;
  final DateTime checkIn;
  final DateTime checkOut;
  final int totalPriceUsd;
  BookingStatus status;

  Booking({
    required this.id,
    required this.guestName,
    required this.guestEmail,
    required this.roomNumber,
    required this.roomName,
    required this.checkIn,
    required this.checkOut,
    required this.totalPriceUsd,
    this.status = BookingStatus.booked,
  });

  Booking copyWith({BookingStatus? status}) {
    return Booking(
      id: id,
      guestName: guestName,
      guestEmail: guestEmail,
      roomNumber: roomNumber,
      roomName: roomName,
      checkIn: checkIn,
      checkOut: checkOut,
      totalPriceUsd: totalPriceUsd,
      status: status ?? this.status,
    );
  }
}

class Guest {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String idNumber;
  final int totalStays;

  Guest({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.idNumber,
    this.totalStays = 1,
  });
}

class ChatMessage {
  final String role;
  final String text;
  final DateTime timestamp;
  final bool isBlocked;
  final Room? bookingOfferRoom;

  ChatMessage({
    required this.role,
    required this.text,
    required this.timestamp,
    this.isBlocked = false,
    this.bookingOfferRoom,
  });
}

// ============================================================================
// RIVERPOD STATE CONTROLLERS
// ============================================================================
class RoomNotifier extends StateNotifier<List<Room>> {
  RoomNotifier() : super([]) {
    _generate50Rooms();
  }

  void _generate50Rooms() {
    final List<Room> initial = [];
    int idCounter = 101;

    final configs = [
      {'name': 'Presidential Suite', 'cat': 'Suites', 'rate': 450, 'cap': 4, 'icon': Icons.king_bed, 'amenities': ['Lake View', 'Jacuzzi', 'Butler', 'Wi-Fi'], 'count': 6},
      {'name': 'Executive Penthouse', 'cat': 'Penthouse', 'rate': 380, 'cap': 6, 'icon': Icons.apartment, 'amenities': ['Panoramic Balcony', 'Rooftop Bar', 'Spa'], 'count': 6},
      {'name': 'Lake View Grand Suite', 'cat': 'Lake View', 'rate': 220, 'cap': 2, 'icon': Icons.water, 'amenities': ['Lake Front', 'Breakfast', 'Workspace'], 'count': 10},
      {'name': 'Poolside Cabana Villa', 'cat': 'Pool & Bar', 'rate': 180, 'cap': 3, 'icon': Icons.pool, 'amenities': ['Direct Pool Access', 'Mini Bar', 'Sunbeds'], 'count': 8},
      {'name': 'Skyline Bar Lounge Suite', 'cat': 'Pool & Bar', 'rate': 160, 'cap': 2, 'icon': Icons.local_bar, 'amenities': ['Complimentary Drinks', 'Lounge'], 'count': 6},
      {'name': 'Corporate Conference Hall', 'cat': 'Office/Meeting', 'rate': 250, 'cap': 16, 'icon': Icons.meeting_room, 'amenities': ['4K Display', 'Fiber Wi-Fi', 'Coffee Station'], 'count': 8},
      {'name': 'Deluxe Double Room', 'cat': 'Suites', 'rate': 120, 'cap': 2, 'icon': Icons.hotel, 'amenities': ['Queen Bed', 'Ensuite Bath'], 'count': 6},
    ];

    for (var cfg in configs) {
      for (int i = 0; i < (cfg['count'] as int); i++) {
        RoomStatus status = RoomStatus.available;
        if (idCounter % 5 == 0) status = RoomStatus.occupied;
        if (idCounter % 9 == 0) status = RoomStatus.cleaning;
        if (idCounter % 17 == 0) status = RoomStatus.maintenance;

        initial.add(Room(
          id: idCounter,
          roomNumber: 'A$idCounter',
          name: '${cfg['name']} #$idCounter',
          category: cfg['cat'] as String,
          rateUsd: cfg['rate'] as int,
          capacity: cfg['cap'] as int,
          amenities: List<String>.from(cfg['amenities'] as List),
          icon: cfg['icon'] as IconData,
          status: status,
        ));
        idCounter++;
      }
    }
    state = initial;
  }

  void updateStatus(String roomNumber, RoomStatus newStatus) {
    state = [
      for (final room in state)
        if (room.roomNumber == roomNumber) room.copyWith(status: newStatus) else room,
    ];
  }
}

final roomProvider = StateNotifierProvider<RoomNotifier, List<Room>>((ref) {
  return RoomNotifier();
});

class BookingNotifier extends StateNotifier<List<Booking>> {
  final Ref ref;

  BookingNotifier(this.ref)
      : super([
          Booking(
            id: 'BK-8901',
            guestName: 'Eleanor Vance',
            guestEmail: 'e.vance@hillhouse.org',
            roomNumber: 'A101',
            roomName: 'Presidential Suite #101',
            checkIn: DateTime.now().subtract(const Duration(days: 1)),
            checkOut: DateTime.now().add(const Duration(days: 2)),
            totalPriceUsd: 1350,
            status: BookingStatus.checkedIn,
          ),
          Booking(
            id: 'BK-8902',
            guestName: 'Theodore Crain',
            guestEmail: 't.crain@design.com',
            roomNumber: 'A113',
            roomName: 'Executive Penthouse #113',
            checkIn: DateTime.now(),
            checkOut: DateTime.now().add(const Duration(days: 3)),
            totalPriceUsd: 1140,
            status: BookingStatus.booked,
          ),
        ]);

  void createBooking(Booking booking) {
    state = [booking, ...state];
    ref.read(roomProvider.notifier).updateStatus(booking.roomNumber, RoomStatus.occupied);
  }

  void checkIn(String bookingId) {
    state = [
      for (final b in state)
        if (b.id == bookingId) b.copyWith(status: BookingStatus.checkedIn) else b,
    ];
  }

  void checkOut(String bookingId) {
    final b = state.firstWhere((item) => item.id == bookingId);
    state = [
      for (final item in state)
        if (item.id == bookingId) item.copyWith(status: BookingStatus.checkedOut) else item,
    ];
    ref.read(roomProvider.notifier).updateStatus(b.roomNumber, RoomStatus.cleaning);
  }

  void cancelBooking(String bookingId) {
    final b = state.firstWhere((item) => item.id == bookingId);
    state = [
      for (final item in state)
        if (item.id == bookingId) item.copyWith(status: BookingStatus.cancelled) else item,
    ];
    ref.read(roomProvider.notifier).updateStatus(b.roomNumber, RoomStatus.available);
  }
}

final bookingProvider = StateNotifierProvider<BookingNotifier, List<Booking>>((ref) {
  return BookingNotifier(ref);
});

final guestProvider = StateProvider<List<Guest>>((ref) => [
  Guest(id: 'G-01', name: 'Eleanor Vance', email: 'e.vance@hillhouse.org', phone: '+1 555-0192', idNumber: 'ID-894-321', totalStays: 3),
  Guest(id: 'G-02', name: 'Theodore Crain', email: 't.crain@design.com', phone: '+1 555-4389', idNumber: 'ID-442-991', totalStays: 1),
  Guest(id: 'G-03', name: 'Marcus Chen', email: 'm.chen@enterprise.com', phone: '+44 7700 9000', idNumber: 'GB-990-213', totalStays: 5),
  Guest(id: 'G-04', name: 'Dr. Sanab', email: 'dr.sanab@hospital.pk', phone: '+92 333 5555555', idNumber: 'PK-212121', totalStays: 2),
]);

// ============================================================================
// 1. INTRO / WELCOME SCREEN
// ============================================================================
class IntroWelcomeScreen extends StatelessWidget {
  const IntroWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1582719508461-905c673771fd?w=1200',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.35),
                    Colors.black.withOpacity(0.92),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white30),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        SizedBox(width: 6),
                        Text(
                          '5-Star Hospitality Suite',
                          style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'World Heart\nHotel & Resort',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.1,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Enterprise terminal for front-desk operations, date-range availability queries, 50-room management in USD, and AI booking assistant.',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white.withOpacity(0.85),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const AppNavigationShell()),
                        );
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Open Enterprise Console', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// APP NAVIGATION SHELL (5 Core Tabs)
// ============================================================================
class AppNavigationShell extends ConsumerStatefulWidget {
  const AppNavigationShell({super.key});

  @override
  ConsumerState<AppNavigationShell> createState() => _AppNavigationShellState();
}

class _AppNavigationShellState extends ConsumerState<AppNavigationShell> {
  int _tabIndex = 0;

  final List<Widget> _screens = const [
    DashboardView(),
    RoomsInventoryView(),
    AvailabilitySearchView(),
    BookingsView(),
    GuestDirectoryView(),
    AIAssistantView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_tabIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
        ),
        child: BottomNavigationBar(
          currentIndex: _tabIndex,
          selectedItemColor: const Color(0xFF0F172A),
          unselectedItemColor: const Color(0xFF94A3B8),
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 10),
          unselectedLabelStyle: const TextStyle(fontSize: 10),
          onTap: (index) => setState(() => _tabIndex = index),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Dashboard'),
            BottomNavigationBarItem(icon: Icon(Icons.meeting_room_outlined), activeIcon: Icon(Icons.meeting_room), label: 'Rooms (50)'),
            BottomNavigationBarItem(icon: Icon(Icons.event_available_outlined), activeIcon: Icon(Icons.event_available), label: 'Search'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), activeIcon: Icon(Icons.calendar_today), label: 'Bookings'),
            BottomNavigationBarItem(icon: Icon(Icons.people_alt_outlined), activeIcon: Icon(Icons.people_alt), label: 'Guests'),
            BottomNavigationBarItem(icon: Icon(Icons.smart_toy_outlined), activeIcon: Icon(Icons.smart_toy), label: 'AI Assistant'),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 1. DASHBOARD VIEW
// ============================================================================
class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rooms = ref.watch(roomProvider);
    final bookings = ref.watch(bookingProvider);

    final occupied = rooms.where((r) => r.status == RoomStatus.occupied).length;
    final available = rooms.where((r) => r.status == RoomStatus.available).length;
    final cleaning = rooms.where((r) => r.status == RoomStatus.cleaning).length;
    final rate = ((occupied / rooms.length) * 100).toStringAsFixed(0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Operations Dashboard', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                CircleAvatar(radius: 4, backgroundColor: Color(0xFF10B981)),
                SizedBox(width: 6),
                Text('RIVERPOD ACTIVE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF10B981))),
              ],
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('TOTAL OCCUPANCY', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('$rate%', style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: Colors.white)),
                      Text('$occupied / ${rooms.length} Units Active', style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: occupied / rooms.length,
                      minHeight: 8,
                      backgroundColor: const Color(0xFF334155),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Available: $available', style: const TextStyle(color: Color(0xFF10B981), fontSize: 12, fontWeight: FontWeight.bold)),
                      Text('Occupied: $occupied', style: const TextStyle(color: Color(0xFFEF4444), fontSize: 12, fontWeight: FontWeight.bold)),
                      Text('Turnover: $cleaning', style: const TextStyle(color: Color(0xFFF59E0B), fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Active Reservations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
            const SizedBox(height: 12),
            ...bookings.take(4).map((b) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: const Color(0xFFF1F5F9),
                        foregroundColor: const Color(0xFF0F172A),
                        child: Text(b.guestName[0], style: const TextStyle(fontWeight: FontWeight.w800)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(b.guestName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text('${b.roomNumber} • ${b.roomName}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                          ],
                        ),
                      ),
                      Text('\$${b.totalPriceUsd}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 2. 50-ROOM INVENTORY VIEW (IN USD)
// ============================================================================
class RoomsInventoryView extends ConsumerStatefulWidget {
  const RoomsInventoryView({super.key});

  @override
  ConsumerState<RoomsInventoryView> createState() => _RoomsInventoryViewState();
}

class _RoomsInventoryViewState extends ConsumerState<RoomsInventoryView> {
  String _selectedCat = 'All';

  @override
  Widget build(BuildContext context) {
    final rooms = ref.watch(roomProvider);
    final categories = ['All', 'Suites', 'Penthouse', 'Lake View', 'Pool & Bar', 'Office/Meeting'];

    final filtered = rooms.where((r) => _selectedCat == 'All' || r.category == _selectedCat).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rooms Directory (50)', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22)),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = _selectedCat == cat;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    selectedColor: const Color(0xFF0F172A),
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF475569),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                    onSelected: (_) => setState(() => _selectedCat = cat),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final r = filtered[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(r.icon, size: 22, color: const Color(0xFF0F172A)),
                              const SizedBox(width: 8),
                              Text(r.roomNumber, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                              const SizedBox(width: 8),
                              Text('(${r.category})', style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                            ],
                          ),
                          _badgeForStatus(r.status),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(r.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        children: r.amenities.map((a) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFFE2E8F0))),
                          child: Text(a, style: const TextStyle(fontSize: 10, color: Color(0xFF475569))),
                        )).toList(),
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('\$${r.rateUsd} / night', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0F172A))),
                          PopupMenuButton<RoomStatus>(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(8)),
                              child: const Text('Update Status', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                            onSelected: (newStatus) {
                              ref.read(roomProvider.notifier).updateStatus(r.roomNumber, newStatus);
                            },
                            itemBuilder: (context) => const [
                              PopupMenuItem(value: RoomStatus.available, child: Text('Available')),
                              PopupMenuItem(value: RoomStatus.occupied, child: Text('Occupied')),
                              PopupMenuItem(value: RoomStatus.cleaning, child: Text('Cleaning')),
                              PopupMenuItem(value: RoomStatus.maintenance, child: Text('Maintenance')),
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _badgeForStatus(RoomStatus status) {
    Color bg = const Color(0xFFECFDF5);
    Color fg = const Color(0xFF059669);
    if (status == RoomStatus.occupied) {
      bg = const Color(0xFFFEF2F2);
      fg = const Color(0xFFDC2626);
    } else if (status == RoomStatus.cleaning) {
      bg = const Color(0xFFFFFBEB);
      fg = const Color(0xFFD97706);
    } else if (status == RoomStatus.maintenance) {
      bg = const Color(0xFFF1F5F9);
      fg = const Color(0xFF64748B);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(status.name.toUpperCase(), style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.w900)),
    );
  }
}

// ============================================================================
// 3. AVAILABILITY SEARCH (IN USD)
// ============================================================================
class AvailabilitySearchView extends ConsumerStatefulWidget {
  const AvailabilitySearchView({super.key});

  @override
  ConsumerState<AvailabilitySearchView> createState() => _AvailabilitySearchViewState();
}

class _AvailabilitySearchViewState extends ConsumerState<AvailabilitySearchView> {
  DateTime _checkIn = DateTime.now();
  DateTime _checkOut = DateTime.now().add(const Duration(days: 2));

  @override
  Widget build(BuildContext context) {
    final rooms = ref.watch(roomProvider);
    final bookings = ref.watch(bookingProvider);

    final bookedRoomNumbers = bookings.where((b) {
      if (b.status == BookingStatus.cancelled || b.status == BookingStatus.checkedOut) return false;
      return (_checkIn.isBefore(b.checkOut) && _checkOut.isAfter(b.checkIn));
    }).map((b) => b.roomNumber).toSet();

    final availableRooms = rooms.where((r) => !bookedRoomNumbers.contains(r.roomNumber) && r.status != RoomStatus.maintenance).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Availability Search', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('CHECK IN', style: TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
                      Text(DateFormat('MMM dd, yyyy').format(_checkIn), style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('CHECK OUT', style: TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
                      Text(DateFormat('MMM dd, yyyy').format(_checkOut), style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white),
                    onPressed: () async {
                      final range = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 180)),
                      );
                      if (range != null) {
                        setState(() {
                          _checkIn = range.start;
                          _checkOut = range.end;
                        });
                      }
                    },
                    child: const Text('Select Dates'),
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Available for selected dates (${availableRooms.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const Text('Excludes Overlaps', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: availableRooms.length,
                itemBuilder: (context, index) {
                  final r = availableRooms[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Icon(r.icon, color: const Color(0xFF0F172A)),
                      title: Text('${r.roomNumber} • ${r.name}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: Text('\$${r.rateUsd} / night • Capacity: ${r.capacity} Guests'),
                      trailing: const Icon(Icons.check_circle, color: Color(0xFF10B981)),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 4. BOOKINGS VIEW
// ============================================================================
class BookingsView extends ConsumerWidget {
  const BookingsView({super.key});

  void _openCreateSheet(BuildContext context, WidgetRef ref) {
    final rooms = ref.read(roomProvider);
    final guests = ref.read(guestProvider);

    String selectedGuest = guests.first.name;
    String selectedRoom = rooms.firstWhere((r) => r.status == RoomStatus.available).roomNumber;
    int nights = 2;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          final r = rooms.firstWhere((item) => item.roomNumber == selectedRoom);
          final total = r.rateUsd * nights;

          return Padding(
            padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('New Guest Reservation', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: selectedGuest,
                  decoration: const InputDecoration(labelText: 'Guest', border: OutlineInputBorder()),
                  items: guests.map((g) => DropdownMenuItem(value: g.name, child: Text(g.name))).toList(),
                  onChanged: (val) => setSheetState(() => selectedGuest = val!),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedRoom,
                  decoration: const InputDecoration(labelText: 'Room', border: OutlineInputBorder()),
                  items: rooms.where((r) => r.status == RoomStatus.available).map((r) => DropdownMenuItem(value: r.roomNumber, child: Text('${r.roomNumber} - ${r.name}'))).toList(),
                  onChanged: (val) => setSheetState(() => selectedRoom = val!),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text('Nights: ', style: TextStyle(fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.remove), onPressed: nights > 1 ? () => setSheetState(() => nights--) : null),
                    Text('$nights', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    IconButton(icon: const Icon(Icons.add), onPressed: () => setSheetState(() => nights++)),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total (USD):', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('\$$total', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF10B981))),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white),
                    onPressed: () {
                      final newBk = Booking(
                        id: 'BK-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                        guestName: selectedGuest,
                        guestEmail: 'guest@worldheart.com',
                        roomNumber: r.roomNumber,
                        roomName: r.name,
                        checkIn: DateTime.now(),
                        checkOut: DateTime.now().add(Duration(days: nights)),
                        totalPriceUsd: total,
                      );
                      ref.read(bookingProvider.notifier).createBooking(newBk);
                      Navigator.pop(ctx);
                    },
                    child: const Text('Confirm Reservation'),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookings = ref.watch(bookingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookings Engine', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: Color(0xFF0F172A), size: 28),
            onPressed: () => _openCreateSheet(context, ref),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final b = bookings[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(b.guestName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('\$${b.totalPriceUsd}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 4),
                Text('${b.roomNumber} • ${b.roomName}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                Text('${DateFormat('MMM dd').format(b.checkIn)} → ${DateFormat('MMM dd').format(b.checkOut)}', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('STATUS: ${b.status.name.toUpperCase()}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
                    Wrap(
                      spacing: 8,
                      children: [
                        if (b.status == BookingStatus.booked)
                          OutlinedButton(
                            onPressed: () => ref.read(bookingProvider.notifier).checkIn(b.id),
                            child: const Text('Check In'),
                          ),
                        if (b.status == BookingStatus.checkedIn)
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white),
                            onPressed: () => ref.read(bookingProvider.notifier).checkOut(b.id),
                            child: const Text('Check Out'),
                          ),
                      ],
                    )
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

// ============================================================================
// 5. GUEST DIRECTORY VIEW
// ============================================================================
class GuestDirectoryView extends ConsumerWidget {
  const GuestDirectoryView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final guests = ref.watch(guestProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Guest Directory', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: guests.length,
        itemBuilder: (context, index) {
          final g = guests[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF0F172A),
                foregroundColor: Colors.white,
                child: Text(g.name[0], style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              title: Text(g.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${g.email} • ${g.phone}\n${g.idNumber} • Stays: ${g.totalStays}'),
            ),
          );
        },
      ),
    );
  }
}

// ============================================================================
// 6. AI HOTEL ASSISTANT (Context-Aware Intent Engine & Instant Booking)
// ============================================================================
class AIAssistantView extends ConsumerStatefulWidget {
  const AIAssistantView({super.key});

  @override
  ConsumerState<AIAssistantView> createState() => _AIAssistantViewState();
}

class _AIAssistantViewState extends ConsumerState<AIAssistantView> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  final List<ChatMessage> _messages = [
    ChatMessage(
      role: 'assistant',
      text: 'World Heart Operations AI active. Ask me about room availability, presidential suites, rates in USD, or booking assistance.',
      timestamp: DateTime.now(),
    ),
  ];

  bool _isInjectionAttempt(String text) {
    final forbidden = [
      'ignore previous instructions',
      'system prompt',
      'developer mode',
      'reveal keys',
      'jailbreak',
      'override rules',
    ];
    final lower = text.toLowerCase();
    return forbidden.any((pattern) => lower.contains(pattern));
  }

  void _submitMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isLoading) return;

    if (_isInjectionAttempt(text)) {
      setState(() {
        _messages.add(ChatMessage(role: 'user', text: text, timestamp: DateTime.now()));
        _messages.add(ChatMessage(
          role: 'assistant',
          text: 'Security Warning: Prompt rejected by client-side guardrail filter.',
          timestamp: DateTime.now(),
          isBlocked: true,
        ));
        _controller.clear();
      });
      return;
    }

    setState(() {
      _messages.add(ChatMessage(role: 'user', text: text, timestamp: DateTime.now()));
      _isLoading = true;
      _controller.clear();
    });

    await Future.delayed(const Duration(milliseconds: 500));

    final rooms = ref.read(roomProvider);
    final bookings = ref.read(bookingProvider);
    final availableRooms = rooms.where((r) => r.status == RoomStatus.available).toList();
    final occupiedRooms = rooms.where((r) => r.status == RoomStatus.occupied).length;

    String reply = '';
    Room? offeredRoom;
    final lower = text.toLowerCase();

    // 1. Presidential Suite Inquiries & Booking Intent
    if (lower.contains('presidential')) {
      final presAvailable = rooms.where((r) => r.category == 'Suites' && r.name.contains('Presidential') && r.status == RoomStatus.available).toList();
      if (presAvailable.isNotEmpty) {
        offeredRoom = presAvailable.first;
        reply = 'We have ${presAvailable.length} Presidential Suite(s) available. Room ${offeredRoom.roomNumber} is ready at \$${offeredRoom.rateUsd}/night. It includes a Jacuzzi, Lake View, Butler Service, and high-speed Wi-Fi. Would you like to confirm this reservation now?';
      } else {
        reply = 'All Presidential Suites are currently occupied. Would you like to check an Executive Penthouse at \$380/night instead?';
      }
    }
    // 2. Penthouse Inquiries
    else if (lower.contains('penthouse')) {
      final pentAvailable = rooms.where((r) => r.category == 'Penthouse' && r.status == RoomStatus.available).toList();
      if (pentAvailable.isNotEmpty) {
        offeredRoom = pentAvailable.first;
        reply = 'We have ${pentAvailable.length} Executive Penthouse(s) available. Room ${offeredRoom.roomNumber} is open at \$${offeredRoom.rateUsd}/night with panoramic balconies and private spa.';
      } else {
        reply = 'No Penthouses are available right now.';
      }
    }
    // 3. Lake View Inquiries
    else if (lower.contains('lake')) {
      final lakeAvailable = rooms.where((r) => r.category == 'Lake View' && r.status == RoomStatus.available).toList();
      if (lakeAvailable.isNotEmpty) {
        offeredRoom = lakeAvailable.first;
        reply = 'There are ${lakeAvailable.length} Lake View Grand Suites available at \$${offeredRoom.rateUsd}/night with private balcony and breakfast.';
      } else {
        reply = 'All Lake View suites are currently booked.';
      }
    }
    // 4. General Availability & Counts
    else if (lower.contains('available') || lower.contains('free') || lower.contains('how many')) {
      reply = 'Current Inventory: ${availableRooms.length} rooms available out of 50 total units across all categories.';
    }
    // 5. Occupancy
    else if (lower.contains('occupied') || lower.contains('occupancy')) {
      final rate = ((occupiedRooms / rooms.length) * 100).toStringAsFixed(0);
      reply = 'Current occupancy is at $rate% ($occupiedRooms of 50 rooms occupied).';
    }
    // 6. Check In/Out Policies
    else if (lower.contains('check in') || lower.contains('policy')) {
      reply = 'Check-in is at 2:00 PM. Check-out is 11:00 AM. Completed check-outs automatically trigger cleaning status for housekeeping.';
    }
    // 7. General Booking Help
    else if (lower.contains('book') || lower.contains('reserve')) {
      if (availableRooms.isNotEmpty) {
        offeredRoom = availableRooms.first;
        reply = 'I found an open unit: ${offeredRoom.name} at \$${offeredRoom.rateUsd}/night. Tap below to confirm allocation.';
      } else {
        reply = 'The hotel is fully booked at this time.';
      }
    } else {
      reply = 'I can help you look up rates in USD, check 50-room availability, or allocate rooms immediately. What would you like to do?';
    }

    setState(() {
      _messages.add(ChatMessage(
        role: 'assistant',
        text: reply,
        timestamp: DateTime.now(),
        bookingOfferRoom: offeredRoom,
      ));
      _isLoading = false;
    });
  }

  void _bookOfferedRoom(Room room) {
    final guests = ref.read(guestProvider);
    final newBooking = Booking(
      id: 'BK-AI-${DateTime.now().millisecondsSinceEpoch.toString().substring(9)}',
      guestName: guests.first.name,
      guestEmail: guests.first.email,
      roomNumber: room.roomNumber,
      roomName: room.name,
      checkIn: DateTime.now(),
      checkOut: DateTime.now().add(const Duration(days: 2)),
      totalPriceUsd: room.rateUsd * 2,
      status: BookingStatus.booked,
    );

    ref.read(bookingProvider.notifier).createBooking(newBooking);

    setState(() {
      _messages.add(ChatMessage(
        role: 'assistant',
        text: '✅ Reservation Confirmed! ${room.name} has been allocated to ${guests.first.name} for 2 nights (\$${room.rateUsd * 2} USD). Room status updated to OCCUPIED.',
        timestamp: DateTime.now(),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Hotel Assistant', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22)),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final m = _messages[index];
                final isUser = m.role == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.82),
                    decoration: BoxDecoration(
                      color: isUser ? const Color(0xFF0F172A) : (m.isBlocked ? const Color(0xFFFEF2F2) : Colors.white),
                      borderRadius: BorderRadius.circular(16),
                      border: isUser ? null : Border.all(color: m.isBlocked ? const Color(0xFFFCA5A5) : const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          m.text,
                          style: TextStyle(
                            color: isUser ? Colors.white : (m.isBlocked ? const Color(0xFFDC2626) : const Color(0xFF0F172A)),
                            fontSize: 14,
                            fontWeight: m.isBlocked ? FontWeight.bold : FontWeight.normal,
                            height: 1.35,
                          ),
                        ),
                        if (m.bookingOfferRoom != null) ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              icon: const Icon(Icons.check_circle_outline, size: 18),
                              label: Text('Book ${m.bookingOfferRoom!.roomNumber} (\$${m.bookingOfferRoom!.rateUsd}/night)'),
                              onPressed: () => _bookOfferedRoom(m.bookingOfferRoom!),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading) const LinearProgressIndicator(color: Color(0xFF0F172A)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.white,
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Ask about presidential suites, rates in USD, or booking...',
                        filled: true,
                        fillColor: const Color(0xFFF1F5F9),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      onSubmitted: (_) => _submitMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    style: IconButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white),
                    icon: const Icon(Icons.send, size: 18),
                    onPressed: _submitMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}