import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:shop/manager/home/controller/women/search/search_women_controller.dart';

import '../../../../../core/constants/routes.dart';
import '../../../../../core/enum/status_request.dart';
import '../../../../../core/functions/handling_data.dart';
import '../../../../../core/services/services.dart';
import '../../../../../model/banner_model.dart';
import '../../../../../model/brands_model.dart';
import '../../../../../model/products_model.dart';
import '../../../offers/data/brands/fetch_brands_remote_datasource.dart';
import '../../data/all_women/all_women_products_remote_datasource.dart';
import '../../data/banners/fetch_banners_remote_datasource.dart';

abstract class AllWomenController extends SearchWomenController {
  fetchWomen();
  checkProductStock(int value);
  goToDetailProduct(ProductModel productModel);
  fetchBanners();
  fetchBrands();
  onPageChanged(int index);
}

class AllWomenControllerImpl extends AllWomenController {
  AllWomenProductsRemoteDataSource allWomenProductsRemoteDataSource =
      AllWomenProductsRemoteDataSource(Get.find());
  FetchBannersRemoteDataSource fetchBannersRemoteDataSource =
      FetchBannersRemoteDataSource(Get.find());
  FetchBrandsRemoteDataSource fetchBrandsRemoteDataSource =
      FetchBrandsRemoteDataSource(Get.find());
  StatusRequest statusRequest = StatusRequest.none;
  AppServices appServices = Get.find();
  List<ProductModel> women = [];
  int deliveryTime = 0;
  List<BannerModel> banners = [];
  List<BrandsModel> brands = [];
  int currentPage = 0;
  late PageController pageController;
  String username = "";
  @override
  checkProductStock(int value) {
    if (value != 0) {
      return "In Stock";
    } else {
      return "Out of stock";
    }
  }

  @override
  fetchWomen() async {
    statusRequest = StatusRequest.loading;
    var response = await allWomenProductsRemoteDataSource.allWomenProducts();
    statusRequest = handlingData(response);
    print("------------------------ Controller $response");
    print(response);
    if (StatusRequest.success == statusRequest) {
      if (response['status'] == "success") {
        List responseData = response["data"];
        women.addAll(responseData.map((e) => ProductModel.fromJson(e)));
      } else {
        statusRequest = StatusRequest.failure;
      }
    }
    update();
  }

  @override
  goToDetailProduct(ProductModel productModel) {
    Get.toNamed(AppRoutes.detailProduct,
        arguments: {"productModel": productModel});
  }

  @override
  void onInit() {
    searchWomenController = TextEditingController();
    deliveryTime = appServices.sharedPreferences.getInt("deliveryTime")!;
    username = appServices.sharedPreferences.getString("username")!;
    print("my delivery time is $deliveryTime");
    pageController = PageController(initialPage: 0);
    fetchWomen();
    fetchBanners();
    fetchBrands();
    super.onInit();
  }

  @override
  fetchBanners() async {
    statusRequest = StatusRequest.loading;
    var response = await fetchBannersRemoteDataSource.fetchBanners();
    statusRequest = handlingData(response);
    print(
        "------------------------------------------------------------------------ Controller $response");
    print(response);
    if (StatusRequest.success == statusRequest) {
      if (response['status'] == "success") {
        List responseData = response['data'];
        banners.addAll(responseData.map((e) => BannerModel.fromJson(e)));
      } else {
        statusRequest = StatusRequest.failure;
      }
    }
    update();
  }

  @override
  onPageChanged(int index) {
    currentPage = index;
    update();
  }

  @override
  fetchBrands() async {
    statusRequest = StatusRequest.loading;
    var response = await fetchBrandsRemoteDataSource.fetchBrands();
    statusRequest = handlingData(response);
    print(
        "------------------------------------------------------------------------ Controller $response");
    print(response);
    if (StatusRequest.success == statusRequest) {
      if (response['status'] == "success") {
        List responseData = response['data'];
        brands.addAll(responseData.map((e) => BrandsModel.fromJson(e)));
      } else {
        statusRequest = StatusRequest.failure;
      }
    }
    update();
  }
}