import json
import sys

def print_metrics(file_path):
    try:
        with open(file_path, 'r') as f:
            data = json.load(f)
        
        print("=== CHỈ SỐ CHÍNH TỪ METRICS.JSON ===")
        keys_to_print = [
            "design__instance__count",
            "design__die__area",
            "design__instance__utilization",
            "route__wirelength",
            "timing__setup__ws",
            "timing__hold__ws",
            "power__switching__total",
            "magic__drc_error__count",
            "design__lvs_error__count"
        ]
        
        for key in keys_to_print:
            if key in data:
                print(f"{key}: {data[key]}")
    except Exception as e:
        print(f"Lỗi đọc metrics: {e}")

if __name__ == "__main__":
    if len(sys.argv) > 1:
        print_metrics(sys.argv[1])
    else:
        print("Thiếu đường dẫn file metrics.json")
