# News Reader

Ứng dụng Flutter hiển thị tin tức theo thời gian thực từ **NewsAPI.org**, thiết kế theo phong cách Material 3 hiện đại và áp dụng Clean Architecture (`core / data / domain / presentation`).

![Home screen](assets/ui1.png)

![Detail screen](assets/ui2.png)

## Kiến trúc

- **core**: exceptions, result wrapper, theme + widget dùng chung.
- **data**: REST service, models, repository implementation.
- **domain**: entities, repository contracts, use cases.
- **presentation**: pages, widgets, theme, entry `main.dart`.

## Thiết lập

1. Cài Flutter >= 3.9.2.
2. Tạo file `.env` (hoặc chỉnh sửa file có sẵn) với khóa NewsAPI:

   ```env
   NEWS_API_KEY=6b7a7c2fb73842929110bdd62527ee78
   ```

3. Cài dependency:

   ```bash
   flutter pub get
   ```

4. Chạy ứng dụng:

   ```bash
   flutter run
   ```

## Tính năng chính

- Lấy top headlines theo quốc gia (mặc định `us`) qua `http`.
- Shimmer loading, Retry error, Empty-state rõ ràng.
- Danh sách bài viết với ảnh, tiêu đề, nguồn, thời gian.
- Trang chi tiết có ảnh lớn, mô tả, nội dung và nút mở trình duyệt (`url_launcher`).
- Hỗ trợ light/dark theme tùy hệ thống.

## Công nghệ

- `http`, `intl`, `flutter_dotenv`, `url_launcher`, `shimmer`, `equatable`.
- Clean Architecture + Material 3 UI.
