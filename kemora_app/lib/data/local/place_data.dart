class PlaceInfo {
  final String id;
  final String name;
  final String category;
  final String location;
  final double rating;
  final int reviewsCount;
  final String price;
  final String distance;
  final String description;
  final String governorateId;
  final List<String> tags;
  final String? imageAsset;

  const PlaceInfo({
    required this.id,
    required this.name,
    required this.category,
    required this.location,
    required this.rating,
    required this.reviewsCount,
    required this.price,
    required this.distance,
    required this.description,
    required this.governorateId,
    this.tags = const [],
    this.imageAsset,
  });
}

final List<PlaceInfo> placesData = [
  // ── Giza (g2) ───────────────────────────────────────────────────
  const PlaceInfo(
    id: 'p1', name: 'Great Pyramid of Giza', category: 'Ancient Places',
    location: 'Giza, Cairo', rating: 4.9, reviewsCount: 25000,
    price: 'EGP 500', distance: '15 km away', governorateId: 'g2',
    tags: ['Historical', 'UNESCO', 'Wonder'],
    imageAsset: 'assets/images/mocked/ThePyramids.png',
    description: 'The defining symbol of Egypt and the last of the ancient Seven Wonders of the World.',
  ),
  const PlaceInfo(
    id: 'p12', name: 'Marriott Mena House', category: 'Hotels',
    location: 'Giza, Egypt', rating: 4.7, reviewsCount: 8000,
    price: 'From EGP 12,000', distance: '0.5 km away', governorateId: 'g2',
    tags: ['Luxury', 'Pyramid View'],
    description: 'Historic hotel at the base of the Pyramids of Giza spanning over a century.',
  ),
  // ── Cairo (g1) ──────────────────────────────────────────────────
  const PlaceInfo(
    id: 'p5', name: 'Egyptian Museum', category: 'Museums',
    location: 'Tahrir Square, Cairo', rating: 4.7, reviewsCount: 15000,
    price: 'EGP 450', distance: '8 km away', governorateId: 'g1',
    tags: ['Museum', 'Cultural', 'History'],
    imageAsset: 'assets/images/mocked/CairoTower.jpg',
    description: 'Home to 120,000 items of ancient Egyptian antiquities.',
  ),
  const PlaceInfo(
    id: 'p6', name: 'Khan el-Khalili', category: 'Others',
    location: 'Islamic Cairo, Cairo', rating: 4.6, reviewsCount: 12000,
    price: 'Free Entry', distance: '10 km away', governorateId: 'g1',
    tags: ['Market', 'Shopping', 'Cultural'],
    description: 'A famous bazaar and souq in the historic center of Cairo.',
  ),
  const PlaceInfo(
    id: 'p13', name: 'Abou El Sid', category: 'Restaurants',
    location: 'Zamalek, Cairo', rating: 4.5, reviewsCount: 3000,
    price: 'EGP 600 - 1500', distance: '12 km away', governorateId: 'g1',
    tags: ['Dining', 'Egyptian Cuisine'],
    description: 'One of Cairo\'s most renowned restaurants offering authentic Egyptian cuisine.',
  ),
  const PlaceInfo(
    id: 'p16', name: 'Cairo Tower', category: 'Others',
    location: 'Gezira Island, Cairo', rating: 4.5, reviewsCount: 9000,
    price: 'EGP 200', distance: '9 km away', governorateId: 'g1',
    tags: ['Landmark', 'Panoramic View', 'Fun'],
    imageAsset: 'assets/images/mocked/CairoTower.jpg',
    description: 'A 187m concrete tower offering panoramic views of Cairo.',
  ),
  const PlaceInfo(
    id: 'p17', name: 'Al-Azhar Park', category: 'Others',
    location: 'Salah Salem, Cairo', rating: 4.6, reviewsCount: 7000,
    price: 'EGP 50', distance: '11 km away', governorateId: 'g1',
    tags: ['Park', 'Fun', 'Family'],
    description: 'A beautiful park on a hill in Islamic Cairo with great views.',
  ),
  // ── Luxor (g4) ──────────────────────────────────────────────────
  const PlaceInfo(
    id: 'p2', name: 'Luxor Temple', category: 'Ancient Places',
    location: 'Luxor City, Luxor', rating: 4.8, reviewsCount: 18000,
    price: 'EGP 400', distance: '2 km away', governorateId: 'g4',
    tags: ['Temple', 'Ancient Egypt', 'Cultural'],
    description: 'A large Ancient Egyptian temple complex on the east bank of the Nile.',
  ),
  const PlaceInfo(
    id: 'p3', name: 'Karnak Temple', category: 'Ancient Places',
    location: 'Karnak, Luxor', rating: 4.9, reviewsCount: 22000,
    price: 'EGP 450', distance: '5 km away', governorateId: 'g4',
    tags: ['Temple', 'UNESCO', 'Colossal'],
    description: 'A vast mix of temples, chapels, pylons from Senusret I to the Ptolemaic period.',
  ),
  const PlaceInfo(
    id: 'p4', name: 'Valley of the Kings', category: 'Ancient Places',
    location: 'West Bank, Luxor', rating: 4.9, reviewsCount: 20000,
    price: 'EGP 600', distance: '12 km away', governorateId: 'g4',
    tags: ['Tombs', 'Pharaohs', 'UNESCO'],
    description: 'Rock-cut tombs for pharaohs and nobles of the New Kingdom.',
  ),
  const PlaceInfo(
    id: 'p14', name: 'Sofra Restaurant & Cafe', category: 'Restaurants',
    location: 'Luxor City, Luxor', rating: 4.6, reviewsCount: 2000,
    price: 'EGP 300 - 800', distance: '3 km away', governorateId: 'g4',
    tags: ['Traditional', 'Local Cuisine', 'Dining'],
    description: 'Housed in a 1930s traditional Egyptian home with classic local recipes.',
  ),
  // ── Aswan (g5) ──────────────────────────────────────────────────
  const PlaceInfo(
    id: 'p7', name: 'Philae Temple', category: 'Ancient Places',
    location: 'Aswan, Egypt', rating: 4.8, reviewsCount: 10000,
    price: 'EGP 450', distance: '7 km away', governorateId: 'g5',
    tags: ['Island Temple', 'Isis', 'UNESCO'],
    description: 'An Egyptian temple complex on an island near the First Cataract of the Nile.',
  ),
  const PlaceInfo(
    id: 'p8', name: 'Abu Simbel', category: 'Ancient Places',
    location: 'Aswan Governorate', rating: 4.9, reviewsCount: 14000,
    price: 'EGP 615', distance: '280 km away', governorateId: 'g5',
    tags: ['UNESCO', 'Ramesses II', 'Monumental'],
    description: 'Two massive rock-cut temples near the border with Sudan.',
  ),
  const PlaceInfo(
    id: 'p11', name: 'Old Cataract Hotel', category: 'Hotels',
    location: 'Aswan, Egypt', rating: 4.9, reviewsCount: 5000,
    price: 'From EGP 15,000', distance: '1 km away', governorateId: 'g5',
    tags: ['Legendary', 'Nile View', 'Luxury'],
    description: 'Historic 5-star luxury resort built in 1899 on the banks of the Nile.',
  ),
  // ── Alexandria (g3) ─────────────────────────────────────────────
  const PlaceInfo(
    id: 'p9', name: 'Qaitbay Citadel', category: 'Ancient Places',
    location: 'Alexandria', rating: 4.7, reviewsCount: 9000,
    price: 'EGP 150', distance: '3 km away', governorateId: 'g3',
    tags: ['Fortress', 'Mediterranean', 'History'],
    imageAsset: 'assets/images/mocked/Alexandria.png',
    description: 'A 15th-century fortress on the Mediterranean sea coast.',
  ),
  const PlaceInfo(
    id: 'p10', name: 'Bibliotheca Alexandrina', category: 'Museums',
    location: 'Alexandria', rating: 4.8, reviewsCount: 11000,
    price: 'EGP 150', distance: '2 km away', governorateId: 'g3',
    tags: ['Library', 'Modern', 'Cultural'],
    description: 'A major library and cultural center commemorating the ancient Library.',
  ),
  const PlaceInfo(
    id: 'p18', name: 'Stanley Bridge', category: 'Others',
    location: 'Stanley, Alexandria', rating: 4.4, reviewsCount: 5000,
    price: 'Free Entry', distance: '5 km away', governorateId: 'g3',
    tags: ['Landmark', 'Fun', 'Scenic'],
    description: 'An iconic modern bridge and popular gathering spot along the corniche.',
  ),
  // ── Red Sea (g6) ────────────────────────────────────────────────
  const PlaceInfo(
    id: 'p19', name: 'Hurghada Marina', category: 'Others',
    location: 'Hurghada, Red Sea', rating: 4.5, reviewsCount: 6000,
    price: 'Free Entry', distance: '1 km away', governorateId: 'g6',
    tags: ['Marina', 'Fun', 'Nightlife'],
    description: 'A vibrant waterfront area with restaurants, cafés and boat trips.',
  ),
  const PlaceInfo(
    id: 'p20', name: 'Giftun Island', category: 'Others',
    location: 'Red Sea Coast', rating: 4.8, reviewsCount: 8000,
    price: 'EGP 600', distance: '12 km away', governorateId: 'g6',
    tags: ['Beach', 'Snorkeling', 'Nature'],
    description: 'Protected island with crystal-clear water and stunning coral reefs.',
  ),
  // ── South Sinai (g7) ────────────────────────────────────────────
  const PlaceInfo(
    id: 'p15', name: 'Ras Mohammed Park', category: 'Others',
    location: 'Sharm El Sheikh', rating: 4.9, reviewsCount: 13000,
    price: 'EGP 200', distance: '20 km away', governorateId: 'g7',
    tags: ['Nature', 'Diving', 'Snorkeling'],
    description: 'A national park renowned for its spectacular coral reefs.',
  ),
  const PlaceInfo(
    id: 'p21', name: 'St. Catherine Monastery', category: 'Ancient Places',
    location: 'St. Catherine', rating: 4.8, reviewsCount: 7000,
    price: 'Free Entry', distance: '200 km away', governorateId: 'g7',
    tags: ['Religious', 'UNESCO', 'Historical'],
    description: 'One of the oldest Christian monasteries, at the foot of Mount Sinai.',
  ),
  // ── Matrouh (g8) ────────────────────────────────────────────────
  const PlaceInfo(
    id: 'p22', name: 'Siwa Oasis', category: 'Others',
    location: 'Siwa, Matrouh', rating: 4.8, reviewsCount: 6000,
    price: 'Free Entry', distance: '300 km away', governorateId: 'g8',
    tags: ['Oasis', 'Desert', 'Nature'],
    description: 'An urban oasis between the Qattara Depression and the Great Sand Sea.',
  ),
  const PlaceInfo(
    id: 'p23', name: 'Cleopatra Spring', category: 'Others',
    location: 'Siwa, Matrouh', rating: 4.5, reviewsCount: 4000,
    price: 'EGP 50', distance: '305 km away', governorateId: 'g8',
    tags: ['Spring', 'Natural', 'Fun'],
    description: 'A natural spring pool where Cleopatra is said to have bathed.',
  ),
  // ── Faiyum (g22) ────────────────────────────────────────────────
  const PlaceInfo(
    id: 'p24', name: 'Wadi El Rayan', category: 'Others',
    location: 'Faiyum', rating: 4.7, reviewsCount: 5000,
    price: 'EGP 100', distance: '90 km away', governorateId: 'g22',
    tags: ['Waterfall', 'Nature', 'Desert'],
    description: 'A nature reserve with Egypt\'s only waterfalls and stunning desert lakes.',
  ),
  const PlaceInfo(
    id: 'p25', name: 'Lake Qarun', category: 'Others',
    location: 'Faiyum', rating: 4.3, reviewsCount: 3000,
    price: 'Free Entry', distance: '85 km away', governorateId: 'g22',
    tags: ['Lake', 'Bird Watching', 'Nature'],
    description: 'One of the oldest natural lakes in the world.',
  ),
  // ── New Valley (g9) ─────────────────────────────────────────────
  const PlaceInfo(
    id: 'p26', name: 'White Desert', category: 'Others',
    location: 'Farafra, New Valley', rating: 4.9, reviewsCount: 7000,
    price: 'EGP 200', distance: '450 km away', governorateId: 'g9',
    tags: ['Desert', 'Adventure', 'Camping'],
    description: 'Surreal white chalk rock formations in the Western Desert.',
  ),
  // ── Port Said (g11) ─────────────────────────────────────────────
  const PlaceInfo(
    id: 'p27', name: 'Port Said Military Museum', category: 'Museums',
    location: 'Port Said', rating: 4.4, reviewsCount: 2000,
    price: 'EGP 30', distance: '2 km away', governorateId: 'g11',
    tags: ['Museum', 'History', 'Cultural'],
    description: 'Exhibits from the 1956 Suez Crisis and the city\'s heroic defense.',
  ),
  // ── Ismailia (g13) ──────────────────────────────────────────────
  const PlaceInfo(
    id: 'p28', name: 'Ismailia Museum', category: 'Museums',
    location: 'Ismailia', rating: 4.3, reviewsCount: 1500,
    price: 'EGP 40', distance: '1 km away', governorateId: 'g13',
    tags: ['Museum', 'Canal History', 'Cultural'],
    description: 'Small but rich museum showcasing Suez Canal history.',
  ),
  // ── Sohag (g26) ─────────────────────────────────────────────────
  const PlaceInfo(
    id: 'p29', name: 'Abydos Temple', category: 'Ancient Places',
    location: 'Abydos, Sohag', rating: 4.8, reviewsCount: 6000,
    price: 'EGP 200', distance: '160 km away', governorateId: 'g26',
    tags: ['Temple', 'Ancient Egypt', 'Osiris'],
    description: 'One of the most important sites — the cult center of Osiris.',
  ),
  // ── Qena (g27) ──────────────────────────────────────────────────
  const PlaceInfo(
    id: 'p30', name: 'Dendera Temple', category: 'Ancient Places',
    location: 'Qena', rating: 4.7, reviewsCount: 5000,
    price: 'EGP 200', distance: '60 km away', governorateId: 'g27',
    tags: ['Temple', 'Hathor', 'Zodiac'],
    description: 'Temple complex dedicated to Hathor, famous for its ceiling.',
  ),
  // ── Minya (g24) ─────────────────────────────────────────────────
  const PlaceInfo(
    id: 'p31', name: 'Beni Hasan Tombs', category: 'Ancient Places',
    location: 'Minya', rating: 4.6, reviewsCount: 3000,
    price: 'EGP 100', distance: '20 km away', governorateId: 'g24',
    tags: ['Tombs', 'Middle Kingdom', 'Historical'],
    description: 'Rock-cut tombs of Middle Kingdom officials with vivid wall paintings.',
  ),
  // ── Beheira (g20) ───────────────────────────────────────────────
  const PlaceInfo(
    id: 'p32', name: 'Wadi El Natrun Monasteries', category: 'Others',
    location: 'Beheira', rating: 4.6, reviewsCount: 4000,
    price: 'Free Entry', distance: '100 km away', governorateId: 'g20',
    tags: ['Religious', 'Monastery', 'Cultural'],
    description: 'Coptic Christian monasteries dating back to the 4th century.',
  ),
  // ── North Sinai (g10) ───────────────────────────────────────────
  const PlaceInfo(
    id: 'p33', name: 'Zaranik Protectorate', category: 'Others',
    location: 'North Sinai', rating: 4.4, reviewsCount: 1500,
    price: 'EGP 50', distance: '30 km away', governorateId: 'g10',
    tags: ['Nature', 'Bird Watching', 'Wetland'],
    description: 'An important wetland and bird migration stop.',
  ),
  // ── Suez (g12) ──────────────────────────────────────────────────
  const PlaceInfo(
    id: 'p34', name: 'Ain Mousa', category: 'Others',
    location: 'Suez', rating: 4.2, reviewsCount: 2000,
    price: 'Free Entry', distance: '5 km away', governorateId: 'g12',
    tags: ['Religious', 'Spring', 'Historical'],
    description: 'Biblical site where Moses is said to have struck a rock.',
  ),
];
