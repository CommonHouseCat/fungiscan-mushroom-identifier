# Dàn Ý Chi Tiết Báo Cáo Luận Văn Tốt Nghiệp (Đã Chỉnh Sửa)
## Đề Tài: Xây dựng Ứng dụng Di động Nhận diện Nấm

---

### PHẦN MỞ ĐẦU (Trang Bìa, Lời Cam Đoan, Lời Cảm Ơn, Mục Lục...)

1.  **Trang Bìa Chính**
2.  **Lời Cam Đoan**
3.  **Lời Cảm Ơn** (1 trang)
4.  **Mục Lục** (1-2 trang trống)
5.  **Danh Mục Hình Ảnh, Bảng Biểu, Thuật Ngữ Viết Tắt**

---

### CHƯƠNG 1: MỞ ĐẦU (INTRODUCTION)

**1.1. Lý do chọn đề tài**
**1.2. Mục tiêu nghiên cứu**
**1.3. Phạm vi nghiên cứu**
**1.4. Bố cục báo cáo**

---

### CHƯƠNG 2: CƠ SỞ LÝ THUYẾT VÀ CÔNG NGHỆ (THEORETICAL FOUNDATION & TECHNOLOGY)

**2.1. Tổng quan về Nấm và Phân loại**
* Đặc điểm sinh học và tầm quan trọng.
* Thách thức trong việc nhận diện nấm bằng hình ảnh.

**2.2. Các Phương pháp Học sâu (Deep Learning) trong Nhận diện Hình ảnh**
* Tổng quan về Mạng Tích chập (CNN) và Mạng Chuyển đổi Hình ảnh (Vision Transformer - ViT).

* **4 Phương pháp Tiếp cận Mô hình Baseline (Baseline Model Approaches):**
    * Baseline 1: Mạng Chuyển đổi Hình ảnh thuần (ViT) - Huấn luyện Đầu-cuối (End-to-end Finetuning).
    * Baseline 2: Mạng Tích chập thuần (CNN - MobileNetV3 Large) - Huấn luyện Đầu-cuối.
    * Baseline 3 (Hybrid ML): Trích xuất Đặc trưng từ ViT Đóng băng (Frozen ViT) + Phân loại bằng các thuật toán Machine Learning truyền thống (Logistic Regression, SVM, XGBOOST).
    * Baseline 4 (Hybrid ML): Trích xuất Đặc trưng từ CNN Đóng băng (Frozen MobileNetV3 Large) + Phân loại bằng các thuật toán Machine Learning truyền thống (Logistic Regression, SVM, XGBOOST).
    
* **Mô hình Đề xuất (Recommended Model):**
    * Giới thiệu kiến trúc Hybrid ViT + CNN (Kết hợp hai nhánh ViT và CNN)
    * Cơ chế Hợp nhất Chú ý (Attention Fusion) để kết hợp đặc trưng từ hai nhánh.
    * Sử dụng Bộ phân loại phi tuyến tính (Non-Linear Classifier).
    * Phương pháp Huấn luyện: Full Fine-tuning.

* **Khung Học sâu PyTorch:**
    * Giới thiệu về PyTorch và lý do lựa chọn cho việc huấn luyện mô hình.
* Các phương pháp đánh giá mô hình (Metrics).

**2.3. Công nghệ phát triển Ứng dụng Di động và Triển khai (Deployment)**
* **Nền tảng Flutter:**
    * Ưu điểm của Flutter (multi-platform, hiệu năng) và lý do lựa chọn.
* **Database Cục bộ SQLite::**
    *  Giới thiệu về SQLite và vai trò quản lý dữ liệu trên thiết bị.
* **Triển khai Mô hình trên Server (lighting.ai):**
    * Vai trò của server/cloud hosting (lighting.ai) trong việc cung cấp API nhận diện.
    * Quy trình tối ưu và đóng gói mô hình (ví dụ: thành file ONNX/TorchScript).

---

### CHƯƠNG 3: PHÂN TÍCH VÀ THIẾT KẾ HỆ THỐNG (SYSTEM ANALYSIS & DESIGN)

