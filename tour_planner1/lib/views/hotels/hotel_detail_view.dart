import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import '../../core/models/hotel_model.dart';
import '../../core/services/api_service.dart';
import '../../core/providers/user_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/trips_provider.dart';

class HotelDetailView extends StatefulWidget {
  final String hotelId;
  final Hotel? hotel;

  const HotelDetailView({
    super.key,
    required this.hotelId,
    this.hotel,
  });

  @override
  State<HotelDetailView> createState() => _HotelDetailViewState();
}

class _HotelDetailViewState extends State<HotelDetailView> {
  final ApiService _apiService = ApiService();
  Hotel? _hotel;
  bool _isLoading = true;
  String _errorMessage = '';

  // Booking form variables
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  int _guestCount = 2;
  HotelPackage? _selectedPackage;
  int _roomsToBook = 1;
  bool _isBooking = false;

  @override
  void initState() {
    super.initState();
    if (widget.hotel != null) {
      _hotel = widget.hotel;
      _isLoading = false;
    } else {
      _loadHotelDetails();
    }
  }

  Future<void> _loadHotelDetails() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final response = await _apiService.getHotelById(widget.hotelId);

      if (response['status'] == 'Success' || response.containsKey('hotel')) {
        final hotelData = response['hotel'] ?? response;
        if (context.mounted) {
          setState(() {
            _hotel = Hotel.fromJson(hotelData);
            _isLoading = false;
          });
        }
      } else {
        if (context.mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage =
                response['message'] ?? 'Failed to load hotel details';
          });
        }
      }
    } catch (e) {
      if (context.mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error loading hotel details: $e';
        });
      }
    }
  }

  Future<void> _selectDate(BuildContext context, bool isCheckIn) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          _checkInDate = picked;
          // Reset checkout date if it's before new checkin date
          if (_checkOutDate != null && _checkOutDate!.isBefore(_checkInDate!)) {
            _checkOutDate = null;
          }
        } else {
          _checkOutDate = picked;
        }
        _calculateRoomsNeeded();
      });
    }
  }

  void _calculateRoomsNeeded() {
    if (_selectedPackage != null && _guestCount > 0) {
      setState(() {
        _roomsToBook =
            _selectedPackage!.calculateMaxRoomsForGuests(_guestCount);
      });
    }
  }

  double _calculateTotalPrice() {
    if (_selectedPackage == null ||
        _checkInDate == null ||
        _checkOutDate == null) {
      return 0.0;
    }

    final nights = _checkOutDate!.difference(_checkInDate!).inDays;
    return _selectedPackage!.price * nights * _roomsToBook;
  }

  Future<void> _addToTrip() async {
    if (_selectedPackage == null ||
        _checkInDate == null ||
        _checkOutDate == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select package and dates first'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Check authentication status using AuthProvider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (!authProvider.isAuthenticated) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please login first'),
            backgroundColor: Colors.red,
          ),
        );
      }
      // Navigate to login screen
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
      return;
    }

    // Get user data
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final tripsProvider = Provider.of<TripsProvider>(context, listen: false);

    // Force fetch user data to ensure it's up to date
    await userProvider.fetchUserData();
    final userData = userProvider.userData;

    // Debug print to check user data
    if (kDebugMode) {
      print('User data: $userData');
    }

    // Check if user data is available
    if (userData == null || userData.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User data not available. Please login again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      // Navigate to login screen
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
      return;
    }

    setState(() {
      _isBooking = true;
    });

    try {
      // Create booking data
      final bookingData = {
        'checkInDate': _checkInDate!.toIso8601String(),
        'checkOutDate': _checkOutDate!.toIso8601String(),
        'roomsBooked': _roomsToBook,
        'guestCount': _guestCount,
        'totalPrice': _calculateTotalPrice(),
      };

      // Set context for trips provider to get user ID correctly
      tripsProvider.setContext(context);

      // Add hotel booking to the trip using trips provider (same pattern as places and guides)
      final success = await tripsProvider.addHotelToTrip(
        _hotel!.id,
        _selectedPackage!.id,
        bookingDetails: bookingData,
      );

      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Hotel added to trip successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(tripsProvider.error ?? 'Failed to add hotel to trip'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error adding hotel to trip: $e');
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add hotel to trip: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (context.mounted) {
        setState(() {
          _isBooking = false;
        });
      }
    }
  }

  Widget _buildImageCarousel() {
    if (_hotel!.images.isEmpty) {
      return Container(
        height: 250,
        color: Colors.grey[300],
        child: const Center(
          child: Icon(
            Icons.hotel,
            size: 80,
            color: Colors.grey,
          ),
        ),
      );
    }

    return SizedBox(
      height: 250,
      child: PageView.builder(
        itemCount: _hotel!.images.length,
        itemBuilder: (context, index) {
          return Image.network(
            _hotel!.images[index],
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[300],
                child: const Center(
                  child: Icon(Icons.broken_image, size: 64, color: Colors.grey),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHotelInfo() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _hotel!.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.red, size: 20),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${_hotel!.address}, ${_hotel!.city}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 20),
              const SizedBox(width: 4),
              Text(
                '${_hotel!.ratings.overall.toStringAsFixed(1)} (${_hotel!.ratings.totalReviews} reviews)',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _hotel!.description,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenities() {
    if (_hotel!.amenities.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Amenities',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _hotel!.amenities.map((amenity) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  amenity,
                  style: TextStyle(
                    color: Colors.blue[800],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPackagesList() {
    final activePackages =
        _hotel!.packages.where((p) => p.isValidForBooking).toList();

    if (activePackages.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'No active packages available',
          style: TextStyle(fontSize: 16, color: Colors.red),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Available Packages',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...activePackages.map((package) => _buildPackageCard(package)),
        ],
      ),
    );
  }

  Widget _buildPackageCard(HotelPackage package) {
    final isSelected = _selectedPackage?.id == package.id;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? const BorderSide(color: Colors.purple, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() {
            _selectedPackage = package;
            _calculateRoomsNeeded();
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      package.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    'LKR ${package.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                package.description,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${package.roomCapacity} guest${package.roomCapacity > 1 ? 's' : ''}/room',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    '${package.availableRooms} left',
                    style: TextStyle(
                      fontSize: 12,
                      color: package.availableRooms > 0
                          ? Colors.green
                          : Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              if (package.includedServices.isNotEmpty) ...[
                const SizedBox(height: 6),
                Wrap(
                  spacing: 4,
                  runSpacing: 2,
                  children: package.includedServices.take(3).map((service) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        service,
                        style: const TextStyle(
                          fontSize: 10,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookingForm() {
    if (_selectedPackage == null) return const SizedBox.shrink();

    final roomsNeeded = (_guestCount / _selectedPackage!.roomCapacity).ceil();
    final maxRoomsAvailable = _selectedPackage!.availableRooms;
    final canBookAllRooms = roomsNeeded <= maxRoomsAvailable;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Booking Details',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),

          // Guest count
          Row(
            children: [
              const Text(
                'Guests: ',
                style: TextStyle(fontSize: 14),
              ),
              const Spacer(),
              IconButton(
                onPressed: _guestCount > 1
                    ? () {
                        setState(() {
                          _guestCount--;
                          _calculateRoomsNeeded();
                        });
                      }
                    : null,
                icon: const Icon(Icons.remove, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '$_guestCount',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _guestCount++;
                    _calculateRoomsNeeded();
                  });
                },
                icon: const Icon(Icons.add, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Date selection
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _selectDate(context, true),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Check-in',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          _checkInDate != null
                              ? '${_checkInDate!.day}/${_checkInDate!.month}/${_checkInDate!.year}'
                              : 'Select date',
                          style: TextStyle(
                            fontSize: 13,
                            color: _checkInDate != null
                                ? Colors.black
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InkWell(
                  onTap: _checkInDate != null
                      ? () => _selectDate(context, false)
                      : null,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Check-out',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          _checkOutDate != null
                              ? '${_checkOutDate!.day}/${_checkOutDate!.month}/${_checkOutDate!.year}'
                              : 'Select date',
                          style: TextStyle(
                            fontSize: 13,
                            color: _checkOutDate != null
                                ? Colors.black
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Room capacity warning
          if (!canBookAllRooms) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Only $maxRoomsAvailable room${maxRoomsAvailable > 1 ? 's' : ''} available. You need $roomsNeeded room${roomsNeeded > 1 ? 's' : ''} for $_guestCount guest${_guestCount > 1 ? 's' : ''}.',
                style: TextStyle(
                  color: Colors.red[800],
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Booking summary
          if (_checkInDate != null && _checkOutDate != null) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Booking Summary',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Rooms:',
                        style: TextStyle(fontSize: 13),
                      ),
                      Text(
                        '$_roomsToBook',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Nights:',
                        style: TextStyle(fontSize: 13),
                      ),
                      Text(
                        '${_checkOutDate!.difference(_checkInDate!).inDays}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'LKR ${_calculateTotalPrice().toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canAddToTrip = _hotel != null &&
        _selectedPackage != null &&
        _checkInDate != null &&
        _checkOutDate != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(_hotel?.name ?? 'Hotel Details'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _errorMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadHotelDetails,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _hotel == null
                  ? const Center(child: Text('Hotel not found'))
                  : Stack(
                      children: [
                        SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildImageCarousel(),
                              _buildHotelInfo(),
                              _buildAmenities(),
                              _buildPackagesList(),
                              _buildBookingForm(),
                              const SizedBox(height: 100), // Space for button
                            ],
                          ),
                        ),
                        // Add to Trip button at the bottom
                        if (canAddToTrip)
                          Positioned(
                            bottom: 16,
                            left: 16,
                            right: 16,
                            child: SizedBox(
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _isBooking ? null : _addToTrip,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: _isBooking
                                    ? const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      Colors.white),
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Text(
                                            'Adding to Trip...',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      )
                                    : const Text(
                                        'Add to Trip',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                              ),
                            ),
                          ),
                      ],
                    ),
    );
  }
}
