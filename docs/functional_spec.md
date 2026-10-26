# B06 · Đặc tả chức năng (Functional Specification)

Tài liệu này mô tả **hành vi đúng** của khối, độc lập với cách hiện thực. Mọi khẳng định ở
đây là *hợp đồng*; phần hiện thực nằm ở `03_ARCHITECTURE/` và `04_IMPLEMENTATION/`.

---

## 1. Phát biểu bài toán

Khối nhận một từ dữ liệu 4 bit và sinh ra một **từ mã Hamming (7,4)** dài 7 bit, sao cho
tầng giải mã (đề B07) có thể phát hiện và sửa **đúng một** bit lỗi.

Bối cảnh ứng dụng (Charter mục 1): thêm mã sửa lỗi cho **dữ liệu cấu hình lưu trong bộ nhớ
dễ bị nhiễu bức xạ**. Nghĩa là khối này chạy ở **đường ghi**; đường đọc là B07.

## 2. Quy ước đánh số bit — phải đọc trước mọi công thức

Hamming (7,4) cổ điển đánh số vị trí **từ 1 đến 7**. RTL đánh số vector **từ 0 đến 6**.
Toàn bộ hồ sơ dùng ánh xạ sau, đọc thẳng từ `04_IMPLEMENTATION/rtl/b06_hamming74_encoder.sv`
dòng 12 và từ chú thích dòng 11 (*"code[0..6] correspond to Hamming positions 1..7"*):

| Vị trí Hamming | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| Bit trong `code` | `code[0]` | `code[1]` | `code[2]` | `code[3]` | `code[4]` | `code[5]` | `code[6]` |
| Nội dung | `p1` | `p2` | `data[0]` | `p4` | `data[1]` | `data[2]` | `data[3]` |
| Loại | kiểm tra | kiểm tra | dữ liệu | kiểm tra | dữ liệu | dữ liệu | dữ liệu |

> ⚠️ **Đây là nguồn nhầm lẫn số một của đề.** Nhiều tài liệu viết `code[6]` là `p1`. Khi
> đối chiếu với sách hoặc với công cụ ngoài, phải kiểm quy ước trước khi kết luận "sai".

## 3. Phương trình hành vi

Với `d = data[3:0]`:

```
  p1 = d[0] ⊕ d[1] ⊕ d[3]
  p2 = d[0] ⊕ d[2] ⊕ d[3]
  p4 = d[1] ⊕ d[2] ⊕ d[3]

  code = { d[3], d[2], d[1], p4, d[0], p2, p1 }
          code[6] code[5] code[4] code[3] code[2] code[1] code[0]
```

### Vì sao đúng ba tổ hợp đó — quy tắc phủ vị trí

Bit kiểm tra đặt ở vị trí `2^k` phải kiểm tra **mọi vị trí có bit `k` bằng 1** trong chỉ số
nhị phân của vị trí:

| Bit kiểm tra | Vị trí | Phủ các vị trí | Tương ứng `code` | Suy ra |
|---|:-:|---|---|---|
| `p1` | 1 = `001` | 1, 3, 5, 7 | `p1`, `d0`, `d1`, `d3` | `p1 = d0⊕d1⊕d3` |
| `p2` | 2 = `010` | 2, 3, 6, 7 | `p2`, `d0`, `d2`, `d3` | `p2 = d0⊕d2⊕d3` |
| `p4` | 4 = `100` | 4, 5, 6, 7 | `p4`, `d1`, `d2`, `d3` | `p4 = d1⊕d2⊕d3` |

Mỗi bit dữ liệu được phủ bởi một **tổ hợp khác nhau** của ba bit kiểm tra (chính là chỉ số
nhị phân của vị trí nó đứng). Đó là toàn bộ lý do mã này sửa được lỗi: dấu vân tay của mỗi
vị trí là duy nhất.

## 4. Bảng hành vi đầy đủ (16/16 tổ hợp)

Suy trực tiếp từ §3, đơn vị nhị phân, thứ tự `code[6:0]`:

