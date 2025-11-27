@echo off
chcp 65001 >nul
cls
echo.
echo ╔═══════════════════════════════════════════════════════════╗
echo ║                                                           ║
echo ║      🚀 Création Structure Projet Flutter                ║
echo ║              E-Commerce App                               ║
echo ║                                                           ║
echo ╚═══════════════════════════════════════════════════════════╝
echo.

echo 📁 Création des dossiers...
echo.

REM Core
mkdir lib\core\constants 2>nul
mkdir lib\core\theme 2>nul
mkdir lib\core\utils 2>nul
mkdir lib\core\services 2>nul

REM Data
mkdir lib\data\models 2>nul
mkdir lib\data\repositories 2>nul
mkdir lib\data\providers 2>nul

REM Presentation
mkdir lib\presentation\screens\auth 2>nul
mkdir lib\presentation\screens\admin 2>nul
mkdir lib\presentation\screens\client 2>nul
mkdir lib\presentation\widgets\common 2>nul
mkdir lib\presentation\widgets\product 2>nul
mkdir lib\presentation\widgets\bill 2>nul
mkdir lib\presentation\widgets\cart 2>nul
mkdir lib\presentation\widgets\payment 2>nul
mkdir lib\presentation\dialogs 2>nul

REM Routes
mkdir lib\routes 2>nul

echo ✅ Dossiers créés!
echo.
echo 📄 Création des fichiers...
echo.

REM Root
type nul > lib\main.dart

REM Core - Constants
type nul > lib\core\constants\api_constants.dart
type nul > lib\core\constants\app_colors.dart
type nul > lib\core\constants\app_strings.dart
type nul > lib\core\constants\app_routes.dart

REM Core - Theme
type nul > lib\core\theme\app_theme.dart
type nul > lib\core\theme\text_styles.dart

REM Core - Utils
type nul > lib\core\utils\validators.dart
type nul > lib\core\utils\formatters.dart
type nul > lib\core\utils\helpers.dart

REM Core - Services
type nul > lib\core\services\api_service.dart
type nul > lib\core\services\auth_service.dart
type nul > lib\core\services\storage_service.dart
type nul > lib\core\services\notification_service.dart

REM Data - Models
type nul > lib\data\models\admin_model.dart
type nul > lib\data\models\client_model.dart
type nul > lib\data\models\category_model.dart
type nul > lib\data\models\product_model.dart
type nul > lib\data\models\bill_model.dart
type nul > lib\data\models\bill_item_model.dart
type nul > lib\data\models\payment_model.dart
type nul > lib\data\models\stock_alert_model.dart
type nul > lib\data\models\notification_model.dart

REM Data - Repositories
type nul > lib\data\repositories\admin_repository.dart
type nul > lib\data\repositories\client_repository.dart
type nul > lib\data\repositories\category_repository.dart
type nul > lib\data\repositories\product_repository.dart
type nul > lib\data\repositories\bill_repository.dart
type nul > lib\data\repositories\payment_repository.dart
type nul > lib\data\repositories\stock_alert_repository.dart
type nul > lib\data\repositories\notification_repository.dart

REM Data - Providers
type nul > lib\data\providers\admin_provider.dart
type nul > lib\data\providers\client_provider.dart
type nul > lib\data\providers\category_provider.dart
type nul > lib\data\providers\product_provider.dart
type nul > lib\data\providers\bill_provider.dart
type nul > lib\data\providers\payment_provider.dart
type nul > lib\data\providers\cart_provider.dart
type nul > lib\data\providers\auth_provider.dart

REM Presentation - Screens - Auth
type nul > lib\presentation\screens\auth\login_screen.dart
type nul > lib\presentation\screens\auth\register_screen.dart
type nul > lib\presentation\screens\auth\splash_screen.dart

REM Presentation - Screens - Admin
type nul > lib\presentation\screens\admin\admin_dashboard_screen.dart
type nul > lib\presentation\screens\admin\admin_products_screen.dart
type nul > lib\presentation\screens\admin\admin_categories_screen.dart
type nul > lib\presentation\screens\admin\admin_clients_screen.dart
type nul > lib\presentation\screens\admin\admin_bills_screen.dart
type nul > lib\presentation\screens\admin\admin_payments_screen.dart
type nul > lib\presentation\screens\admin\admin_stock_alerts_screen.dart
type nul > lib\presentation\screens\admin\admin_notifications_screen.dart
type nul > lib\presentation\screens\admin\admin_profile_screen.dart

REM Presentation - Screens - Client
type nul > lib\presentation\screens\client\client_home_screen.dart
type nul > lib\presentation\screens\client\products_list_screen.dart
type nul > lib\presentation\screens\client\product_detail_screen.dart
type nul > lib\presentation\screens\client\cart_screen.dart
type nul > lib\presentation\screens\client\my_bills_screen.dart
type nul > lib\presentation\screens\client\bill_detail_screen.dart
type nul > lib\presentation\screens\client\client_profile_screen.dart

REM Presentation - Widgets - Common
type nul > lib\presentation\widgets\common\custom_app_bar.dart
type nul > lib\presentation\widgets\common\custom_button.dart
type nul > lib\presentation\widgets\common\custom_text_field.dart
type nul > lib\presentation\widgets\common\loading_widget.dart
type nul > lib\presentation\widgets\common\error_widget.dart
type nul > lib\presentation\widgets\common\empty_state_widget.dart

REM Presentation - Widgets - Product
type nul > lib\presentation\widgets\product\product_card.dart
type nul > lib\presentation\widgets\product\product_list_item.dart
type nul > lib\presentation\widgets\product\product_form.dart

REM Presentation - Widgets - Bill
type nul > lib\presentation\widgets\bill\bill_card.dart
type nul > lib\presentation\widgets\bill\bill_item_widget.dart
type nul > lib\presentation\widgets\bill\bill_summary_widget.dart

REM Presentation - Widgets - Cart
type nul > lib\presentation\widgets\cart\cart_item_widget.dart
type nul > lib\presentation\widgets\cart\cart_summary_widget.dart

REM Presentation - Widgets - Payment
type nul > lib\presentation\widgets\payment\payment_card.dart
type nul > lib\presentation\widgets\payment\payment_form.dart

REM Presentation - Dialogs
type nul > lib\presentation\dialogs\add_product_dialog.dart
type nul > lib\presentation\dialogs\add_category_dialog.dart
type nul > lib\presentation\dialogs\add_payment_dialog.dart
type nul > lib\presentation\dialogs\confirmation_dialog.dart

REM Routes
type nul > lib\routes\app_router.dart

echo ✅ Fichiers créés!
echo.
echo ╔═══════════════════════════════════════════════════════════╗
echo ║                                                           ║
echo ║      ✨ Structure créée avec succès! ✨                   ║
echo ║                                                           ║
echo ╚═══════════════════════════════════════════════════════════╝
echo.
echo 📊 Résumé:
echo   📁 ~17 dossiers créés
echo   📄 ~80 fichiers créés
echo.
echo 🎯 Prochaines étapes:
echo   1. Installez les dépendances: flutter pub get
echo   2. Configurez pubspec.yaml
echo   3. Commencez à coder! 🚀
echo.
pause