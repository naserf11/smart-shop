import 'package:flutter/material.dart';

// Auth Screens
import '../screens/auth/splash_screen.dart';
import '../screens/auth/phone_login_screen.dart';
import '../screens/auth/otp_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/create_password_screen.dart';

// Home Screens
import '../screens/home/home_screen.dart';
import '../screens/home/categories_screen.dart';
import '../screens/home/scan_screen.dart';
import '../screens/home/notifications_screen.dart';
import '../screens/home/more_screen.dart';

import '../screens/products/search_screen.dart';
import '../screens/products/filter_screen.dart';

import '../screens/cart/cart_screen.dart';
import '../screens/cart/checkout_screen.dart';
import '../screens/cart/payment_screen.dart';


import '../screens/profile/profile_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/profile/settings_screen.dart';



import '../screens/orders/orders_screen.dart';
import '../screens/orders/order_history_screen.dart';
import '../screens/orders/scheduled_orders_screen.dart';

class AppRoutes {

  static const splash = '/';
  static const login = '/login';
  static const otp = '/otp';
  static const register = '/register';
  static const createPassword = '/createPassword';
  

static const profile = '/profile';
static const editProfile = '/editProfile';
static const settings = '/settings';

static const orders = '/orders';
static const orderHistory = '/orderHistory';
static const scheduledOrders = '/scheduledOrders';
static const help = '/help';
static const search = '/search';
static const filter = '/filter';

static const cart = '/cart';
static const checkout = '/checkout';
static const payment = '/payment';

  static const home = '/home';
  static const categories = '/categories';
  static const scan = '/scan';
  static const notifications = '/notifications';
  static const more = '/more';

  static Map<String, WidgetBuilder> routes = {

    splash: (_) => const SplashScreen(),

    login: (_) => PhoneLoginScreen(),

    otp: (_) => const OTPScreen(),

    register: (_) => RegisterScreen(),

profile: (_) =>
    const ProfileScreen(),

editProfile: (_) =>
    const EditProfileScreen(),

settings: (_) =>
    const SettingsScreen(),


    createPassword: (_) =>
        CreatePasswordScreen(),

    home: (_) => const HomeScreen(),

cart: (_) => const CartScreen(),

checkout: (_) =>
    const CheckoutScreen(),

payment: (_) =>
    const PaymentScreen(),

    categories: (_) =>
        const CategoriesScreen(),

    scan: (_) =>
        const ScanScreen(),

orders: (_) =>
    const OrdersScreen(),

orderHistory: (_) =>
    const OrderHistoryScreen(),

scheduledOrders: (_) =>
    const ScheduledOrdersScreen(),

    notifications: (_) =>
        const NotificationsScreen(),
search: (_) =>
    const SearchScreen(),

filter: (_) =>
    const FilterScreen(),

    more: (_) =>
        const MoreScreen(),
  };
}