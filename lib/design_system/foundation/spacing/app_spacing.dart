abstract class AppSpacing {
  const AppSpacing();

  /// Không có khoảng cách.
  double get none;

  /// Extra Small - khoảng cách rất nhỏ (ví dụ: 4px).
  /// Thường dùng giữa icon và text hoặc các phần tử rất gần nhau.
  double get xs;

  /// Small - khoảng cách nhỏ (ví dụ: 8px).
  /// Thường dùng giữa các widget nhỏ.
  double get sm;

  /// Medium - khoảng cách trung bình (ví dụ: 16px).
  /// Đây là khoảng cách được sử dụng phổ biến nhất.
  double get md;

  /// Large - khoảng cách lớn (ví dụ: 24px).
  /// Thường dùng để ngăn cách các nhóm nội dung.
  double get lg;

  /// Extra Large - khoảng cách rất lớn (ví dụ: 32px).
  /// Thường dùng giữa các section hoặc các thành phần quan trọng.
  double get xl;
}
