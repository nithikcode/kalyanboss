enum PostApiStatus {
  initial,
  loading,
  success,
  error,
  locationServiceDisabled,
  permissionDenied,
  permissionDeniedForever,
  loadingMore,
}


enum SortOptions {
  latest_true,
  price_low,
  price_high,
  best_seller
}

enum ValidationType {
  none,
  required,
  email,
  phone,
  minLength,
  custom,
  maxLength
}

enum StoreSearchStatus { initial, loading, success, failure }