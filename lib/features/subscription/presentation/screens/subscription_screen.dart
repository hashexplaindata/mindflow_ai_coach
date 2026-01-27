import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/services/api_service.dart';
import '../../../auth/presentation/providers/user_provider.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool _isAnnual = true;
  bool _isLoading = true;
  bool _isSubscribing = false;
  List<Map<String, dynamic>> _products = [];
  String? _monthlyPriceId;
  String? _annualPriceId;
  String _monthlyPrice = '\$9.99';
  String _annualPrice = '\$79.99';

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final apiService = ApiService();
      final products = await apiService.getProducts();
      
      setState(() {
        _products = products;
        
        for (final product in products) {
          final prices = product['prices'] as List? ?? [];
          for (final price in prices) {
            final recurring = price['recurring'];
            final interval = recurring?['interval'];
            final unitAmount = price['unit_amount'] as int? ?? 0;
            final priceStr = '\$${(unitAmount / 100).toStringAsFixed(2)}';
            
            if (interval == 'month') {
              _monthlyPriceId = price['id'];
              _monthlyPrice = priceStr;
            } else if (interval == 'year') {
              _annualPriceId = price['id'];
              _annualPrice = priceStr;
            }
          }
        }
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading products: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.jobsCream,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: AppColors.jobsObsidian,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primaryOrange, AppColors.primaryOrangeDark],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.workspace_premium, size: 16, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'PREMIUM',
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                
                const SizedBox(height: AppSpacing.spacing32),
                
                const Text(
                  'Unlock Your\nFull Potential',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: AppColors.jobsObsidian,
                    height: 1.15,
                    letterSpacing: -0.5,
                  ),
                ),
                
                const SizedBox(height: AppSpacing.spacing32),
                
                const Text(
                  'FREE FEATURES',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.jobsSage,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.spacing16),
                
                _FeatureItem(
                  icon: Icons.check_circle,
                  text: 'Basic meditation sessions',
                  isIncluded: true,
                ),
                _FeatureItem(
                  icon: Icons.check_circle,
                  text: 'Daily reminders',
                  isIncluded: true,
                ),
                _FeatureItem(
                  icon: Icons.check_circle,
                  text: 'Progress tracking',
                  isIncluded: true,
                ),
                
                const SizedBox(height: AppSpacing.spacing24),
                
                const Text(
                  'PREMIUM FEATURES',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryOrange,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.spacing16),
                
                _FeatureItem(
                  icon: Icons.star,
                  text: 'All meditation sessions',
                  isIncluded: false,
                  isPremium: true,
                ),
                _FeatureItem(
                  icon: Icons.star,
                  text: 'Sleep stories & soundscapes',
                  isIncluded: false,
                  isPremium: true,
                ),
                _FeatureItem(
                  icon: Icons.star,
                  text: 'Personalized recommendations',
                  isIncluded: false,
                  isPremium: true,
                ),
                _FeatureItem(
                  icon: Icons.star,
                  text: 'Offline downloads',
                  isIncluded: false,
                  isPremium: true,
                ),
                _FeatureItem(
                  icon: Icons.star,
                  text: 'Priority support',
                  isIncluded: false,
                  isPremium: true,
                ),
                
                const SizedBox(height: AppSpacing.spacing32),
                
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  Row(
                    children: [
                      Expanded(
                        child: _PricingCard(
                          title: 'Monthly',
                          price: _monthlyPrice,
                          period: '/month',
                          isSelected: !_isAnnual,
                          onTap: () => setState(() => _isAnnual = false),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _PricingCard(
                          title: 'Annual',
                          price: _annualPrice,
                          period: '/year',
                          savings: 'Save 33%',
                          isSelected: _isAnnual,
                          onTap: () => setState(() => _isAnnual = true),
                        ),
                      ),
                    ],
                  ),
                
                const SizedBox(height: AppSpacing.spacing24),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubscribing ? null : () => _handleSubscribe(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.jobsObsidian,
                      foregroundColor: AppColors.jobsCream,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                    child: _isSubscribing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(AppColors.jobsCream),
                            ),
                          )
                        : const Text(
                            'Subscribe Now',
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                
                const SizedBox(height: AppSpacing.spacing16),
                
                Center(
                  child: Text(
                    'Cancel anytime. No commitments.',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 13,
                      color: AppColors.jobsObsidian.withOpacity(0.5),
                    ),
                  ),
                ),
                
                const SizedBox(height: AppSpacing.spacing24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleSubscribe(BuildContext context) async {
    final priceId = _isAnnual ? _annualPriceId : _monthlyPriceId;
    
    if (priceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No pricing available. Please try again later.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
      return;
    }

    setState(() => _isSubscribing = true);

    try {
      final userProvider = context.read<UserProvider>();
      final apiService = ApiService();
      
      final checkoutUrl = await apiService.createCheckoutSession(
        priceId: priceId,
        userId: userProvider.userId,
        email: userProvider.email,
      );

      if (checkoutUrl != null) {
        final uri = Uri.parse(checkoutUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          
          await Future.delayed(const Duration(seconds: 2));
          await userProvider.refreshSubscriptionStatus();
          
          if (mounted) {
            Navigator.of(context).pop();
          }
        } else {
          throw Exception('Could not launch checkout URL');
        }
      }
    } catch (e) {
      debugPrint('Subscription error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubscribing = false);
      }
    }
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isIncluded;
  final bool isPremium;

  const _FeatureItem({
    required this.icon,
    required this.text,
    required this.isIncluded,
    this.isPremium = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isPremium ? AppColors.primaryOrange : AppColors.jobsSage,
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 15,
              color: AppColors.jobsObsidian.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _PricingCard extends StatelessWidget {
  final String title;
  final String price;
  final String period;
  final String? savings;
  final bool isSelected;
  final VoidCallback onTap;

  const _PricingCard({
    required this.title,
    required this.price,
    required this.period,
    this.savings,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.jobsObsidian : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: isSelected ? null : Border.all(
            color: AppColors.jobsObsidian.withOpacity(0.1),
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (savings != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected 
                    ? AppColors.primaryOrange 
                    : AppColors.primaryOrange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  savings!,
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : AppColors.primaryOrange,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            Text(
              title,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white.withOpacity(0.7) : AppColors.jobsObsidian.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : AppColors.jobsObsidian,
                  ),
                ),
                const SizedBox(width: 2),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    period,
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 12,
                      color: isSelected ? Colors.white.withOpacity(0.6) : AppColors.jobsObsidian.withOpacity(0.5),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