**3.1. Phân tích Yêu cầu Hệ thống (Chức năng và Phi Chức năng)**
* Liệt kê chi tiết **Các Chức năng (Features)** cốt lõi của ứng dụng (Nhận diện nấm qua camera/album, Tra cứu thông tin nấm, Lưu lịch sử, ...).
* Yêu cầu Phi chức năng (Tốc độ, Độ chính xác, Bảo mật...).

**3.2. Sơ đồ Use Case và Biểu đồ Chức năng**
* **Sơ đồ Use Case:** Minh họa tương tác giữa người dùng và các chức năng chính của hệ thống.
* Biểu đồ Hoạt động (Activity Diagram) hoặc Trình tự (Sequence Diagram) cho luồng nhận diện ảnh.

**3.3. Thiết kế Kiến trúc Hệ thống (System Architecture)**
* **Kiến trúc Tổng thể:** (Client Flutter, Model Server lighting.ai, Database).
* **Thiết kế Lớp Dữ liệu và Database:**
    * Thiết kế Cấu trúc Database (Mô hình Entity-Relationship - ERD) cho dữ liệu nấm, lịch sử nhận diện...
    * Lựa chọn công nghệ Database (ví dụ: Firebase Firestore/SQLite).
* **Thiết kế Lớp API/Server:** Mô tả luồng gửi ảnh từ ứng dụng tới **lighting.ai** và nhận kết quả.

**3.4. Phân tích và Thiết kế Mô hình Học máy**
* Tiền xử lý và Tăng cường Dữ liệu (Data Augmentation).
* **Chiến lược So sánh Mô hình:** Mô tả tiêu chí và phương pháp để so sánh 4 Baseline Models.
* Thiết kế chi tiết Kiến trúc Mô hình Đề xuất Hybrid ViT+CNN.

---

### CHƯƠNG 4: TRIỂN KHAI, THỰC NGHIỆM VÀ ĐÁNH GIÁ (IMPLEMENTATION, EXPERIMENTATION & EVALUATION)

**4.1. Môi trường Phát triển và Bộ Dữ liệu**
* Cấu hình môi trường (PyTorch, Flutter SDK, lighting.ai tools).
* Giới thiệu chi tiết về Bộ Dữ liệu Nấm (số lượng ảnh, số lớp, phân chia tập train/val/test).

**4.2. Thực nghiệm Huấn luyện và Đánh giá các Mô hình**
* **Huấn luyện 4 Mô hình Baseline:** Trình bày kết quả huấn luyện chi tiết cho từng mô hình.
* **So sánh và Lựa chọn Mô hình Đề xuất:**
    * Sử dụng bảng biểu để so sánh độ chính xác, tốc độ, kích thước mô hình của 4 Baseline.
    * Lý do lựa chọn **Recommended Model**.
* Huấn luyện và Tối ưu hóa Mô hình Đề xuất cuối cùng.

**4.3. Triển khai và Tích hợp Ứng dụng Di động (Flutter)**
* Triển khai Giao diện Người dùng (UI/UX) trên Flutter.
* Lập trình Lớp Kết nối Database và Lớp Mạng (Network Layer) để giao tiếp với Server.
* **Tích hợp Mô hình:** Triển khai mô hình đã tối ưu lên nền tảng **lighting.ai** và kết nối qua API.

**4.4. Thiết kế và Thực hiện Test Case**
* **Thiết kế Test Case:** Lập bảng các Test Case cho các chức năng chính (đăng nhập/nhận diện/tra cứu) và các kịch bản lỗi.
* **Thực hiện Test Case và Kết quả:** Báo cáo kết quả kiểm thử.

**4.5. Đánh giá Tổng thể Hệ thống**
* Đánh giá Hiệu năng (Performance) của ứng dụng trên thiết bị di động.
* Đánh giá Độ chính xác của kết quả nhận diện trên ứng dụng thực tế.

---

### CHƯƠNG 5: KẾT LUẬN VÀ HƯỚNG PHÁT TRIỂN (CONCLUSION & FUTURE WORK)

**5.1. Kết luận**
**5.2. Hạn chế của đề tài**
**5.3. Hướng phát triển trong tương lai**

---

### PHỤ LỤC VÀ TÀI LIỆU THAM KHẢO

**Phụ lục** (Mã nguồn chính, Bảng Test Case chi tiết, ảnh chụp màn hình ứng dụng...)
**Tài liệu tham khảo**
