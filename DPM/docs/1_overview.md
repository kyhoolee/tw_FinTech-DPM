Dưới đây là **phân tích chi tiết cấu trúc project DPM (Deep Portfolio Management)** — được tổ chức theo dạng *modular framework*, phục vụ nghiên cứu reinforcement learning (RL) trong portfolio optimization.

---

## 🧱 **I. Tổng quan cấu trúc thư mục**

```
DPM/
├── main.py               # Entry-point khởi tạo train/test
├── train.sh              # Script chạy training
├── code_summary.txt      # Tổng hợp code
├── policies/             # Các mô hình policy (ATN, CNN, NRI...)
├── pgportfolio/          # Core logic: RL agents, data, train, backtest
│   ├── learn/            # RL agents và trainer (torch/tensorflow)
│   ├── marketdata/       # Load + xử lý dữ liệu
│   ├── tdagent/          # Các baseline rule-based / statistical
│   ├── trade/            # Backtest và mô phỏng giao dịch
│   ├── tools/            # Indicator, xử lý config, trade logic
│   ├── resultprocess/    # Plot kết quả và table
│   ├── autotrain/        # Auto pipeline chạy train các config
│   └── data/             # Dataset (.pkl/.npy)
├── docs/summary.sh       # Script tổng hợp code
└── README.md
```

---

## 🔁 **II. Các Flow chính**

### ✅ 1. **Huấn luyện mô hình**

```
train.sh
  ↓
main.py
  ↓
pgportfolio.autotrain.generate
  ↓
pgportfolio.learn.[torch/tensorflow].nnagent + rollingtrainer
  ↓
→ Load dữ liệu (marketdata)
→ Trích xuất indicator (tools/indicator)
→ Sinh state
→ Update policy
→ Log kết quả
```

### ✅ 2. **Backtest mô hình**

```
pgportfolio.trade.backtest
  ↓
pgportfolio.trade.trader
  ↓
→ Load policy đã train
→ Sinh tín hiệu & giao dịch
→ Ghi lại lịch sử giao dịch
```

### ✅ 3. **So sánh và visualize**

```
pgportfolio.resultprocess.plot + table
  ↓
→ Sinh biểu đồ return
→ Tổng hợp metric: Sharpe, Drawdown, Mean Return...
```

---

## 🔍 **III. Chi tiết các module chính**

### 📦 **1. `policies/` — Neural policy**

* Chứa các network custom:

  * `cnn`, `cnn_sarl`, `cnn_loss`, `nri_conv4`, `atn`, `sarl`, ...
* Có mô hình **NRI** riêng ở `NRI/` (Neural Relational Inference):

  * `modules.py`: định nghĩa encoder/decoder kiến trúc đồ thị.
  * `utils.py`: util giúp tạo adjacency, mask, normalize.

> 🔥 Đây là nơi quyết định “policy” — bản chất mô hình học điều khiển phân bổ.

---

### 📦 **2. `pgportfolio/learn/` — RL agent + trainer**

* Tổ chức theo 2 backend:

  * `torch/`: modern backend chính (PyTorch).
  * `tensorflow/`: bản cũ.

* File chính:

  * `nnagent.py`: define policy → action.
  * `rollingtrainer.py`: huấn luyện theo rolling window.
  * `tradertrainer.py`: test policy.

* Tính năng đặc biệt:

  * Có cấu trúc rolling training: chia giai đoạn lịch sử → huấn luyện lặp.

---

### 📦 **3. `pgportfolio/tdagent/` — Baseline algorithms**

> Tập hợp hơn 20 thuật toán rule-based:

* `crp`, `bcrp`, `pamr`, `eg`, `olmar`, `anticor`, `ubahn`, `wmamr`, `ons`,...
* `tdagent.py`: lớp tổng quát quản lý agent (tương tự `nnagent.py`).

\=> Giúp benchmark các policy RL mới.

---

### 📦 **4. `pgportfolio/marketdata/` — Load dữ liệu thị trường**

* `datamatrices.py`: load tập dữ liệu cụ thể.
* `poloniex.py`: API lấy dữ liệu từ sàn.
* `globaldatamatrix.py`: dữ liệu toàn cục cho nhiều tài sản.
* `replaybuffer.py`: buffer cho RL training (theo batch).

---

### 📦 **5. `pgportfolio/tools/` — Xử lý indicator & config**

* `indicator.py`: sinh các technical indicators từ giá (EMA, volatility,...).
* `configprocess.py`: xử lý file cấu hình `net_config.json`.
* `trade.py`, `shortcut.py`: tiện ích tạo order, strategy,...

\=> Dùng trong pipeline để sinh state từ data.

---

### 📦 **6. `pgportfolio/autotrain/` — Tự động huấn luyện**

* `generate.py`: sinh cấu hình từ template (cho nhiều mô hình).
* `training.py`: chạy training nhiều config (batch train experiment).

\=> Dùng để tạo nhiều kết quả huấn luyện cho so sánh hoặc tuning.

---

### 📦 **7. `pgportfolio/resultprocess/` — Phân tích kết quả**

* `plot.py`: vẽ biểu đồ return theo thời gian.
* `table.py`: xuất bảng tổng hợp performance.

---

## 📂 **IV. Dữ liệu**

Nằm ở: `pgportfolio/data/`

* Dạng `.pkl`, `.npy` — đã xử lý:

  * `btc.pkl`, `crix_2.pkl`, `stock.npy`...

\=> Sử dụng trực tiếp trong `datamatrices.py`.

---

## ✅ **V. Tổng kết kiến trúc**

| Layer               | Mục đích                   | Module                            |
| ------------------- | -------------------------- | --------------------------------- |
| **Policy**          | Neural network học phân bổ | `policies/`                       |
| **Agent**           | Huấn luyện policy          | `learn/`                          |
| **Baseline**        | So sánh phương pháp cũ     | `tdagent/`                        |
| **Data**            | Load dữ liệu + preprocess  | `marketdata/` + `tools/`          |
| **Training Engine** | Rolling trainer            | `rollingtrainer.py`, `autotrain/` |
| **Evaluation**      | Backtest + Plot + Table    | `trade/`, `resultprocess/`        |

---

Bạn có muốn mình tiếp tục:

* So sánh kỹ `SARL`, `ATN`, `NRI` để hiểu style modeling?
* Viết lại bản sơ đồ pipeline toàn bộ flow?
* Extract lại tên các baseline + mô tả + paper gốc?

Mình có thể giúp tiếp.
