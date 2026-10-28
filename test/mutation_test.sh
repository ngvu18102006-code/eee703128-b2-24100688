#!/usr/bin/env bash
# Phep thu pha mach: co tinh gay loi vao BAN SAO cua RTL, KHONG sua src/project.v.
cd "$(dirname "$0")/.."
SRC=src/project.v; TB=test/mutation_tb.v; TMP=$(mktemp -d)

run() {
  local name="$1" expr="$2"
  if [ -n "$expr" ]; then
    sed -E "$expr" "$SRC" > "$TMP/m.v"
    if cmp -s "$SRC" "$TMP/m.v"; then echo "[$name] BO QUA: mau sed khong khop RTL"; return; fi
  else cp "$SRC" "$TMP/m.v"; fi
  iverilog -g2012 -o "$TMP/m.vvp" "$TMP/m.v" "$TB" 2>"$TMP/err" || { echo "[$name] LOI BIEN DICH"; cat "$TMP/err"; return; }
  out=$(vvp "$TMP/m.vvp")
  echo "[$name] $(echo "$out" | grep RESULT)"
  echo "$out" | grep RED | sed 's/^/      /'
}

run "M0 goc, khong loi (doi chung)" ""
run "M1 XOR->XNOR o p1" 's/p1 = data\[0\] \^ data\[1\] \^ data\[3\];/p1 = ~(data[0] ^ data[1] ^ data[3]);/'
run "M2 bo data[3] khoi p4" 's/p4 = data\[1\] \^ data\[2\] \^ data\[3\];/p4 = data[1] ^ data[2];/'
run "M3 hoan p2<->p4 khi ghep" 's/\{data\[3\], data\[2\], data\[1\], p4, data\[0\], p2, p1\}/{data[3], data[2], data[1], p2, data[0], p4, p1}/'
run "M4 p1 dung d2 thay d3" 's/p1 = data\[0\] \^ data\[1\] \^ data\[3\];/p1 = data[0] ^ data[1] ^ data[2];/'
run "M5 XOR->AND trong p2 (pha tuyen tinh)" 's/p2 = data\[0\] \^ data\[2\] \^ data\[3\];/p2 = data[0] ^ (data[2] \& data[3]);/'
run "M6 quy uoc bit nguoc (p1 o bit cao)" 's/\{data\[3\], data\[2\], data\[1\], p4, data\[0\], p2, p1\}/{p1, p2, data[3], p4, data[2], data[1], data[0]}/'
run "M7 hoan vi tri data[1], data[2]" 's/\{data\[3\], data\[2\], data\[1\], p4/{data[3], data[1], data[2], p4/'
rm -rf "$TMP"
