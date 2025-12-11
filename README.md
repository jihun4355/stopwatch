## 🔍 Project Overview – STOPWATCH / WATCH (Verilog on Basys-3)

본 프로젝트는 **디지털 스톱워치 + 디지털 시계(WATCH)를 하나의 FPGA 시스템에 통합한 설계**이다.  
FSM 기반 제어, 타임 카운터, 버튼 디바운스, 7-Segment FND 표시, 모드 전환 등  
디지털 시스템 설계의 핵심 개념이 모두 포함된 프로젝트이다.  
(출처: PDF 1~3p :contentReference[oaicite:2]{index=2})

---

## 🧩 1. 기능 요약 (PDF p.3)

- STAR/STOP: Btn_R → 스톱워치 실행/정지  
- CLEAR: Btn_L → 시간 초기화  
- FND 표시: sw[0] → ns / s / min / hour 모드 전환  
- WATCH 모드: 실시간 시계 표시 + 수정(editing) 가능  
- STOPWATCH 모드: RUN/STOP/CLEAR 상태 제어  
- FPGA Basys-3 보드에서 직접 동작  

---

## 🔧 2. Block Diagram 구성 (PDF p.4~6)

### ✔ tick_gen_100Hz  
- 클럭 기반 100Hz tick 생성  
- i_runstop=1일 때만 카운터 동작

### ✔ button_debounce (p.7)  
- 버튼 노이즈 제거 → 1클럭 펄스 생성  
- 동기화·카운터·비교기·엣지 검출기 포함

### ✔ Button Controller (p.5)  
- SW 입력으로 현재 모드 결정  
- Watch / Stopwatch 제어 신호 분기

### ✔ watch_cu + watch_dp (p.8~9)  
- cursor 이동  
- 시간 증가/감소  
- reset 기능  
- 시/분/초/밀리초 관리

### ✔ stopwatch_cu + stopwatch_dp (p.10~11)  
- FSM 기반 RUN → STOP → CLEAR 상태 전환  
- 100Hz tick으로 카운트  
- clear 시 전체 카운터 초기화

### ✔ fnd_controller (p.12)  
- FND 자리 선택 + BCD to 7-Segment 디코딩  
- {hour, min, sec, msec} 데이터를 4자리 FND로 출력

---

## 🧪 3. Simulation Results (PDF p.14~18)

### ✔ Stopwatch 모드 (sw[1] = 0)
- RUN / STOP / CLEAR 정상 동작  
- RUN 중 clear는 무시  
- LED 표시:
  - LED1 = RUN 상태 표시  
  - LED0 = Stopwatch 모드 표시  
- sw[0] = 0 → 초/밀리초  
- sw[0] = 1 → 시/분

### ✔ Watch 모드 (sw[1] = 1)
- cursor 이동  
- up/down 증가·감소 정상  
- reset → 기본값 12:00:00.00 복귀  
- 편집 시 edit_activity LED 약 0.1s 점등  
- stopwatch RUN 중 모드 전환해도 백그라운드에서 계속 동작 → sw[0]=0으로 돌아오면 누적 시간이 표시  

---

## 🎥 4. 동작 영상 (PDF p.19)

- Basys3 보드 상에서 실제로 Stopwatch와 Watch 모드가 동작  
- 버튼 입력에 따라 FND 표시가 실시간 변경됨  
- RUN/STOP 시 LED가 정상 반응

---

## ⚙ 5. Troubleshooting & 고찰 (PDF p.20~22)

### ✔ 문제 1: 버튼/모드 AND·MUX 난잡 (p.20)
- 버튼 신호가 Watch/Stopwatch 양쪽에 동시에 전달되는 문제  
- 스키매틱 복잡해지고 오동작 발생

➡ **해결:** “버스화 + 단일 게이팅(MUX) 적용”  
- AND 덩어리 제거  
- RTL_MUX 2개만 남도록 단순화  
- 반대 모드의 버튼이 절대 전달되지 않도록 0으로 게이트

---

### ✔ 문제 2: 시간 선택 MUX가 4개나 생겨 복잡 (p.21)
➡ **해결:** 24-bit 단일 시간 버스(time_sel) MUX로 통합  
- FND는 항상 time_sel만 받도록 구조 단순화  

---

### ✔ 문제 3: watch_dp 내부 inc/dec AND 게이트 난잡 (p.22)
➡ **해결:** 구조 정리 + 범위 wrap 처리 정교화  
- msec → sec → min → hour 연속 carry가 간결하게 구성됨

---

## ✔ 결과 요약  
- Stopwatch + Watch 모드 모두 안정적으로 동작  
- 버튼 / 모드 분기 / FND 표시 구조가 깨끗하게 정리됨  
- FPGA 기반 디지털 시계 시스템의 모든 요소(FSM, 데이터패스, 디바운스, 타이머, FND)가 구현됨





## 📄 STOPWATCH / WATCH Project (PDF Report)

전체 프로젝트 보고서는 아래 PDF에서 확인할 수 있습니다.

👉 [📘 **STOPWATCH/WATCH PDF 열기**](./STOPWATCH_WATCH.pdf)


:contentReference[oaicite:1]{index=1}

---

### 📌 PDF 미리보기 썸네일 (옵션)

[![PDF Preview](./stopwatch_watch_page1.png)](./STOPWATCH_WATCH.pdf)