| `data[3:0]` | `p4 p2 p1` | `code[6:0]` | `data` (hex) | `code` (hex) |
|:-:|:-:|:-:|:-:|:-:|
| 0000 | 0 0 0 | 0000000 | 0 | 00 |
| 0001 | 0 1 1 | 0000111 | 1 | 07 |
| 0010 | 1 0 1 | 0011001 | 2 | 19 |
| 0011 | 1 1 0 | 0011110 | 3 | 1E |
| 0100 | 1 1 0 | 0101010 | 4 | 2A |
| 0101 | 1 0 1 | 0101101 | 5 | 2D |
| 0110 | 0 1 1 | 0110011 | 6 | 33 |
| 0111 | 0 0 0 | 0110100 | 7 | 34 |
| 1000 | 1 1 1 | 1001011 | 8 | 4B |
| 1001 | 1 0 0 | 1001100 | 9 | 4C |
| 1010 | 0 1 0 | 1010010 | A | 52 |
| 1011 | 0 0 1 | 1010101 | B | 55 |
| 1100 | 0 0 1 | 1100001 | C | 61 |
| 1101 | 0 1 0 | 1100110 | D | 66 |
| 1110 | 1 0 0 | 1111000 | E | 78 |
| 1111 | 1 1 1 | 1111111 | F | 7F |

**Cách kiểm tay một dòng** (Charter mục 10 yêu cầu làm được việc này tại chỗ):
lấy `data = 1010` ⟹ `d3=1, d2=0, d1=1, d0=0`.
`p1 = 0⊕1⊕1 = 0` · `p2 = 0⊕0⊕1 = 1` · `p4 = 1⊕0⊕1 = 0`.
`code = {d3,d2,d1,p4,d0,p2,p1} = {1,0,1,0,0,1,0} = 1010010₂ = 0x52`.
Khớp dòng `1010` ở bảng trên.

> 🔎 **Kiểm chéo nhanh cả bảng:** mọi dòng phải thoả INV-2…INV-4. Ví dụ dòng `1010`
> (`code = 1010010`): `c0⊕c2⊕c4⊕c6 = 0⊕0⊕1⊕1 = 0` ✅ · `c1⊕c2⊕c5⊕c6 = 1⊕0⊕0⊕1 = 0` ✅ ·
> `c3⊕c4⊕c5⊕c6 = 0⊕1⊕0⊕1 = 0` ✅. Nếu một dòng nào trong bảng không thoả cả ba, **bảng
> sai**, không phải mạch sai.

## 5. Ràng buộc cấu trúc bắt buộc

| # | Ràng buộc | Vì sao bắt buộc | Bằng chứng tuân thủ |
|---|---|---|---|
| CT-1 | Mã phải **hệ thống (systematic)**: 4 bit dữ liệu xuất hiện **nguyên văn** trong từ mã | B07 chỉ trích bit ở vị trí 3,5,6,7; nếu trộn dữ liệu thì B07 phải giải hệ phương trình | RTL dòng 12 ghép thẳng `d[3],d[2],d[1],…,d[0]`; netlist có `assign { code[6:4], code[2] } = data;` — **0 cell** |
| CT-2 | Ba bit kiểm tra phải viết **tường minh** bằng XOR, không gọi hàm thư viện | Charter mục 9 yêu cầu đếm được số cổng XOR | RTL dòng 7–9, ba biểu thức XOR rời |
| CT-3 | **0 ô nhớ** — mạch tổ hợp thuần | Charter metadata "Loại mạch: Tổ hợp", mục 10 "dấu hiệu làm đúng: 0 ô nhớ" | `06_GDSII/synthesis/synth_stat.txt`: 3 cell, toàn bộ là `xor3_1` |
| CT-4 | Quy ước bit của §2 phải **giống hệt** B07 | Hai khối ghép nối trực tiếp | So dòng 7–9 của B06 với dòng 11–13 của `b07_hamming74_decoder.sv` |

## 6. Tính chất bất biến (Invariants)

Dùng trực tiếp làm assertion (SVA hoặc assertion trong testbench). `c = code`, `d = data`.

| # | Phát biểu | Đã được kiểm chưa |
|---|---|---|
| **INV-1** | `c[2] = d[0]` ∧ `c[4] = d[1]` ∧ `c[5] = d[2]` ∧ `c[6] = d[3]` (tính hệ thống) | ✅ `reference_model.py` dòng 18–21, cả 16 giá trị |
| **INV-2** | `c[0] ⊕ c[2] ⊕ c[4] ⊕ c[6] = 0` (syndrome bit `s1` của từ mã sạch bằng 0) | ⚠️ gián tiếp — chưa có assertion viết riêng |
| **INV-3** | `c[1] ⊕ c[2] ⊕ c[5] ⊕ c[6] = 0` (`s2 = 0`) | ⚠️ gián tiếp |
| **INV-4** | `c[3] ⊕ c[4] ⊕ c[5] ⊕ c[6] = 0` (`s4 = 0`) | ⚠️ gián tiếp |
| **INV-5** | Ánh xạ **đơn ánh**: 16 giá trị `data` cho 16 từ mã **phân biệt** | ✅ `reference_model.py` dòng 22–23 (`len(seen)==16`) |
| **INV-6** | **Tuyến tính**: `encode(a ⊕ b) = encode(a) ⊕ encode(b)`, kéo theo `encode(0) = 0` | ⚠️ chỉ `encode(0)==0` được kiểm (dòng 24); tính tuyến tính đầy đủ chưa kiểm |
| **INV-7** | Khoảng cách Hamming nhỏ nhất giữa hai từ mã bất kỳ **= 3** | ❌ **chưa kiểm** — xem `corner_cases.md` §3 |
| **INV-8** | Mạch không có trạng thái: cùng `data` luôn cho cùng `code`, không phụ thuộc lịch sử | ✅ gián tiếp qua 0 flip-flop (`synth_stat.txt`) |

> INV-2…INV-4 là **cầu nối hợp đồng giữa B06 và B07**: chúng nói "từ mã do B06 sinh ra luôn
> có hội chứng bằng 0". Nếu INV-2…4 sai thì B07 sẽ báo lỗi trên dữ liệu sạch. Đây là
> assertion đáng viết nhất khi ghép hai khối.
>
> INV-7 là tính chất **duy nhất** bảo đảm "sửa được một bit". Nó **chưa được chứng minh bằng
> mô phỏng** trong gói này — chỉ cần một vòng lặp 16×16 so sánh trọng số Hamming. Xem đề
> xuất ở `corner_cases.md`.

## 7. Điều kiện biên và hành vi không xác định

| Tình huống | Hành vi đặc tả | Ghi chú |
|---|---|---|
| `data = 0000` | `code = 0000000` | Từ mã toàn 0 — hợp lệ, là phần tử trung hoà của mã tuyến tính |
| `data = 1111` | `code = 1111111` | Từ mã toàn 1 — hợp lệ |
| `data` chứa `X` hoặc `Z` | **Không xác định.** XOR với `X` cho `X`; `X` lan sang cả 3 bit kiểm tra và 4 bit dữ liệu | Tầng ngoài phải bảo đảm đầu vào sạch (`interface.md` §4) |
| Đầu ra lấy mẫu trước khi ổn định | **Không xác định** — có thể đọc trúng glitch | Xem `timing_diagram.md` §3 |
| Đầu vào đổi liên tục | Hợp lệ — không có ràng buộc tần số vì không có ô nhớ | Chỉ ràng buộc bởi độ trễ lan truyền 0,33 ns |

## 8. Vì sao **không** có mục trạng thái sau reset / độ trễ chu kỳ

Đề này là **mạch tổ hợp**. Không có clock, không có reset, không có khái niệm "sau N chu kỳ
thì đầu ra hợp lệ". Đại lượng tương đương duy nhất là **độ trễ lan truyền**:

| Đầu ra | Độ trễ đo được (OpenSTA) |
|---|---:|
| `code[2]`, `code[4]`, `code[5]`, `code[6]` (bit dữ liệu) | **0,00 ns** — chỉ là dây |
| `code[0]`, `code[1]`, `code[3]` (bit kiểm tra) | **0,33 ns** |

Nguồn: `06_GDSII/sta/timing_report_max.txt` (7 đường, đủ 7 endpoint).
Ba bằng chứng "không có trạng thái": xem `03_ARCHITECTURE/fsm.md` §2.

---

*Phiên bản: v1.0 · Ngày: 2026-09-24*
